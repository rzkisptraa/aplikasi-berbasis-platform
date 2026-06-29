class WalletTransactionModel {
  final int id;
  final int walletId;
  final String type; // DEBIT, CREDIT
  final double amount;
  final String description;
  final String status; // PENDING, SUCCESS, FAILED
  final String createdAt;

  WalletTransactionModel({
    required this.id,
    required this.walletId,
    required this.type,
    required this.amount,
    required this.description,
    required this.status,
    required this.createdAt,
  });

  factory WalletTransactionModel.fromJson(Map<String, dynamic> json) {
    return WalletTransactionModel(
      id: json['id'] ?? 0,
      walletId: json['wallet_id'] ?? 0,
      type: json['type'] ?? 'CREDIT',
      amount: double.tryParse(json['amount']?.toString() ?? '0') ?? 0.0,
      description: json['description'] ?? '',
      status: json['status'] ?? 'SUCCESS',
      createdAt: json['created_at'] ?? '',
    );
  }
}
