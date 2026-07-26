import 'package:flutter/material.dart';
import '../config/theme.dart';
import 'payment_screen.dart';

class SlotScreen extends StatefulWidget {
  final Map<String, dynamic> station;
  const SlotScreen({super.key, required this.station});

  @override
  State<SlotScreen> createState() => _SlotScreenState();
}

class _SlotScreenState extends State<SlotScreen> {
  static const int _prixParHeure = 500; // FCFA/h — miroir de CONFIG.PRIX_PAR_HEURE
  static const int _minMinutes = 30;
  static const int _maxMinutes = 1440; // 24h

  static const List<int> _presets = [30, 60, 120, 180, 360]; // 30min,1h,2h,3h,6h

  int _minutes = 60;

  String get _stationName =>
      widget.station['location_name'] ?? widget.station['name'] ?? 'Borne';
  String get _stationCode =>
      (widget.station['station_code'] ?? widget.station['deviceId'] ?? '').toString();
  bool get _isOnline =>
      widget.station['is_online'] ?? widget.station['isOnline'] ?? true;
  int get _dispo =>
      (widget.station['available_slots'] ?? widget.station['availableSlots'] ?? 0) as int;
  int get _total =>
      (widget.station['total_slots'] ?? widget.station['totalSlots'] ?? 0) as int;

  double get _hours => _minutes / 60;
  int get _amount => (_hours * _prixParHeure).round();

  void _decrement() {
    setState(() {
      if (_minutes > 60) {
        _minutes -= 60;
      } else if (_minutes == 60) {
        _minutes = 30;
      }
    });
  }

  void _increment() {
    setState(() {
      if (_minutes == 30) {
        _minutes = 60;
      } else {
        _minutes = (_minutes + 60).clamp(_minMinutes, _maxMinutes);
      }
    });
  }

  String get _bigLabel => _minutes < 60 ? '$_minutes' : '${(_minutes / 60).round()}';
  String get _bigUnit => _minutes < 60 ? 'min' : 'h';

  String _presetLabel(int min) {
    if (min < 60) return '$min min';
    final h = min ~/ 60;
    return '${h}h';
  }

  String _fullDurationLabel(int min) {
    if (min < 60) return '$min minutes';
    final h = min ~/ 60;
    final rem = min % 60;
    if (rem == 0) return h == 1 ? '1 heure' : '$h heures';
    return '${h}h${rem.toString().padLeft(2, '0')}';
  }

  String _tarifMultiplier() {
    final h = _hours;
    if (h == h.roundToDouble()) return h.round().toString();
    return h.toStringAsFixed(1);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.energoColors;

    return Scaffold(
      appBar: AppBar(
        leading: TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('← Retour', style: TextStyle(color: c.primary)),
        ),
        leadingWidth: 100,
        title: const Text('Tarification', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Carte borne ────────────────────────────────
              Container(
                padding: const EdgeInsets.all(14),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: c.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: c.primary.withValues(alpha: 0.25)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 48, height: 48,
                      decoration: BoxDecoration(
                        color: c.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(child: Text('⚡', style: TextStyle(fontSize: 22))),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (_stationCode.isNotEmpty)
                            Text('Borne · $_stationCode',
                                style: TextStyle(color: c.textSecondary, fontSize: 11)),
                          Text(_stationName,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: (_isOnline ? c.green : c.textSecondary).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.circle, size: 6,
                                  color: _isOnline ? c.green : c.textSecondary),
                              const SizedBox(width: 4),
                              Text(_isOnline ? 'En ligne' : 'Hors ligne',
                                  style: TextStyle(
                                      color: _isOnline ? c.green : c.textSecondary,
                                      fontSize: 11, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text('$_dispo/$_total dispo',
                            style: TextStyle(color: c.textSecondary, fontSize: 11)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              Text('Durée de location',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text('Une batterie disponible vous sera attribuée automatiquement',
                  style: TextStyle(color: c.textSecondary, fontSize: 12)),
              const SizedBox(height: 24),

              // ── Stepper ────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _StepperButton(icon: Icons.remove, c: c, onTap: _decrement),
                  const SizedBox(width: 28),
                  Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(_bigLabel, style: const TextStyle(
                              fontSize: 44, fontWeight: FontWeight.w900, height: 1)),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 6, left: 2),
                            child: Text(_bigUnit, style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(width: 28),
                  _StepperButton(icon: Icons.add, c: c, filled: true, onTap: _increment),
                ],
              ),
              const SizedBox(height: 6),
              Center(
                child: Text('jusqu\'à 24h', style: TextStyle(color: c.textSecondary, fontSize: 12)),
              ),
              const SizedBox(height: 20),

              // ── Presets rapides ──────────────────────────────
              SizedBox(
                width: double.infinity,
                child: Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 8,
                  runSpacing: 8,
                  children: _presets.map((p) {
                    final active = _minutes == p;
                    return GestureDetector(
                      onTap: () => setState(() => _minutes = p),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: active ? c.primary : c.surface800,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: active ? c.primary : c.surface700),
                        ),
                        child: Text(_presetLabel(p), style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 13,
                            color: active ? Colors.black : c.textPrimary)),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 24),
              Divider(color: c.surface700),
              const SizedBox(height: 12),

              // ── Tarif ──────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Tarif · $_prixParHeure F/h × ${_tarifMultiplier()}',
                      style: TextStyle(color: c.textSecondary, fontSize: 13)),
                  Text('$_amount FCFA', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Total à payer', style: TextStyle(color: c.primary, fontWeight: FontWeight.bold, fontSize: 15)),
                  Text('$_amount FCFA', style: TextStyle(
                      color: c.primary, fontWeight: FontWeight.w900, fontSize: 20)),
                ],
              ),

              const Spacer(),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PaymentScreen(
                          stationDeviceId: _stationCode,
                          stationName: _stationName,
                          durationMinutes: _minutes,
                          durationLabel: _fullDurationLabel(_minutes),
                          amount: _amount,
                        ),
                      ),
                    );
                  },
                  child: const Text('Continuer vers le paiement'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StepperButton extends StatelessWidget {
  final IconData icon;
  final EnergoColors c;
  final bool filled;
  final VoidCallback onTap;

  const _StepperButton({
    required this.icon, required this.c, this.filled = false, required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 46, height: 46,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: filled ? c.primary : Colors.transparent,
          border: Border.all(color: filled ? c.primary : c.surface700, width: 1.5),
        ),
        child: Icon(icon, color: filled ? Colors.black : c.textPrimary, size: 22),
      ),
    );
  }
}