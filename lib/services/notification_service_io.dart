import 'package:firebase_messaging/firebase_messaging.dart';
import '../models/notification_model.dart';

/// Notification service for mobile platforms (iOS/Android)
/// Handles push notifications using Firebase
class NotificationService {
  static FirebaseMessaging? _messaging;
  static final List<NotificationModel> _notifications = [];

  /// Initialize notification service
  Future<void> initialize() async {
    try {
      _messaging = FirebaseMessaging.instance;
      
      // Request permission for iOS
      NotificationSettings settings = await _messaging!.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        // Get FCM token (for future use)
        String? token = await _messaging!.getToken();
        print('FCM Token: $token');

        // Listen for foreground messages
        FirebaseMessaging.onMessage.listen((RemoteMessage message) {
          // Handle foreground message
          _handleNotification(message);
        });

        // Handle background messages (would need a top-level function)
        FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
          // Handle notification tap
          _handleNotification(message);
        });
      }
    } catch (e) {
      print('Firebase Messaging initialization error: $e');
      // Continue without Firebase - app will work with mock notifications
    }
  }

  /// Handle incoming notification
  void _handleNotification(RemoteMessage message) {
    final notification = NotificationModel(
      id: message.messageId ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: message.notification?.title ?? 'Notification',
      message: message.notification?.body ?? '',
      timestamp: message.sentTime ?? DateTime.now(),
      organizationId: message.data['organizationId'] ?? '',
      userId: message.data['userId'],
    );
    _notifications.insert(0, notification);
  }

  /// Get notifications for a user
  Future<List<NotificationModel>> getNotifications({
    required String organizationId,
    String? userId,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));

    // Return dummy notifications if empty
    if (_notifications.isEmpty) {
      return _generateDummyNotifications(organizationId, userId);
    }

    return _notifications
        .where((n) =>
            n.organizationId == organizationId &&
            (userId == null || n.userId == userId))
        .toList();
  }

  /// Generate dummy notifications
  List<NotificationModel> _generateDummyNotifications(
    String organizationId,
    String? userId,
  ) {
    final now = DateTime.now();
    return [
      NotificationModel(
        id: 'notif_1',
        title: 'Bus Started',
        message: 'Bus BUS-001 started its route at ${_formatTime(now.subtract(const Duration(minutes: 30)))}',
        timestamp: now.subtract(const Duration(minutes: 30)),
        organizationId: organizationId,
        userId: userId,
      ),
      NotificationModel(
        id: 'notif_2',
        title: 'Bus Approaching',
        message: 'Bus is 5 minutes away from pickup point',
        timestamp: now.subtract(const Duration(minutes: 15)),
        organizationId: organizationId,
        userId: userId,
      ),
      NotificationModel(
        id: 'notif_3',
        title: 'Trip Completed',
        message: 'Your child has safely reached school',
        timestamp: now.subtract(const Duration(hours: 1)),
        organizationId: organizationId,
        userId: userId,
      ),
    ];
  }

  /// Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
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
