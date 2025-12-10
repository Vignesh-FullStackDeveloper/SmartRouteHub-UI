import 'package:equatable/equatable.dart';

/// Bus model
class Bus extends Equatable {
  final String id;
  final String busNumber;
  final int capacity;
  final String organizationId;
  final String? driverId;
  final String? assignedRouteId;
  final bool isActive;

  const Bus({
    required this.id,
    required this.busNumber,
    required this.capacity,
    required this.organizationId,
    this.driverId,
    this.assignedRouteId,
    this.isActive = true,
  });

  @override
  List<Object?> get props => [
        id,
        busNumber,
        capacity,
        organizationId,
        driverId,
        assignedRouteId,
        isActive,
      ];

  Bus copyWith({
    String? id,
    String? busNumber,
    int? capacity,
    String? organizationId,
    String? driverId,
    String? assignedRouteId,
    bool? isActive,
  }) {
    return Bus(
      id: id ?? this.id,
      busNumber: busNumber ?? this.busNumber,
      capacity: capacity ?? this.capacity,
      organizationId: organizationId ?? this.organizationId,
      driverId: driverId ?? this.driverId,
      assignedRouteId: assignedRouteId ?? this.assignedRouteId,
      isActive: isActive ?? this.isActive,
    );
  }
}

