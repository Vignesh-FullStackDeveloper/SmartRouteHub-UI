import 'package:equatable/equatable.dart';
import 'stop.dart';

/// Route model
class Route extends Equatable {
  final String id;
  final String name;
  final String organizationId;
  final DateTime startTime;
  final DateTime endTime;
  final List<Stop> stops;
  final String? assignedBusId;

  const Route({
    required this.id,
    required this.name,
    required this.organizationId,
    required this.startTime,
    required this.endTime,
    required this.stops,
    this.assignedBusId,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        organizationId,
        startTime,
        endTime,
        stops,
        assignedBusId,
      ];

  Route copyWith({
    String? id,
    String? name,
    String? organizationId,
    DateTime? startTime,
    DateTime? endTime,
    List<Stop>? stops,
    String? assignedBusId,
  }) {
    return Route(
      id: id ?? this.id,
      name: name ?? this.name,
      organizationId: organizationId ?? this.organizationId,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      stops: stops ?? this.stops,
      assignedBusId: assignedBusId ?? this.assignedBusId,
    );
  }
}

