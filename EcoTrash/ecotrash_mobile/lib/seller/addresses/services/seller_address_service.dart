import 'package:dio/dio.dart';
import '../../../core/network/dio_client.dart';

class SellerAddressService {
  final Dio _dio = DioClient().dio;

  Future<List<dynamic>> getAddresses() async {
    try {
      final response = await _dio.get('/seller-addresses');
      return response.data['data'];
    } on DioException catch (e) {
      throw Exception(e.message ?? 'Gagal mengambil alamat');
    }
  }

  Future<void> addAddress({
    required String label,
    required String address,
    required double latitude,
    required double longitude,
    required bool isDefault,
  }) async {
    try {
      await _dio.post(
        '/seller-addresses',
        data: {
          'label': label,
          'address': address,
          'latitude': latitude,
          'longitude': longitude,
          'is_default': isDefault,
        },
      );
    } on DioException catch (e) {
      throw Exception(e.message ?? 'Gagal menambah alamat');
    }
  }

  Future<void> deleteAddress(int id) async {
    try {
      await _dio.delete('/seller-addresses/$id');
    } on DioException catch (e) {
      throw Exception(e.message ?? 'Gagal menghapus alamat');
    }
  }

  Future<void> updateAddress({
    required int id,
    required String label,
    required String address,
    required double latitude,
    required double longitude,
    required bool isDefault,
  }) async {
    try {
      await _dio.put(
        '/seller-addresses/$id',
        data: {
          'label': label,
          'address': address,
          'latitude': latitude,
          'longitude': longitude,
          'is_default': isDefault,
        },
      );
    } on DioException catch (e) {
      throw Exception(e.message ?? 'Gagal memperbarui alamat');
    }
  }
}
