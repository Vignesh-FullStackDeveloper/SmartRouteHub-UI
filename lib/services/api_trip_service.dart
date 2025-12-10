import '../core/api/api_client.dart';
import '../models/trip.dart';
import 'api_client_service.dart';

/// Real API-based trip service
class ApiTripService {
  final ApiClient _apiClient;

  ApiTripService({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClientService.instance;

  /// Get active trips
  Future<List<Trip>> getActiveTrips() async {
    try {
      final response = await _apiClient.get('/trips/active');
      if (response is List) {
        return response.map((e) => _parseTrip(e as Map<String, dynamic>)).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to get active trips: ${e.toString()}');
    }
  }

  /// Get trip by ID
  Future<Trip> getTripById(String id) async {
    try {
      final response = await _apiClient.get('/trips/$id');
      return _parseTrip(response);
    } catch (e) {
      throw Exception('Failed to get trip: ${e.toString()}');
    }
  }

  /// Start trip
  Future<Trip> startTrip({
    required String busId,
    required String routeId,
    required double latitude,
    required double longitude,
  }) async {
    try {
      final response = await _apiClient.post(
        '/trips/start',
        body: {
          'bus_id': busId,
          'route_id': routeId,
          'latitude': latitude,
          'longitude': longitude,
        },
      );
      return _parseTrip(response);
    } catch (e) {
      throw Exception('Failed to start trip: ${e.toString()}');
    }
  }

  /// Update trip location
  Future<Trip> updateLocation({
    required String tripId,
    required double latitude,
    required double longitude,
    double? speedKmh,
    double? heading,
    double? accuracy,
  }) async {
    try {
      final response = await _apiClient.post(
        '/trips/$tripId/location',
        body: {
          'latitude': latitude,
          'longitude': longitude,
          if (speedKmh != null) 'speed_kmh': speedKmh,
          if (heading != null) 'heading': heading,
          if (accuracy != null) 'accuracy': accuracy,
        },
      );
      return _parseTrip(response);
    } catch (e) {
      throw Exception('Failed to update location: ${e.toString()}');
    }
  }

  /// End trip
  Future<Trip> endTrip(String tripId) async {
    try {
      final response = await _apiClient.post('/trips/$tripId/end');
      return _parseTrip(response);
    } catch (e) {
      throw Exception('Failed to end trip: ${e.toString()}');
    }
  }

  Trip _parseTrip(Map<String, dynamic> data) {
    final locationHistory = data['location_history'] as List<dynamic>?;
    
    return Trip(
      id: data['id'] as String,
      organizationId: data['organization_id'] as String,
      busId: data['bus_id'] as String,
      routeId: data['route_id'] as String,
      driverId: data['driver_id'] as String,
      status: _parseTripStatus(data['status'] as String),
      startTime: data['start_time'] != null
          ? DateTime.parse(data['start_time'] as String)
          : null,
      endTime: data['end_time'] != null
          ? DateTime.parse(data['end_time'] as String)
          : null,
      currentLatitude: (data['current_latitude'] as num?)?.toDouble(),
      currentLongitude: (data['current_longitude'] as num?)?.toDouble(),
      speedKmh: (data['speed_kmh'] as num?)?.toDouble(),
      lastUpdateTime: data['last_update_time'] != null
          ? DateTime.parse(data['last_update_time'] as String)
          : null,
      passengerCount: (data['passenger_count'] as num?)?.toInt() ?? 0,
      locationHistory: locationHistory
              ?.map((l) => {
                    'latitude': (l['latitude'] as num).toDouble(),
                    'longitude': (l['longitude'] as num).toDouble(),
                    'timestamp': DateTime.parse(l['recorded_at'] as String),
                  })
              .toList() ??
          [],
    );
  }

  TripStatus _parseTripStatus(String status) {
    switch (status) {
      case 'not_started':
        return TripStatus.notStarted;
      case 'in_progress':
        return TripStatus.inProgress;
      case 'completed':
        return TripStatus.completed;
      case 'cancelled':
        return TripStatus.cancelled;
      default:
        return TripStatus.notStarted;
    }
  }
}

