import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../config/theme.dart';
import '../services/auth_service.dart';
import '../services/station_service.dart';
import '../services/theme_service.dart';
import 'slot_screen.dart';

class HomeScreen extends StatefulWidget {
  final Map<String, dynamic> profile;
  const HomeScreen({super.key, required this.profile});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> _stations = [];
  bool _loadingStations = true;
  String? _stationsError;

  @override
  void initState() {
    super.initState();
    _loadStations();
  }

  String get _prenom {
    final name = (widget.profile['fullName'] ?? widget.profile['name'] ?? '').toString();
    if (name.trim().isNotEmpty) return name.trim().split(' ').first;
    final phone = (widget.profile['phone'] ?? widget.profile['phone_number'] ?? '').toString();
    return phone.length >= 4 ? '...${phone.substring(phone.length - 4)}' : 'ami';
  }

  int get _points => (widget.profile['points'] ?? 0) as int;

  Future<void> _loadStations() async {
    setState(() {
      _loadingStations = true;
      _stationsError = null;
    });

    // Position par défaut : Brazzaville (miroir DEFAULT_POSITION dans config.js)
    double lat = -4.2634, lng = 15.2429;

    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission != LocationPermission.denied &&
          permission != LocationPermission.deniedForever) {
        final pos = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            timeLimit: Duration(seconds: 10),
          ),
        );
        lat = pos.latitude;
        lng = pos.longitude;
      }
    } catch (_) {
      // GPS indisponible → on garde la position par défaut
    }

    try {
      final stations = await StationService.getNearby(lat: lat, lng: lng);
      if (!mounted) return;
      setState(() {
        _stations = stations;
        _loadingStations = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _stationsError = 'Impossible de charger les bornes — réessayez';
        _loadingStations = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.energoColors;
    return Scaffold(
      appBar: AppBar(
        title: Text('ENERGO',
            style: TextStyle(color: c.primary, fontWeight: FontWeight.w900)),
        actions: [
          IconButton(
            icon: Text(
              Theme.of(context).brightness == Brightness.dark ? '🌙' : '☀️',
              style: const TextStyle(fontSize: 18),
            ),
            onPressed: () => ThemeService.instance.toggle(),
          ),
          CircleAvatar(
            backgroundColor: c.surface800,
            child: Text(
              _prenom.replaceAll('.', '').substring(0, _prenom.replaceAll('.', '').length.clamp(0, 2)).toUpperCase(),
              style: TextStyle(color: c.textPrimary),
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadStations,
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Bonjour, $_prenom 👋',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),

                Container(
                  padding: const EdgeInsets.all(22),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: c.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: c.primary.withValues(alpha: 0.25)),
                  ),
                  child: Column(
                    children: [
                      Text('Scannez une borne pour louer une batterie',
                          style: TextStyle(color: c.textSecondary)),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () {
                          // TODO: scan QR code (prochaine étape)
                        },
                        icon: const Icon(Icons.qr_code_scanner, color: Colors.black),
                        label: const Text('Scanner un QR code'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                Text('MON ACTIVITÉ',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: c.textSecondary, letterSpacing: 1)),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(child: _StatCard(label: 'Locations', value: '0')),
                    const SizedBox(width: 10),
                    Expanded(child: _StatCard(label: 'Points fidélité', value: '$_points pts', green: true)),
                  ],
                ),
                const SizedBox(height: 24),

                Text('BORNES DISPONIBLES',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: c.textSecondary, letterSpacing: 1)),
                const SizedBox(height: 10),
                _buildStationsCard(c),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStationsCard(EnergoColors c) {
    if (_loadingStations) {
      return Column(
        children: List.generate(3, (_) => Container(
          height: 56,
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: c.surface700,
            borderRadius: BorderRadius.circular(10),
          ),
        )),
      );
    }

    if (_stationsError != null) {
      return Container(
        padding: const EdgeInsets.all(20),
        width: double.infinity,
        decoration: BoxDecoration(
          color: c.surface800,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: c.surface700),
        ),
        child: Column(
          children: [
            Text(_stationsError!, style: TextStyle(color: c.textSecondary), textAlign: TextAlign.center),
            const SizedBox(height: 10),
            TextButton(onPressed: _loadStations, child: const Text('Réessayer')),
          ],
        ),
      );
    }

    if (_stations.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        width: double.infinity,
        decoration: BoxDecoration(
          color: c.surface800,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: c.surface700),
        ),
        child: Center(
          child: Text('Aucune borne disponible pour le moment',
              style: TextStyle(color: c.textSecondary)),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: c.surface800,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: c.surface700),
      ),
      child: Column(
        children: _stations.map((borne) {
          final dispo = borne['available_slots'] ?? borne['availableSlots'] ?? 0;
          final total = borne['total_slots'] ?? borne['totalSlots'] ?? 12;
          final enligne = borne['is_online'] ?? borne['isOnline'] ?? true;
          final name = borne['location_name'] ?? borne['name'] ?? 'Borne';
          final distanceM = borne['distance_m'];
          final distance = distanceM == null
              ? ''
              : distanceM < 1000
                  ? '$distanceM m'
                  : '${(distanceM / 1000).toStringAsFixed(1)} km';

          final badgeColor = dispo >= 5 ? c.green : (dispo > 0 ? c.orange : c.textSecondary);

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(
                width: 42, height: 42,
                decoration: BoxDecoration(
                  color: c.surface700,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(child: Text('⚡', style: TextStyle(fontSize: 18))),
              ),
              title: Text(name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
              subtitle: Row(
                children: [
                  Icon(Icons.circle, size: 7, color: enligne ? c.green : c.textSecondary),
                  const SizedBox(width: 5),
                  Text(distance, style: TextStyle(color: c.textSecondary, fontSize: 12)),
                ],
              ),
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: badgeColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text('$dispo/$total',
                    style: TextStyle(color: badgeColor, fontWeight: FontWeight.bold, fontSize: 12)),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => SlotScreen(station: borne)),
                );
              },
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final bool green;
  const _StatCard({required this.label, required this.value, this.green = false});

  @override
  Widget build(BuildContext context) {
    final c = context.energoColors;
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
          Text(value, style: TextStyle(
              fontSize: 22, fontWeight: FontWeight.bold,
              color: green ? c.primary : c.textPrimary)),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(color: c.textSecondary, fontSize: 12)),
        ],
      ),
    );
  }
}