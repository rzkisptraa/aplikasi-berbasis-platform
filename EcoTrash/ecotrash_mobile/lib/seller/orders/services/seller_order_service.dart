import 'package:dio/dio.dart';
import '../../../core/network/dio_client.dart';

class SellerOrderService {
  final Dio _dio = DioClient().dio;

  Future<List<dynamic>> getWasteCategories() async {
    try {
      final response = await _dio.get('/waste-categories');
      return response.data['data'] ?? [];
    } on DioException catch (e) {
      throw Exception(e.message ?? 'Gagal mengambil kategori sampah');
    }
  }

  Future<List<dynamic>> getMyOrders() async {
    try {
      final response = await _dio.get('/orders');
      return response.data['data'] ?? [];
    } on DioException catch (e) {
      throw Exception(e.message ?? 'Gagal mengambil daftar pesanan');
    }
  }

  Future<Map<String, dynamic>> createOrder({
    required int addressId,
    required String notes,
    required double latitude,
    required double longitude,
    required List<Map<String, dynamic>> items,
    required String vehicleType,
  }) async {
    try {
      final response = await _dio.post(
        '/orders',
        data: {
          'seller_address_id': addressId,
          'pickup_notes': notes,
          'latitude': latitude,
          'longitude': longitude,
          'items': items,
          'vehicle_type': vehicleType,
        },
      );
      return response.data;
    } on DioException catch (e) {
      throw Exception(e.message ?? 'Gagal membuat pesanan');
    }
  }

  Future<void> cancelOrder({
    required int orderId,
    required String reason,
  }) async {
    try {
      await _dio.patch(
        '/orders/$orderId/cancel',
        data: {'cancel_reason': reason},
      );
    } on DioException catch (e) {
      throw Exception(e.message ?? 'Gagal membatalkan pesanan');
    }
  }

  Future<void> submitReview({
    required int orderId,
    required int courierId,
    required int rating,
    required String comment,
  }) async {
    try {
      await _dio.post(
        '/reviews',
        data: {
          'order_id': orderId,
          'courier_id': courierId,
          'rating': rating,
          'comment': comment,
        },
      );
    } on DioException catch (e) {
      throw Exception(e.message ?? 'Gagal mengirim ulasan');
    }
  }
}
