class SystemStats {
  double cpuPercent;
  int cpuCount;
  MemoryStats memory;
  DiskStats disk;
  NetworkStats network;
  String uptime;

  SystemStats({
    this.cpuPercent = 0,
    this.cpuCount = 0,
    required this.memory,
    required this.disk,
    required this.network,
    this.uptime = "N/A",
  });

  factory SystemStats.empty() {
    return SystemStats(
      memory: MemoryStats(),
      disk: DiskStats(),
      network: NetworkStats(),
    );
  }
}

class MemoryStats {
  int total;
  int used;
  int free;
  double percent;
  String totalHuman;
  String usedHuman;
  String freeHuman;

  MemoryStats({
    this.total = 0,
    this.used = 0,
    this.free = 0,
    this.percent = 0,
    this.totalHuman = "N/A",
    this.usedHuman = "N/A",
    this.freeHuman = "N/A",
  });
}

class DiskStats {
  int total;
  int used;
  int free;
  double percent;
  String totalHuman;
  String usedHuman;
  String freeHuman;

  DiskStats({
    this.total = 0,
    this.used = 0,
    this.free = 0,
    this.percent = 0,
    this.totalHuman = "N/A",
    this.usedHuman = "N/A",
    this.freeHuman = "N/A",
  });
}

class NetworkStats {
  int bytesSent;
  int bytesRecv;
  String sentHuman;
  String recvHuman;
  String totalHuman;

  NetworkStats({
    this.bytesSent = 0,
    this.bytesRecv = 0,
    this.sentHuman = "0 B",
    this.recvHuman = "0 B",
    this.totalHuman = "0 B",
  });
}

class ProcessItem {
  int pid;
  String name;
  double cpuPercent;
  double memoryPercent;
  int memory;
  String memoryHuman;

  ProcessItem({
    required this.pid,
    required this.name,
    required this.cpuPercent,
    required this.memoryPercent,
    required this.memory,
    required this.memoryHuman,
  });
}
