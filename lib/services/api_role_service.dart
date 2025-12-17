import '../core/api/api_client.dart';
import '../models/role.dart';
import 'api_client_service.dart';

/// API-based role service
class ApiRoleService {
  final ApiClient _apiClient;

  ApiRoleService({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClientService.instance;

  /// Get all roles
  Future<List<Role>> getAllRoles() async {
    try {
      final response = await _apiClient.get('/roles');
      
      // Handle new response format: { success: true, data: [...], message: "..." }
      if (response is Map<String, dynamic> && response.containsKey('data')) {
        final data = response['data'];
        if (data is List) {
          return data
              .map((json) => Role.fromJson(json as Map<String, dynamic>))
              .toList();
        }
      }
      
      // Handle old response format: direct list
      if (response is List) {
        return response
            .map((json) => Role.fromJson(json as Map<String, dynamic>))
            .toList();
      }
      
      throw Exception('Invalid response format');
    } catch (e) {
      throw Exception('Failed to get roles: ${e.toString()}');
    }
  }

  /// Get role by ID
  Future<Role> getRoleById(String id) async {
    try {
      final response = await _apiClient.get('/roles/$id');
      
      // Handle new response format: { success: true, data: {...}, message: "..." }
      if (response is Map<String, dynamic> && response.containsKey('data')) {
        return Role.fromJson(response['data'] as Map<String, dynamic>);
      }
      
      // Handle old response format: direct object
      return Role.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to get role: ${e.toString()}');
    }
  }

  /// Create a new role
  Future<Role> createRole({
    required String name,
    required List<String> permissionIds,
    String? description,
  }) async {
    try {
      if (permissionIds.isEmpty) {
        throw Exception('At least one permission is required');
      }

      final body = <String, dynamic>{
        'name': name,
        'permissionIds': permissionIds,
      };
      if (description != null && description.isNotEmpty) {
        body['description'] = description;
      }

      final response = await _apiClient.post('/roles', body: {'data': body});
      
      // Handle new response format: { success: true, data: {...}, message: "..." }
      if (response is Map<String, dynamic> && response.containsKey('data')) {
        return Role.fromJson(response['data'] as Map<String, dynamic>);
      }
      
      // Handle old response format: direct object
      return Role.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to create role: ${e.toString()}');
    }
  }

  /// Update role by ID
  Future<Role> updateRole(
    String roleId, {
    String? name,
    String? description,
    List<String>? permissionIds,
  }) async {
    try {
      final body = <String, dynamic>{};
      if (name != null) body['name'] = name;
      if (description != null) body['description'] = description;
      if (permissionIds != null) {
        if (permissionIds.isEmpty) {
          throw Exception('At least one permission is required');
        }
        body['permissionIds'] = permissionIds;
      }

      final response = await _apiClient.put('/roles/$roleId', body: {'data': body});
      
      // Handle new response format: { success: true, data: {...}, message: "..." }
      if (response is Map<String, dynamic> && response.containsKey('data')) {
        return Role.fromJson(response['data'] as Map<String, dynamic>);
      }
      
      // Handle old response format: direct object
      return Role.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to update role: ${e.toString()}');
    }
  }

  /// Delete role by ID
  Future<void> deleteRole(String roleId) async {
    try {
      await _apiClient.delete('/roles/$roleId');
    } catch (e) {
      // Re-throw ApiException as-is to preserve the error message
      if (e is ApiException) {
        rethrow;
      }
      throw Exception('Failed to delete role: ${e.toString()}');
    }
  }
}

