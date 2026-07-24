import 'package:flutter/material.dart';
import 'config/theme.dart';
import 'screens/splash_screen.dart';

void main() {
  runApp(const EnergoApp());
}

class EnergoApp extends StatelessWidget {
  const EnergoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ENERGO',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: const SplashScreen(),
    );
  }
}