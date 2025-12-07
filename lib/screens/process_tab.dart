import 'package:flutter/material.dart';
import 'package:moon_design/moon_design.dart';
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
  Widget build(BuildContext context) {
    final system = Provider.of<SystemService>(context);
    final stats = system.stats;

    return Scaffold(
      backgroundColor: context.moonColors!.goku,
      body: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: context.moonColors!.gohan,
              border: Border(
                bottom: BorderSide(color: context.moonColors!.beerus),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "System Monitor",
                  style: context.moonTypography!.heading.text24,
                ),
                const SizedBox(height: 4),
                Text(
                  "Uptime: ${stats.uptime}",
                  style: context.moonTypography!.body.text14.copyWith(
                    color: context.moonColors!.trunks,
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Stats Grid
                  LayoutBuilder(
                    builder: (context, constraints) {
                      return Row(
                        children: [
                          Expanded(
                            child: _buildStatCard(
                              context,
                              "CPU",
                              "${stats.cpuPercent.toStringAsFixed(1)}%",
                              stats.cpuPercent / 100,
                              context.moonColors!.piccolo,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildStatCard(
                              context,
                              "Memory",
                              "${stats.memory.percent.toStringAsFixed(1)}%",
                              stats.memory.percent / 100,
                              const Color(0xFFF85149),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildStatCard(
                              context,
                              "Network",
                              stats.network.totalHuman,
                              0.5,
                              const Color(0xFF238636),
                            ),
                          ),
                        ],
                      );
                    },
                  ),

                  const SizedBox(height: 32),

                  Text(
                    "Top Processes",
                    style: context.moonTypography!.heading.text20,
                  ),
                  const SizedBox(height: 16),

                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: context.moonColors!.gohan,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: context.moonColors!.beerus),
                    ),
                    child: DataTable(
                      columns: [
                        DataColumn(
                          label: Text(
                            "Process Name",
                            style: context.moonTypography!.heading.text14
                                .copyWith(color: context.moonColors!.trunks),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            "PID",
                            style: context.moonTypography!.heading.text14
                                .copyWith(color: context.moonColors!.trunks),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            "CPU %",
                            style: context.moonTypography!.heading.text14
                                .copyWith(color: context.moonColors!.trunks),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            "Memory",
                            style: context.moonTypography!.heading.text14
                                .copyWith(color: context.moonColors!.trunks),
                          ),
                        ),
                      ],
                      rows: system.topProcessesCpu.take(10).map((p) {
                        return DataRow(
                          cells: [
                            DataCell(
                              Text(
                                p.name,
                                style: context.moonTypography!.body.text14,
                              ),
                            ),
                            DataCell(
                              Text(
                                p.pid.toString(),
                                style: context.moonTypography!.body.text14
                                    .copyWith(
                                      color: context.moonColors!.trunks,
                                    ),
                              ),
                            ),
                            DataCell(
                              Text(
                                "${p.cpuPercent.toStringAsFixed(1)}%",
                                style: context.moonTypography!.body.text14
                                    .copyWith(
                                      color: p.cpuPercent > 50
                                          ? const Color(0xFFF85149)
                                          : context.moonColors!.piccolo,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ),
                            DataCell(
                              Text(
                                p.memoryHuman,
                                style: context.moonTypography!.body.text14,
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String label,
    String value,
    double progress,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.moonColors!.gohan,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.moonColors!.beerus),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: context.moonTypography!.body.text12.copyWith(
              color: context.moonColors!.trunks,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(value, style: context.moonTypography!.heading.text32),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: progress.clamp(0.0, 1.0),
            color: color,
            backgroundColor: context.moonColors!.beerus,
            minHeight: 4,
            borderRadius: BorderRadius.circular(2),
          ),
        ],
      ),
    );
  }
}
