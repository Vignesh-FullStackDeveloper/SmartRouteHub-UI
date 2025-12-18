import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/api/api_client.dart';
import '../core/constants/app_constants.dart';
import 'api_client_service.dart';

/// Real API-based maps service for location operations
class ApiMapsService {
  final ApiClient _apiClient;
  final http.Client _httpClient;

  ApiMapsService({ApiClient? apiClient, http.Client? httpClient})
      : _apiClient = apiClient ?? ApiClientService.instance,
        _httpClient = httpClient ?? http.Client();

  /// Calculate route distance and duration - calls Google Routes API v2
  Future<Map<String, dynamic>> calculateRoute({
    required double originLat,
    required double originLng,
    required double destLat,
    required double destLng,
    List<Map<String, double>>? waypoints,
  }) async {
    try {
      // Build request body for Routes API v2
      final requestBody = <String, dynamic>{
        'origin': {
          'location': {
            'latLng': {
              'latitude': originLat,
              'longitude': originLng,
            }
          }
        },
        'destination': {
          'location': {
            'latLng': {
              'latitude': destLat,
              'longitude': destLng,
            }
          }
        },
        'travelMode': 'DRIVE',
        'routingPreference': 'TRAFFIC_AWARE',
        'computeAlternativeRoutes': false,
        'routeModifiers': {
          'avoidTolls': false,
          'avoidHighways': false,
          'avoidFerries': false,
        },
        'languageCode': 'en-US',
        'units': 'METRIC',
      };

      // Add waypoints/intermediates if provided
      if (waypoints != null && waypoints.isNotEmpty) {
        requestBody['intermediates'] = waypoints.map((w) => {
          'location': {
            'latLng': {
              'latitude': w['lat']!,
              'longitude': w['lng']!,
            }
          }
        }).toList();
      }

      // Call Google Routes API v2
      final url = Uri.parse(
        'https://routes.googleapis.com/directions/v2:computeRoutes',
      );

      final response = await _httpClient.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'X-Goog-Api-Key': AppConstants.googleMapsApiKey,
          'X-Goog-FieldMask': 'routes.duration,routes.distanceMeters,routes.polyline.encodedPolyline',
        },
        body: json.encode(requestBody),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;

        // Check for routes in response
        if (data['routes'] != null && (data['routes'] as List).isNotEmpty) {
          final route = (data['routes'] as List)[0] as Map<String, dynamic>;
          
          // Extract polyline encodedPolyline directly
          String? encodedPolyline;
          if (route['polyline'] != null && route['polyline'] is Map) {
            final polyline = route['polyline'] as Map<String, dynamic>;
            encodedPolyline = polyline['encodedPolyline'] as String?;
          }
          
          // Return in a format compatible with existing code
          return {
            'routes': [
              {
                'polyline': route['polyline'], // Keep original structure
                'distanceMeters': route['distanceMeters'],
                'duration': route['duration'],
              }
            ],
            // Also include direct polyline string for easier access
            'polyline': encodedPolyline,
          };
        } else {
          throw Exception('Route calculation failed: No routes found in response');
        }
      } else {
        final errorBody = response.body;
        throw Exception('HTTP ${response.statusCode}: $errorBody');
      }
    } catch (e) {
      throw Exception('Failed to calculate route: ${e.toString()}');
    }
  }

  /// Geocode address to coordinates - calls Google Maps API directly
  Future<Map<String, dynamic>> geocode(String address) async {
    try {
      // Call Google Maps Geocoding API directly
      final encodedAddress = Uri.encodeComponent(address);
      final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/geocode/json?address=$encodedAddress&key=${AppConstants.googleMapsApiKey}',
      );
      
      final response = await _httpClient.get(url);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        
        // Check for errors
        if (data['status'] == 'OK' && data['results'] != null) {
          return data; // Return full Google Maps response
        } else {
          throw Exception('Geocoding failed: ${data['status']} - ${data['error_message'] ?? 'Unknown error'}');
        }
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to geocode address: ${e.toString()}');
    }
  }

  /// Reverse geocode coordinates to address - calls Google Maps API directly
  Future<Map<String, dynamic>> reverseGeocode({
    required double latitude,
    required double longitude,
  }) async {
    try {
      // Call Google Maps Reverse Geocoding API directly
      final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=$latitude,$longitude&key=${AppConstants.googleMapsApiKey}',
      );
      
      final response = await _httpClient.get(url);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        
        // Check for errors
        if (data['status'] == 'OK' && data['results'] != null && (data['results'] as List).isNotEmpty) {
          final firstResult = (data['results'] as List)[0] as Map<String, dynamic>;
          // Return in a format compatible with existing code
          return {
            'address': firstResult['formatted_address'] ?? 'Unknown location',
            'results': data['results'],
          };
        } else {
          throw Exception('Reverse geocoding failed: ${data['status']} - ${data['error_message'] ?? 'Unknown error'}');
        }
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }
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

