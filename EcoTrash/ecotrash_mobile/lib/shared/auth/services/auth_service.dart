import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import '../../../core/network/dio_client.dart';

class AuthService {
  final Dio _dio = DioClient().dio;

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        '/login',
        data: {'email': email, 'password': password},
      );
      return response.data;
    } on DioException catch (e) {
      throw Exception(e.message ?? 'Login gagal');
    }
  }

  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      final response = await _dio.post(
        '/register',
        data: {
          'name': name,
          'email': email,
          'phone': phone,
          'password': password,
          'password_confirmation': passwordConfirmation,
        },
      );
      return response.data;
    } on DioException catch (e) {
      throw Exception(e.message ?? 'Registrasi gagal');
    }
  }

  Future<Map<String, dynamic>> getProfile() async {
    try {
      final response = await _dio.get('/profile');
      return response.data;
    } on DioException catch (e) {
      throw Exception(e.message ?? 'Gagal mengambil data profil');
    }
  }

  Future<Map<String, dynamic>> changePassword({
    required String currentPassword,
    required String newPassword,
    required String newPasswordConfirmation,
  }) async {
    try {
      final response = await _dio.patch(
        '/profile/password',
        data: {
          'current_password': currentPassword,
          'new_password': newPassword,
          'new_password_confirmation': newPasswordConfirmation,
        },
      );
      return response.data;
    } on DioException catch (e) {
      throw Exception(e.message ?? 'Gagal mengubah password');
    }
  }

  Future<Map<String, dynamic>> updateProfile({
    required String name,
    required String email,
    required String phone,
    List<int>? photoBytes,
    String? photoName,
    // courier details optional
    String? vehicleType,
    String? vehiclePlate,
    String? address,
    String? city,
    String? province,
  }) async {
    try {
      final Map<String, dynamic> fields = {
        'name': name,
        'email': email,
        'phone': phone,
      };
      if (vehicleType != null) fields['vehicle_type'] = vehicleType;
      if (vehiclePlate != null) fields['vehicle_plate'] = vehiclePlate;
      if (address != null) fields['address'] = address;
      if (city != null) fields['city'] = city;
      if (province != null) fields['province'] = province;

      Response response;
      if (photoBytes != null && photoName != null) {
        String mimeType = 'image/jpeg';
        final nameLower = photoName.toLowerCase();
        if (nameLower.endsWith('.png')) {
          mimeType = 'image/png';
        } else if (nameLower.endsWith('.webp')) {
          mimeType = 'image/webp';
        } else if (nameLower.endsWith('.gif')) {
          mimeType = 'image/gif';
        }

        final formDataMap = Map<String, dynamic>.from(fields);
        formDataMap['profile_photo'] = MultipartFile.fromBytes(
          photoBytes,
          filename: photoName,
          contentType: MediaType.parse(mimeType),
        );
        formDataMap['_method'] = 'PATCH'; // backup for method spoofing

        final formData = FormData.fromMap(formDataMap);

        response = await _dio.post(
          '/profile',
          data: formData,
        );
      } else {
        response = await _dio.patch(
          '/profile',
          data: fields,
        );
      }
      return response.data;
    } on DioException catch (e) {
      throw Exception(e.message ?? 'Gagal memperbarui profil');
    }
  }
}
