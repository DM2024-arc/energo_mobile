import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../services/rental_service.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<Map<String, dynamic>> _rentals = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final data = await RentalService.getMyRentals();
      if (!mounted) return;
      setState(() { _rentals = data; _loading = false; });
    } catch (e) {
      if (!mounted) return;
      setState(() { _error = 'Impossible de charger l\'historique'; _loading = false; });
    }
  }

  int get _totalSpent => _rentals.fold(0, (sum, r) => sum + ((r['amount'] ?? 0) as num).toInt());

  @override
  Widget build(BuildContext context) {
    final c = context.energoColors;
    return Scaffold(
      appBar: AppBar(
        title: Text('ENERGO', style: TextStyle(color: c.primary, fontWeight: FontWeight.w900)),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Center(child: Text('Historique')),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(child: _StatCard(label: 'Locations totales', value: '${_rentals.length}', c: c)),
                  const SizedBox(width: 10),
                  Expanded(child: _StatCard(label: 'Total dépensé', value: '$_totalSpent F', green: true, c: c)),
                ],
              ),
              const SizedBox(height: 20),

              if (_loading)
                const Padding(
                  padding: EdgeInsets.only(top: 60),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(top: 60),
                  child: Column(
                    children: [
                      Text(_error!, style: TextStyle(color: c.textSecondary)),
                      const SizedBox(height: 10),
                      TextButton(onPressed: _load, child: const Text('Réessayer')),
                    ],
                  ),
                )
              else if (_rentals.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 60),
                  child: Column(
                    children: [
                      const Text('📋', style: TextStyle(fontSize: 40)),
                      const SizedBox(height: 10),
                      const Text('Aucune location', style: TextStyle(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 4),
                      Text('Scannez une borne pour commencer',
                          style: TextStyle(color: c.textSecondary, fontSize: 13)),
                    ],
                  ),
                )
              else
                Container(
                  decoration: BoxDecoration(
                    color: c.surface800,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: c.surface700),
                  ),
                  child: Column(
                    children: _rentals.map((r) {
                      final station = r['stationName'] ?? r['station_name'] ?? 'Borne';
                      final amount = r['amount'] ?? 0;
                      final status = r['status'] ?? '';
                      final startedAt = r['startedAt'] ?? r['started_at'];

                      return ListTile(
                        leading: Container(
                          width: 40, height: 40,
                          decoration: BoxDecoration(
                            color: c.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Center(child: Text('🔋', style: TextStyle(fontSize: 16))),
                        ),
                        title: Text(station, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                        subtitle: Text(
                          '$status${startedAt != null ? " · $startedAt" : ""}',
                          style: TextStyle(color: c.textSecondary, fontSize: 12),
                        ),
                        trailing: Text('$amount F',
                            style: TextStyle(fontWeight: FontWeight.bold, color: c.primary)),
                      );
                    }).toList(),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final bool green;
  final EnergoColors c;
  const _StatCard({required this.label, required this.value, this.green = false, required this.c});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: c.surface800,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: c.surface700),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold,
              color: green ? c.primary : c.textPrimary)),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(color: c.textSecondary, fontSize: 11)),
        ],
      ),
    );
  }
}