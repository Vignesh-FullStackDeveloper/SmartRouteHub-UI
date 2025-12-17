import '../core/api/api_client.dart';
import 'api_client_service.dart';

/// Real API-based analytics service
class ApiAnalyticsService {
  final ApiClient _apiClient;

  ApiAnalyticsService({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClientService.instance;

  /// Get student travel history
  Future<Map<String, dynamic>> getStudentTravelHistory(
    String studentId, {
    String? startDate, // YYYY-MM-DD
    String? endDate, // YYYY-MM-DD
  }) async {
    try {
      final queryParams = <String, String>{};
      if (startDate != null) queryParams['start_date'] = startDate;
      if (endDate != null) queryParams['end_date'] = endDate;

      final response = await _apiClient.get(
        '/analytics/students/$studentId/travel-history',
        queryParams: queryParams.isEmpty ? null : queryParams,
      );
      // Handle new response format: { success: true, data: {...}, message: "..." }
      if (response is Map<String, dynamic> && response.containsKey('data')) {
        return response['data'] as Map<String, dynamic>;
      }
      
      // Handle old response format: direct object
      return response as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Failed to get student travel history: ${e.toString()}');
    }
  }

  /// Get bus travel history
  Future<Map<String, dynamic>> getBusTravelHistory(
    String busId, {
    String? startDate,
    String? endDate,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (startDate != null) queryParams['start_date'] = startDate;
      if (endDate != null) queryParams['end_date'] = endDate;

      final response = await _apiClient.get(
        '/analytics/buses/$busId/travel-history',
        queryParams: queryParams.isEmpty ? null : queryParams,
      );
      // Handle new response format: { success: true, data: {...}, message: "..." }
      if (response is Map<String, dynamic> && response.containsKey('data')) {
        return response['data'] as Map<String, dynamic>;
      }
      
      // Handle old response format: direct object
      return response as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Failed to get bus travel history: ${e.toString()}');
    }
  }

  /// Get driver travel history
  Future<Map<String, dynamic>> getDriverTravelHistory(
    String driverId, {
    String? startDate,
    String? endDate,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (startDate != null) queryParams['start_date'] = startDate;
      if (endDate != null) queryParams['end_date'] = endDate;

      final response = await _apiClient.get(
        '/analytics/drivers/$driverId/travel-history',
        queryParams: queryParams.isEmpty ? null : queryParams,
      );
      // Handle new response format: { success: true, data: {...}, message: "..." }
      if (response is Map<String, dynamic> && response.containsKey('data')) {
        return response['data'] as Map<String, dynamic>;
      }
      
      // Handle old response format: direct object
      return response as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Failed to get driver travel history: ${e.toString()}');
    }
  }

  /// Get dashboard insights
  Future<Map<String, dynamic>> getDashboardInsights() async {
    try {
      final response = await _apiClient.get('/analytics/dashboard');
      // Handle new response format: { success: true, data: {...}, message: "..." }
      if (response is Map<String, dynamic> && response.containsKey('data')) {
        return response['data'] as Map<String, dynamic>;
      }
      
      // Handle old response format: direct object
      return response as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Failed to get dashboard insights: ${e.toString()}');
    }
  }
}

