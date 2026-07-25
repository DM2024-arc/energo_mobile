import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import 'auth_service.dart';

class RentalService {
  static Future<List<Map<String, dynamic>>> getMyRentals() async {
    final token = await AuthService.getToken();
    final res = await http.get(
      Uri.parse('${AppConfig.apiBaseUrl}/users/me/rentals'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (res.statusCode != 200) throw Exception('Erreur ${res.statusCode}');
    final data = jsonDecode(res.body);
    return data is List ? data.cast<Map<String, dynamic>>() : [];
  }
}