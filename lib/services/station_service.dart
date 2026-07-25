import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import 'auth_service.dart';

class StationService {
  static Future<List<Map<String, dynamic>>> getNearby({
    required double lat,
    required double lng,
    int radius = 50000, // miroir de NEARBY_RADIUS_M (dev) dans config.js
  }) async {
    final token = await AuthService.getToken();
    final res = await http.get(
      Uri.parse('${AppConfig.apiBaseUrl}/stations/nearby?lat=$lat&lng=$lng&radius=$radius'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (res.statusCode != 200) {
      throw Exception('Erreur ${res.statusCode}');
    }

    final data = jsonDecode(res.body);
    if (data is List) {
      return data.cast<Map<String, dynamic>>();
    }
    return [];
  }
}