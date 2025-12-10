import 'package:equatable/equatable.dart';
import '../../models/trip.dart';
import '../../models/route.dart';
import '../../models/bus.dart';

/// Driver trip states
abstract class DriverTripState extends Equatable {
  const DriverTripState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class DriverTripInitial extends DriverTripState {
  const DriverTripInitial();
}

/// Loading state
class DriverTripLoading extends DriverTripState {
  const DriverTripLoading();
}

/// Loaded state
class DriverTripLoaded extends DriverTripState {
  final Trip? currentTrip;
  final Route? assignedRoute;
  final Bus? assignedBus;
  final bool hasActiveTrip;

  const DriverTripLoaded({
    this.currentTrip,
    this.assignedRoute,
    this.assignedBus,
    this.hasActiveTrip = false,
  });

  @override
  List<Object?> get props => [
        currentTrip,
        assignedRoute,
        assignedBus,
        hasActiveTrip,
      ];
}

/// Error state
class DriverTripError extends DriverTripState {
  final String message;

  const DriverTripError(this.message);

  @override
  List<Object?> get props => [message];
}

