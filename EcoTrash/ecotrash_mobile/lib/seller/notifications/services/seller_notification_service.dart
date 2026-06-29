import 'package:dio/dio.dart';
import '../../../core/network/dio_client.dart';

class SellerNotificationService {
  final Dio _dio = DioClient().dio;

  Future<List<dynamic>> getNotifications() async {
    try {
      final response = await _dio.get('/notifications');
      return response.data['data'] ?? [];
    } on DioException catch (e) {
      throw Exception(e.message ?? 'Gagal mengambil notifikasi');
    }
  }

  Future<void> markAsRead(int id) async {
    try {
      await _dio.patch('/notifications/$id/read');
    } on DioException catch (e) {
      throw Exception(e.message ?? 'Gagal memperbarui notifikasi');
    }
  }

  Future<void> markAllAsRead() async {
    try {
      await _dio.patch('/notifications/read-all');
    } on DioException catch (e) {
      throw Exception(e.message ?? 'Gagal memperbarui semua notifikasi');
    }
  }

  Future<int> getUnreadCount() async {
    try {
      final response = await _dio.get('/notifications/unread-count');
      return response.data['data']['unread_count'] ?? 0;
    } on DioException catch (e) {
      throw Exception(e.message ?? 'Gagal mengambil jumlah notifikasi baru');
    }
  }
}
