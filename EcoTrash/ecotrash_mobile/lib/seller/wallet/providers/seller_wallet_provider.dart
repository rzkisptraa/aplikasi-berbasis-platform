import 'package:flutter/material.dart';
import '../../../shared/models/wallet_model.dart';
import '../../../shared/models/wallet_transaction_model.dart';
import '../../../shared/models/withdrawal_model.dart';
import '../services/seller_wallet_service.dart';

class SellerWalletProvider extends ChangeNotifier {
  final SellerWalletService _service = SellerWalletService();
  bool _isLoading = false;
  WalletModel? _wallet;
  Map<String, dynamic> _summary = {};
  List<WalletTransactionModel> _transactions = [];
  List<WithdrawalModel> _withdrawals = [];

  bool get isLoading => _isLoading;
  WalletModel? get wallet => _wallet;
  Map<String, dynamic> get summary => _summary;
  List<WalletTransactionModel> get transactions => _transactions;
  List<WithdrawalModel> get withdrawals => _withdrawals;

  double get balance => _wallet?.balance ?? 0.0;

  Future<void> fetchWalletData() async {
    try {
      _isLoading = true;
      notifyListeners();

      // Retrieve all wallet assets in parallel
      final walletData = await _service.getWallet();
      _wallet = WalletModel.fromJson(walletData);

      try {
        _summary = await _service.getWalletSummary();
      } catch (_) {}

      final txData = await _service.getTransactions();
      _transactions = txData.map((item) => WalletTransactionModel.fromJson(item)).toList();

      final wdData = await _service.getWithdrawals();
      _withdrawals = wdData.map((item) => WithdrawalModel.fromJson(item)).toList();

      notifyListeners();
    } catch (_) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> requestWithdrawal({
    required String bankName,
    required String accountName,
    required String accountNumber,
    required double amount,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _service.requestWithdrawal(
        bankName: bankName,
        accountName: accountName,
        accountNumber: accountNumber,
        amount: amount,
      );
      
      // Refresh wallet after withdrawal
      await fetchWalletData();
    } catch (_) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
