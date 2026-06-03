// lib/core/api_service.dart
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'auth_manager.dart';
import '../models/analysis_model.dart';

String _resolveBaseUrl() {
  if (kIsWeb) return 'http://127.0.0.1:8000/api/v1';
  switch (defaultTargetPlatform) {
    case TargetPlatform.android:
      return 'http://10.0.2.2:8000/api/v1';
    default:
      return 'http://127.0.0.1:8000/api/v1';
  }
}

abstract class IApiService {
  Future<SkinLensAnalysisOutput> analyzeIngredients(IngredientAnalysisRequest request);
  Future<bool> saveProfile(String skinType, Map<String, bool> sensitivities);
  Future<bool> login(String email, String password);
}

class ApiService implements IApiService {
  final Dio _dio;

  ApiService({Dio? dio}) : _dio = dio ?? Dio(BaseOptions(baseUrl: _resolveBaseUrl(),
    connectTimeout: const Duration(seconds: 10),
  receiveTimeout: const Duration(seconds: 10),
  headers: {
    "Content-Type": "application/json",
    "Accept": "application/json",
  },
  )) 
  {
    if (kDebugMode) {
      print('API baseUrl: ${_dio.options.baseUrl}');
      _dio.interceptors.add(LogInterceptor(
        request: true,
        requestHeader: true,
        requestBody: true,
        responseHeader: false,
        responseBody: true,
        error: true,
      ));
    }

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          try {
            final token = await AuthManager.getToken();
            if (token != null) {
              options.headers["Authorization"] = "Bearer $token";
            }
          } catch (e) {
            if (kDebugMode) print('Token okuma hatası: $e');
          }
          return handler.next(options);
        },
      ),
    );
  }

  Map<String, dynamic> _parseResponseData(dynamic raw) {
    if (raw is Map<String, dynamic>) return raw;
    if (raw is Map) return Map<String, dynamic>.from(raw);
    if (raw is String && raw.isNotEmpty) {
      return Map<String, dynamic>.from(jsonDecode(raw) as Map);
    }
    return {};
  }

  @override
  Future<SkinLensAnalysisOutput> analyzeIngredients(IngredientAnalysisRequest request) async {
    try {
      final response = await _dio.post(
        '/ingredient/analyze',
        data: request.toJson(),
      );

      if (response.statusCode == 200) {
        final json = _parseResponseData(response.data);
        if (kDebugMode) {
          print('Analyze response: $json');
        }
        return SkinLensAnalysisOutput.fromJson(json);
      } else {
        throw Exception("Backend Hata Kodu: ${response.statusCode}");
      }
    } on DioException catch (e) {
      // Dio'nun kendi ürettiği detaylı hatayı terminale basalım nerede koptuğunu görelim
      print("DIO ERROR: ${e.type} -> ${e.message}");
      throw Exception("Backend Bağlantı Hatası: ${e.message}");
    }
  }

  @override
  Future<bool> saveProfile(String skinType, Map<String, bool> sensitivities) async {
    try {
      final List<String> activeSensitivities = sensitivities.entries
          .where((e) => e.value == true)
          .map((e) => e.key)
          .toList();

      final response = await _dio.put(
        '/users/profile',
        data: {
          "skin_type": skinType,
          "sensitivities": activeSensitivities,
          "goals": {}
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      print("Profil güncelleme hatası: $e");
      return false;
    }
  }

  @override
  Future<bool> login(String email, String password) async {
    try {
      final response = await _dio.post(
        '/auth/token',
        data: {
          'username': email,
          'password': password,
        },
        options: Options(contentType: Headers.formUrlEncodedContentType),
      );

      if (response.statusCode == 200) {
        String token = response.data['access_token'];
        await AuthManager.saveToken(token); 
        return true;
      }
      return false;
    } catch (e) {
      print("Giriş hatası (${_dio.options.baseUrl}/auth/token): $e");
      return false;
    }
  }
}