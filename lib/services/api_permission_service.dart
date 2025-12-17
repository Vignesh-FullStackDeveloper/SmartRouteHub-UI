import '../core/api/api_client.dart';
import '../models/permission.dart';
import 'api_client_service.dart';

/// API-based permission service
class ApiPermissionService {
  final ApiClient _apiClient;

  ApiPermissionService({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClientService.instance;

  /// Get all permissions
  Future<List<Permission>> getAllPermissions() async {
    try {
      final response = await _apiClient.get('/permissions');
      
      // Handle new response format: { success: true, data: [...], message: "..." }
      if (response is Map<String, dynamic> && response.containsKey('data')) {
        final data = response['data'];
        if (data is List) {
          return data
              .map((json) => Permission.fromJson(json as Map<String, dynamic>))
              .toList();
        }
      }
      
      // Handle old response format: direct list
      if (response is List) {
        return response
            .map((json) => Permission.fromJson(json as Map<String, dynamic>))
            .toList();
      }
      
      throw Exception('Invalid response format');
    } catch (e) {
      throw Exception('Failed to get permissions: ${e.toString()}');
    }
  }

  /// Get permission by ID
  Future<Permission> getPermissionById(String id) async {
    try {
      final response = await _apiClient.get('/permissions/$id');
      
      // Handle new response format: { success: true, data: {...}, message: "..." }
      if (response is Map<String, dynamic> && response.containsKey('data')) {
        return Permission.fromJson(response['data'] as Map<String, dynamic>);
      }
      
      // Handle old response format: direct object
      return Permission.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to get permission: ${e.toString()}');
    }
  }

  /// Create a new permission
  Future<Permission> createPermission({
    required String name,
    required String code,
    String? description,
  }) async {
    try {
      final body = <String, dynamic>{
        'name': name,
        'code': code,
      };
      if (description != null && description.isNotEmpty) {
        body['description'] = description;
      }

      final response = await _apiClient.post('/permissions', body: {'data': body});
      
      // Handle new response format: { success: true, data: {...}, message: "..." }
      if (response is Map<String, dynamic> && response.containsKey('data')) {
        return Permission.fromJson(response['data'] as Map<String, dynamic>);
      }
      
      // Handle old response format: direct object
      return Permission.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to create permission: ${e.toString()}');
    }
  }

  /// Delete permission by ID
  Future<void> deletePermission(String permissionId) async {
    try {
      await _apiClient.delete('/permissions/$permissionId');
    } catch (e) {
      throw Exception('Failed to delete permission: ${e.toString()}');
    }
  }
}

