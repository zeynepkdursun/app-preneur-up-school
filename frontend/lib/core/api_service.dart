// lib/core/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

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

  final Dio _dio = Dio(BaseOptions(baseUrl: 'http://localhost:8000'));
  final _storage = const FlutterSecureStorage();

  Future<bool> login(String email, String password) async {
    try {
      // Backend OAuth2 formatında veri bekler
      final response = await _dio.post(
        '/api/v1/auth/token',
        data: {
          'username': email, // Backend'de email'i username olarak alıyoruz
          'password': password,
        },
        options: Options(contentType: Headers.formUrlEncodedContentType),
      );

      if (response.statusCode == 200) {
        String token = response.data['access_token'];
        await _storage.write(key: 'jwt_token', value: token); // Token'ı cihazda sakla
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  
}