import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_config.dart';

class AuthService {
  static Future<Map<String, dynamic>> login(String phone, String password) async {
    final res = await http.post(
      Uri.parse('${AppConfig.apiBaseUrl}/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'phone': phone, 'password': password}),
    );

    final data = jsonDecode(res.body);
    if (res.statusCode != 200 && res.statusCode != 201) {
      throw Exception(data['message'] ?? 'Erreur ${res.statusCode}');
    }

    await _saveTokens(data['accessToken'], data['refreshToken']);
    return data;
  }

  static Future<Map<String, dynamic>> register(
      String fullName, String phone, String password) async {
    final res = await http.post(
      Uri.parse('${AppConfig.apiBaseUrl}/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'phone': phone,
        'fullName': fullName,
        'password': password,
      }),
    );

    final data = jsonDecode(res.body);
    if (res.statusCode != 200 && res.statusCode != 201) {
      if (res.statusCode == 409) {
        throw Exception('Un compte existe déjà avec ce numéro');
      }
      throw Exception(data['message'] ?? 'Erreur ${res.statusCode}');
    }

    await _saveTokens(data['accessToken'], data['refreshToken']);
    return data;
  }

  static Future<Map<String, dynamic>> getMe() async {
    final token = await getToken();
    final res = await http.get(
      Uri.parse('${AppConfig.apiBaseUrl}/users/me'),
      headers: {'Authorization': 'Bearer $token'},
    );

    final data = jsonDecode(res.body);
    if (res.statusCode != 200) {
      throw Exception(data['message'] ?? 'Erreur ${res.statusCode}');
    }
    return data;
  }

  static Future<void> _saveTokens(String? access, String? refresh) async {
    final prefs = await SharedPreferences.getInstance();
    if (access != null) await prefs.setString('access_token', access);
    if (refresh != null) await prefs.setString('refresh_token', refresh);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token');
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    await prefs.remove('refresh_token');
  }
}