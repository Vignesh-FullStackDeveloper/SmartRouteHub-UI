import 'package:equatable/equatable.dart';

/// Notification type enum
enum NotificationType {
  busStarted,
  busNearStudent,
  busArrivedSchool,
  busNearPickup,
  tripCompleted,
}

/// Notification model
class NotificationModel extends Equatable {
  final String id;
  final NotificationType type;
  final String title;
  final String message;
  final DateTime timestamp;
  final bool read;
  final Map<String, dynamic>? data;

  const NotificationModel({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.timestamp,
    this.read = false,
    this.data,
  });

  @override
  List<Object?> get props => [
        id,
        type,
        title,
        message,
        timestamp,
        read,
        data,
      ];

  NotificationModel copyWith({
    String? id,
    NotificationType? type,
    String? title,
    String? message,
    DateTime? timestamp,
    bool? read,
    Map<String, dynamic>? data,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      message: message ?? this.message,
      timestamp: timestamp ?? this.timestamp,
      read: read ?? this.read,
      data: data ?? this.data,
    );
  }
}

