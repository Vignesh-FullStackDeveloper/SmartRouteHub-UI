import 'package:equatable/equatable.dart';

/// Parent tracking events
abstract class ParentTrackingEvent extends Equatable {
  const ParentTrackingEvent();

  @override
  List<Object?> get props => [];
}

/// Load parent tracking data
class LoadParentTrackingData extends ParentTrackingEvent {
  final String parentId;
  final String organizationId;

  const LoadParentTrackingData({
    required this.parentId,
    required this.organizationId,
  });

  @override
  List<Object?> get props => [parentId, organizationId];
}

/// Load child tracking
class LoadChildTracking extends ParentTrackingEvent {
  final String childId;
  final String organizationId;

  const LoadChildTracking({
    required this.childId,
    required this.organizationId,
  });

  @override
  List<Object?> get props => [childId, organizationId];
}

/// Refresh tracking data
class RefreshTrackingData extends ParentTrackingEvent {
  final String parentId;
  final String organizationId;

  const RefreshTrackingData({
    required this.parentId,
    required this.organizationId,
  });

  @override
  List<Object?> get props => [parentId, organizationId];
}

