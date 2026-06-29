import 'package:dio/dio.dart';
import '../../../core/network/dio_client.dart';

class SellerWalletService {
  final Dio _dio = DioClient().dio;

  Future<Map<String, dynamic>> getWallet() async {
    try {
      final response = await _dio.get('/wallet');
      return response.data['data'] ?? {};
    } on DioException catch (e) {
      throw Exception(e.message ?? 'Gagal mengambil data dompet');
    }
  }

  Future<Map<String, dynamic>> getWalletSummary() async {
    try {
      final response = await _dio.get('/wallet/summary');
      return response.data['data'] ?? {};
    } on DioException catch (e) {
      throw Exception(e.message ?? 'Gagal mengambil ringkasan dompet');
    }
  }

  Future<List<dynamic>> getTransactions() async {
    try {
      final response = await _dio.get('/wallet/transactions');
      return response.data['data'] ?? [];
    } on DioException catch (e) {
      throw Exception(e.message ?? 'Gagal mengambil riwayat transaksi');
    }
  }

  Future<List<dynamic>> getWithdrawals() async {
    try {
      final response = await _dio.get('/withdrawals');
      return response.data['data'] ?? [];
    } on DioException catch (e) {
      throw Exception(e.message ?? 'Gagal mengambil riwayat penarikan');
    }
  }

  Future<void> requestWithdrawal({
    required String bankName,
    required String accountName,
    required String accountNumber,
    required double amount,
  }) async {
    try {
      await _dio.post(
        '/withdrawals',
        data: {
          'bank_name': bankName,
          'account_name': accountName,
          'account_number': accountNumber,
          'amount': amount,
        },
      );
    } on DioException catch (e) {
      throw Exception(e.message ?? 'Gagal mengajukan penarikan');
    }
  }
}
