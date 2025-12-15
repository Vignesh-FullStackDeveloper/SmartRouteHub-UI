import '../core/api/api_client.dart';
import '../models/user.dart';
import 'api_client_service.dart';

/// Real API-based authentication service
class ApiAuthService {
  final ApiClient _apiClient;

  ApiAuthService({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClientService.instance;

  /// Login with email and password
  Future<User> login({
    required String email,
    required String password,
    String? organizationCode,
  }) async {
    try {
      final response = await _apiClient.post(
        '/auth/login',
        body: {
          'email': email,
          'password': password,
          if (organizationCode != null) 'organizationCode': organizationCode,
        },
        includeAuth: false,
      );

      // Save token
      if (response['token'] != null) {
        await _apiClient.saveToken(response['token']);
      }

      // Parse user from response
      final userData = response['user'] ?? response;
      return _parseUser(userData);
    } catch (e) {
      throw Exception('Login failed: ${e.toString()}');
    }
  }

  /// Verify token
  Future<User> verifyToken() async {
    try {
      final response = await _apiClient.get('/auth/verify');
      return _parseUser(response['user'] ?? response);
    } catch (e) {
      throw Exception('Token verification failed: ${e.toString()}');
    }
  }

  /// Logout
  Future<void> logout() async {
    try {
      // Send empty object to satisfy API requirement for application/json content-type
      await _apiClient.post('/auth/logout', body: {});
    } catch (e) {
      // Continue even if logout fails
    } finally {
      await _apiClient.clearToken();
    }
  }

  /// Create organization and admin in a single request
  /// Returns the admin user with token already set
  Future<User> createOrganizationAndAdmin({
    required String organizationName,
    required String organizationCode,
    required String adminName,
    required String adminEmail,
    String? adminPhone,
    required String adminPassword,
    String primaryColor = '#2196F3',
    String? contactEmail,
    String? contactPhone,
    String? address,
  }) async {
    try {
      // Create organization with admin in single request
      final body = <String, dynamic>{
        'name': organizationName,
        'code': organizationCode,
        'primary_color': primaryColor,
      };

      // Add optional organization fields
      if (contactEmail != null && contactEmail.isNotEmpty) {
        body['contact_email'] = contactEmail;
      }
      if (contactPhone != null && contactPhone.isNotEmpty) {
        body['contact_phone'] = contactPhone;
      }
      if (address != null && address.isNotEmpty) {
        body['address'] = address;
      }

      // Add admin object
      body['admin'] = {
        'name': adminName,
        'email': adminEmail,
        'password': adminPassword,
        if (adminPhone != null && adminPhone.isNotEmpty) 'phone': adminPhone,
      };

      final response = await _apiClient.post(
        '/organizations',
        body: body,
        includeAuth: false,
      );

      // Response includes organization and admin with token
      final responseData = response as Map<String, dynamic>;
      
      // Check if admin was created and token is present
      if (responseData['admin'] != null) {
        final adminData = responseData['admin'] as Map<String, dynamic>;
        
        // Save token if present
        if (adminData['token'] != null) {
          await _apiClient.saveToken(adminData['token'] as String);
        }

        // Parse and return user
        // The user object should have organization_id from the response
        final userData = adminData['user'] as Map<String, dynamic>;
        
        // Ensure organization_id is set from the organization in response
        if (responseData['id'] != null && userData['organization_id'] == null) {
          userData['organization_id'] = responseData['id'];
        }
        
        return _parseUser(userData);
      } else {
        // Admin not created, throw error
        throw Exception('Admin user was not created');
      }
    } catch (e) {
      throw Exception('Failed to create organization: ${e.toString()}');
    }
  }

  /// Login driver (placeholder - backend may need OTP endpoint)
  Future<User> loginDriver({
    required String organizationCode,
    required String phone,
    String? driverId,
    required String otp,
  }) async {
    // For now, use regular login with phone as email
    // Backend may need separate OTP endpoint
    try {
      return await login(
        email: phone, // Use phone as identifier
        password: otp, // Use OTP as password (temporary)
        organizationCode: organizationCode,
      );
    } catch (e) {
      throw Exception('Driver login failed: ${e.toString()}');
    }
  }

  /// Login parent
  Future<User> loginParent({
    required String organizationCode,
    String? phone,
    String? email,
    String? otp,
    String? password,
  }) async {
    try {
      if (email != null && password != null) {
        return await login(
          email: email,
          password: password,
          organizationCode: organizationCode,
        );
      } else if (phone != null && otp != null) {
        // Use phone as email and OTP as password for now
        return await login(
          email: phone,
          password: otp,
          organizationCode: organizationCode,
        );
      } else {
        throw Exception('Invalid login method');
      }
    } catch (e) {
      throw Exception('Parent login failed: ${e.toString()}');
    }
  }

  /// Send OTP (placeholder - backend may need OTP endpoint)
  Future<void> sendOtp(String phone) async {
    // Backend may need separate OTP endpoint
    // For now, this is a placeholder
    await Future.delayed(const Duration(seconds: 1));
    // In production, call: POST /api/auth/send-otp
  }

  /// Get current user from stored token
  User? getCurrentUser() {
    // This should get user from stored token
    // For now, return null - user should be stored in AuthBloc state
    return null;
  }

  /// Parse user from API response
  User _parseUser(Map<String, dynamic> data) {
    final role = data['role'] as String;
    final organizationId = data['organization_id'] as String?;
    
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
          organizationId: organizationId ?? '',
          permissions: permissions,
        );
      case 'driver':
        return DriverUser(
          id: data['id'] as String,
          name: data['name'] as String,
          email: data['email'] as String,
          phone: data['phone'] as String?,
          organizationId: organizationId ?? '',
          driverId: data['driver_id'] as String?,
          assignedBusId: data['assigned_bus_id'] as String?,
          assignedRouteId: data['assigned_route_id'] as String?,
          permissions: permissions,
        );
      case 'parent':
        return ParentUser(
          id: data['id'] as String,
          name: data['name'] as String,
          email: data['email'] as String,
          phone: data['phone'] as String?,
          organizationId: organizationId ?? '',
          childrenIds: (data['children_ids'] as List<dynamic>?)
                  ?.map((e) => e.toString())
                  .toList() ??
              [],
          permissions: permissions,
        );
      case 'superadmin':
        return AdminUser(
          id: data['id'] as String,
          name: data['name'] as String,
          email: data['email'] as String,
          phone: data['phone'] as String?,
          organizationId: '', // Superadmin has no org
          permissions: permissions,
        );
      default:
        throw Exception('Unknown user role: $role');
    }
  }
}

