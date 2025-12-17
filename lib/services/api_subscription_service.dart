import '../core/api/api_client.dart';
import 'api_client_service.dart';

/// Real API-based subscription service
class ApiSubscriptionService {
  final ApiClient _apiClient;

  ApiSubscriptionService({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClientService.instance;

  /// Create subscription
  Future<Map<String, dynamic>> createSubscription({
    required String studentId,
    required String validFrom, // YYYY-MM-DD
    required String validUntil, // YYYY-MM-DD
    double? amountPaid,
    String? paymentMethod,
    String? notes,
  }) async {
    try {
      final body = <String, dynamic>{
        'student_id': studentId,
        'valid_from': validFrom,
        'valid_until': validUntil,
        if (amountPaid != null) 'amount_paid': amountPaid,
        if (paymentMethod != null) 'payment_method': paymentMethod,
        if (notes != null) 'notes': notes,
      };

      final response = await _apiClient.post('/subscriptions', body: {'data': body});
      
      // Handle new response format: { success: true, data: {...}, message: "..." }
      if (response is Map<String, dynamic> && response.containsKey('data')) {
        return response['data'] as Map<String, dynamic>;
      }
      
      // Handle old response format: direct object
      return response as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Failed to create subscription: ${e.toString()}');
    }
  }

  /// Get student subscriptions
  Future<List<Map<String, dynamic>>> getStudentSubscriptions(String studentId) async {
    try {
      final response = await _apiClient.get('/subscriptions/student/$studentId');
      
      // Handle new response format: { success: true, data: [...], message: "..." }
      if (response is Map<String, dynamic> && response.containsKey('data')) {
        final data = response['data'];
        if (data is List) {
          return data.map((e) => e as Map<String, dynamic>).toList();
        }
      }
      
      // Handle old response format: direct list
      if (response is List) {
        return response.map((e) => e as Map<String, dynamic>).toList();
      }
      
      return [];
    } catch (e) {
      throw Exception('Failed to get subscriptions: ${e.toString()}');
    }
  }

  /// Get active subscription
  Future<Map<String, dynamic>?> getActiveSubscription(String studentId) async {
    try {
      final response = await _apiClient.get('/subscriptions/student/$studentId/active');
      
      // Handle new response format: { success: true, data: {...}, message: "..." }
      Map<String, dynamic> data;
      if (response is Map<String, dynamic> && response.containsKey('data')) {
        data = response['data'] as Map<String, dynamic>;
      } else {
        data = response as Map<String, dynamic>;
      }
      
      if (data['active'] == true) {
        return data['subscription'] as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get active subscription: ${e.toString()}');
    }
  }

  /// Update subscription
  Future<Map<String, dynamic>> updateSubscription(
    String id, {
    String? validFrom,
    String? validUntil,
    double? amountPaid,
    String? paymentMethod,
    String? notes,
    String? status, // 'active', 'expired', 'cancelled'
  }) async {
    try {
      final body = <String, dynamic>{};
      if (validFrom != null) body['valid_from'] = validFrom;
      if (validUntil != null) body['valid_until'] = validUntil;
      if (amountPaid != null) body['amount_paid'] = amountPaid;
      if (paymentMethod != null) body['payment_method'] = paymentMethod;
      if (notes != null) body['notes'] = notes;
      if (status != null) body['status'] = status;

      final response = await _apiClient.put('/subscriptions/$id', body: {'data': body});
      
      // Handle new response format: { success: true, data: {...}, message: "..." }
      if (response is Map<String, dynamic> && response.containsKey('data')) {
        return response['data'] as Map<String, dynamic>;
      }
      
      // Handle old response format: direct object
      return response as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Failed to update subscription: ${e.toString()}');
    }
  }

  /// Get expiring subscriptions
  Future<Map<String, dynamic>> getExpiringSubscriptions({int days = 30}) async {
    try {
      final response = await _apiClient.get(
        '/subscriptions/expiring',
        queryParams: {'days': days.toString()},
      );
      
      // Handle new response format: { success: true, data: {...}, message: "..." }
      if (response is Map<String, dynamic> && response.containsKey('data')) {
        return response['data'] as Map<String, dynamic>;
      }
      
      // Handle old response format: direct object
      return response as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Failed to get expiring subscriptions: ${e.toString()}');
    }
  }
}

