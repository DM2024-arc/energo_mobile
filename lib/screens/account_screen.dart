import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../config/app_config.dart';
import '../services/auth_service.dart';
import '../services/theme_service.dart';

class AccountScreen extends StatelessWidget {
  final Map<String, dynamic> profile;
  const AccountScreen({super.key, required this.profile});

  String get _name => (profile['fullName'] ?? profile['name'] ?? '—').toString();
  String get _phone => (profile['phone'] ?? profile['phone_number'] ?? '—').toString();
  int get _points => (profile['points'] ?? 0) as int;

  static const List<Map<String, Object>> _levels = [
    {'name': 'Bronze 🥉', 'min': 0},
    {'name': 'Argent 🥈', 'min': 100},
    {'name': 'Or 🥇', 'min': 300},
    {'name': 'Platine 💎', 'min': 600},
  ];

  Map<String, Object> get _currentLevel {
    var current = _levels.first;
    for (final l in _levels) {
      if (_points >= (l['min'] as int)) current = l;
    }
    return current;
  }

  Map<String, Object>? get _nextLevel {
    final idx = _levels.indexOf(_currentLevel);
    return idx < _levels.length - 1 ? _levels[idx + 1] : null;
  }

  double get _progress {
    final next = _nextLevel;
    if (next == null) return 1.0;
    final min = _currentLevel['min'] as int;
    final max = next['min'] as int;
    return ((_points - min) / (max - min)).clamp(0.0, 1.0);
  }

  String get _memberSince {
    final raw = profile['created_at'] ?? profile['createdAt'];
    if (raw == null) return '—';
    try {
      final date = DateTime.parse(raw.toString());
      const mois = ['janvier','février','mars','avril','mai','juin',
        'juillet','août','septembre','octobre','novembre','décembre'];
      return '${mois[date.month - 1]} ${date.year}';
    } catch (_) {
      return '—';
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.energoColors;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final initials = _name.trim().isNotEmpty && _name != '—'
        ? _name.trim().split(' ').where((w) => w.isNotEmpty).map((w) => w[0]).take(2).join().toUpperCase()
        : 'E';
    final next = _nextLevel;

    return Scaffold(
      appBar: AppBar(
        title: Text('ENERGO', style: TextStyle(color: c.primary, fontWeight: FontWeight.w900)),
        actions: [
          IconButton(
            icon: Text(isDark ? '🌙' : '☀️', style: const TextStyle(fontSize: 18)),
            onPressed: () => ThemeService.instance.toggle(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        child: Column(
          children: [
            // ── En-tête profil avec crayon éditer à droite ──────────
            Stack(
              children: [
                Column(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: c.primary,
                      child: Text(initials, style: const TextStyle(
                          fontSize: 26, fontWeight: FontWeight.bold, color: Colors.black)),
                    ),
                    const SizedBox(height: 12),
                    Text(_name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(_phone, style: TextStyle(color: c.textSecondary)),
                  ],
                ),
                Positioned(
                  top: 0,
                  right: 0,
                  child: IconButton(
                    icon: Icon(Icons.edit_outlined, color: c.primary, size: 20),
                    style: IconButton.styleFrom(
                      backgroundColor: c.surface800,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: BorderSide(color: c.surface700),
                      ),
                    ),
                    onPressed: () => _toast(context, 'Modifier le profil — bientôt disponible'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // ── 3 cartes stats ────────────────────────────────────
            Row(
              children: [
                Expanded(child: _MiniStat(value: '0', label: 'Locations', c: c)),
                const SizedBox(width: 8),
                Expanded(child: _MiniStat(value: '$_points', label: 'Points fidélité', c: c, green: true)),
                const SizedBox(width: 8),
                Expanded(child: _MiniStat(
                    value: (_currentLevel['name'] as String).split(' ').first,
                    emoji: (_currentLevel['name'] as String).split(' ').last,
                    label: 'Niveau', c: c, green: true)),
              ],
            ),
            const SizedBox(height: 16),

            // ── Progression vers le prochain niveau ────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Progression vers le prochain niveau',
                    style: TextStyle(color: c.textSecondary, fontSize: 12)),
                Text(next != null ? '$_points / ${next['min']} pts' : 'Niveau max',
                    style: TextStyle(color: c.textSecondary, fontSize: 12)),
              ],
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: _progress,
                minHeight: 6,
                backgroundColor: c.surface700,
                valueColor: AlwaysStoppedAnimation(c.primary),
              ),
            ),
            const SizedBox(height: 24),

            // ── INFORMATIONS ────────────────────────────────────────
            Align(
              alignment: Alignment.centerLeft,
              child: Text('INFORMATIONS', style: TextStyle(
                  fontSize: 12, fontWeight: FontWeight.bold, color: c.textSecondary, letterSpacing: 1)),
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Material(
                color: c.surface800,
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: c.surface700),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      _InfoRow(icon: '📱', label: 'Téléphone', value: _phone, c: c),
                      Divider(height: 1, color: c.surface700),
                      _InfoRow(icon: '📅', label: 'Membre depuis', value: _memberSince, c: c),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // ── PARAMÈTRES ───────────────────────────────────────────
            Align(
              alignment: Alignment.centerLeft,
              child: Text('PARAMÈTRES', style: TextStyle(
                  fontSize: 12, fontWeight: FontWeight.bold, color: c.textSecondary, letterSpacing: 1)),
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Material(
                color: c.surface800,
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: c.surface700),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Text('✏️', style: TextStyle(fontSize: 18)),
                        title: const Text('Modifier le profil', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                        trailing: Icon(Icons.chevron_right, color: c.textSecondary),
                        onTap: () => _toast(context, 'Modifier le profil — bientôt disponible'),
                      ),
                      Divider(height: 1, color: c.surface700),
                      ListTile(
                        leading: const Text('🎨', style: TextStyle(fontSize: 18)),
                        title: const Text('Thème', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                        trailing: _ThemeToggle(isDark: isDark, c: c),
                      ),
                      Divider(height: 1, color: c.surface700),
                      ListTile(
                        leading: const Text('🌍', style: TextStyle(fontSize: 18)),
                        title: const Text('Langue', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                        trailing: _LangToggle(c: c),
                      ),
                      Divider(height: 1, color: c.surface700),
                      ListTile(
                        leading: const Text('🔔', style: TextStyle(fontSize: 18)),
                        title: const Text('Notifications', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                        trailing: Icon(Icons.chevron_right, color: c.textSecondary),
                        onTap: () => _toast(context, 'Notifications activées ✓'),
                      ),
                      Divider(height: 1, color: c.surface700),
                      ListTile(
                        leading: const Text('💬', style: TextStyle(fontSize: 18)),
                        title: const Text('Support & Aide', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                        trailing: Icon(Icons.chevron_right, color: c.textSecondary),
                        onTap: () => _toast(context, 'Support — bientôt disponible'),
                      ),
                      Divider(height: 1, color: c.surface700),
                      ListTile(
                        leading: const Text('ℹ️', style: TextStyle(fontSize: 18)),
                        title: const Text('À propos', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                        trailing: Text('v${AppConfig.version}', style: TextStyle(color: c.textSecondary, fontSize: 12)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // ── SE DÉCONNECTER ───────────────────────────────────────
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: c.red,
                  side: BorderSide(color: c.red.withValues(alpha: 0.4)),
                ),
                onPressed: () async {
                  await AuthService.logout();
                  if (context.mounted) {
                    Navigator.of(context).popUntil((r) => r.isFirst);
                  }
                },
                child: const Text('↩ Se déconnecter'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _toast(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }
}

class _MiniStat extends StatelessWidget {
  final String value;
  final String? emoji;
  final String label;
  final bool green;
  final EnergoColors c;
  const _MiniStat({required this.value, this.emoji, required this.label, this.green = false, required this.c});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        color: c.surface800,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: c.surface700),
      ),
      child: Column(
        children: [
          Text(
            emoji != null ? '$value $emoji' : value,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold,
                color: green ? c.primary : c.textPrimary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(color: c.textSecondary, fontSize: 10.5), textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String icon;
  final String label;
  final String value;
  final EnergoColors c;
  const _InfoRow({required this.icon, required this.label, required this.value, required this.c});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(icon, style: const TextStyle(fontSize: 16)),
              const SizedBox(width: 10),
              Text(label, style: TextStyle(color: c.textSecondary, fontSize: 13)),
            ],
          ),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
        ],
      ),
    );
  }
}

class _ThemeToggle extends StatelessWidget {
  final bool isDark;
  final EnergoColors c;
  const _ThemeToggle({required this.isDark, required this.c});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _Pill(label: '🌙 Sombre', active: isDark, c: c,
            onTap: () { if (!isDark) ThemeService.instance.toggle(); }),
        const SizedBox(width: 6),
        _Pill(label: '☀️ Clair', active: !isDark, c: c,
            onTap: () { if (isDark) ThemeService.instance.toggle(); }),
      ],
    );
  }
}

class _LangToggle extends StatelessWidget {
  final EnergoColors c;
  const _LangToggle({required this.c});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _Pill(label: 'FR', active: true, c: c, onTap: () {}),
        const SizedBox(width: 6),
        _Pill(label: 'EN', active: false, c: c, onTap: () {}),
      ],
    );
  }
}

class _Pill extends StatelessWidget {
  final String label;
  final bool active;
  final EnergoColors c;
  final VoidCallback onTap;
  const _Pill({required this.label, required this.active, required this.c, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: active ? c.primary : c.surface700,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(label, style: TextStyle(
            fontSize: 11, fontWeight: FontWeight.bold,
            color: active ? Colors.black : c.textSecondary)),
      ),
    );
  }
}