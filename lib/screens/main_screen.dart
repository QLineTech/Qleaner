import 'package:flutter/material.dart';
import 'package:moon_design/moon_design.dart';
import 'package:provider/provider.dart';
import '../services/system_service.dart';
import '../widgets/gradient_header.dart';
import '../widgets/toggle_switch.dart';
import 'process_tab.dart';
import 'storage_tab.dart';
import 'cleaner_section.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _alwaysUpdate = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_onTabChanged);
    // Start monitoring for initial tab
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateMonitoring();
    });
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (!_tabController.indexIsChanging) {
      _updateMonitoring();
    }
  }

  void _updateMonitoring() {
    final system = Provider.of<SystemService>(context, listen: false);
    if (_alwaysUpdate ||
        _tabController.index == 0 ||
        _tabController.index == 1) {
      system.startMonitoring();
    } else {
      system.stopMonitoring();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.moonColors!.goku,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Gradient Header
              const GradientHeader(),
              const SizedBox(height: 24),

              // Tabs Container
              Container(
                decoration: BoxDecoration(
                  color: context.moonColors!.gohan,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: context.moonColors!.beerus),
                ),
                child: Column(
                  children: [
                    // Tab Header
                    Container(
                      decoration: BoxDecoration(
                        color: context.moonColors!.gohan,
                        border: Border(
                          bottom: BorderSide(color: context.moonColors!.beerus),
                        ),
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(12),
                        ),
                      ),
                      child: Row(
                        children: [
                          // Tabs
                          Expanded(
                            child: TabBar(
                              controller: _tabController,
                              isScrollable: true,
                              indicatorColor: context.moonColors!.piccolo,
                              indicatorWeight: 2,
                              labelColor: context.moonColors!.piccolo,
                              unselectedLabelColor: context.moonColors!.trunks,
                              labelStyle: context.moonTypography!.body.text14
                                  .copyWith(fontWeight: FontWeight.w600),
                              tabAlignment: TabAlignment.start,
                              tabs: const [
                                Tab(
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text("⚡"),
                                      SizedBox(width: 8),
                                      Text("PROCESS"),
                                    ],
                                  ),
                                ),
                                Tab(
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text("💾"),
                                      SizedBox(width: 8),
                                      Text("STORAGE"),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Toggle
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: ToggleSwitch(
                              value: _alwaysUpdate,
                              label: "Always Update",
                              onChanged: (val) {
                                setState(() {
                                  _alwaysUpdate = val;
                                });
                                _updateMonitoring();
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Tab Content
                    SizedBox(
                      height: 400,
                      child: TabBarView(
                        controller: _tabController,
                        children: const [
                          ProcessTabContent(),
                          StorageTabContent(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Cleaner Section
              const CleanerSection(),
            ],
          ),
        ),
      ),
    );
  }
}
