import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../shared/storage/secure_storage.dart';

class DioClient {
  static final DioClient _instance = DioClient._internal();
  late final Dio dio;
  String _currentBaseUrl = kIsWeb ? 'http://127.0.0.1:8000/api' : 'http://10.0.2.2:8000/api'; // Fallback default for android emulator / web

  factory DioClient() {
    return _instance;
  }

  DioClient._internal() {
    dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ),
    );

    // Initial load from storage
    _loadBaseUrl();

    // Adding interceptors
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Dynamically adjust baseUrl
          options.baseUrl = _currentBaseUrl;

          // Fetch token from SecureStorage
          final token = await SecureStorage.getToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          
          return handler.next(options);
        },
        onError: (DioException e, handler) {
          // Standardized dynamic error extraction
          String errorMessage = 'Terjadi kesalahan pada jaringan';
          if (e.response != null && e.response?.data != null) {
            final data = e.response?.data;
            if (data is Map) {
              errorMessage = data['message'] ?? data['error'] ?? errorMessage;
            }
          } else if (e.type == DioExceptionType.connectionTimeout) {
            errorMessage = 'Koneksi ke server timeout';
          } else if (e.type == DioExceptionType.receiveTimeout) {
            errorMessage = 'Respon dari server timeout';
          }
          
          // Re-wrap error message into customized DioException message
          final customError = DioException(
            requestOptions: e.requestOptions,
            response: e.response,
            type: e.type,
            error: errorMessage,
            message: errorMessage,
          );
          
          return handler.next(customError);
        },
      ),
    );
  }

  String get baseUrl => _currentBaseUrl;

  Future<void> _loadBaseUrl() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      var savedUrl = prefs.getString('api_base_url');
      if (kIsWeb) {
        if (savedUrl == null || savedUrl.contains('10.0.2.2')) {
          savedUrl = 'http://127.0.0.1:8000/api';
        }
      }
      if (savedUrl != null && savedUrl.isNotEmpty) {
        _currentBaseUrl = savedUrl;
      }
    } catch (_) {}
  }

  Future<void> updateBaseUrl(String newUrl) async {
    if (newUrl.isEmpty) return;
    _currentBaseUrl = newUrl;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('api_base_url', newUrl);
    } catch (_) {}
  }
}
