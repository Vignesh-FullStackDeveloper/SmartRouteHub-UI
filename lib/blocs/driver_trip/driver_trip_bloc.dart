import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/trip_service.dart';
import '../../services/route_service.dart';
import '../../services/bus_service.dart';
import '../../services/driver_service.dart';
import '../../services/location_service.dart';
import '../../models/route.dart';
import '../../models/bus.dart';
import '../../models/trip.dart';
import 'driver_trip_event.dart';
import 'driver_trip_state.dart';

/// Driver trip BLoC
class DriverTripBloc extends Bloc<DriverTripEvent, DriverTripState> {
  final TripService _tripService;
  final RouteService _routeService;
  final BusService _busService;
  final DriverService _driverService;
  final LocationService _locationService;

  DriverTripBloc({
    TripService? tripService,
    RouteService? routeService,
    BusService? busService,
    DriverService? driverService,
    LocationService? locationService,
  })  : _tripService = tripService ?? TripService(),
        _routeService = routeService ?? RouteService(),
        _busService = busService ?? BusService(),
        _driverService = driverService ?? DriverService(),
        _locationService = locationService ?? LocationService(),
        super(const DriverTripInitial()) {
    on<LoadDriverTripData>(_onLoadDriverTripData);
    on<StartTrip>(_onStartTrip);
    on<UpdateTripLocation>(_onUpdateTripLocation);
    on<MarkStopArrived>(_onMarkStopArrived);
    on<EndTrip>(_onEndTrip);
  }

  Future<void> _onLoadDriverTripData(
    LoadDriverTripData event,
    Emitter<DriverTripState> emit,
  ) async {
    emit(const DriverTripLoading());
    try {
      final driver = await _driverService.getDriverById(event.driverId);
      if (driver == null) {
        emit(const DriverTripError('Driver not found'));
        return;
      }

      final trip = await _tripService.getTripByDriverId(event.driverId);
      Route? route;
      Bus? bus;

      if (driver.assignedRouteId != null) {
        route = await _routeService.getRouteById(driver.assignedRouteId!);
      }
      if (driver.assignedBusId != null) {
        bus = await _busService.getBusById(driver.assignedBusId!);
      }

      emit(DriverTripLoaded(
        currentTrip: trip,
        assignedRoute: route,
        assignedBus: bus,
        hasActiveTrip: trip != null,
      ));
    } catch (e) {
      emit(DriverTripError(e.toString()));
    }
  }

  Future<void> _onStartTrip(
    StartTrip event,
    Emitter<DriverTripState> emit,
  ) async {
    emit(const DriverTripLoading());
    try {
      final trip = await _tripService.startTrip(
        busId: event.busId,
        routeId: event.routeId,
        driverId: event.driverId,
        organizationId: event.organizationId,
        latitude: event.latitude,
        longitude: event.longitude,
      );

      final route = await _routeService.getRouteById(event.routeId);
      final bus = await _busService.getBusById(event.busId);

      await _locationService.startTracking();

      emit(DriverTripLoaded(
        currentTrip: trip,
        assignedRoute: route,
        assignedBus: bus,
        hasActiveTrip: true,
      ));
    } catch (e) {
      emit(DriverTripError(e.toString()));
    }
  }

  Future<void> _onUpdateTripLocation(
    UpdateTripLocation event,
    Emitter<DriverTripState> emit,
  ) async {
    try {
      final updatedTrip = await _tripService.updateTripLocation(
        tripId: event.tripId,
        latitude: event.latitude,
        longitude: event.longitude,
        speed: event.speed,
      );

      final currentState = state;
      if (currentState is DriverTripLoaded) {
        emit(DriverTripLoaded(
          currentTrip: updatedTrip,
          assignedRoute: currentState.assignedRoute,
          assignedBus: currentState.assignedBus,
          hasActiveTrip: true,
        ));
      }
    } catch (e) {
      emit(DriverTripError(e.toString()));
    }
  }

  Future<void> _onMarkStopArrived(
    MarkStopArrived event,
    Emitter<DriverTripState> emit,
  ) async {
    try {
      await _tripService.markStopArrived(event.tripId);
      // Reload trip data
      final trip = await _tripService.getTripById(event.tripId);
      final currentState = state;
      if (currentState is DriverTripLoaded && trip != null) {
        emit(DriverTripLoaded(
          currentTrip: trip,
          assignedRoute: currentState.assignedRoute,
          assignedBus: currentState.assignedBus,
          hasActiveTrip: true,
        ));
      }
    } catch (e) {
      emit(DriverTripError(e.toString()));
    }
  }

  Future<void> _onEndTrip(
    EndTrip event,
    Emitter<DriverTripState> emit,
  ) async {
    emit(const DriverTripLoading());
    try {
      await _tripService.endTrip(event.tripId);
      await _locationService.stopTracking();

      final currentState = state;
      if (currentState is DriverTripLoaded) {
        emit(DriverTripLoaded(
          assignedRoute: currentState.assignedRoute,
          assignedBus: currentState.assignedBus,
          hasActiveTrip: false,
        ));
      }
    } catch (e) {
      emit(DriverTripError(e.toString()));
    }
  }
}

