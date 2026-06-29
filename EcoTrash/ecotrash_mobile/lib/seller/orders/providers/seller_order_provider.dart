import 'package:flutter/material.dart';
import '../../../shared/models/order_model.dart';
import '../../../shared/models/waste_category_model.dart';
import '../services/seller_order_service.dart';

class SellerOrderProvider extends ChangeNotifier {
  final SellerOrderService _service = SellerOrderService();
  bool _isLoading = false;
  List<WasteCategoryModel> _categories = [];
  List<OrderModel> _orders = [];

  bool get isLoading => _isLoading;
  List<WasteCategoryModel> get categories => _categories;
  List<OrderModel> get orders => _orders;

  // Active orders (PENDING, ACCEPTED, PICKED_UP, DELIVERED)
  List<OrderModel> get activeOrders => _orders
      .where((o) => o.status == 'PENDING' || o.status == 'ACCEPTED' || o.status == 'PICKED_UP' || o.status == 'DELIVERED')
      .toList();

  // Completed or Cancelled orders
  List<OrderModel> get historyOrders => _orders
      .where((o) => o.status == 'COMPLETED' || o.status == 'CANCELLED')
      .toList();

  Future<void> fetchCategories() async {
    try {
      final data = await _service.getWasteCategories();
      _categories = data.map((item) => WasteCategoryModel.fromJson(item)).toList();
      notifyListeners();
    } catch (_) {
      rethrow;
    }
  }

  Future<void> fetchOrders() async {
    try {
      _isLoading = true;
      notifyListeners();

      final data = await _service.getMyOrders();
      _orders = data.map((item) => OrderModel.fromJson(item)).toList();
      notifyListeners();
    } catch (_) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createOrder({
    required int addressId,
    required String notes,
    required double latitude,
    required double longitude,
    required List<Map<String, dynamic>> items,
    required String vehicleType,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _service.createOrder(
        addressId: addressId,
        notes: notes,
        latitude: latitude,
        longitude: longitude,
        items: items,
        vehicleType: vehicleType,
      );
      await fetchOrders();
    } catch (_) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> cancelOrder(int orderId, String reason) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _service.cancelOrder(orderId: orderId, reason: reason);
      await fetchOrders();
    } catch (_) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> submitReview({
    required int orderId,
    required int courierId,
    required int rating,
    required String comment,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _service.submitReview(
        orderId: orderId,
        courierId: courierId,
        rating: rating,
        comment: comment,
      );
      await fetchOrders();
    } catch (_) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
