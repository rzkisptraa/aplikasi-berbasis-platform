class WithdrawalModel {
  final int id;
  final int userId;
  final String bankName;
  final String accountName;
  final String accountNumber;
  final double amount;
  final String status; // PENDING, APPROVED, REJECTED, PAID
  final String? adminNotes;
  final String? processedAt;
  final String createdAt;

  WithdrawalModel({
    required this.id,
    required this.userId,
    required this.bankName,
    required this.accountName,
    required this.accountNumber,
    required this.amount,
    required this.status,
    this.adminNotes,
    this.processedAt,
    required this.createdAt,
  });

  factory WithdrawalModel.fromJson(Map<String, dynamic> json) {
    return WithdrawalModel(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      bankName: json['bank_name'] ?? '',
      accountName: json['account_name'] ?? '',
      accountNumber: json['account_number'] ?? '',
      amount: double.tryParse(json['amount']?.toString() ?? '0') ?? 0.0,
      status: json['status'] ?? 'PENDING',
      adminNotes: json['admin_notes'],
      processedAt: json['processed_at'],
      createdAt: json['created_at'] ?? '',
    );
  }
}
