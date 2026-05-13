// lib/core/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = "http://127.0.0.1:8000/api/v1"; // Emülatör IP'si

  static Future<void> saveProfile(String skinType, Map<String, bool> sensitivities) async {
    final response = await http.post(
      Uri.parse('$baseUrl/users/profile'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "skin_type": skinType,
        "sensitivities": sensitivities,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Backend hatası: ${response.statusCode}');
    }
  }
}