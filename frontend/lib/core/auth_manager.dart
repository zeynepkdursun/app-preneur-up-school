import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthManager {
  static const _storage = FlutterSecureStorage();
  static const _tokenKey = 'jwt_token';

  // Token'ı kaydet
  static Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  // Token'ı oku
  static Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  // Çıkış yap (Token'ı sil)
  static Future<void> logout() async {
    await _storage.delete(key: _tokenKey);
    

  }
}