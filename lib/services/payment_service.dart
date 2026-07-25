import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import 'auth_service.dart';

class PaymentService {
  static Future<Map<String, dynamic>> createRental(
      String stationDeviceId, int durationMinutes) async {
    final token = await AuthService.getToken();
    final res = await http.post(
      Uri.parse('${AppConfig.apiBaseUrl}/rentals'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'stationDeviceId': stationDeviceId,
        'durationMinutes': durationMinutes,
      }),
    );
    final data = jsonDecode(res.body);
    if (res.statusCode != 200 && res.statusCode != 201) {
      throw Exception(data['message'] ?? 'Erreur ${res.statusCode}');
    }
    return data;
  }

  static Future<Map<String, dynamic>> initiatePayment(
      String rentalId, String provider, String phone) async {
    final token = await AuthService.getToken();
    final res = await http.post(
      Uri.parse('${AppConfig.apiBaseUrl}/payments/initiate'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'rentalId': rentalId, 'provider': provider, 'phone': phone}),
    );
    final data = jsonDecode(res.body);
    if (res.statusCode != 200 && res.statusCode != 201) {
      throw Exception(data['message'] ?? 'Erreur ${res.statusCode}');
    }
    return data;
  }

  static Future<Map<String, dynamic>> getPaymentStatus(String paymentId) async {
    final token = await AuthService.getToken();
    final res = await http.get(
      Uri.parse('${AppConfig.apiBaseUrl}/payments/$paymentId/status'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (res.statusCode != 200) throw Exception('Erreur ${res.statusCode}');
    return jsonDecode(res.body);
  }

  static Future<Map<String, dynamic>> getRental(String id) async {
    final token = await AuthService.getToken();
    final res = await http.get(
      Uri.parse('${AppConfig.apiBaseUrl}/rentals/$id'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (res.statusCode != 200) throw Exception('Erreur ${res.statusCode}');
    return jsonDecode(res.body);
  }
}