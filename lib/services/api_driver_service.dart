import '../core/api/api_client.dart';
import '../models/user.dart';
import 'api_client_service.dart';

/// Real API-based driver service
class ApiDriverService {
  final ApiClient _apiClient;

  ApiDriverService({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClientService.instance;

  /// Get all drivers
  Future<List<DriverUser>> getDrivers({
    bool? isActive,
    bool? hasBus,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (isActive != null) queryParams['is_active'] = isActive.toString();
      if (hasBus != null) queryParams['has_bus'] = hasBus.toString();

      final response = await _apiClient.get(
        '/drivers',
        queryParams: queryParams.isEmpty ? null : queryParams,
      );

      if (response is List) {
        return response.map((e) => _parseDriver(e as Map<String, dynamic>)).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to get drivers: ${e.toString()}');
    }
  }

  /// Get driver by ID
  Future<DriverUser> getDriverById(String id) async {
    try {
      final response = await _apiClient.get('/drivers/$id');
      return _parseDriver(response);
    } catch (e) {
      throw Exception('Failed to get driver: ${e.toString()}');
    }
  }

  /// Create driver
  Future<DriverUser> createDriver({
    required String name,
    required String email,
    required String password,
    required String driverId,
    String? phone,
  }) async {
    try {
      final response = await _apiClient.post(
        '/drivers',
        body: {
          'name': name,
          'email': email,
          'password': password,
          'driver_id': driverId,
          if (phone != null) 'phone': phone,
        },
      );
      return _parseDriver(response);
    } catch (e) {
      throw Exception('Failed to create driver: ${e.toString()}');
    }
  }

  /// Update driver
  Future<DriverUser> updateDriver(
    String id, {
    String? name,
    String? email,
    String? phone,
    String? driverId,
    bool? isActive,
    String? assignedBusId,
    String? assignedRouteId,
  }) async {
    try {
      final body = <String, dynamic>{};
      if (name != null) body['name'] = name;
      if (email != null) body['email'] = email;
      if (phone != null) body['phone'] = phone;
      if (driverId != null) body['driver_id'] = driverId;
      if (isActive != null) body['is_active'] = isActive;
      if (assignedBusId != null) body['assigned_bus_id'] = assignedBusId;
      if (assignedRouteId != null) body['assigned_route_id'] = assignedRouteId;

      final response = await _apiClient.put('/drivers/$id', body: body);
      return _parseDriver(response);
    } catch (e) {
      throw Exception('Failed to update driver: ${e.toString()}');
    }
  }

  /// Get driver schedule
  Future<Map<String, dynamic>> getDriverSchedule(String id) async {
    try {
      final response = await _apiClient.get('/drivers/$id/schedule');
      return response as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Failed to get driver schedule: ${e.toString()}');
    }
  }

  DriverUser _parseDriver(Map<String, dynamic> data) {
    return DriverUser(
      id: data['id'] as String,
      name: data['name'] as String,
      email: data['email'] as String,
      phone: data['phone'] as String?,
      organizationId: data['organization_id'] as String? ?? '',
      driverId: data['driver_id'] as String?,
      assignedBusId: data['assigned_bus_id'] as String?,
      assignedRouteId: data['assigned_route_id'] as String?,
      isActive: data['is_active'] as bool? ?? true,
    );
  }
}

