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
  // Miroir des tarifs de ta PWA : durée (min) → prix FCFA
  static const List<Map<String, Object>> _tarifs = [
    {'label': '30 min', 'min': 30, 'price': 250},
    {'label': '1 heure', 'min': 60, 'price': 500},
    {'label': '3 heures', 'min': 180, 'price': 1500},
    {'label': '6 heures', 'min': 360, 'price': 3000},
    {'label': '12 heures', 'min': 720, 'price': 6000},
    {'label': '24 heures', 'min': 1440, 'price': 12000},
  ];

  int _selectedIndex = -1;

  String get _stationName =>
      widget.station['location_name'] ?? widget.station['name'] ?? 'Borne';
  String get _stationCode =>
      (widget.station['station_code'] ?? widget.station['deviceId'] ?? '').toString();

  @override
  Widget build(BuildContext context) {
    final c = context.energoColors;
    final selected = _selectedIndex >= 0 ? _tarifs[_selectedIndex] : null;

    return Scaffold(
      appBar: AppBar(
        leading: TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('← Retour', style: TextStyle(color: c.primary)),
        ),
        leadingWidth: 100,
        title: Text(_stationName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Carte info borne
              Container(
                padding: const EdgeInsets.all(18),
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
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_stationName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                          Text(widget.station['address'] ?? '',
                              style: TextStyle(color: c.textSecondary, fontSize: 12)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              Text('Durée de location', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text('Une batterie disponible vous sera attribuée automatiquement',
                  style: TextStyle(color: c.textSecondary, fontSize: 12)),
              const SizedBox(height: 16),

              Expanded(
                child: GridView.builder(
                  itemCount: _tarifs.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: 0.95,
                  ),
                  itemBuilder: (_, i) {
                    final t = _tarifs[i];
                    final active = _selectedIndex == i;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedIndex = i),
                      child: Container(
                        decoration: BoxDecoration(
                          color: active ? c.primary.withValues(alpha: 0.1) : c.surface800,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: active ? c.primary : c.surface700,
                            width: active ? 2 : 1.5,
                          ),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(t['label'] as String,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                              const SizedBox(height: 4),
                              Text('${t['price']} FCFA',
                                  style: TextStyle(color: c.primary, fontWeight: FontWeight.bold, fontSize: 11)),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              if (selected != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: c.surface800,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Total à payer', style: TextStyle(color: c.textSecondary, fontSize: 13)),
                      Text('${selected['price']} FCFA',
                          style: TextStyle(color: c.primary, fontWeight: FontWeight.w800, fontSize: 18)),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 14),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: selected == null
                      ? null
                      : () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => PaymentScreen(
                                stationDeviceId: _stationCode,
                                stationName: _stationName,
                                durationMinutes: selected['min'] as int,
                                durationLabel: selected['label'] as String,
                                amount: selected['price'] as int,
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