import 'package:flutter/material.dart';
import 'package:moon_design/moon_design.dart';
import 'package:provider/provider.dart';
import '../services/system_service.dart';
import '../widgets/ring_chart.dart';

class StorageTabContent extends StatelessWidget {
  const StorageTabContent({super.key});

  @override
  Widget build(BuildContext context) {
    final system = Provider.of<SystemService>(context);
    final disk = system.stats.disk;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Disk Visual
          Container(
            width: 300,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: context.moonColors!.gohan,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                RingChart(percent: disk.percent, size: 180, strokeWidth: 12),
                const SizedBox(height: 20),
                const RingLegend(),
              ],
            ),
          ),
          const SizedBox(width: 24),

          // Storage Details
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: context.moonColors!.gohan,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Disk Information",
                    style: context.moonTypography!.body.text14.copyWith(
                      color: context.moonColors!.trunks,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _StorageStat(label: "Total Capacity", value: disk.totalHuman),
                  _StorageStat(
                    label: "Used Space",
                    value: disk.usedHuman,
                    valueColor: const Color(0xFFD29922),
                  ),
                  _StorageStat(
                    label: "Free Space",
                    value: disk.freeHuman,
                    valueColor: const Color(0xFF3FB950),
                  ),
                  _StorageStat(
                    label: "Uptime",
                    value: system.stats.uptime,
                    isLast: true,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StorageStat extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final bool isLast;

  const _StorageStat({
    required this.label,
    required this.value,
    this.valueColor,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(bottom: BorderSide(color: context.moonColors!.beerus)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: context.moonTypography!.body.text14.copyWith(
              color: context.moonColors!.trunks,
            ),
          ),
          Text(
            value,
            style: context.moonTypography!.heading.text16.copyWith(
              color: valueColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// Keep original StorageTab for backward compatibility
class StorageTab extends StatelessWidget {
  const StorageTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.moonColors!.goku,
      body: const SingleChildScrollView(child: StorageTabContent()),
    );
  }
}
