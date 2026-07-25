import 'package:flutter/material.dart';
import 'config/theme.dart';
import 'screens/splash_screen.dart';
import 'services/theme_service.dart';

void main() {
  runApp(const EnergoApp());
}

class EnergoApp extends StatefulWidget {
  const EnergoApp({super.key});

  @override
  State<EnergoApp> createState() => _EnergoAppState();
}

class _EnergoAppState extends State<EnergoApp> {
  @override
  void initState() {
    super.initState();
    ThemeService.instance.load();
    ThemeService.instance.addListener(_onThemeChanged);
  }

  @override
  void dispose() {
    ThemeService.instance.removeListener(_onThemeChanged);
    super.dispose();
  }

  void _onThemeChanged() => setState(() {});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ENERGO',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeService.instance.mode,
      home: const SplashScreen(),
    );
  }
}