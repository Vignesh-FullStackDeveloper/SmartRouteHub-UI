import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/student_service.dart';
import '../../services/trip_service.dart';
import '../../services/bus_service.dart';
import '../../services/route_service.dart';
import '../../services/location_service.dart';
import '../../models/student.dart';
import '../../models/bus.dart';
import '../../models/route.dart';
import '../../models/trip.dart';
import '../../models/stop.dart';
import 'parent_tracking_event.dart';
import 'parent_tracking_state.dart';

/// Parent tracking BLoC
class ParentTrackingBloc
    extends Bloc<ParentTrackingEvent, ParentTrackingState> {
  final StudentService _studentService;
  final TripService _tripService;
  final BusService _busService;
  final RouteService _routeService;
  final LocationService _locationService;

  ParentTrackingBloc({
    StudentService? studentService,
    TripService? tripService,
    BusService? busService,
    RouteService? routeService,
    LocationService? locationService,
  })  : _studentService = studentService ?? StudentService(),
        _tripService = tripService ?? TripService(),
        _busService = busService ?? BusService(),
        _routeService = routeService ?? RouteService(),
        _locationService = locationService ?? LocationService(),
        super(const ParentTrackingInitial()) {
    on<LoadParentTrackingData>(_onLoadParentTrackingData);
    on<LoadChildTracking>(_onLoadChildTracking);
    on<RefreshTrackingData>(_onRefreshTrackingData);
  }

  Future<void> _onLoadParentTrackingData(
    LoadParentTrackingData event,
    Emitter<ParentTrackingState> emit,
  ) async {
    emit(const ParentTrackingLoading());
    try {
      // Get all students for the organization (in real app, filter by parentId)
      final students = await _studentService.getStudentsByOrganization(
        event.organizationId,
      );

      // Filter students for this parent (dummy: use first 2 students)
      final parentStudents = students.take(2).toList();

      final children = await Future.wait(
        parentStudents.map((student) => _buildChildTrackingInfo(student)),
      );

      emit(ParentTrackingLoaded(children: children));
    } catch (e) {
      emit(ParentTrackingError(e.toString()));
    }
  }

  Future<void> _onLoadChildTracking(
    LoadChildTracking event,
    Emitter<ParentTrackingState> emit,
  ) async {
    emit(const ParentTrackingLoading());
    try {
      final student = await _studentService.getStudentById(event.childId);
      if (student == null) {
        emit(const ParentTrackingError('Student not found'));
        return;
      }

      final childInfo = await _buildChildTrackingInfo(student);
      emit(ParentTrackingLoaded(children: [childInfo]));
    } catch (e) {
      emit(ParentTrackingError(e.toString()));
    }
  }

  Future<void> _onRefreshTrackingData(
    RefreshTrackingData event,
    Emitter<ParentTrackingState> emit,
  ) async {
    await _onLoadParentTrackingData(
      LoadParentTrackingData(
        parentId: event.parentId,
        organizationId: event.organizationId,
      ),
      emit,
    );
  }

  Future<ChildTrackingInfo> _buildChildTrackingInfo(Student student) async {
    // Get bus and route
    Bus? bus;
    Route? route;
    Trip? trip;
    Stop? pickupPoint;

    if (student.assignedBusId != null) {
      bus = await _busService.getBusById(student.assignedBusId!);
    }
    if (student.assignedRouteId != null) {
      route = await _routeService.getRouteById(student.assignedRouteId!);
      if (route != null && student.pickupPointId != null) {
        final currentRoute = route;
        pickupPoint = currentRoute.stops.firstWhere(
          (s) => s.id == student.pickupPointId,
          orElse: () => currentRoute.stops.first,
        );
      }
    }

    // Find active trip for this bus
    if (bus?.id != null) {
      final trips = await _tripService.getActiveTrips(student.organizationId);
      try {
        trip = trips.firstWhere((t) => t.busId == bus!.id);
      } catch (e) {
        // No active trip for this bus
        trip = null;
      }
    }

    // Determine status
    ChildBusStatus status = ChildBusStatus.notStarted;
    double? distanceToPickup;
    Duration? etaToPickup;

    if (trip != null && trip.status.name == 'inProgress') {
      status = ChildBusStatus.started;
      if (pickupPoint != null &&
          trip.currentLatitude != null &&
          trip.currentLongitude != null) {
        distanceToPickup = _locationService.calculateDistance(
          trip.currentLatitude!,
          trip.currentLongitude!,
          pickupPoint.latitude,
          pickupPoint.longitude,
        );

        if (distanceToPickup < 1.0) {
          status = ChildBusStatus.nearPickup;
        }

        // Dummy ETA calculation (5 minutes per km at 12 km/h)
        if (trip.speed != null && trip.speed! > 0) {
          final hours = distanceToPickup / trip.speed!;
          etaToPickup = Duration(minutes: (hours * 60).round());
        } else {
          etaToPickup = Duration(minutes: (distanceToPickup * 5).round());
        }
      }
    } else if (trip != null && trip.status.name == 'completed') {
      status = ChildBusStatus.completed;
    }

    return ChildTrackingInfo(
      student: student,
      status: status,
      trip: trip,
      bus: bus,
      route: route,
      pickupPoint: pickupPoint,
      distanceToPickup: distanceToPickup,
      etaToPickup: etaToPickup,
    );
  }
}

