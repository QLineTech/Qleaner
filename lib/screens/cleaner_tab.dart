import 'package:flutter/material.dart';
import 'package:moon_design/moon_design.dart';
import 'package:provider/provider.dart';
import '../services/scanner_service.dart';
import '../services/cleaner_service.dart';
import '../models/cache_location.dart';

class CleanerTab extends StatefulWidget {
  const CleanerTab({super.key});

  @override
  State<CleanerTab> createState() => _CleanerTabState();
}

class _CleanerTabState extends State<CleanerTab> {
  @override
  Widget build(BuildContext context) {
    final scanner = Provider.of<ScannerService>(context);
    final cleaner = Provider.of<CleanerService>(context);

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
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Cleaner",
                      style: context.moonTypography!.heading.text24,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Free up space by removing cache files",
                      style: context.moonTypography!.body.text14.copyWith(
                        color: context.moonColors!.trunks,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                if (scanner.isScanning)
                  const MoonCircularLoader()
                else
                  MoonButton(
                    label: const Text("Scan Now"),
                    leading: const Icon(Icons.refresh),
                    backgroundColor: context.moonColors!.piccolo,
                    onTap: () => scanner.startScan(),
                  ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: scanner.scanResults.isEmpty && !scanner.isScanning
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.cleaning_services_outlined,
                          size: 64,
                          color: context.moonColors!.trunks,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "Ready to scan",
                          style: context.moonTypography!.heading.text18
                              .copyWith(color: context.moonColors!.trunks),
                        ),
                        const SizedBox(height: 24),
                        MoonButton(
                          label: const Text("Start Scan"),
                          leading: const Icon(Icons.search),
                          backgroundColor: context.moonColors!.piccolo,
                          onTap: () => scanner.startScan(),
                        ),
                      ],
                    ),
                  )
                : Column(
                    children: [
                      if (scanner.isScanning)
                        LinearProgressIndicator(
                          value: scanner.scanProgress['total'] > 0
                              ? scanner.scanProgress['current'] /
                                    scanner.scanProgress['total']
                              : null,
                          color: context.moonColors!.piccolo,
                          backgroundColor: context.moonColors!.beerus,
                          minHeight: 4,
                        ),
                      Expanded(
                        child: ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: scanner.scanResults.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final loc = scanner.scanResults[index];
                            return Container(
                              decoration: BoxDecoration(
                                color: context.moonColors!.gohan,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: loc.selected
                                      ? context.moonColors!.piccolo
                                      : context.moonColors!.beerus,
                                ),
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                leading: Checkbox(
                                  value: loc.selected,
                                  activeColor: context.moonColors!.piccolo,
                                  onChanged: (val) {
                                    setState(() {
                                      loc.selected = val ?? false;
                                    });
                                  },
                                ),
                                title: Text(
                                  loc.name,
                                  style: context.moonTypography!.heading.text16,
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 4),
                                    Text(
                                      loc.description,
                                      style: context.moonTypography!.body.text12
                                          .copyWith(
                                            color: context.moonColors!.trunks,
                                          ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      loc.path,
                                      style: context.moonTypography!.body.text10
                                          .copyWith(
                                            color: context.moonColors!.trunks,
                                            fontFamily: 'monospace',
                                          ),
                                    ),
                                  ],
                                ),
                                trailing: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      loc.sizeHuman,
                                      style: context
                                          .moonTypography!
                                          .heading
                                          .text16
                                          .copyWith(
                                            color: loc.size > 1024 * 1024 * 100
                                                ? const Color(0xFFF85149)
                                                : const Color(0xFF238636),
                                          ),
                                    ),
                                    const SizedBox(height: 4),
                                    MoonChip(
                                      label: Text(loc.risk.toUpperCase()),
                                      chipSize: MoonChipSize.sm,
                                      backgroundColor: loc.risk == 'high'
                                          ? const Color(
                                              0xFFF85149,
                                            ).withOpacity(0.1)
                                          : loc.risk == 'medium'
                                          ? Colors.orange.withOpacity(0.1)
                                          : const Color(
                                              0xFF238636,
                                            ).withOpacity(0.1),
                                      textColor: loc.risk == 'high'
                                          ? const Color(0xFFF85149)
                                          : loc.risk == 'medium'
                                          ? Colors.orange
                                          : const Color(0xFF238636),
                                    ),
                                  ],
                                ),
                                onTap: () {
                                  // Show details
                                  showMoonModal(
                                    context: context,
                                    builder: (context) => MoonModal(
                                      child: Padding(
                                        padding: const EdgeInsets.all(24),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              loc.name,
                                              style: context
                                                  .moonTypography!
                                                  .heading
                                                  .text20,
                                            ),
                                            const SizedBox(height: 16),
                                            _buildDetailRow(
                                              context,
                                              "Path",
                                              loc.path,
                                            ),
                                            _buildDetailRow(
                                              context,
                                              "Description",
                                              loc.description,
                                            ),
                                            _buildDetailRow(
                                              context,
                                              "Impact",
                                              loc.impact,
                                            ),
                                            _buildDetailRow(
                                              context,
                                              "Hint",
                                              loc.hint,
                                            ),
                                            const SizedBox(height: 24),
                                            SizedBox(
                                              width: double.infinity,
                                              child: MoonButton(
                                                label: const Text("Close"),
                                                onTap: () =>
                                                    Navigator.pop(context),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: context.moonColors!.gohan,
                          border: Border(
                            top: BorderSide(color: context.moonColors!.beerus),
                          ),
                        ),
                        child: Row(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "${scanner.scanResults.where((l) => l.selected).length} items selected",
                                  style: context.moonTypography!.body.text14
                                      .copyWith(
                                        color: context.moonColors!.trunks,
                                      ),
                                ),
                                Text(
                                  scanner.humanReadableSize(
                                    scanner.scanResults
                                        .where((l) => l.selected)
                                        .fold(
                                          0,
                                          (sum, item) => sum + item.size,
                                        ),
                                  ),
                                  style: context.moonTypography!.heading.text20
                                      .copyWith(
                                        color: context.moonColors!.piccolo,
                                      ),
                                ),
                              ],
                            ),
                            const Spacer(),
                            MoonButton(
                              label: Text(
                                cleaner.isCleaning
                                    ? "Cleaning..."
                                    : "Clean Selected",
                              ),
                              leading: cleaner.isCleaning
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: MoonCircularLoader(),
                                    )
                                  : const Icon(Icons.delete_outline),
                              backgroundColor: const Color(0xFFF85149),
                              onTap:
                                  (scanner.isScanning ||
                                      cleaner.isCleaning ||
                                      scanner.scanResults
                                          .where((l) => l.selected)
                                          .isEmpty)
                                  ? null
                                  : () async {
                                      final selected = scanner.scanResults
                                          .where((l) => l.selected)
                                          .toList();
                                      // Simple confirm dialog
                                      final confirm = await showDialog<bool>(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          backgroundColor:
                                              context.moonColors!.gohan,
                                          title: Text(
                                            "Confirm Clean",
                                            style: context
                                                .moonTypography!
                                                .heading
                                                .text20,
                                          ),
                                          content: Text(
                                            "Are you sure you want to clean ${selected.length} items? This cannot be undone.",
                                            style: context
                                                .moonTypography!
                                                .body
                                                .text14,
                                          ),
                                          actions: [
                                            MoonButton(
                                              label: const Text("Cancel"),
                                              backgroundColor:
                                                  Colors.transparent,
                                              borderColor:
                                                  context.moonColors!.trunks,
                                              onTap: () =>
                                                  Navigator.pop(context, false),
                                            ),
                                            MoonButton(
                                              label: const Text("Clean"),
                                              backgroundColor: const Color(
                                                0xFFF85149,
                                              ),
                                              onTap: () =>
                                                  Navigator.pop(context, true),
                                            ),
                                          ],
                                        ),
                                      );

                                      if (confirm == true) {
                                        await cleaner.cleanLocations(
                                          scanner.scanResults,
                                        );
                                        scanner.startScan();
                                      }
                                    },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: context.moonTypography!.body.text12.copyWith(
              color: context.moonColors!.trunks,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(value, style: context.moonTypography!.body.text14),
        ],
      ),
    );
  }
}
