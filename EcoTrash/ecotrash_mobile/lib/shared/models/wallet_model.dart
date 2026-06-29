class WalletModel {
  final int id;
  final int userId;
  final double balance;

  WalletModel({
    required this.id,
    required this.userId,
    required this.balance,
  });

  factory WalletModel.fromJson(Map<String, dynamic> json) {
    return WalletModel(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      balance: double.tryParse(json['balance']?.toString() ?? '0') ?? 0.0,
    );
  }
}
