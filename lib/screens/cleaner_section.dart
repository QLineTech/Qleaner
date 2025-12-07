import 'package:flutter/material.dart';
import 'package:moon_design/moon_design.dart';
import 'package:provider/provider.dart';
import '../services/scanner_service.dart';
import '../services/cleaner_service.dart';
import '../widgets/location_card.dart';

class CleanerSection extends StatefulWidget {
  const CleanerSection({super.key});

  @override
  State<CleanerSection> createState() => _CleanerSectionState();
}

class _CleanerSectionState extends State<CleanerSection> {
  String _activeCategory = 'all';
  final Set<String> _expandedHints = {};

  @override
  Widget build(BuildContext context) {
    final scanner = Provider.of<ScannerService>(context);
    final cleaner = Provider.of<CleanerService>(context);

    final categories = [
      'all',
      ...scanner.scanResults.map((l) => l.category).toSet(),
    ];
    final filteredLocations = _activeCategory == 'all'
        ? scanner.scanResults
        : scanner.scanResults
              .where((l) => l.category == _activeCategory)
              .toList();

    final selectedCount = scanner.scanResults.where((l) => l.selected).length;
    final selectedSize = scanner.scanResults
        .where((l) => l.selected)
        .fold<int>(0, (sum, l) => sum + l.size);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Controls
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            MoonButton(
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text("🔍"),
                  const SizedBox(width: 8),
                  Text(scanner.isScanning ? "Scanning..." : "Scan System"),
                ],
              ),
              backgroundColor: context.moonColors!.piccolo,
              onTap: scanner.isScanning ? null : () => scanner.startScan(),
            ),
            MoonButton(
              label: const Text("Select All"),
              backgroundColor: context.moonColors!.gohan,
              borderColor: context.moonColors!.beerus,
              onTap: () {
                for (var loc in scanner.scanResults) {
                  loc.selected = true;
                }
                setState(() {});
              },
            ),
            MoonButton(
              label: const Text("Select None"),
              backgroundColor: context.moonColors!.gohan,
              borderColor: context.moonColors!.beerus,
              onTap: () {
                for (var loc in scanner.scanResults) {
                  loc.selected = false;
                }
                setState(() {});
              },
            ),
            MoonButton(
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text("🗑️"),
                  const SizedBox(width: 8),
                  Text(cleaner.isCleaning ? "Cleaning..." : "Clean Selected"),
                ],
              ),
              backgroundColor: const Color(0xFFF85149),
              onTap: selectedCount == 0 || cleaner.isCleaning
                  ? null
                  : () => _cleanSelected(context, scanner, cleaner),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Summary Cards
        Row(
          children: [
            Expanded(
              child: _SummaryCard(
                title: "Selected Items",
                value: selectedCount.toString(),
                valueColor: context.moonColors!.piccolo,
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: _SummaryCard(
                title: "Space to Reclaim",
                value: scanner.humanReadableSize(selectedSize),
                valueColor: const Color(0xFFF85149),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Category Filters
        if (scanner.scanResults.isNotEmpty)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: categories.map((cat) {
              final isActive = cat == _activeCategory;
              return GestureDetector(
                onTap: () => setState(() => _activeCategory = cat),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isActive
                        ? context.moonColors!.piccolo
                        : context.moonColors!.gohan,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isActive
                          ? context.moonColors!.piccolo
                          : context.moonColors!.beerus,
                    ),
                  ),
                  child: Text(
                    cat == 'all' ? 'All' : cat,
                    style: context.moonTypography!.body.text14.copyWith(
                      color: isActive
                          ? Colors.white
                          : context.moonColors!.trunks,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        const SizedBox(height: 20),

        // Locations Grid / Empty State
        if (scanner.scanResults.isEmpty && !scanner.isScanning)
          Container(
            padding: const EdgeInsets.all(60),
            decoration: BoxDecoration(
              color: context.moonColors!.gohan,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: context.moonColors!.beerus),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.check_circle_outline,
                  size: 80,
                  color: context.moonColors!.trunks.withOpacity(0.5),
                ),
                const SizedBox(height: 20),
                Text(
                  'Click "Scan System" to start',
                  style: context.moonTypography!.heading.text18.copyWith(
                    color: context.moonColors!.trunks,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "We'll find all cache and temporary files on your Mac",
                  style: context.moonTypography!.body.text14.copyWith(
                    color: context.moonColors!.trunks,
                  ),
                ),
              ],
            ),
          )
        else if (scanner.isScanning)
          Container(
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: context.moonColors!.gohan,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: context.moonColors!.beerus),
            ),
            child: Column(
              children: [
                const MoonCircularLoader(),
                const SizedBox(height: 20),
                Text(
                  "Scanning...",
                  style: context.moonTypography!.heading.text18,
                ),
                const SizedBox(height: 8),
                Text(
                  "Looking for cache files",
                  style: context.moonTypography!.body.text14.copyWith(
                    color: context.moonColors!.trunks,
                  ),
                ),
              ],
            ),
          )
        else
          Column(
            children: filteredLocations.map((loc) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: LocationCard(
                  location: loc,
                  showHint: _expandedHints.contains(loc.id),
                  onToggle: () {
                    setState(() {
                      loc.selected = !loc.selected;
                    });
                  },
                  onHintTap: () {
                    setState(() {
                      if (_expandedHints.contains(loc.id)) {
                        _expandedHints.remove(loc.id);
                      } else {
                        _expandedHints.add(loc.id);
                      }
                    });
                  },
                ),
              );
            }).toList(),
          ),
      ],
    );
  }

  Future<void> _cleanSelected(
    BuildContext context,
    ScannerService scanner,
    CleanerService cleaner,
  ) async {
    final selected = scanner.scanResults.where((l) => l.selected).toList();
    if (selected.isEmpty) return;

    final totalSize = scanner.humanReadableSize(
      selected.fold<int>(0, (sum, l) => sum + l.size),
    );

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: context.moonColors!.gohan,
        title: Text(
          "Confirm Clean",
          style: context.moonTypography!.heading.text20,
        ),
        content: Text(
          "This will permanently delete ${selected.length} cache locations ($totalSize).\n\nAre you sure?",
          style: context.moonTypography!.body.text14,
        ),
        actions: [
          MoonButton(
            label: const Text("Cancel"),
            backgroundColor: Colors.transparent,
            borderColor: context.moonColors!.trunks,
            onTap: () => Navigator.pop(ctx, false),
          ),
          MoonButton(
            label: const Text("Clean"),
            backgroundColor: const Color(0xFFF85149),
            onTap: () => Navigator.pop(ctx, true),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await cleaner.cleanLocations(scanner.scanResults);
      scanner.startScan();
    }
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final Color? valueColor;

  const _SummaryCard({
    required this.title,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
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
            title.toUpperCase(),
            style: context.moonTypography!.body.text12.copyWith(
              color: context.moonColors!.trunks,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: context.moonTypography!.heading.text32.copyWith(
              color: valueColor,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
