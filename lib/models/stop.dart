import 'package:equatable/equatable.dart';

/// Stop model representing a pickup/drop point
class Stop extends Equatable {
  final String id;
  final String name;
  final double latitude;
  final double longitude;
  final int order; // Order in the route
  final DateTime? estimatedArrivalTime;
  final bool isCompleted;

  const Stop({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.order,
    this.estimatedArrivalTime,
    this.isCompleted = false,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        latitude,
        longitude,
        order,
        estimatedArrivalTime,
        isCompleted,
      ];

  Stop copyWith({
    String? id,
    String? name,
    double? latitude,
    double? longitude,
    int? order,
    DateTime? estimatedArrivalTime,
    bool? isCompleted,
  }) {
    return Stop(
      id: id ?? this.id,
      name: name ?? this.name,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      order: order ?? this.order,
      estimatedArrivalTime: estimatedArrivalTime ?? this.estimatedArrivalTime,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}

