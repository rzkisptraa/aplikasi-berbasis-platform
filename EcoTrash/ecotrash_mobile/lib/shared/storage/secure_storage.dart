import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  static const FlutterSecureStorage _storage =
      FlutterSecureStorage();

  static const String tokenKey = 'auth_token';
  static const String roleKey = 'user_role';

  static Future<void> saveToken(
    String token,
  ) async {
    await _storage.write(
      key: tokenKey,
      value: token,
    );
  }

  static Future<String?> getToken() async {
    return await _storage.read(
      key: tokenKey,
    );
  }

  static Future<void> saveRole(
    String role,
  ) async {
    await _storage.write(
      key: roleKey,
      value: role,
    );
  }

  static Future<String?> getRole() async {
    return await _storage.read(
      key: roleKey,
    );
  }

  static Future<void> clearSession() async {
    await _storage.deleteAll();
  }
}