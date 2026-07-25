import 'package:flutter/material.dart';
import '../widgets/bottom_nav.dart';
import 'home_screen.dart';
import 'map_screen.dart';
import 'history_screen.dart';
import 'account_screen.dart';

class MainShell extends StatefulWidget {
  final Map<String, dynamic> profile;
  const MainShell({super.key, required this.profile});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final screens = [
      HomeScreen(profile: widget.profile),
      const MapScreen(),
      const HistoryScreen(),
      AccountScreen(profile: widget.profile),
    ];

    return Scaffold(
      body: IndexedStack(index: _index, children: screens),
      bottomNavigationBar: EnergoBottomNav(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
      ),
    );
  }
}