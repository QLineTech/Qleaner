import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/system_service.dart';

class ProcessTab extends StatefulWidget {
  const ProcessTab({super.key});

  @override
  State<ProcessTab> createState() => _ProcessTabState();
}

class _ProcessTabState extends State<ProcessTab> {
  @override
  void initState() {
    super.initState();
    // Start monitoring when tab is active
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<SystemService>(context, listen: false).startMonitoring();
    });
  }

  @override
  void dispose() {
    // Stop monitoring is handled by the service or we can stop it here if we want to save resources
    // But since it's a singleton-ish service provided at root, we might want to keep it running or stop it.
    // For now, let's stop it to save resources when switching tabs if we were re-creating tabs,
    // but NavigationRail keeps state.
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final system = Provider.of<SystemService>(context);
    final stats = system.stats;

    return Scaffold(
      appBar: AppBar(title: const Text('System Monitor')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Stats Grid
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1.5,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            children: [
              _buildStatCard(
                context,
                "CPU",
                "${stats.cpuPercent.toStringAsFixed(1)}%",
                "${stats.cpuCount} Cores",
                stats.cpuPercent / 100,
                Colors.blue,
              ),
              _buildStatCard(
                context,
                "Memory",
                stats.memory.percent.toStringAsFixed(1) + "%",
                "${stats.memory.usedHuman} / ${stats.memory.totalHuman}",
                stats.memory.percent / 100,
                Colors.purple,
              ),
              _buildStatCard(
                context,
                "Network",
                "In: ${stats.network.recvHuman}",
                "Out: ${stats.network.sentHuman}",
                0.5, // No progress bar for network really
                Colors.green,
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Text(
            "Top Processes (CPU)",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Card(
            child: DataTable(
              columns: const [
                DataColumn(label: Text("PID")),
                DataColumn(label: Text("Name")),
                DataColumn(label: Text("CPU %")),
                DataColumn(label: Text("Memory")),
              ],
              rows: system.topProcessesCpu.map((p) {
                return DataRow(
                  cells: [
                    DataCell(Text(p.pid.toString())),
                    DataCell(Text(p.name)),
                    DataCell(Text(p.cpuPercent.toStringAsFixed(1))),
                    DataCell(Text(p.memoryHuman)),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    String sub,
    double progress,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(color: Colors.grey[400], fontSize: 12),
            ),
            const Spacer(),
            Text(
              value,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(sub, style: TextStyle(color: Colors.grey[400], fontSize: 12)),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              color: color,
              backgroundColor: color.withOpacity(0.2),
            ),
          ],
        ),
      ),
    );
  }
}
