import 'package:flutter/material.dart';
import '../../../shared/models/order_model.dart';
import '../../../shared/models/review_model.dart';
import '../../../shared/models/notification_model.dart';
import '../services/courier_order_service.dart';

class CourierOrderProvider extends ChangeNotifier {
  final CourierOrderService _service = CourierOrderService();
  bool _isLoading = false;
  List<OrderModel> _availableJobs = [];
  List<OrderModel> _myJobs = [];
  List<ReviewModel> _reviews = [];
  List<NotificationModel> _notifications = [];
  int _unreadCount = 0;

  bool get isLoading => _isLoading;
  List<OrderModel> get availableJobs => _availableJobs;
  List<OrderModel> get myJobs => _myJobs;
  List<ReviewModel> get reviews => _reviews;
  List<NotificationModel> get notifications => _notifications;
  int get unreadCount => _unreadCount;

  // Courier's current active accepted order (ACCEPTED, PICKED_UP, DELIVERED)
  OrderModel? get activeJob {
    final list = _myJobs.where((o) => o.status == 'ACCEPTED' || o.status == 'PICKED_UP' || o.status == 'DELIVERED');
    return list.isNotEmpty ? list.first : null;
  }

  // Courier's completed job history
  List<OrderModel> get completedJobs => _myJobs.where((o) => o.status == 'COMPLETED').toList();

  Future<void> toggleOnlineStatus() async {
    try {
      await _service.toggleOnline();
    } catch (_) {
      rethrow;
    }
  }

  Future<void> updateLiveLocation(double lat, double lng) async {
    try {
      await _service.updateLocation(latitude: lat, longitude: lng);
    } catch (_) {}
  }

  Future<void> fetchAvailableJobs() async {
    try {
      _isLoading = true;
      notifyListeners();

      final list = await _service.getAvailableOrders();
      _availableJobs = list.map((item) => OrderModel.fromJson(item)).toList();
      notifyListeners();
    } catch (_) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchMyCourierJobs() async {
    try {
      _isLoading = true;
      notifyListeners();

      final list = await _service.getMyCourierOrders();
      _myJobs = list.map((item) => OrderModel.fromJson(item)).toList();
      notifyListeners();
    } catch (_) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> acceptJob(int orderId) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _service.acceptOrder(orderId);
      await fetchMyCourierJobs();
      await fetchAvailableJobs();
    } catch (_) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> pickupJob(int orderId, List<int> fileBytes, String fileName) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _service.pickupOrder(orderId: orderId, fileBytes: fileBytes, fileName: fileName);
      await fetchMyCourierJobs();
    } catch (_) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deliverJob(int orderId) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _service.deliverOrder(orderId);
      await fetchMyCourierJobs();
    } catch (_) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> completeJob(int orderId, List<Map<String, dynamic>> items) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _service.completeOrder(orderId: orderId, items: items);
      await fetchMyCourierJobs();
    } catch (_) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchReviews() async {
    try {
      final list = await _service.getReceivedReviews();
      _reviews = list.map((item) => ReviewModel.fromJson(item)).toList();
      notifyListeners();
    } catch (_) {
      rethrow;
    }
  }

  Future<void> fetchNotifications() async {
    try {
      final list = await _service.getNotifications();
      _notifications = list.map((item) => NotificationModel.fromJson(item)).toList();
      _unreadCount = await _service.getUnreadCount();
      notifyListeners();
    } catch (_) {}
  }

  Future<void> markNotificationAsRead(int id) async {
    try {
      await _service.markAsRead(id);
      final index = _notifications.indexWhere((n) => n.id == id);
      if (index != -1) {
        final current = _notifications[index];
        _notifications[index] = NotificationModel(
          id: current.id,
          userId: current.userId,
          title: current.title,
          message: current.message,
          type: current.type,
          data: current.data,
          isRead: true,
          createdAt: current.createdAt,
        );
      }
      _unreadCount = await _service.getUnreadCount();
      notifyListeners();
    } catch (_) {}
  }

  Future<void> markAllNotificationsAsRead() async {
    try {
      await _service.markAllAsRead();
      _notifications = _notifications.map((n) {
        return NotificationModel(
          id: n.id,
          userId: n.userId,
          title: n.title,
          message: n.message,
          type: n.type,
          data: n.data,
          isRead: true,
          createdAt: n.createdAt,
        );
      }).toList();
      _unreadCount = 0;
      notifyListeners();
    } catch (_) {}
  }
}
