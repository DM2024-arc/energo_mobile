import 'dart:async';
import 'package:flutter/material.dart';
import '../config/theme.dart';

class SessionScreen extends StatefulWidget {
  final Map<String, dynamic> rental;
  const SessionScreen({super.key, required this.rental});

  @override
  State<SessionScreen> createState() => _SessionScreenState();
}

class _SessionScreenState extends State<SessionScreen> {
  Timer? _timer;
  Duration _elapsed = Duration.zero;
  late final DateTime _started;

  @override
  void initState() {
    super.initState();
    final startedAt = widget.rental['startedAt'] ?? widget.rental['started_at'];
    _started = startedAt != null ? DateTime.tryParse(startedAt.toString()) ?? DateTime.now() : DateTime.now();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => _elapsed = DateTime.now().difference(_started));
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _fmt(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes % 60;
    final s = d.inSeconds % 60;
    if (h > 0) return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final c = context.energoColors;
    final slotNumber = widget.rental['slotNumber'] ?? widget.rental['slot_number'];
    final stationName = widget.rental['stationName'] ?? widget.rental['station_name'] ?? '—';

    return Scaffold(
      appBar: AppBar(
        title: Text('ENERGO', style: TextStyle(color: c.primary, fontWeight: FontWeight.w900)),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: c.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text('⚡ Actif', style: TextStyle(color: c.primary, fontWeight: FontWeight.bold, fontSize: 12)),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 20),
              Container(
                width: 190, height: 190,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: c.primary, width: 4),
                ),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(_fmt(_elapsed), style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w800)),
                      Text('écoulé', style: TextStyle(color: c.textSecondary, fontSize: 12)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text('Batterie en cours d\'utilisation',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              Text('Slot ${slotNumber ?? "—"} · $stationName',
                  style: TextStyle(color: c.textSecondary)),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: c.red,
                    side: BorderSide(color: c.red.withValues(alpha: 0.4)),
                  ),
                  onPressed: () {
                    // TODO: retour batterie
                    Navigator.of(context).popUntil((r) => r.isFirst);
                  },
                  child: const Text('Retourner la batterie'),
                ),
              ),
              const SizedBox(height: 10),
              Text('Vous pouvez retourner la batterie dans n\'importe quelle borne ENERGO',
                  style: TextStyle(color: c.textSecondary, fontSize: 11), textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}