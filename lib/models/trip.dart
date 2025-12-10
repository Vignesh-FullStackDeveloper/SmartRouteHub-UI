import 'package:equatable/equatable.dart';

/// Trip status enum
enum TripStatus {
  notStarted,
  inProgress,
  completed,
  cancelled,
}

/// Trip model representing an active bus trip
class Trip extends Equatable {
  final String id;
  final String busId;
  final String routeId;
  final String driverId;
  final String organizationId;
  final TripStatus status;
  final DateTime? startTime;
  final DateTime? endTime;
  final double? currentLatitude;
  final double? currentLongitude;
  final double? speed; // km/h
  final DateTime? lastUpdateTime;

  const Trip({
    required this.id,
    required this.busId,
    required this.routeId,
    required this.driverId,
    required this.organizationId,
    this.status = TripStatus.notStarted,
    this.startTime,
    this.endTime,
    this.currentLatitude,
    this.currentLongitude,
    this.speed,
    this.lastUpdateTime,
  });

  @override
  List<Object?> get props => [
        id,
        busId,
        routeId,
        driverId,
        organizationId,
        status,
        startTime,
        endTime,
        currentLatitude,
        currentLongitude,
        speed,
        lastUpdateTime,
      ];

  Trip copyWith({
    String? id,
    String? busId,
    String? routeId,
    String? driverId,
    String? organizationId,
    TripStatus? status,
    DateTime? startTime,
    DateTime? endTime,
    double? currentLatitude,
    double? currentLongitude,
    double? speed,
    DateTime? lastUpdateTime,
  }) {
    return Trip(
      id: id ?? this.id,
      busId: busId ?? this.busId,
      routeId: routeId ?? this.routeId,
      driverId: driverId ?? this.driverId,
      organizationId: organizationId ?? this.organizationId,
      status: status ?? this.status,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      currentLatitude: currentLatitude ?? this.currentLatitude,
      currentLongitude: currentLongitude ?? this.currentLongitude,
      speed: speed ?? this.speed,
      lastUpdateTime: lastUpdateTime ?? this.lastUpdateTime,
    );
  }
}

