import 'user_model.dart';

class ReviewModel {
  final int id;
  final int sellerId;
  final int courierId;
  final int orderId;
  final int rating;
  final String? comment;
  final String createdAt;
  final UserModel? seller;

  ReviewModel({
    required this.id,
    required this.sellerId,
    required this.courierId,
    required this.orderId,
    required this.rating,
    this.comment,
    required this.createdAt,
    this.seller,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: json['id'] ?? 0,
      sellerId: json['seller_id'] ?? 0,
      courierId: json['courier_id'] ?? 0,
      orderId: json['order_id'] ?? 0,
      rating: json['rating'] ?? 5,
      comment: json['comment'],
      createdAt: json['created_at'] ?? '',
      seller: json['seller'] != null ? UserModel.fromJson(json['seller']) : null,
    );
  }
}
