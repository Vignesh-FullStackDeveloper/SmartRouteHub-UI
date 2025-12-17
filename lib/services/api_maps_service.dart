import '../core/api/api_client.dart';
import 'api_client_service.dart';

/// Real API-based maps service for location operations
class ApiMapsService {
  final ApiClient _apiClient;

  ApiMapsService({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClientService.instance;

  /// Calculate route distance and duration
  Future<Map<String, dynamic>> calculateRoute({
    required double originLat,
    required double originLng,
    required double destLat,
    required double destLng,
    List<Map<String, double>>? waypoints,
  }) async {
    try {
      final body = {
        'origin': {'latitude': originLat, 'longitude': originLng},
        'destination': {'latitude': destLat, 'longitude': destLng},
        if (waypoints != null)
          'waypoints': waypoints
              .map((w) => {'latitude': w['lat']!, 'longitude': w['lng']!})
              .toList(),
      };

      final response = await _apiClient.post('/maps/route/calculate', body: {'data': body});
      
      // Handle new response format: { success: true, data: {...}, message: "..." }
      if (response is Map<String, dynamic> && response.containsKey('data')) {
        return response['data'] as Map<String, dynamic>;
      }
      
      // Handle old response format: direct object
      return response as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Failed to calculate route: ${e.toString()}');
    }
  }

  /// Geocode address to coordinates
  Future<Map<String, dynamic>> geocode(String address) async {
    try {
      final response = await _apiClient.post(
        '/maps/geocode',
        body: {'data': {'address': address}},
      );
      
      // Handle new response format: { success: true, data: {...}, message: "..." }
      if (response is Map<String, dynamic> && response.containsKey('data')) {
        return response['data'] as Map<String, dynamic>;
      }
      
      // Handle old response format: direct object
      return response as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Failed to geocode address: ${e.toString()}');
    }
  }

  /// Reverse geocode coordinates to address
  Future<Map<String, dynamic>> reverseGeocode({
    required double latitude,
    required double longitude,
  }) async {
    try {
      final response = await _apiClient.post(
        '/maps/reverse-geocode',
        body: {
          'data': {
            'latitude': latitude,
            'longitude': longitude,
          },
        },
      );
      
      // Handle new response format: { success: true, data: {...}, message: "..." }
      if (response is Map<String, dynamic> && response.containsKey('data')) {
        return response['data'] as Map<String, dynamic>;
      }
      
      // Handle old response format: direct object
      return response as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Failed to reverse geocode: ${e.toString()}');
    }
  }

  /// Save location pin to database (as a route stop)
  /// This updates the route with a new stop
  Future<Map<String, dynamic>> saveLocationPin({
    required String routeId,
    required String name,
    required double latitude,
    required double longitude,
    required int order,
    Map<String, dynamic>? address,
    int? estimatedArrivalMinutes,
  }) async {
    try {
      // Get current route to get existing stops
      final routeResponse = await _apiClient.get('/routes/$routeId');
      
      // Handle new response format: { success: true, data: {...}, message: "..." }
      Map<String, dynamic> route;
      if (routeResponse is Map<String, dynamic> && routeResponse.containsKey('data')) {
        route = routeResponse['data'] as Map<String, dynamic>;
      } else {
        route = routeResponse as Map<String, dynamic>;
      }
      
      final stops = (route['stops'] as List<dynamic>?) ?? [];

      // Add new stop to the list
      stops.add({
        'name': name,
        'latitude': latitude,
        'longitude': longitude,
        'order': order,
        if (estimatedArrivalMinutes != null)
          'estimated_arrival_minutes': estimatedArrivalMinutes,
        if (address != null) 'address': address,
      });

      // Update route with new stops array
      final updateBody = <String, dynamic>{
        'stops': stops,
      };

      final response = await _apiClient.put('/routes/$routeId', body: {'data': updateBody});
      
      // Handle new response format: { success: true, data: {...}, message: "..." }
      if (response is Map<String, dynamic> && response.containsKey('data')) {
        return response['data'] as Map<String, dynamic>;
      }
      
      // Handle old response format: direct object
      return response as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Failed to save location pin: ${e.toString()}');
    }
  }
}

