import 'dart:async';
import 'dart:convert';
import '../core/api/api_client.dart';
import '../models/notification_model.dart';
import 'api_client_service.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

/// Real API-based notification service with SSE support
class ApiNotificationService {
  final ApiClient _apiClient;
  StreamController<NotificationModel>? _notificationStream;
  StreamSubscription<String>? _sseSubscription;

  ApiNotificationService({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClientService.instance;

  /// Get notifications
  /// Note: Backend returns notifications directly or wrapped in a response
  Future<List<NotificationModel>> getNotifications({
    bool unreadOnly = false,
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final response = await _apiClient.get(
        '/notifications',
        queryParams: {
          if (unreadOnly) 'unread_only': 'true',
          'limit': limit.toString(),
          'offset': offset.toString(),
        },
      );

      // Handle new response format: { success: true, data: [...], message: "..." }
      if (response is Map<String, dynamic> && response.containsKey('data')) {
        final data = response['data'];
        if (data is List) {
          return data
              .map((e) => _parseNotification(e as Map<String, dynamic>))
              .toList();
        }
      }
      
      // Handle old response format: direct list
      if (response is List) {
        return response
            .map((e) => _parseNotification(e as Map<String, dynamic>))
            .toList();
      } else if (response is Map && response['notifications'] != null) {
        final notifications = response['notifications'] as List;
        return notifications
            .map((e) => _parseNotification(e as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to get notifications: ${e.toString()}');
    }
  }

  /// Get unread count
  Future<int> getUnreadCount() async {
    try {
      final response = await _apiClient.get('/notifications/unread-count');
      
      // Handle new response format: { success: true, data: {...}, message: "..." }
      Map<String, dynamic> responseData;
      if (response is Map<String, dynamic> && response.containsKey('data')) {
        responseData = response['data'] as Map<String, dynamic>;
      } else {
        responseData = response as Map<String, dynamic>;
      }
      
      return (responseData['unread_count'] as num?)?.toInt() ?? 0;
    } catch (e) {
      throw Exception('Failed to get unread count: ${e.toString()}');
    }
  }

  /// Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    try {
      await _apiClient.patch('/notifications/$notificationId/read', body: {'data': {}});
    } catch (e) {
      throw Exception('Failed to mark as read: ${e.toString()}');
    }
  }

  /// Mark all notifications as read
  Future<void> markAllAsRead() async {
    try {
      await _apiClient.patch('/notifications/read-all', body: {'data': {}});
    } catch (e) {
      throw Exception('Failed to mark all as read: ${e.toString()}');
    }
  }

  /// Start listening to real-time notifications (SSE)
  Stream<NotificationModel> startListening() {
    if (_notificationStream != null && !_notificationStream!.isClosed) {
      return _notificationStream!.stream;
    }

    _notificationStream = StreamController<NotificationModel>.broadcast();

    // SSE may not work on web, use polling instead
    if (kIsWeb) {
      // Poll for notifications every 5 seconds
      Timer.periodic(const Duration(seconds: 5), (timer) async {
        if (_notificationStream!.isClosed) {
          timer.cancel();
          return;
        }
        try {
          final notifications = await getNotifications(limit: 1);
          if (notifications.isNotEmpty) {
            _notificationStream!.add(notifications.first);
          }
        } catch (e) {
          // Ignore errors in polling
        }
      });
      return _notificationStream!.stream;
    }

    try {
      _sseSubscription = _apiClient.stream('/notifications/stream').listen(
        (data) {
          try {
            if (data.trim().isEmpty) return;
            
            // Handle SSE format: "data: {...}\n\n"
            final lines = data.split('\n');
            for (final line in lines) {
              if (line.startsWith('data: ')) {
                final jsonStr = line.substring(6); // Remove "data: " prefix
                if (jsonStr.trim().isEmpty) continue;
                
                final json = jsonDecode(jsonStr);
                if (json is Map && json['type'] == 'connected') continue;
                
                final notification = _parseNotification(json as Map<String, dynamic>);
                _notificationStream!.add(notification);
              }
            }
          } catch (e) {
            print('Error parsing notification: $e');
          }
        },
        onError: (error) {
          _notificationStream!.addError(error);
        },
        onDone: () {
          _notificationStream!.close();
        },
        cancelOnError: false,
      );
    } catch (e) {
      _notificationStream!.addError(e);
    }

    return _notificationStream!.stream;
  }

  /// Stop listening to notifications
  void stopListening() {
    _sseSubscription?.cancel();
    _notificationStream?.close();
    _notificationStream = null;
    _sseSubscription = null;
  }

  NotificationModel _parseNotification(Map<String, dynamic> data) {
    return NotificationModel(
      id: data['id'] as String,
      type: _parseNotificationType(data['type'] as String),
      title: data['title'] as String,
      message: data['message'] as String,
      timestamp: DateTime.parse(data['created_at'] as String),
      read: data['read'] as bool? ?? false,
      data: data['data'] as Map<String, dynamic>?,
    );
  }

  NotificationType _parseNotificationType(String type) {
    switch (type) {
      case 'bus_started':
        return NotificationType.busStarted;
      case 'bus_near_student':
        return NotificationType.busNearStudent;
      case 'bus_arrived_school':
        return NotificationType.busArrivedSchool;
      case 'bus_near_pickup':
        return NotificationType.busNearPickup;
      case 'trip_completed':
        return NotificationType.tripCompleted;
      default:
        return NotificationType.busStarted;
    }
  }
}

