import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../config/theme.dart';
import '../services/station_service.dart';
import 'package:geolocator/geolocator.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  List<Map<String, dynamic>> _stations = [];
  bool _loading = true;
  String _filter = 'all'; // all | available | nearby
  final _mapController = MapController();

  static const _brazzaville = LatLng(-4.2634, 15.2429);

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    double lat = _brazzaville.latitude, lng = _brazzaville.longitude;

    try {
      LocationPermission perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm != LocationPermission.denied && perm != LocationPermission.deniedForever) {
        final pos = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(timeLimit: Duration(seconds: 8)),
        );
        lat = pos.latitude;
        lng = pos.longitude;
      }
    } catch (_) {}

    try {
      final stations = await StationService.getNearby(lat: lat, lng: lng);
      if (!mounted) return;
      setState(() {
        _stations = stations;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  List<Map<String, dynamic>> get _filtered {
    if (_filter == 'available') {
      return _stations.where((s) =>
          (s['available_slots'] ?? s['availableSlots'] ?? 0) > 0).toList();
    }
    if (_filter == 'nearby') {
      return _stations.where((s) =>
          (s['distance_m'] ?? 999999) < 500).toList();
    }
    return _stations;
  }

  LatLng? _coords(Map<String, dynamic> s) {
    final lat = s['lat'] ?? s['latitude'] ?? s['location']?['lat'];
    final lng = s['lng'] ?? s['longitude'] ?? s['location']?['lng'];
    if (lat == null || lng == null) return null;
    return LatLng((lat as num).toDouble(), (lng as num).toDouble());
  }

  @override
  Widget build(BuildContext context) {
    final c = context.energoColors;
    final markers = _filtered
        .map((s) {
          final pos = _coords(s);
          if (pos == null) return null;
          final dispo = s['available_slots'] ?? s['availableSlots'] ?? 0;
          final color = dispo >= 5 ? c.green : (dispo > 0 ? c.orange : c.textSecondary);
          return Marker(
            point: pos,
            width: 36,
            height: 36,
            child: Icon(Icons.bolt, color: color, size: 32),
          );
        })
        .whereType<Marker>()
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('ENERGO', style: TextStyle(color: c.primary, fontWeight: FontWeight.w900)),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Center(child: Text('Brazzaville', style: TextStyle(fontSize: 12))),
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
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: SizedBox(
                  height: 260,
                  child: FlutterMap(
                    mapController: _mapController,
                    options: const MapOptions(
                      initialCenter: _brazzaville,
                      initialZoom: 12,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.example.energo_mobile',
                      ),
                      MarkerLayer(markers: markers),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Filtres
              SizedBox(
                height: 36,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _FilterChip(label: 'Toutes', value: 'all', current: _filter,
                        onTap: (v) => setState(() => _filter = v), c: c),
                    const SizedBox(width: 8),
                    _FilterChip(label: 'Disponibles', value: 'available', current: _filter,
                        onTap: (v) => setState(() => _filter = v), c: c),
                    const SizedBox(width: 8),
                    _FilterChip(label: 'Proches (<500m)', value: 'nearby', current: _filter,
                        onTap: (v) => setState(() => _filter = v), c: c),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              Text('TOUTES LES BORNES',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: c.textSecondary, letterSpacing: 1)),
              const SizedBox(height: 10),

              if (_loading)
                Column(
                  children: List.generate(3, (_) => Container(
                    height: 72,
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(color: c.surface700, borderRadius: BorderRadius.circular(10)),
                  )),
                )
              else if (_filtered.isEmpty)
                Container(
                  padding: const EdgeInsets.all(24),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: c.surface800,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: c.surface700),
                  ),
                  child: Center(
                    child: Text('Aucune borne trouvée', style: TextStyle(color: c.textSecondary)),
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
                    children: _filtered.map((s) {
                      final dispo = s['available_slots'] ?? s['availableSlots'] ?? 0;
                      final total = s['total_slots'] ?? s['totalSlots'] ?? 12;
                      final name = s['location_name'] ?? s['name'] ?? 'Borne';
                      final address = s['address'] ?? '';
                      final distanceM = s['distance_m'];
                      final distance = distanceM == null ? '' : distanceM < 1000
                          ? '$distanceM m' : '${(distanceM / 1000).toStringAsFixed(1)} km';
                      final badgeColor = dispo >= 5 ? c.green : (dispo > 0 ? c.orange : c.textSecondary);

                      return ListTile(
                        leading: Container(
                          width: 46, height: 46,
                          decoration: BoxDecoration(
                            color: c.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Center(child: Text('⚡', style: TextStyle(fontSize: 18))),
                        ),
                        title: Text(name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                        subtitle: Text('$address ${address.isNotEmpty ? "· " : ""}$distance',
                            style: TextStyle(color: c.textSecondary, fontSize: 12)),
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
                          // TODO: naviguer vers l'écran slot
                        },
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

class _FilterChip extends StatelessWidget {
  final String label;
  final String value;
  final String current;
  final ValueChanged<String> onTap;
  final EnergoColors c;

  const _FilterChip({
    required this.label, required this.value, required this.current,
    required this.onTap, required this.c,
  });

  @override
  Widget build(BuildContext context) {
    final active = value == current;
    return GestureDetector(
      onTap: () => onTap(value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: active ? c.primary.withValues(alpha: 0.12) : c.surface700,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: active ? c.primary.withValues(alpha: 0.3) : Colors.transparent),
        ),
        child: Center(
          child: Text(label, style: TextStyle(
              fontSize: 12, fontWeight: FontWeight.w600,
              color: active ? c.primary : c.textSecondary)),
        ),
      ),
    );
  }
}