import 'package:equatable/equatable.dart';

/// Driver trip events
abstract class DriverTripEvent extends Equatable {
  const DriverTripEvent();

  @override
  List<Object?> get props => [];
}

/// Load driver trip data
class LoadDriverTripData extends DriverTripEvent {
  final String driverId;
  final String organizationId;

  const LoadDriverTripData({
    required this.driverId,
    required this.organizationId,
  });

  @override
  List<Object?> get props => [driverId, organizationId];
}

/// Start trip
class StartTrip extends DriverTripEvent {
  final String busId;
  final String routeId;
  final String driverId;
  final String organizationId;
  final double latitude;
  final double longitude;

  const StartTrip({
    required this.busId,
    required this.routeId,
    required this.driverId,
    required this.organizationId,
    required this.latitude,
    required this.longitude,
  });

  @override
  List<Object?> get props => [
        busId,
        routeId,
        driverId,
        organizationId,
        latitude,
        longitude,
      ];
}

/// Update trip location
class UpdateTripLocation extends DriverTripEvent {
  final String tripId;
  final double latitude;
  final double longitude;
  final double? speed;

  const UpdateTripLocation({
    required this.tripId,
    required this.latitude,
    required this.longitude,
    this.speed,
  });

  @override
  List<Object?> get props => [tripId, latitude, longitude, speed];
}

/// Mark stop arrived
class MarkStopArrived extends DriverTripEvent {
  final String tripId;

  const MarkStopArrived(this.tripId);

  @override
  List<Object?> get props => [tripId];
}

/// End trip
class EndTrip extends DriverTripEvent {
  final String tripId;

  const EndTrip(this.tripId);

  @override
  List<Object?> get props => [tripId];
}

