import 'package:flutter/material.dart';
import 'package:moon_design/moon_design.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../services/system_service.dart';

class StorageTab extends StatelessWidget {
  const StorageTab({super.key});

  @override
  Widget build(BuildContext context) {
    final system = Provider.of<SystemService>(context);
    final disk = system.stats.disk;

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
                  "Storage Analysis",
                  style: context.moonTypography!.heading.text24,
                ),
                const SizedBox(height: 4),
                Text(
                  "Disk usage overview",
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
                children: [
                  Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: context.moonColors!.gohan,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: context.moonColors!.beerus),
                    ),
                    child: Row(
                      children: [
                        // Chart
                        SizedBox(
                          height: 200,
                          width: 200,
                          child: Stack(
                            children: [
                              PieChart(
                                PieChartData(
                                  sectionsSpace: 0,
                                  centerSpaceRadius: 70,
                                  sections: [
                                    PieChartSectionData(
                                      color: context.moonColors!.piccolo,
                                      value: disk.used.toDouble(),
                                      title: '',
                                      radius: 20,
                                    ),
                                    PieChartSectionData(
                                      color: const Color(0xFF238636),
                                      value: disk.free.toDouble(),
                                      title: '',
                                      radius: 20,
                                    ),
                                  ],
                                ),
                              ),
                              Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      "${disk.percent.toStringAsFixed(1)}%",
                                      style: context
                                          .moonTypography!
                                          .heading
                                          .text32,
                                    ),
                                    Text(
                                      "Used",
                                      style: context.moonTypography!.body.text12
                                          .copyWith(
                                            color: context.moonColors!.trunks,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 48),
                        // Legend and Details
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLegendItem(
                                context,
                                "Used Space",
                                disk.usedHuman,
                                context.moonColors!.piccolo,
                              ),
                              const SizedBox(height: 24),
                              _buildLegendItem(
                                context,
                                "Free Space",
                                disk.freeHuman,
                                const Color(0xFF238636),
                              ),
                              const SizedBox(height: 24),
                              Container(
                                height: 1,
                                color: context.moonColors!.beerus,
                              ),
                              const SizedBox(height: 24),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Total Capacity",
                                    style: context.moonTypography!.body.text14
                                        .copyWith(
                                          color: context.moonColors!.trunks,
                                        ),
                                  ),
                                  Text(
                                    disk.totalHuman,
                                    style:
                                        context.moonTypography!.heading.text16,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
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

  Widget _buildLegendItem(
    BuildContext context,
    String label,
    String value,
    Color color,
  ) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: context.moonTypography!.body.text12.copyWith(
                color: context.moonColors!.trunks,
              ),
            ),
            Text(value, style: context.moonTypography!.heading.text20),
          ],
        ),
      ],
    );
  }
}
