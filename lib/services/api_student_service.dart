import '../core/api/api_client.dart';
import '../models/student.dart';
import 'api_client_service.dart';

/// Real API-based student service
class ApiStudentService {
  final ApiClient _apiClient;

  ApiStudentService({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClientService.instance;

  /// Get all students
  Future<List<Student>> getStudents({
    String? busId,
    String? routeId,
    String? classGrade,
    String? parentId,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (busId != null) queryParams['bus_id'] = busId;
      if (routeId != null) queryParams['route_id'] = routeId;
      if (classGrade != null) queryParams['class_grade'] = classGrade;
      if (parentId != null) queryParams['parent_id'] = parentId;

      final response = await _apiClient.get(
        '/students',
        queryParams: queryParams.isEmpty ? null : queryParams,
      );

      // Handle new response format: { success: true, data: [...], message: "..." }
      if (response is Map<String, dynamic>) {
        if (response.containsKey('data')) {
          final data = response['data'];
          if (data is List) {
            return data.map((e) => _parseStudent(e as Map<String, dynamic>)).toList();
          }
        }
      }
      
      // Handle old response format: direct list
      if (response is List) {
        return response.map((e) => _parseStudent(e as Map<String, dynamic>)).toList();
      }
      
      return [];
    } catch (e) {
      throw Exception('Failed to get students: ${e.toString()}');
    }
  }

  /// Get student by ID
  Future<Student> getStudentById(String id) async {
    try {
      final response = await _apiClient.get('/students/$id');
      
      // Handle new response format: { success: true, data: {...}, message: "..." }
      if (response is Map<String, dynamic>) {
        if (response.containsKey('data')) {
          return _parseStudent(response['data'] as Map<String, dynamic>);
        }
      }
      
      // Handle old response format: direct object
      return _parseStudent(response as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to get student: ${e.toString()}');
    }
  }

  /// Create student
  Future<Student> createStudent({
    required String name,
    required String classGrade,
    required String section,
    required String parentContact,
    required String parentId,
    String? pickupPointId,
    String? assignedRouteId,
    bool? isActive,
  }) async {
    try {
      final response = await _apiClient.post(
        '/students',
        body: {
          'data': {
            'name': name,
            'class_grade': classGrade,
            'section': section,
            'parent_contact': parentContact,
            'parent_id': parentId,
            if (pickupPointId != null) 'pickup_point_id': pickupPointId,
            if (assignedRouteId != null) 'assigned_route_id': assignedRouteId,
            if (isActive != null) 'is_active': isActive,
          },
        },
      );
      
      // Handle new response format: { success: true, data: {...}, message: "..." }
      if (response is Map<String, dynamic>) {
        if (response.containsKey('data')) {
          return _parseStudent(response['data'] as Map<String, dynamic>);
        }
      }
      
      // Handle old response format: direct object
      return _parseStudent(response as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to create student: ${e.toString()}');
    }
  }

  /// Update student
  Future<Student> updateStudent(
    String id, {
    String? name,
    String? classGrade,
    String? section,
    String? parentContact,
    String? parentId,
    String? pickupPointId,
    String? assignedRouteId,
    bool? isActive,
  }) async {
    try {
      final body = <String, dynamic>{};
      if (name != null) body['name'] = name;
      if (classGrade != null) body['class_grade'] = classGrade;
      if (section != null) body['section'] = section;
      if (parentContact != null) body['parent_contact'] = parentContact;
      if (parentId != null) body['parent_id'] = parentId;
      if (pickupPointId != null) body['pickup_point_id'] = pickupPointId;
      if (assignedRouteId != null) body['assigned_route_id'] = assignedRouteId;
      if (isActive != null) body['is_active'] = isActive;

      final response = await _apiClient.put('/students/$id', body: {'data': body});
      
      // Handle new response format: { success: true, data: {...}, message: "..." }
      if (response is Map<String, dynamic>) {
        if (response.containsKey('data')) {
          return _parseStudent(response['data'] as Map<String, dynamic>);
        }
      }
      
      // Handle old response format: direct object
      return _parseStudent(response as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to update student: ${e.toString()}');
    }
  }

  /// Delete student
  Future<void> deleteStudent(String id) async {
    try {
      await _apiClient.delete('/students/$id');
    } catch (e) {
      throw Exception('Failed to delete student: ${e.toString()}');
    }
  }

  /// Get student pickup location
  Future<Map<String, dynamic>> getPickupLocation(String id) async {
    try {
      final response = await _apiClient.get('/students/$id/pickup-location');
      return response as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Failed to get pickup location: ${e.toString()}');
    }
  }

  Student _parseStudent(Map<String, dynamic> data) {
    return Student(
      id: data['id'] as String,
      name: data['name'] as String,
      classGrade: data['class_grade'] as String,
      section: data['section'] as String,
      organizationId: data['organization_id'] as String? ?? '',
      parentId: data['parent_id'] as String?,
      parentContact: data['parent_contact'] as String,
      pickupPointId: data['pickup_point_id'] as String?,
      assignedBusId: data['assigned_bus_id'] as String?,
      assignedRouteId: data['assigned_route_id'] as String?,
      isActive: data['is_active'] as bool? ?? true,
    );
  }
}

