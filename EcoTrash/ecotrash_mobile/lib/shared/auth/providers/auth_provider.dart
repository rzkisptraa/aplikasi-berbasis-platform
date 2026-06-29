import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../../storage/secure_storage.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  bool _isLoading = false;
  Map<String, dynamic>? _user;

  bool get isLoading => _isLoading;
  Map<String, dynamic>? get user => _user;

  Future<String> login({
    required String email,
    required String password,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      final response = await _authService.login(
        email: email,
        password: password,
      );

      final token = response['token'];
      final role = response['user']['role'];
      _user = response['user'];

      await SecureStorage.saveToken(token);
      await SecureStorage.saveRole(role);
      
      notifyListeners();
      return role;
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      final response = await _authService.register(
        name: name,
        email: email,
        phone: phone,
        password: password,
        passwordConfirmation: passwordConfirmation,
      );

      final token = response['token'];
      final role = response['user']['role'];
      _user = response['user'];

      await SecureStorage.saveToken(token);
      await SecureStorage.saveRole(role);
      
      notifyListeners();
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchProfile() async {
    try {
      final response = await _authService.getProfile();
      _user = response['data'];
      notifyListeners();
    } catch (e) {
      // If unauthorized (invalid/expired token), clear session
      if (e.toString().contains('Unauthorized') || e.toString().contains('401')) {
        await logout();
      }
      rethrow;
    }
  }

  Future<void> updateProfile({
    required String name,
    required String email,
    required String phone,
    List<int>? photoBytes,
    String? photoName,
    String? vehicleType,
    String? vehiclePlate,
    String? address,
    String? city,
    String? province,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      final response = await _authService.updateProfile(
        name: name,
        email: email,
        phone: phone,
        photoBytes: photoBytes,
        photoName: photoName,
        vehicleType: vehicleType,
        vehiclePlate: vehiclePlate,
        address: address,
        city: city,
        province: province,
      );
      
      _user = response['data'];
      notifyListeners();
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String newPasswordConfirmation,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _authService.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
        newPasswordConfirmation: newPasswordConfirmation,
      );
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    try {
      _isLoading = true;
      notifyListeners();
      // Optional: Call logout endpoint in backend
      // await DioClient().dio.post('/logout');
    } catch (_) {
    } finally {
      _user = null;
      await SecureStorage.clearSession();
      _isLoading = false;
      notifyListeners();
    }
  }
}
