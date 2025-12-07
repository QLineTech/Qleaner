import 'package:flutter/material.dart';
import 'package:moon_design/moon_design.dart';
import 'package:provider/provider.dart';
import 'services/scanner_service.dart';
import 'services/cleaner_service.dart';
import 'services/system_service.dart';
import 'screens/main_screen.dart';

void main() {
  runApp(const QleanerApp());
}

class QleanerApp extends StatelessWidget {
  const QleanerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ScannerService()),
        ChangeNotifierProvider(create: (_) => CleanerService()),
        ChangeNotifierProvider(create: (_) => SystemService()),
      ],
      child: MaterialApp(
        title: 'Qleaner',
        theme: ThemeData.dark().copyWith(
          extensions: <ThemeExtension<dynamic>>[
            MoonTheme(
              tokens: MoonTokens.dark.copyWith(
                colors: MoonColors.dark.copyWith(
                  piccolo: const Color(0xFF58A6FF), // Accent blue
                  hit: const Color(0xFF238636), // Success green
                  chichi: const Color(0xFFF85149), // Error red
                  goku: const Color(0xFF0D1117), // Background
                  gohan: const Color(0xFF161B22), // Surface
                  beerus: const Color(0xFF30363D), // Border
                  trunks: const Color(0xFF8B949E), // Text secondary
                  bulma: const Color(0xFFF0F6FC), // Text primary
                ),
              ),
            ),
          ],
        ),
        home: const MainScreen(),
      ),
    );
  }
}
