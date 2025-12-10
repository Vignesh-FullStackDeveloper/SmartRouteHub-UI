import 'package:equatable/equatable.dart';

/// Admin dashboard events
abstract class AdminDashboardEvent extends Equatable {
  const AdminDashboardEvent();

  @override
  List<Object?> get props => [];
}

/// Load dashboard data
class LoadDashboardData extends AdminDashboardEvent {
  final String organizationId;

  const LoadDashboardData(this.organizationId);

  @override
  List<Object?> get props => [organizationId];
}

/// Refresh dashboard
class RefreshDashboard extends AdminDashboardEvent {
  final String organizationId;

  const RefreshDashboard(this.organizationId);

  @override
  List<Object?> get props => [organizationId];
}

