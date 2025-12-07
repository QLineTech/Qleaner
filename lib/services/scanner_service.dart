import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import '../models/cache_location.dart';

class ScannerService extends ChangeNotifier {
  List<CacheLocation> _scanResults = [];
  bool _isScanning = false;
  Map<String, dynamic> _scanProgress = {
    "current": 0,
    "total": 0,
    "percent": 0,
    "current_location": "",
    "found_count": 0,
    "total_size": 0,
  };

  List<CacheLocation> get scanResults => _scanResults;
  bool get isScanning => _isScanning;
  Map<String, dynamic> get scanProgress => _scanProgress;

  Future<String> get _homePath async {
    final directory = await getApplicationDocumentsDirectory();
    // getApplicationDocumentsDirectory returns /Users/user/Documents
    // We want /Users/user
    return directory.parent.path;
  }

  String humanReadableSize(int sizeBytes) {
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

  Future<int> _getDirectorySize(String path) async {
    int totalSize = 0;
    try {
      final dir = Directory(path);
      if (await dir.exists()) {
        await for (final entity in dir.list(
          recursive: true,
          followLinks: false,
        )) {
          if (entity is File) {
            try {
              totalSize += await entity.length();
            } catch (e) {
              // Ignore permission errors etc
            }
          }
        }
      }
    } catch (e) {
      // Ignore
    }
    return totalSize;
  }

  // Faster implementation using du -sk
  Future<int> _getDirectorySizeFast(String path) async {
    try {
      final result = await Process.run('du', ['-sk', path]);
      if (result.exitCode == 0) {
        final output = result.stdout.toString().trim();
        final sizeKb = int.tryParse(output.split(RegExp(r'\s+')).first) ?? 0;
        return sizeKb * 1024;
      }
    } catch (e) {
      // Fallback to manual scan if du fails
    }
    return _getDirectorySize(path);
  }

  Future<List<CacheLocation>> _getCacheLocations() async {
    final home = Platform.environment['HOME'] ?? await _homePath;

    return [
      CacheLocation(
        id: "user_caches",
        path: "$home/Library/Caches",
        name: "User Application Caches",
        description: "Cache files from all your applications",
        category: "System",
        hint: "This folder contains cached data from all applications you use.",
        impact:
            "Apps will need to re-download or regenerate their cached data.",
        risk: "low",
      ),
      CacheLocation(
        id: "system_caches",
        path: "/Library/Caches",
        name: "System Application Caches",
        description: "System-wide application caches",
        category: "System",
        hint:
            "Contains cached data for system-level applications and services.",
        impact: "System apps will regenerate caches as needed.",
        risk: "medium",
      ),
      CacheLocation(
        id: "xcode_derived",
        path: "$home/Library/Developer/Xcode/DerivedData",
        name: "Xcode DerivedData",
        description: "Xcode build intermediates and indexes",
        category: "Developer",
        hint:
            "Contains all build products, indexes, and logs from Xcode projects.",
        impact: "Next build will take longer as Xcode rebuilds everything.",
        risk: "low",
      ),
      CacheLocation(
        id: "xcode_archives",
        path: "$home/Library/Developer/Xcode/Archives",
        name: "Xcode Archives",
        description: "App Store submission archives",
        category: "Developer",
        hint: "Contains archived builds used for App Store submissions.",
        impact: "⚠️ You will lose the ability to symbolicate crash reports.",
        risk: "high",
      ),
      CacheLocation(
        id: "xcode_device_support",
        path: "$home/Library/Developer/Xcode/iOS DeviceSupport",
        name: "iOS Device Support",
        description: "Debug symbols for iOS devices",
        category: "Developer",
        hint: "Contains debug symbols for each iOS version you've connected.",
        impact:
            "Xcode will re-download symbols when you next connect a device.",
        risk: "low",
      ),
      CacheLocation(
        id: "simulator_devices",
        path: "$home/Library/Developer/CoreSimulator/Devices",
        name: "iOS Simulator Devices",
        description: "All iOS Simulator instances and data",
        category: "Developer",
        hint:
            "Contains all simulator devices and their installed apps and data.",
        impact: "⚠️ ALL simulator devices and their app data will be deleted.",
        risk: "high",
      ),
      CacheLocation(
        id: "npm_cache",
        path: "$home/.npm/_cacache",
        name: "NPM Cache",
        description: "Downloaded NPM packages cache",
        category: "Packages",
        hint: "NPM stores downloaded packages here.",
        impact: "NPM will re-download packages when needed.",
        risk: "low",
      ),
      CacheLocation(
        id: "yarn_cache",
        path: "$home/.yarn/cache",
        name: "Yarn Cache",
        description: "Downloaded Yarn packages cache",
        category: "Packages",
        hint: "Yarn's offline cache of all packages.",
        impact: "Yarn will need to re-download packages.",
        risk: "low",
      ),
      CacheLocation(
        id: "pip_cache",
        path: "$home/.cache/pip",
        name: "Python Pip Cache",
        description: "Downloaded Python packages cache",
        category: "Packages",
        hint: "Pip caches downloaded wheel and source packages here.",
        impact: "Pip will re-download packages when installing.",
        risk: "low",
      ),
      CacheLocation(
        id: "pub_cache",
        path: "$home/.pub-cache",
        name: "Flutter/Dart Pub Cache",
        description: "Dart and Flutter packages",
        category: "Packages",
        hint: "Contains all Flutter and Dart packages.",
        impact: "Run 'flutter pub get' again after cleaning.",
        risk: "low",
      ),
      CacheLocation(
        id: "gradle_cache",
        path: "$home/.gradle/caches",
        name: "Gradle Cache",
        description: "Android/Java build cache",
        category: "Packages",
        hint: "Gradle stores downloaded dependencies and build outputs here.",
        impact: "Android/Gradle builds will re-download dependencies.",
        risk: "low",
      ),
      CacheLocation(
        id: "cocoapods",
        path: "$home/.cocoapods/repos",
        name: "CocoaPods Repos",
        description: "CocoaPods spec repositories",
        category: "Packages",
        hint: "Contains the CocoaPods master spec repo.",
        impact: "Next 'pod install' will re-clone spec repos.",
        risk: "low",
      ),
      CacheLocation(
        id: "safari_cache",
        path: "$home/Library/Caches/com.apple.Safari",
        name: "Safari Cache",
        description: "Safari browser cache",
        category: "Browsers",
        hint: "Contains cached web pages, images, scripts from Safari.",
        impact: "Websites will reload fresh content.",
        risk: "low",
      ),
      CacheLocation(
        id: "chrome_cache",
        path: "$home/Library/Caches/Google/Chrome/Default/Cache",
        name: "Chrome Cache",
        description: "Chrome browser cache",
        category: "Browsers",
        hint: "Chrome's cached web content.",
        impact: "Chrome will re-download web content.",
        risk: "low",
      ),
      CacheLocation(
        id: "firefox_cache",
        path: "$home/Library/Caches/Firefox",
        name: "Firefox Cache",
        description: "Firefox browser cache",
        category: "Browsers",
        hint: "Firefox's cached web content.",
        impact: "Firefox will reload content.",
        risk: "low",
      ),
      CacheLocation(
        id: "vscode_cache",
        path: "$home/Library/Application Support/Code/CachedData",
        name: "VS Code Cache",
        description: "Visual Studio Code cached data",
        category: "Applications",
        hint: "VS Code caches extension data and workspace state.",
        impact: "VS Code may take slightly longer to start.",
        risk: "low",
      ),
      CacheLocation(
        id: "slack_cache",
        path: "$home/Library/Application Support/Slack/Cache",
        name: "Slack Cache",
        description: "Slack cached messages and files",
        category: "Applications",
        hint: "Contains cached messages, files, and images from Slack.",
        impact: "Slack will re-download message history and files.",
        risk: "low",
      ),
      CacheLocation(
        id: "discord_cache",
        path: "$home/Library/Application Support/discord/Cache",
        name: "Discord Cache",
        description: "Discord cached content",
        category: "Applications",
        hint: "Cached images, videos, and other media from Discord.",
        impact: "Discord will re-download media from channels.",
        risk: "low",
      ),
      CacheLocation(
        id: "spotify_cache",
        path: "$home/Library/Application Support/Spotify/PersistentCache",
        name: "Spotify Cache",
        description: "Spotify offline music cache",
        category: "Applications",
        hint: "Contains cached and downloaded music for offline playback.",
        impact: "⚠️ Downloaded songs for offline will be removed.",
        risk: "medium",
      ),
      CacheLocation(
        id: "docker_data",
        path: "$home/Library/Containers/com.docker.docker/Data/vms",
        name: "Docker VM Data",
        description: "Docker Desktop VM disk images",
        category: "Docker",
        hint:
            "Docker Desktop runs in a VM. This contains all containers and images.",
        impact:
            "⚠️ ALL Docker images, containers, and volumes will be deleted.",
        risk: "high",
      ),
      CacheLocation(
        id: "tmp",
        path: "/tmp",
        name: "System Temp Files",
        description: "Temporary files from running apps",
        category: "Temp",
        hint: "Standard Unix temp directory. Cleared on reboot.",
        impact: "Running apps may lose temporary work.",
        risk: "low",
      ),
      CacheLocation(
        id: "user_logs",
        path: "$home/Library/Logs",
        name: "User Application Logs",
        description: "Log files from applications",
        category: "Logs",
        hint: "Applications store their log files here for debugging.",
        impact: "Historical logs will be lost.",
        risk: "low",
      ),
      CacheLocation(
        id: "ios_backups",
        path: "$home/Library/Application Support/MobileSync/Backup",
        name: "iOS Device Backups",
        description: "iPhone/iPad local backups",
        category: "Backups",
        hint: "Local backups of iOS devices.",
        impact: "⚠️ ALL local device backups will be permanently deleted.",
        risk: "high",
      ),
      CacheLocation(
        id: "homebrew_cache",
        path: "$home/Library/Caches/Homebrew",
        name: "Homebrew Downloads",
        description: "Downloaded Homebrew packages",
        category: "Packages",
        hint: "Homebrew caches downloaded bottles and source archives.",
        impact: "Homebrew will re-download packages if reinstalled.",
        risk: "low",
      ),
    ];
  }

  Future<void> startScan() async {
    if (_isScanning) return;
    _isScanning = true;
    _scanResults = [];
    _scanProgress = {
      "current": 0,
      "total": 0,
      "percent": 0,
      "current_location": "",
      "found_count": 0,
      "total_size": 0,
    };
    notifyListeners();

    final locations = await _getCacheLocations();
    final totalLocations = locations.length;
    _scanProgress["total"] = totalLocations;

    for (var i = 0; i < totalLocations; i++) {
      final loc = locations[i];
      _scanProgress["current"] = i + 1;
      _scanProgress["current_location"] = loc.name;
      _scanProgress["percent"] = ((i / totalLocations) * 100).toInt();
      notifyListeners();

      final path = loc.path;
      final dir = Directory(path);
      if (await dir.exists()) {
        loc.exists = true;
        loc.size = await _getDirectorySizeFast(path);
        loc.sizeHuman = humanReadableSize(loc.size);
        if (loc.size > 0) {
          loc.selected = true;
          _scanResults.add(loc);
          _scanProgress["found_count"] = _scanResults.length;
          _scanProgress["total_size"] = _scanResults.fold(
            0,
            (sum, item) => sum + item.size,
          );
        }
      }
    }

    // Scan container caches (simplified for now)
    // ...

    _scanProgress["percent"] = 100;
    _scanProgress["current_location"] = "Complete";
    _scanResults.sort((a, b) => b.size.compareTo(a.size));
    _isScanning = false;
    notifyListeners();
  }
}
