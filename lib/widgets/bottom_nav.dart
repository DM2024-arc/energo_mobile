import 'package:flutter/material.dart';
import '../config/theme.dart';

class EnergoBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const EnergoBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.energoColors;
    return Container(
      decoration: BoxDecoration(
        color: c.surface900,
        border: Border(top: BorderSide(color: c.surface700)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            _NavItem(icon: Icons.home_rounded, label: 'Accueil', index: 0,
                current: currentIndex, onTap: onTap, c: c),
            _NavItem(icon: Icons.location_on_rounded, label: 'Carte', index: 1,
                current: currentIndex, onTap: onTap, c: c),
            _NavItem(icon: Icons.history_rounded, label: 'Historique', index: 2,
                current: currentIndex, onTap: onTap, c: c),
            _NavItem(icon: Icons.person_rounded, label: 'Compte', index: 3,
                current: currentIndex, onTap: onTap, c: c),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final int index;
  final int current;
  final ValueChanged<int> onTap;
  final EnergoColors c;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.index,
    required this.current,
    required this.onTap,
    required this.c,
  });

  @override
  Widget build(BuildContext context) {
    final active = index == current;
    return Expanded(
      child: InkWell(
        onTap: () => onTap(index),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 22, color: active ? c.primary : c.textSecondary),
              const SizedBox(height: 3),
              Text(label, style: TextStyle(
                  fontSize: 10.5, fontWeight: FontWeight.w500,
                  color: active ? c.primary : c.textSecondary)),
              const SizedBox(height: 2),
              Container(
                width: 4, height: 4,
                decoration: BoxDecoration(
                  color: active ? c.primary : Colors.transparent,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}