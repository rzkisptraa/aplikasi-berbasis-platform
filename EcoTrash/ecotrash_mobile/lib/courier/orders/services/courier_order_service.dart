import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import '../../../core/network/dio_client.dart';

class CourierOrderService {
  final Dio _dio = DioClient().dio;

  Future<void> toggleOnline() async {
    try {
      await _dio.patch('/courier/toggle-online');
    } on DioException catch (e) {
      throw Exception(e.message ?? 'Gagal memperbarui status online');
    }
  }

  Future<void> updateLocation({
    required double latitude,
    required double longitude,
  }) async {
    try {
      await _dio.patch(
        '/courier/location',
        data: {
          'current_latitude': latitude,
          'current_longitude': longitude,
        },
      );
    } on DioException catch (e) {
      throw Exception(e.message ?? 'Gagal memperbarui koordinat lokasi');
    }
  }

  Future<List<dynamic>> getAvailableOrders() async {
    try {
      final response = await _dio.get('/courier/orders/available');
      return response.data['data'] ?? [];
    } on DioException catch (e) {
      throw Exception(e.message ?? 'Gagal mengambil lowongan tugas');
    }
  }

  Future<List<dynamic>> getMyCourierOrders() async {
    try {
      // Using optimized index filters
      final response = await _dio.get('/orders');
      return response.data['data'] ?? [];
    } on DioException catch (e) {
      throw Exception(e.message ?? 'Gagal mengambil tugas kurir');
    }
  }

  Future<Map<String, dynamic>> acceptOrder(int orderId) async {
    try {
      final response = await _dio.patch('/orders/$orderId/accept');
      return response.data;
    } on DioException catch (e) {
      throw Exception(e.message ?? 'Gagal menerima pesanan');
    }
  }

  Future<void> pickupOrder({
    required int orderId,
    required List<int> fileBytes,
    required String fileName,
  }) async {
    try {
      String mimeType = 'image/jpeg';
      final nameLower = fileName.toLowerCase();
      if (nameLower.endsWith('.png')) {
        mimeType = 'image/png';
      } else if (nameLower.endsWith('.webp')) {
        mimeType = 'image/webp';
      } else if (nameLower.endsWith('.gif')) {
        mimeType = 'image/gif';
      }

      FormData formData = FormData.fromMap({
        'pickup_photo': MultipartFile.fromBytes(
          fileBytes,
          filename: fileName,
          contentType: MediaType.parse(mimeType),
        ),
      });

      await _dio.post(
        '/orders/$orderId/pickup',
        data: formData,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
          },
        ),
      );
    } on DioException catch (e) {
      throw Exception(e.message ?? 'Gagal memproses pengambilan');
    }
  }

  Future<void> deliverOrder(int orderId) async {
    try {
      await _dio.patch('/orders/$orderId/deliver');
    } on DioException catch (e) {
      throw Exception(e.message ?? 'Gagal memproses pengiriman');
    }
  }

  Future<void> completeOrder({
    required int orderId,
    required List<Map<String, dynamic>> items,
  }) async {
    try {
      await _dio.patch(
        '/orders/$orderId/complete',
        data: {
          'items': items,
        },
      );
    } on DioException catch (e) {
      throw Exception(e.message ?? 'Gagal menyelesaikan pesanan');
    }
  }

  Future<List<dynamic>> getReceivedReviews() async {
    try {
      final response = await _dio.get('/reviews/my-received');
      return response.data['data'] ?? [];
    } on DioException catch (e) {
      throw Exception(e.message ?? 'Gagal mengambil ulasan kurir');
    }
  }

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
