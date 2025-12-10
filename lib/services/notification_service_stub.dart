import '../models/notification_model.dart';

/// Stub notification service for web platform
/// Handles push notifications (placeholder implementation)
class NotificationService {
  static final List<NotificationModel> _notifications = [];

  /// Initialize notification service
  Future<void> initialize() async {
    // Firebase not available on web - use mock notifications only
    print('Notification service initialized (web mode - mock only)');
  }

  /// Handle incoming notification
  void _handleNotification(dynamic message) {
    // Not used on web
  }

  /// Get notifications for a user
  Future<List<NotificationModel>> getNotifications({
    required String organizationId,
    String? userId,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));

    // Return dummy notifications if empty
    if (_notifications.isEmpty) {
      return _generateDummyNotifications();
    }

    return _notifications;
  }

  /// Generate dummy notifications
  List<NotificationModel> _generateDummyNotifications() {
    final now = DateTime.now();
    return [
      NotificationModel(
        id: 'notif_1',
        type: NotificationType.busStarted,
        title: 'Bus Started',
        message: 'Bus BUS-001 started its route at ${_formatTime(now.subtract(const Duration(minutes: 30)))}',
        timestamp: now.subtract(const Duration(minutes: 30)),
        read: false,
      ),
      NotificationModel(
        id: 'notif_2',
        type: NotificationType.busNearStudent,
        title: 'Bus Approaching',
        message: 'Bus is 5 minutes away from pickup point',
        timestamp: now.subtract(const Duration(minutes: 15)),
        read: false,
      ),
      NotificationModel(
        id: 'notif_3',
        type: NotificationType.busArrivedSchool,
        title: 'Trip Completed',
        message: 'Your child has safely reached school',
        timestamp: now.subtract(const Duration(hours: 1)),
        read: true,
      ),
    ];
  }

  /// Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      _notifications[index] = _notifications[index].copyWith(read: true);
    }
  }

  /// Format time for display
  String _formatTime(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.hour >= 12 ? 'PM' : 'AM';
    final displayHour = time.hour > 12 ? time.hour - 12 : (time.hour == 0 ? 12 : time.hour);
    return '$displayHour:$minute $period';
  }
}
