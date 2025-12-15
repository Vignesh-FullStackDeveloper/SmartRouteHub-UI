import '../core/api/api_client.dart';
import '../models/user.dart';
import 'api_client_service.dart';

/// Real API-based user service (for profile management)
class ApiUserService {
  final ApiClient _apiClient;

  ApiUserService({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClientService.instance;

  /// Get current user profile
  Future<User> getCurrentUser() async {
    try {
      // Get user ID from token or stored user
      // For now, we'll need to get it from auth service
      // This should be called after login
      throw UnimplementedError('Get current user from stored token');
    } catch (e) {
      throw Exception('Failed to get user: ${e.toString()}');
    }
  }

  /// Get all users
  Future<List<User>> getAllUsers() async {
    try {
      final response = await _apiClient.get('/users');
      if (response is List) {
        return response
            .map((json) => _parseUser(json as Map<String, dynamic>))
            .toList();
      }
      throw Exception('Invalid response format');
    } catch (e) {
      throw Exception('Failed to get users: ${e.toString()}');
    }
  }

  /// Get user by ID
  Future<User> getUserById(String id) async {
    try {
      final response = await _apiClient.get('/users/$id');
      return _parseUser(response);
    } catch (e) {
      throw Exception('Failed to get user: ${e.toString()}');
    }
  }

  /// Update user profile
  Future<User> updateProfile({
    String? name,
    String? email,
    String? phone,
  }) async {
    try {
      // Get current user ID - this should come from auth state
      // For now, we'll need to pass it
      throw UnimplementedError('Update profile - need user ID from auth');
    } catch (e) {
      throw Exception('Failed to update profile: ${e.toString()}');
    }
  }

  /// Update user profile by ID
  Future<User> updateUserProfile(
    String userId, {
    String? name,
    String? email,
    String? phone,
  }) async {
    try {
      final body = <String, dynamic>{};
      if (name != null) body['name'] = name;
      if (email != null) body['email'] = email;
      if (phone != null) body['phone'] = phone;

      final response = await _apiClient.put('/users/$userId', body: body);
      return _parseUser(response);
    } catch (e) {
      throw Exception('Failed to update profile: ${e.toString()}');
    }
  }

  /// Update user by ID (full update with all optional fields)
  Future<User> updateUser(
    String userId, {
    String? name,
    String? email,
    String? phone,
    bool? isActive,
    String? roleId,
  }) async {
    try {
      final body = <String, dynamic>{};
      if (name != null) body['name'] = name;
      if (email != null) body['email'] = email;
      if (phone != null) body['phone'] = phone;
      if (isActive != null) body['is_active'] = isActive;
      if (roleId != null) body['role_id'] = roleId;

      final response = await _apiClient.put('/users/$userId', body: body);
      return _parseUser(response);
    } catch (e) {
      throw Exception('Failed to update user: ${e.toString()}');
    }
  }

  /// Delete user (soft delete - sets is_active to false)
  Future<void> deleteUser(String userId) async {
    try {
      await _apiClient.delete('/users/$userId');
    } catch (e) {
      throw Exception('Failed to delete user: ${e.toString()}');
    }
  }

  /// Create a new user
  Future<User> createUser({
    required String name,
    required String email,
    required String password,
    required String role,
    required String roleId,
    String? phone,
    String? driverId,
  }) async {
    try {
      final body = <String, dynamic>{
        'name': name,
        'email': email,
        'password': password,
        'role': role,
        'role_id': roleId,
      };
      if (phone != null && phone.isNotEmpty) {
        body['phone'] = phone;
      }
      if (driverId != null && driverId.isNotEmpty) {
        body['driver_id'] = driverId;
      }

      final response = await _apiClient.post('/users', body: body);
      return _parseUser(response as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to create user: ${e.toString()}');
    }
  }

  User _parseUser(Map<String, dynamic> data) {
    final role = data['role'] as String;
    final organizationId = data['organization_id'] as String? ?? '';
    
    // Parse permissions from response
    final permissions = (data['permissions'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        [];

    switch (role) {
      case 'admin':
        return AdminUser(
          id: data['id'] as String,
          name: data['name'] as String,
          email: data['email'] as String,
          phone: data['phone'] as String?,
          organizationId: organizationId,
          permissions: permissions,
        );
      case 'driver':
        return DriverUser(
          id: data['id'] as String,
          name: data['name'] as String,
          email: data['email'] as String,
          phone: data['phone'] as String?,
          organizationId: organizationId,
          driverId: data['driver_id'] as String?,
          assignedBusId: data['assigned_bus_id'] as String?,
          assignedRouteId: data['assigned_route_id'] as String?,
          isActive: data['is_active'] as bool? ?? true,
          permissions: permissions,
        );
      case 'parent':
        return ParentUser(
          id: data['id'] as String,
          name: data['name'] as String,
          email: data['email'] as String,
          phone: data['phone'] as String?,
          organizationId: organizationId,
          childrenIds: (data['children_ids'] as List<dynamic>?)
                  ?.map((e) => e.toString())
                  .toList() ??
              [],
          permissions: permissions,
        );
      default:
        throw Exception('Unknown user role: $role');
    }
  }
}

