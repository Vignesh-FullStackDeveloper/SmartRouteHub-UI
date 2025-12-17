import '../core/api/api_client.dart';
import '../models/organization.dart';
import 'api_client_service.dart';

/// Real API-based organization service
class ApiOrgService {
  final ApiClient _apiClient;

  ApiOrgService({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClientService.instance;

  /// Get organization by ID
  Future<Organization> getOrganizationById(String id) async {
    try {
      final response = await _apiClient.get('/organizations/$id');
      
      // Handle new response format: { success: true, data: {...}, message: "..." }
      if (response is Map<String, dynamic> && response.containsKey('data')) {
        return _parseOrganization(response['data'] as Map<String, dynamic>);
      }
      
      // Handle old response format: direct object
      return _parseOrganization(response as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to get organization: ${e.toString()}');
    }
  }

  /// Get organization by code
  /// Note: Backend may need code as ID, or we need to add a code endpoint
  Future<Organization> getOrganizationByCode(String code) async {
    try {
      // Try using code as ID first (if backend supports it)
      // Otherwise, we may need to add a /organizations/code/:code endpoint
      final response = await _apiClient.get('/organizations/$code');
      
      // Handle new response format: { success: true, data: {...}, message: "..." }
      if (response is Map<String, dynamic> && response.containsKey('data')) {
        return _parseOrganization(response['data'] as Map<String, dynamic>);
      }
      
      // Handle old response format: direct object
      return _parseOrganization(response as Map<String, dynamic>);
    } catch (e) {
      // If not found, try searching through all (requires superadmin or different approach)
      throw Exception('Failed to get organization: ${e.toString()}');
    }
  }

  /// Create organization (with optional admin user)
  /// Returns organization and optionally admin user with token
  Future<Map<String, dynamic>> createOrganization({
    required String name,
    required String code,
    String primaryColor = '#2196F3',
    String? contactEmail,
    String? contactPhone,
    String? address,
    // Optional admin creation
    String? adminName,
    String? adminEmail,
    String? adminPassword,
    String? adminPhone,
  }) async {
    try {
      final body = <String, dynamic>{
        'name': name,
        'code': code,
        'primary_color': primaryColor,
      };

      if (contactEmail != null) body['contact_email'] = contactEmail;
      if (contactPhone != null) body['contact_phone'] = contactPhone;
      if (address != null) body['address'] = address;

      // Add admin if provided
      if (adminName != null && adminEmail != null && adminPassword != null) {
        body['admin'] = {
          'name': adminName,
          'email': adminEmail,
          'password': adminPassword,
          if (adminPhone != null) 'phone': adminPhone,
        };
      }

      final response = await _apiClient.post(
        '/organizations',
        body: {'data': body},
        includeAuth: false,
      );

      // Handle new response format: { success: true, data: {...}, message: "..." }
      if (response is Map<String, dynamic> && response.containsKey('data')) {
        return response['data'] as Map<String, dynamic>;
      }
      
      // Handle old response format: direct object
      return response as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Failed to create organization: ${e.toString()}');
    }
  }

  /// Create organization without admin (legacy method)
  Future<Organization> createOrganizationOnly({
    required String name,
    required String code,
    String primaryColor = '#2196F3',
    String? contactEmail,
    String? contactPhone,
    String? address,
  }) async {
    final response = await createOrganization(
      name: name,
      code: code,
      primaryColor: primaryColor,
      contactEmail: contactEmail,
      contactPhone: contactPhone,
      address: address,
    );
    return _parseOrganization(response);
  }

  /// Update organization
  Future<Organization> updateOrganization(
    String id, {
    String? name,
    String? code,
    String? primaryColor,
    String? contactEmail,
    String? contactPhone,
    String? address,
  }) async {
    try {
      final body = <String, dynamic>{};
      if (name != null) body['name'] = name;
      if (code != null) body['code'] = code;
      if (primaryColor != null) body['primary_color'] = primaryColor;
      if (contactEmail != null) body['contact_email'] = contactEmail;
      if (contactPhone != null) body['contact_phone'] = contactPhone;
      if (address != null) body['address'] = address;

      final response = await _apiClient.put('/organizations/$id', body: {'data': body});
      
      // Handle new response format: { success: true, data: {...}, message: "..." }
      if (response is Map<String, dynamic> && response.containsKey('data')) {
        return _parseOrganization(response['data'] as Map<String, dynamic>);
      }
      
      // Handle old response format: direct object
      return _parseOrganization(response as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to update organization: ${e.toString()}');
    }
  }

  Organization _parseOrganization(Map<String, dynamic> data) {
    return Organization(
      id: data['id'] as String,
      name: data['name'] as String,
      code: data['code'] as String,
      primaryColor: data['primary_color'] as String? ?? '#2196F3',
      contactEmail: data['contact_email'] as String?,
      contactPhone: data['contact_phone'] as String?,
      address: data['address'] as String?,
      logo: data['logo_url'] as String?,
    );
  }
}

