import '../core/api/api_client.dart';
import '../models/bus.dart';
import 'api_client_service.dart';

/// Real API-based bus service
class ApiBusService {
  final ApiClient _apiClient;

  ApiBusService({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClientService.instance;

  /// Get all buses
  Future<List<Bus>> getBuses({bool? isActive}) async {
    try {
      final queryParams = <String, String>{};
      if (isActive != null) queryParams['is_active'] = isActive.toString();

      final response = await _apiClient.get(
        '/buses',
        queryParams: queryParams.isEmpty ? null : queryParams,
      );

      if (response is List) {
        return response.map((e) => _parseBus(e as Map<String, dynamic>)).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to get buses: ${e.toString()}');
    }
  }

  /// Get bus by ID
  Future<Bus> getBusById(String id) async {
    try {
      final response = await _apiClient.get('/buses/$id');
      return _parseBus(response);
    } catch (e) {
      throw Exception('Failed to get bus: ${e.toString()}');
    }
  }

  /// Create bus
  Future<Bus> createBus({
    required String busNumber,
    required int capacity,
    String? driverId,
    String? assignedRouteId,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final response = await _apiClient.post(
        '/buses',
        body: {
          'bus_number': busNumber,
          'capacity': capacity,
          if (driverId != null) 'driver_id': driverId,
          if (assignedRouteId != null) 'assigned_route_id': assignedRouteId,
          if (metadata != null) 'metadata': metadata,
        },
      );
      return _parseBus(response);
    } catch (e) {
      throw Exception('Failed to create bus: ${e.toString()}');
    }
  }

  /// Update bus
  Future<Bus> updateBus(
    String id, {
    String? busNumber,
    int? capacity,
    String? driverId,
    String? assignedRouteId,
    bool? isActive,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final body = <String, dynamic>{};
      if (busNumber != null) body['bus_number'] = busNumber;
      if (capacity != null) body['capacity'] = capacity;
      if (driverId != null) body['driver_id'] = driverId;
      if (assignedRouteId != null) body['assigned_route_id'] = assignedRouteId;
      if (isActive != null) body['is_active'] = isActive;
      if (metadata != null) body['metadata'] = metadata;

      final response = await _apiClient.put('/buses/$id', body: body);
      return _parseBus(response);
    } catch (e) {
      throw Exception('Failed to update bus: ${e.toString()}');
    }
  }

  /// Delete bus
  Future<void> deleteBus(String id) async {
    try {
      await _apiClient.delete('/buses/$id');
    } catch (e) {
      throw Exception('Failed to delete bus: ${e.toString()}');
    }
  }

  /// Assign driver to bus
  Future<Bus> assignDriver(String busId, String driverId) async {
    try {
      final response = await _apiClient.post(
        '/buses/$busId/assign-driver',
        body: {'driver_id': driverId},
      );
      return _parseBus(response);
    } catch (e) {
      throw Exception('Failed to assign driver: ${e.toString()}');
    }
  }

  Bus _parseBus(Map<String, dynamic> data) {
    return Bus(
      id: data['id'] as String,
      busNumber: data['bus_number'] as String,
      capacity: (data['capacity'] as num).toInt(),
      driverId: data['driver_id'] as String?,
      assignedRouteId: data['assigned_route_id'] as String?,
      isActive: data['is_active'] as bool? ?? true,
      metadata: data['metadata'] as Map<String, dynamic>?,
    );
  }
}

