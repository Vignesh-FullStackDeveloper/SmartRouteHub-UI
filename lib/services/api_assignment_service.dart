import '../core/api/api_client.dart';
import 'api_client_service.dart';

/// Real API-based assignment service
class ApiAssignmentService {
  final ApiClient _apiClient;

  ApiAssignmentService({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClientService.instance;

  /// Assign students to route
  Future<Map<String, dynamic>> assignStudentsToRoute({
    required List<String> studentIds,
    required String routeId,
    String? busId,
  }) async {
    try {
      final response = await _apiClient.post(
        '/assignments/students-to-route',
        body: {
          'student_ids': studentIds,
          'route_id': routeId,
          if (busId != null) 'bus_id': busId,
        },
      );
      return response as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Failed to assign students to route: ${e.toString()}');
    }
  }

  /// Assign students to bus
  Future<Map<String, dynamic>> assignStudentsToBus({
    required List<String> studentIds,
    required String busId,
  }) async {
    try {
      final response = await _apiClient.post(
        '/assignments/students-to-bus',
        body: {
          'student_ids': studentIds,
          'bus_id': busId,
        },
      );
      return response as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Failed to assign students to bus: ${e.toString()}');
    }
  }

  /// Get route assignments (which students in which route)
  Future<Map<String, dynamic>> getRouteAssignments(String routeId) async {
    try {
      final response = await _apiClient.get('/assignments/route/$routeId/students');
      return response as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Failed to get route assignments: ${e.toString()}');
    }
  }

  /// Get bus assignments (which students in which bus)
  Future<Map<String, dynamic>> getBusAssignments(String busId) async {
    try {
      final response = await _apiClient.get('/assignments/bus/$busId/students');
      return response as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Failed to get bus assignments: ${e.toString()}');
    }
  }
}

