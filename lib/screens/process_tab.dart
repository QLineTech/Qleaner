import 'package:flutter/material.dart';
import 'package:moon_design/moon_design.dart';
import 'package:provider/provider.dart';
import '../services/system_service.dart';
import '../widgets/stat_card.dart';

class ProcessTabContent extends StatelessWidget {
  const ProcessTabContent({super.key});

  @override
  Widget build(BuildContext context) {
    final system = Provider.of<SystemService>(context);
    final stats = system.stats;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stats Grid
          Row(
            children: [
              Expanded(
                child: StatCard(
                  label: "CPU Usage",
                  value: "${stats.cpuPercent.toStringAsFixed(1)}%",
                  subText: "${stats.cpuCount} cores",
                  progress: stats.cpuPercent / 100,
                  gradientColors: const [Color(0xFF667EEA), Color(0xFF764BA2)],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: StatCard(
                  label: "Memory",
                  value: "${stats.memory.percent.toStringAsFixed(1)}%",
                  subText:
                      "${stats.memory.usedHuman} / ${stats.memory.totalHuman}",
                  progress: stats.memory.percent / 100,
                  gradientColors: const [Color(0xFFF093FB), Color(0xFFF5576C)],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: StatCard(
                  label: "Network",
                  value: stats.network.recvHuman,
                  subText:
                      "↑ ${stats.network.sentHuman} / ↓ ${stats.network.recvHuman}",
                  gradientColors: const [Color(0xFF3FB950), Color(0xFF2EA043)],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Process Table
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: context.moonColors!.gohan,
                borderRadius: BorderRadius.circular(10),
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Table Header
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: context.moonColors!.beerus),
                      ),
                    ),
                    child: Row(
                      children: [
                        Text(
                          "Top Processes",
                          style: context.moonTypography!.heading.text14
                              .copyWith(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                  // Table
                  Container(
                    color: context.moonColors!.gohan,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: _tableHeader(context, "PROCESS"),
                        ),
                        Expanded(child: _tableHeader(context, "PID")),
                        Expanded(child: _tableHeader(context, "CPU %")),
                        Expanded(child: _tableHeader(context, "MEMORY")),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: system.topProcessesCpu.take(10).length,
                      itemBuilder: (context, index) {
                        final p = system.topProcessesCpu.elementAt(index);
                        final cpuColor = p.cpuPercent > 50
                            ? const Color(0xFFF85149)
                            : p.cpuPercent > 20
                            ? const Color(0xFFD29922)
                            : context.moonColors!.trunks;

                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: context.moonColors!.beerus.withOpacity(
                                  0.5,
                                ),
                              ),
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: Text(
                                  p.name,
                                  style: context.moonTypography!.body.text14
                                      .copyWith(fontWeight: FontWeight.w500),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  p.pid.toString(),
                                  style: context.moonTypography!.body.text12
                                      .copyWith(
                                        color: context.moonColors!.trunks,
                                      ),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  "${p.cpuPercent.toStringAsFixed(1)}%",
                                  style: context.moonTypography!.body.text14
                                      .copyWith(
                                        color: cpuColor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  p.memoryHuman,
                                  style: context.moonTypography!.body.text14,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
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

  Widget _tableHeader(BuildContext context, String text) {
    return Text(
      text,
      style: context.moonTypography!.body.text12.copyWith(
        color: context.moonColors!.trunks,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      ),
    );
  }
}

// Keep original ProcessTab for backward compatibility
class ProcessTab extends StatefulWidget {
  const ProcessTab({super.key});

  @override
  State<ProcessTab> createState() => _ProcessTabState();
}

class _ProcessTabState extends State<ProcessTab> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<SystemService>(context, listen: false).startMonitoring();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.moonColors!.goku,
      body: const ProcessTabContent(),
    );
  }
}
