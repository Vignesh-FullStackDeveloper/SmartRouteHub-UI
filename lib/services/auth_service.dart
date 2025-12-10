import '../models/user.dart';
import '../core/constants/app_constants.dart';
import 'org_service.dart';

/// Mock authentication service
/// This service handles login/logout for all user roles with dummy data
class AuthService {
  final OrgService _orgService = OrgService();
  // In-memory storage for demo purposes
  static User? _currentUser;
  static final List<AdminUser> _adminUsers = [
    // Dummy admin for easy testing - accepts both 'org_1' and 'GHS001'
    const AdminUser(
      id: 'admin_dummy',
      name: 'Admin User',
      email: 'admin@test.com',
      phone: '+1234567890',
      organizationId: 'org_1', // This maps to code 'GHS001' in org service
    ),
  ];
  static final List<DriverUser> _driverUsers = [];
  static final List<ParentUser> _parentUsers = [];

  /// Login as Admin with email/phone and password
  Future<User?> loginAdmin({
    required String organizationCode,
    required String emailOrPhone,
    required String password,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));

    // Dummy validation - accept any password for demo
    // Also accept common test credentials
    // Accept both 'org_1' (id) and 'GHS001' (code) for organization
    try {
      final admin = _adminUsers.firstWhere(
        (a) => (a.organizationId == organizationCode || 
                organizationCode == 'GHS001' || 
                organizationCode == 'org_1') &&
            (a.email == emailOrPhone || 
             a.phone == emailOrPhone ||
             emailOrPhone.toLowerCase() == 'admin' ||
             emailOrPhone.toLowerCase() == 'admin@test.com'),
        orElse: () => throw Exception('Invalid credentials'),
      );

      _currentUser = admin;
      return admin;
    } catch (e) {
      // If not found, create a new admin for demo purposes
      // Normalize org code to 'org_1' for consistency
      final normalizedOrgCode = (organizationCode == 'GHS001') ? 'org_1' : organizationCode;
      final newAdmin = AdminUser(
        id: 'admin_${DateTime.now().millisecondsSinceEpoch}',
        name: 'Admin User',
        email: emailOrPhone.contains('@') ? emailOrPhone : '$emailOrPhone@test.com',
        phone: emailOrPhone.contains('@') ? null : emailOrPhone,
        organizationId: normalizedOrgCode,
      );
      _adminUsers.add(newAdmin);
      _currentUser = newAdmin;
      return newAdmin;
    }
  }

  /// Create new organization and admin user
  Future<User> createOrganizationAndAdmin({
    required String organizationName,
    required String organizationCode,
    required String adminName,
    required String adminEmail,
    required String adminPhone,
    required String adminPassword,
    String primaryColor = '#2196F3',
  }) async {
    await Future.delayed(const Duration(seconds: 1));

    // Create organization
    await _orgService.createOrganization(
      name: organizationName,
      code: organizationCode,
      primaryColor: primaryColor,
      contactEmail: adminEmail,
      contactPhone: adminPhone,
    );

    // Create admin user
    final admin = AdminUser(
      id: 'admin_${DateTime.now().millisecondsSinceEpoch}',
      name: adminName,
      email: adminEmail,
      phone: adminPhone,
      organizationId: organizationCode,
    );

    _adminUsers.add(admin);
    _currentUser = admin;
    return admin;
  }

  /// Login as Driver with OTP
  Future<User?> loginDriver({
    required String organizationCode,
    required String phone,
    String? driverId,
    required String otp,
  }) async {
    await Future.delayed(const Duration(seconds: 1));

    // Validate OTP (dummy OTP is 123456)
    if (otp != AppConstants.dummyOtp) {
      throw Exception('Invalid OTP');
    }

    // Find or create driver
    DriverUser? driver = _driverUsers.firstWhere(
      (d) => d.phone == phone && d.organizationId == organizationCode,
      orElse: () => DriverUser(
        id: 'driver_${DateTime.now().millisecondsSinceEpoch}',
        name: 'Driver ${phone.substring(phone.length - 4)}',
        email: 'driver_$phone@example.com',
        phone: phone,
        organizationId: organizationCode,
        driverId: driverId ?? 'DRV${phone.substring(phone.length - 4)}',
        assignedBusId: 'bus_1',
        assignedRouteId: 'route_1',
      ),
    );

    if (!_driverUsers.contains(driver)) {
      _driverUsers.add(driver);
    }

    _currentUser = driver;
    return driver;
  }

  /// Login as Parent with phone + OTP or email + password
  Future<User?> loginParent({
    required String organizationCode,
    String? phone,
    String? email,
    String? otp,
    String? password,
  }) async {
    await Future.delayed(const Duration(seconds: 1));

    if (phone != null && otp != null) {
      // Phone + OTP login
      if (otp != AppConstants.dummyOtp) {
        throw Exception('Invalid OTP');
      }
    } else if (email != null && password != null) {
      // Email + password login (dummy validation)
    } else {
      throw Exception('Invalid login method');
    }

    // Find or create parent
    ParentUser? parent = _parentUsers.firstWhere(
      (p) => (phone != null && p.phone == phone) ||
          (email != null && p.email == email),
      orElse: () => ParentUser(
        id: 'parent_${DateTime.now().millisecondsSinceEpoch}',
        name: 'Parent ${phone ?? email}',
        email: email ?? 'parent_$phone@example.com',
        phone: phone,
        organizationId: organizationCode,
        childrenIds: ['child_1', 'child_2'],
      ),
    );

    if (!_parentUsers.contains(parent)) {
      _parentUsers.add(parent);
    }

    _currentUser = parent;
    return parent;
  }

  /// Get current logged-in user
  User? getCurrentUser() => _currentUser;

  /// Logout current user
  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _currentUser = null;
  }

  /// Send OTP (dummy implementation)
  Future<void> sendOtp(String phone) async {
    await Future.delayed(const Duration(seconds: 1));
    // In real app, this would send OTP via SMS
    // For demo, OTP is always 123456
  }
}

