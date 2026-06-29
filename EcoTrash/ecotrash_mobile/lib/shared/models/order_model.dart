import '../../seller/addresses/models/seller_address_model.dart';
import 'user_model.dart';
import 'waste_category_model.dart';

class OrderModel {
  final int id;
  final String orderCode;
  final int sellerId;
  final int? courierId;
  final int sellerAddressId;
  final String status; // PENDING, ACCEPTED, PICKED_UP, DELIVERED, COMPLETED, CANCELLED
  final String? pickupPhoto;
  final double estimatedTotalWeight;
  final double? actualTotalWeight;
  final double estimatedTotalPrice;
  final double totalPrice;
  final String? pickupNotes;
  final String? cancelReason;
  final double latitude;
  final double longitude;
  final String? pickedUpAt;
  final String? deliveredAt;
  final String? completedAt;
  final String? cancelledAt;
  final String? vehicleType;
  final String createdAt;
  final List<OrderItemModel> items;
  final SellerAddressModel? sellerAddress;
  final UserModel? seller;
  final UserModel? courier;

  OrderModel({
    required this.id,
    required this.orderCode,
    required this.sellerId,
    this.courierId,
    required this.sellerAddressId,
    required this.status,
    this.pickupPhoto,
    required this.estimatedTotalWeight,
    this.actualTotalWeight,
    required this.estimatedTotalPrice,
    required this.totalPrice,
    this.pickupNotes,
    this.cancelReason,
    required this.latitude,
    required this.longitude,
    this.pickedUpAt,
    this.deliveredAt,
    this.completedAt,
    this.cancelledAt,
    this.vehicleType,
    required this.createdAt,
    required this.items,
    this.sellerAddress,
    this.seller,
    this.courier,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    var itemsList = json['items'] as List? ?? [];
    List<OrderItemModel> parsedItems = itemsList.map((i) => OrderItemModel.fromJson(i)).toList();

    return OrderModel(
      id: json['id'] ?? 0,
      orderCode: json['order_code'] ?? '',
      sellerId: json['seller_id'] ?? 0,
      courierId: json['courier_id'],
      sellerAddressId: json['seller_address_id'] ?? 0,
      status: json['status'] ?? 'PENDING',
      pickupPhoto: json['pickup_photo'],
      estimatedTotalWeight: double.tryParse(json['estimated_total_weight']?.toString() ?? '0') ?? 0.0,
      actualTotalWeight: double.tryParse(json['actual_total_weight']?.toString() ?? ''),
      estimatedTotalPrice: double.tryParse(json['estimated_total_price']?.toString() ?? '0') ?? 0.0,
      totalPrice: double.tryParse(json['total_price']?.toString() ?? '0') ?? 0.0,
      pickupNotes: json['pickup_notes'],
      cancelReason: json['cancel_reason'],
      latitude: double.tryParse(json['latitude']?.toString() ?? '0') ?? 0.0,
      longitude: double.tryParse(json['longitude']?.toString() ?? '0') ?? 0.0,
      pickedUpAt: json['picked_up_at'],
      deliveredAt: json['delivered_at'],
      completedAt: json['completed_at'],
      cancelledAt: json['cancelled_at'],
      vehicleType: json['vehicle_type'],
      createdAt: json['created_at'] ?? '',
      items: parsedItems,
      sellerAddress: json['seller_address'] != null
          ? SellerAddressModel.fromJson(json['seller_address'])
          : null,
      seller: json['seller'] != null ? UserModel.fromJson(json['seller']) : null,
      courier: json['courier'] != null ? UserModel.fromJson(json['courier']) : null,
    );
  }
}

class OrderItemModel {
  final int id;
  final int orderId;
  final int wasteCategoryId;
  final double estimatedWeight;
  final double? actualWeight;
  final double pricePerKg;
  final double subtotal;
  final WasteCategoryModel? wasteCategory;

  OrderItemModel({
    required this.id,
    required this.orderId,
    required this.wasteCategoryId,
    required this.estimatedWeight,
    this.actualWeight,
    required this.pricePerKg,
    required this.subtotal,
    this.wasteCategory,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      id: json['id'] ?? 0,
      orderId: json['order_id'] ?? 0,
      wasteCategoryId: json['waste_category_id'] ?? 0,
      estimatedWeight: double.tryParse(json['estimated_weight']?.toString() ?? '0') ?? 0.0,
      actualWeight: double.tryParse(json['actual_weight']?.toString() ?? ''),
      pricePerKg: double.tryParse(json['price_per_kg']?.toString() ?? '0') ?? 0.0,
      subtotal: double.tryParse(json['subtotal']?.toString() ?? '0') ?? 0.0,
      wasteCategory: json['waste_category'] != null
          ? WasteCategoryModel.fromJson(json['waste_category'])
          : null,
    );
  }
}
