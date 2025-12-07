import 'package:flutter/material.dart';
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
        theme: ThemeData(
          brightness: Brightness.dark,
          primarySwatch: Colors.blue,
          scaffoldBackgroundColor: const Color(0xFF0D1117),
          cardColor: const Color(0xFF161B22),
          dividerColor: const Color(0xFF30363D),
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFF58A6FF),
            secondary: Color(0xFF238636),
            surface: Color(0xFF161B22),
            background: Color(0xFF0D1117),
            error: Color(0xFFF85149),
          ),
          useMaterial3: true,
        ),
        home: const MainScreen(),
      ),
    );
  }
}
