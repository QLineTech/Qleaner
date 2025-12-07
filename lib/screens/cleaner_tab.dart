import 'package:flutter/material.dart';
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
      appBar: AppBar(
        title: const Text('System Cleaner'),
        actions: [
          if (scanner.isScanning)
            const Center(
              child: Padding(
                padding: EdgeInsets.only(right: 16.0),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () => scanner.startScan(),
              tooltip: "Scan Now",
            ),
        ],
      ),
      body: scanner.scanResults.isEmpty && !scanner.isScanning
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.cleaning_services,
                    size: 64,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Ready to scan",
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => scanner.startScan(),
                    icon: const Icon(Icons.search),
                    label: const Text("Start Scan"),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                    ),
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
                  ),
                Expanded(
                  child: ListView.builder(
                    itemCount: scanner.scanResults.length,
                    itemBuilder: (context, index) {
                      final loc = scanner.scanResults[index];
                      return ListTile(
                        leading: Checkbox(
                          value: loc.selected,
                          onChanged: (val) {
                            setState(() {
                              loc.selected = val ?? false;
                            });
                          },
                        ),
                        title: Text(loc.name),
                        subtitle: Text(loc.description),
                        trailing: Text(
                          loc.sizeHuman,
                          style: TextStyle(
                            color: loc.size > 1024 * 1024 * 100
                                ? Colors.red
                                : Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        onTap: () {
                          // Show details
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text(loc.name),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Path: ${loc.path}",
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontFamily: 'monospace',
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text("Description: ${loc.description}"),
                                  const SizedBox(height: 8),
                                  Text(
                                    "Impact: ${loc.impact}",
                                    style: const TextStyle(
                                      color: Colors.orange,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text("Hint: ${loc.hint}"),
                                ],
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text("Close"),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    border: Border(
                      top: BorderSide(color: Theme.of(context).dividerColor),
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(
                        "Found: ${scanner.scanResults.length} items",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const Spacer(),
                      ElevatedButton.icon(
                        onPressed:
                            scanner.isScanning ||
                                cleaner.isCleaning ||
                                scanner.scanResults
                                    .where((l) => l.selected)
                                    .isEmpty
                            ? null
                            : () async {
                                final selected = scanner.scanResults
                                    .where((l) => l.selected)
                                    .toList();
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text("Confirm Clean"),
                                    content: Text(
                                      "Are you sure you want to clean ${selected.length} items? This cannot be undone.",
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, false),
                                        child: const Text("Cancel"),
                                      ),
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, true),
                                        child: const Text(
                                          "Clean",
                                          style: TextStyle(color: Colors.red),
                                        ),
                                      ),
                                    ],
                                  ),
                                );

                                if (confirm == true) {
                                  await cleaner.cleanLocations(
                                    scanner.scanResults,
                                  );
                                  // Re-scan after clean
                                  scanner.startScan();
                                }
                              },
                        icon: cleaner.isCleaning
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.delete),
                        label: Text(
                          cleaner.isCleaning ? "Cleaning..." : "Clean Selected",
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
