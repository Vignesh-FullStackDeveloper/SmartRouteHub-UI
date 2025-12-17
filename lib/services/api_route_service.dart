import '../core/api/api_client.dart';
import '../models/route.dart';
import '../models/stop.dart';
import 'api_client_service.dart';

/// Real API-based route service
class ApiRouteService {
  final ApiClient _apiClient;

  ApiRouteService({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClientService.instance;

  /// Get all routes
  Future<List<Route>> getRoutes({String? busId}) async {
    try {
      final queryParams = <String, String>{};
      if (busId != null) queryParams['bus_id'] = busId;

      final response = await _apiClient.get(
        '/routes',
        queryParams: queryParams.isEmpty ? null : queryParams,
      );

      // Handle new response format: { success: true, data: [...], message: "..." }
      if (response is Map<String, dynamic> && response.containsKey('data')) {
        final data = response['data'];
        if (data is List) {
          return data.map((e) => _parseRoute(e as Map<String, dynamic>)).toList();
        }
      }
      
      // Handle old response format: direct list
      if (response is List) {
        return response.map((e) => _parseRoute(e as Map<String, dynamic>)).toList();
      }
      
      return [];
    } catch (e) {
      throw Exception('Failed to get routes: ${e.toString()}');
    }
  }

  /// Get route by ID with stops
  Future<Route> getRouteById(String id) async {
    try {
      final response = await _apiClient.get('/routes/$id');
      
      // Handle new response format: { success: true, data: {...}, message: "..." }
      if (response is Map<String, dynamic> && response.containsKey('data')) {
        return _parseRoute(response['data'] as Map<String, dynamic>);
      }
      
      // Handle old response format: direct object
      return _parseRoute(response as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to get route: ${e.toString()}');
    }
  }

  /// Create route with stops
  Future<Route> createRoute({
    required String name,
    required String startTime,
    required String endTime,
    int? estimatedDurationMinutes,
    double? totalDistanceKm,
    String? assignedBusId,
    String? routePolyline,
    List<Stop>? stops,
  }) async {
    try {
      final response = await _apiClient.post(
        '/routes',
        body: {
          'data': {
            'name': name,
            'start_time': startTime,
            'end_time': endTime,
            if (estimatedDurationMinutes != null)
              'estimated_duration_minutes': estimatedDurationMinutes,
            if (totalDistanceKm != null) 'total_distance_km': totalDistanceKm,
            if (assignedBusId != null) 'assigned_bus_id': assignedBusId,
            if (routePolyline != null) 'route_polyline': routePolyline,
            if (stops != null)
              'stops': stops.map((s) => {
                    'name': s.name,
                    'latitude': s.latitude,
                    'longitude': s.longitude,
                    'order': s.order,
                    if (s.estimatedArrivalTime != null)
                      'estimated_arrival_time': s.estimatedArrivalTime!.toIso8601String(),
                  }).toList(),
          },
        },
      );
      
      // Handle new response format: { success: true, data: {...}, message: "..." }
      if (response is Map<String, dynamic> && response.containsKey('data')) {
        return _parseRoute(response['data'] as Map<String, dynamic>);
      }
      
      // Handle old response format: direct object
      return _parseRoute(response as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to create route: ${e.toString()}');
    }
  }

  /// Update route
  Future<Route> updateRoute(
    String id, {
    String? name,
    String? startTime,
    String? endTime,
    int? estimatedDurationMinutes,
    double? totalDistanceKm,
    String? routePolyline,
    String? assignedBusId,
    List<Stop>? stops,
  }) async {
    try {
      final body = <String, dynamic>{};
      if (name != null) {
        body['name'] = name;
      }
      if (startTime != null) {
        body['start_time'] = startTime;
      }
      if (endTime != null) {
        body['end_time'] = endTime;
      }
      if (estimatedDurationMinutes != null) {
        body['estimated_duration_minutes'] = estimatedDurationMinutes;
      }
      if (totalDistanceKm != null) {
        body['total_distance_km'] = totalDistanceKm;
      }
      if (routePolyline != null) {
        body['route_polyline'] = routePolyline;
      }
      if (assignedBusId != null) {
        body['assigned_bus_id'] = assignedBusId;
      }
      if (stops != null) {
        body['stops'] = stops.map((s) => {
              'name': s.name,
              'latitude': s.latitude,
              'longitude': s.longitude,
              'order': s.order,
              if (s.estimatedArrivalTime != null)
                'estimated_arrival_time': s.estimatedArrivalTime!.toIso8601String(),
            }).toList();
      }

      final response = await _apiClient.put('/routes/$id', body: {'data': body});
      
      // Handle new response format: { success: true, data: {...}, message: "..." }
      if (response is Map<String, dynamic> && response.containsKey('data')) {
        return _parseRoute(response['data'] as Map<String, dynamic>);
      }
      
      // Handle old response format: direct object
      return _parseRoute(response as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to update route: ${e.toString()}');
    }
  }

  /// Delete route
  Future<void> deleteRoute(String id) async {
    try {
      await _apiClient.delete('/routes/$id');
    } catch (e) {
      throw Exception('Failed to delete route: ${e.toString()}');
    }
  }

  /// Assign students to route
  Future<Map<String, dynamic>> assignStudentsToRoute(
    String routeId,
    List<String> studentIds, {
    String? busId,
  }) async {
    try {
      final response = await _apiClient.post(
        '/routes/$routeId/assign-students',
        body: {
          'data': {
            'student_ids': studentIds,
            if (busId != null) 'bus_id': busId,
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
      throw Exception('Failed to assign students: ${e.toString()}');
    }
  }

  Route _parseRoute(Map<String, dynamic> data) {
    final stopsData = data['stops'] as List<dynamic>?;
    final stops = stopsData
            ?.map((s) => _parseStop(s as Map<String, dynamic>))
            .toList() ??
        [];

    // Parse time strings (can be "HH:MM:SS" or full ISO datetime)
    DateTime parseTimeString(String timeStr) {
      try {
        // If it's just a time string like "19:00:00", combine with today's date
        if (timeStr.contains(':') && !timeStr.contains('T') && !timeStr.contains('-')) {
          final parts = timeStr.split(':');
          if (parts.length >= 2) {
            final now = DateTime.now();
            return DateTime(
              now.year,
              now.month,
              now.day,
              int.parse(parts[0]),
              int.parse(parts[1]),
              parts.length > 2 ? int.parse(parts[2]) : 0,
            );
          }
        }
        // Otherwise, parse as full datetime
        return DateTime.parse(timeStr);
      } catch (e) {
        // Fallback: try parsing as-is
        return DateTime.parse(timeStr);
      }
    }

    return Route(
      id: data['id'] as String,
      name: data['name'] as String,
      organizationId: data['organization_id'] as String? ?? '',
      startTime: parseTimeString(data['start_time'] as String),
      endTime: parseTimeString(data['end_time'] as String),
      assignedBusId: data['assigned_bus_id'] as String?,
      stops: stops,
    );
  }

  Stop _parseStop(Map<String, dynamic> data) {
    return Stop(
      id: data['id'] as String,
      name: data['name'] as String,
      latitude: (data['latitude'] as num).toDouble(),
      longitude: (data['longitude'] as num).toDouble(),
      order: (data['order'] as num).toInt(),
      estimatedArrivalTime: data['estimated_arrival_time'] != null
          ? DateTime.parse(data['estimated_arrival_time'] as String)
          : null,
      isCompleted: data['is_completed'] as bool? ?? false,
    );
  }
}

