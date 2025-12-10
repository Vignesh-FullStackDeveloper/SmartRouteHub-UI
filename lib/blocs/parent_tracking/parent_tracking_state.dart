import 'package:equatable/equatable.dart';
import '../../models/student.dart';
import '../../models/trip.dart';
import '../../models/bus.dart';
import '../../models/route.dart';
import '../../models/stop.dart';

/// Child bus status enum
enum ChildBusStatus {
  notStarted,
  started,
  nearPickup,
  completed,
}

/// Child tracking info
class ChildTrackingInfo extends Equatable {
  final Student student;
  final ChildBusStatus status;
  final Trip? trip;
  final Bus? bus;
  final Route? route;
  final Stop? pickupPoint;
  final double? distanceToPickup; // in km
  final Duration? etaToPickup;

  const ChildTrackingInfo({
    required this.student,
    required this.status,
    this.trip,
    this.bus,
    this.route,
    this.pickupPoint,
    this.distanceToPickup,
    this.etaToPickup,
  });

  @override
  List<Object?> get props => [
        student,
        status,
        trip,
        bus,
        route,
        pickupPoint,
        distanceToPickup,
        etaToPickup,
      ];
}

/// Parent tracking states
abstract class ParentTrackingState extends Equatable {
  const ParentTrackingState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class ParentTrackingInitial extends ParentTrackingState {
  const ParentTrackingInitial();
}

/// Loading state
class ParentTrackingLoading extends ParentTrackingState {
  const ParentTrackingLoading();
}

/// Loaded state
class ParentTrackingLoaded extends ParentTrackingState {
  final List<ChildTrackingInfo> children;

  const ParentTrackingLoaded({required this.children});

  @override
  List<Object?> get props => [children];
}

/// Error state
class ParentTrackingError extends ParentTrackingState {
  final String message;

  const ParentTrackingError(this.message);

  @override
  List<Object?> get props => [message];
}

