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

  User _parseUser(Map<String, dynamic> data) {
    final role = data['role'] as String;
    final organizationId = data['organization_id'] as String? ?? '';

    switch (role) {
      case 'admin':
        return AdminUser(
          id: data['id'] as String,
          name: data['name'] as String,
          email: data['email'] as String,
          phone: data['phone'] as String?,
          organizationId: organizationId,
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
        );
      default:
        throw Exception('Unknown user role: $role');
    }
  }
}

