import 'package:flutter/material.dart';
import 'package:moon_design/moon_design.dart';
import 'cleaner_tab.dart';
import 'process_tab.dart';
import 'storage_tab.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const CleanerTab(),
    const ProcessTab(),
    const StorageTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.moonColors!.goku,
      body: Row(
        children: [
          Container(
            width: 80,
            color: context.moonColors!.gohan,
            child: Column(
              children: [
                const SizedBox(height: 24),
                // App Logo
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    image: const DecorationImage(
                      image: AssetImage('assets/icon.png'),
                      fit: BoxFit.cover,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                _buildNavItem(
                  0,
                  Icons.cleaning_services_outlined,
                  Icons.cleaning_services,
                  "Cleaner",
                ),
                const SizedBox(height: 16),
                _buildNavItem(
                  1,
                  Icons.memory_outlined,
                  Icons.memory,
                  "Process",
                ),
                const SizedBox(height: 16),
                _buildNavItem(
                  2,
                  Icons.storage_outlined,
                  Icons.storage,
                  "Storage",
                ),
              ],
            ),
          ),
          Container(width: 1, color: context.moonColors!.beerus),
          Expanded(child: _screens[_selectedIndex]),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    int index,
    IconData icon,
    IconData selectedIcon,
    String label,
  ) {
    final isSelected = _selectedIndex == index;
    return MoonButton.icon(
      icon: Icon(isSelected ? selectedIcon : icon, size: 24),
      buttonSize: MoonButtonSize.lg,
      backgroundColor: isSelected
          ? context.moonColors!.piccolo.withOpacity(0.1)
          : Colors.transparent,
      iconColor: isSelected
          ? context.moonColors!.piccolo
          : context.moonColors!.trunks,
      hoverEffectColor: context.moonColors!.beerus,
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
      },
    );
  }
}
