import 'package:equatable/equatable.dart';
import '../../models/trip.dart';

/// Admin dashboard states
abstract class AdminDashboardState extends Equatable {
  const AdminDashboardState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class AdminDashboardInitial extends AdminDashboardState {
  const AdminDashboardInitial();
}

/// Loading state
class AdminDashboardLoading extends AdminDashboardState {
  const AdminDashboardLoading();
}

/// Loaded state
class AdminDashboardLoaded extends AdminDashboardState {
  final int totalBuses;
  final int totalStudents;
  final int activeTrips;
  final int driversOnline;
  final List<Trip> tripsInProgress;

  const AdminDashboardLoaded({
    required this.totalBuses,
    required this.totalStudents,
    required this.activeTrips,
    required this.driversOnline,
    required this.tripsInProgress,
  });

  @override
  List<Object?> get props => [
        totalBuses,
        totalStudents,
        activeTrips,
        driversOnline,
        tripsInProgress,
      ];
}

/// Error state
class AdminDashboardError extends AdminDashboardState {
  final String message;

  const AdminDashboardError(this.message);

  @override
  List<Object?> get props => [message];
}

