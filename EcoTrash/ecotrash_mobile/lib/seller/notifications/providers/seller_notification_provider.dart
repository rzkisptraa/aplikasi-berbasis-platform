import 'package:flutter/material.dart';
import '../../../shared/models/notification_model.dart';
import '../services/seller_notification_service.dart';

class SellerNotificationProvider extends ChangeNotifier {
  final SellerNotificationService _service = SellerNotificationService();
  bool _isLoading = false;
  List<NotificationModel> _notifications = [];
  int _unreadCount = 0;

  bool get isLoading => _isLoading;
  List<NotificationModel> get notifications => _notifications;
  int get unreadCount => _unreadCount;

  Future<void> fetchNotifications() async {
    try {
      _isLoading = true;
      notifyListeners();

      final list = await _service.getNotifications();
      _notifications = list.map((item) => NotificationModel.fromJson(item)).toList();

      _unreadCount = await _service.getUnreadCount();
      notifyListeners();
    } catch (_) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> markAsRead(int id) async {
    try {
      await _service.markAsRead(id);
      
      // Update local state
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

  Future<void> markAllAsRead() async {
    try {
      await _service.markAllAsRead();
      
      // Mark all local as read
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
