import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import '../models/system_stats.dart';

class SystemService extends ChangeNotifier {
  SystemStats _stats = SystemStats.empty();
  List<ProcessItem> _topProcessesCpu = [];
  List<ProcessItem> _topProcessesMem = [];
  Timer? _timer;
  bool _isMonitoring = false;

  SystemStats get stats => _stats;
  List<ProcessItem> get topProcessesCpu => _topProcessesCpu;
  List<ProcessItem> get topProcessesMem => _topProcessesMem;

  void startMonitoring() {
    if (_isMonitoring) return;
    _isMonitoring = true;
    _updateStats();
    _timer = Timer.periodic(const Duration(seconds: 2), (_) => _updateStats());
  }

  void stopMonitoring() {
    _timer?.cancel();
    _isMonitoring = false;
  }

  bool _isUpdating = false;

  Future<void> _updateStats() async {
    if (_isUpdating) return;
    _isUpdating = true;

    try {
      await Future.wait([
        _updateCpu(),
        _updateMemory(),
        _updateDisk(),
        _updateNetwork(),
        _updateUptime(),
        _updateProcesses(),
      ]);
      notifyListeners();
    } finally {
      _isUpdating = false;
    }
  }

  String _humanReadableSize(int sizeBytes) {
    if (sizeBytes < 0) return "0 B";
    const suffixes = ["B", "KB", "MB", "GB", "TB", "PB"];
    var i = 0;
    double size = sizeBytes.toDouble();
    while (size >= 1024 && i < suffixes.length - 1) {
      size /= 1024;
      i++;
    }
    return "${size.toStringAsFixed(1)} ${suffixes[i]}";
  }

  Future<void> _updateCpu() async {
    try {
      // Get CPU usage using top
      final result = await Process.run('top', ['-l', '1', '-n', '0']);
      if (result.exitCode == 0) {
        final output = result.stdout.toString();
        final lines = output.split('\n');
        for (final line in lines) {
          if (line.contains('CPU usage:')) {
            // Example: CPU usage: 5.0% user, 10.0% sys, 85.0% idle
            final parts = line.split(':')[1].split(',');
            double user = 0;
            double sys = 0;
            for (final part in parts) {
              if (part.contains('user')) {
                user = double.tryParse(part.trim().split('%')[0]) ?? 0;
              } else if (part.contains('sys')) {
                sys = double.tryParse(part.trim().split('%')[0]) ?? 0;
              }
            }
            _stats.cpuPercent = user + sys;
            break;
          }
        }
      }

      // Get CPU count
      final countResult = await Process.run('sysctl', ['-n', 'hw.ncpu']);
      if (countResult.exitCode == 0) {
        _stats.cpuCount =
            int.tryParse(countResult.stdout.toString().trim()) ?? 0;
      }
    } catch (e) {
      print("Error updating CPU: $e");
    }
  }

  Future<void> _updateMemory() async {
    try {
      // Get total memory
      final totalResult = await Process.run('sysctl', ['-n', 'hw.memsize']);
      int total = 0;
      if (totalResult.exitCode == 0) {
        total = int.tryParse(totalResult.stdout.toString().trim()) ?? 0;
      }

      // Get used memory using vm_stat
      final vmStatResult = await Process.run('vm_stat', []);
      int free = 0;
      if (vmStatResult.exitCode == 0) {
        final lines = vmStatResult.stdout.toString().split('\n');
        int pageSize = 4096;
        int pagesFree = 0;
        int pagesSpeculative = 0;

        for (final line in lines) {
          if (line.contains('Pages free:')) {
            pagesFree =
                int.tryParse(line.split(':')[1].replaceAll('.', '').trim()) ??
                0;
          } else if (line.contains('Pages speculative:')) {
            pagesSpeculative =
                int.tryParse(line.split(':')[1].replaceAll('.', '').trim()) ??
                0;
          }
        }
        free = (pagesFree + pagesSpeculative) * pageSize;
      }

      int used = total - free;
      double percent = total > 0 ? (used / total) * 100 : 0;

      _stats.memory = MemoryStats(
        total: total,
        used: used,
        free: free,
        percent: percent,
        totalHuman: _humanReadableSize(total),
        usedHuman: _humanReadableSize(used),
        freeHuman: _humanReadableSize(free),
      );
    } catch (e) {
      print("Error updating Memory: $e");
    }
  }

  Future<void> _updateDisk() async {
    try {
      final result = await Process.run('df', ['-k', '/']);
      if (result.exitCode == 0) {
        final lines = result.stdout.toString().trim().split('\n');
        if (lines.length >= 2) {
          final parts = lines[1].split(RegExp(r'\s+'));
          // Filesystem 1024-blocks Used Available Capacity iused ifree %iused Mounted on
          // /dev/disk1s1s1 494384000 10240000 300000000 4% ... /

          int total = (int.tryParse(parts[1]) ?? 0) * 1024;
          int used = (int.tryParse(parts[2]) ?? 0) * 1024;
          int free = (int.tryParse(parts[3]) ?? 0) * 1024;
          double percent = total > 0 ? (used / total) * 100 : 0;

          _stats.disk = DiskStats(
            total: total,
            used: used,
            free: free,
            percent: percent,
            totalHuman: _humanReadableSize(total),
            usedHuman: _humanReadableSize(used),
            freeHuman: _humanReadableSize(free),
          );
        }
      }
    } catch (e) {
      print("Error updating Disk: $e");
    }
  }

  Future<void> _updateNetwork() async {
    try {
      final result = await Process.run('netstat', ['-ib']);
      if (result.exitCode == 0) {
        final lines = result.stdout.toString().trim().split('\n');
        int bytesSent = 0;
        int bytesRecv = 0;

        // Skip header
        for (int i = 1; i < lines.length; i++) {
          final parts = lines[i].split(RegExp(r'\s+'));
          if (parts.length >= 10) {
            // Name Mtu Network Address Ipkts Ierrs Opkts Oerrs Coll Ibtyes Obytes
            // We want Ibytes (input) and Obytes (output)
            // Note: netstat output format varies, this is a best guess for macOS
            // Usually last two columns are Ibytes and Obytes
            if (parts[0].startsWith('en') || parts[0].startsWith('lo')) {
              // Only count ethernet/wifi/loopback
              try {
                bytesRecv += int.tryParse(parts[6]) ?? 0; // Ibytes
                bytesSent +=
                    int.tryParse(parts[9]) ??
                    0; // Obytes (sometimes index varies)
                // Actually, netstat -ib on mac:
                // Name Mtu Network Address Ipkts Ierrs Ibytes Opkts Oerrs Obytes Coll
                // en0 1500 <Link#4> ... ... ... 12345 ... ... 67890 0
                // Index: 0 1 2 3 4 5 6 7 8 9 10
                // So Ibytes is 6, Obytes is 9.
              } catch (e) {
                // ignore
              }
            }
          }
        }

        _stats.network = NetworkStats(
          bytesSent: bytesSent,
          bytesRecv: bytesRecv,
          sentHuman: _humanReadableSize(bytesSent),
          recvHuman: _humanReadableSize(bytesRecv),
        );
      }
    } catch (e) {
      print("Error updating Network: $e");
    }
  }

  Future<void> _updateUptime() async {
    try {
      final result = await Process.run('sysctl', ['-n', 'kern.boottime']);
      if (result.exitCode == 0) {
        // { sec = 1700000000, usec = 0 } Thu Nov ...
        final output = result.stdout.toString();
        final match = RegExp(r'sec = (\d+)').firstMatch(output);
        if (match != null) {
          final bootTimeSec = int.parse(match.group(1)!);
          final nowSec = DateTime.now().millisecondsSinceEpoch ~/ 1000;
          final uptimeSec = nowSec - bootTimeSec;

          final days = uptimeSec ~/ 86400;
          final hours = (uptimeSec % 86400) ~/ 3600;
          final minutes = (uptimeSec % 3600) ~/ 60;

          if (days > 0) {
            _stats.uptime = "${days}d ${hours}h ${minutes}m";
          } else if (hours > 0) {
            _stats.uptime = "${hours}h ${minutes}m";
          } else {
            _stats.uptime = "${minutes}m";
          }
        }
      }
    } catch (e) {
      print("Error updating Uptime: $e");
    }
  }

  Future<void> _updateProcesses() async {
    try {
      // ps -A -o pid,pcpu,pmem,rss,comm
      // Limit to top 50 to avoid huge output parsing overhead
      final result = await Process.run('ps', [
        '-A',
        '-o',
        'pid,pcpu,pmem,rss,comm',
      ]);
      if (result.exitCode == 0) {
        final lines = result.stdout.toString().trim().split('\n');
        List<ProcessItem> processes = [];

        // Skip header
        for (int i = 1; i < lines.length; i++) {
          final line = lines[i].trim();
          if (line.isEmpty) continue;

          final parts = line.split(RegExp(r'\s+'));
          if (parts.length >= 5) {
            // PID %CPU %MEM RSS COMM
            final pid = int.tryParse(parts[0]) ?? 0;
            final cpu = double.tryParse(parts[1]) ?? 0.0;
            final memPercent = double.tryParse(parts[2]) ?? 0.0;
            final rss = (int.tryParse(parts[3]) ?? 0) * 1024; // RSS is in KB
            final name = parts.sublist(4).join(' ');

            final shortName = name.split('/').last;

            processes.add(
              ProcessItem(
                pid: pid,
                name: shortName,
                cpuPercent: cpu,
                memoryPercent: memPercent,
                memory: rss,
                memoryHuman: _humanReadableSize(rss),
              ),
            );
          }
        }

        // Sort by CPU
        processes.sort((a, b) => b.cpuPercent.compareTo(a.cpuPercent));
        _topProcessesCpu = processes.take(15).toList();

        // Sort by Memory
        processes.sort((a, b) => b.memory.compareTo(a.memory));
        _topProcessesMem = processes.take(15).toList();
      }
    } catch (e) {
      print("Error updating Processes: $e");
    }
  }
}
