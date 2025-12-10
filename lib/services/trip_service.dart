import '../models/trip.dart';
import '../models/bus.dart';
import '../models/route.dart';

/// Mock trip service
/// Manages active trips and trip status
class TripService {
  // In-memory storage
  static final List<Trip> _trips = [];

  /// Get all active trips for an organization
  Future<List<Trip>> getActiveTrips(String organizationId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _trips
        .where((t) =>
            t.organizationId == organizationId &&
            t.status == TripStatus.inProgress)
        .toList();
  }

  /// Get all trips for an organization
  Future<List<Trip>> getAllTrips(String organizationId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _trips
        .where((t) => t.organizationId == organizationId)
        .toList();
  }

  /// Get trip by ID
  Future<Trip?> getTripById(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    try {
      return _trips.firstWhere((t) => t.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Get trip by driver ID
  Future<Trip?> getTripByDriverId(String driverId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    try {
      return _trips.firstWhere(
        (t) => t.driverId == driverId && t.status == TripStatus.inProgress,
      );
    } catch (e) {
      return null;
    }
  }

  /// Start a new trip
  Future<Trip> startTrip({
    required String busId,
    required String routeId,
    required String driverId,
    required String organizationId,
    required double latitude,
    required double longitude,
  }) async {
    await Future.delayed(const Duration(seconds: 1));

    final trip = Trip(
      id: 'trip_${DateTime.now().millisecondsSinceEpoch}',
      busId: busId,
      routeId: routeId,
      driverId: driverId,
      organizationId: organizationId,
      status: TripStatus.inProgress,
      startTime: DateTime.now(),
      currentLatitude: latitude,
      currentLongitude: longitude,
      lastUpdateTime: DateTime.now(),
    );

    _trips.add(trip);
    return trip;
  }

  /// Update trip location
  Future<Trip> updateTripLocation({
    required String tripId,
    required double latitude,
    required double longitude,
    double? speed,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final index = _trips.indexWhere((t) => t.id == tripId);
    if (index != -1) {
      _trips[index] = _trips[index].copyWith(
        currentLatitude: latitude,
        currentLongitude: longitude,
        speed: speed,
        lastUpdateTime: DateTime.now(),
      );
      return _trips[index];
    }

    throw Exception('Trip not found');
  }

  /// End a trip
  Future<Trip> endTrip(String tripId) async {
    await Future.delayed(const Duration(seconds: 1));

    final index = _trips.indexWhere((t) => t.id == tripId);
    if (index != -1) {
      _trips[index] = _trips[index].copyWith(
        status: TripStatus.completed,
        endTime: DateTime.now(),
      );
      return _trips[index];
    }

    throw Exception('Trip not found');
  }

  /// Mark stop as arrived
  Future<Trip> markStopArrived(String tripId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    // In real app, this would update the route progress
    final trip = await getTripById(tripId);
    if (trip != null) {
      return trip;
    }
    throw Exception('Trip not found');
  }
}

