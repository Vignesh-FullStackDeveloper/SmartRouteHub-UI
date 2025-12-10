import '../models/organization.dart';

/// Mock organization service
/// Manages organization data and branding
class OrgService {
  // In-memory storage
  static final List<Organization> _organizations = [
    const Organization(
      id: 'org_1',
      name: 'Greenwood High School',
      code: 'GHS001',
      primaryColor: '#4CAF50',
      contactEmail: 'info@greenwood.edu',
      contactPhone: '+1234567890',
      address: '123 Education Street, City',
    ),
    const Organization(
      id: 'org_2',
      name: 'Sunshine Elementary',
      code: 'SES002',
      primaryColor: '#FF9800',
      contactEmail: 'contact@sunshine.edu',
      contactPhone: '+1234567891',
      address: '456 Learning Avenue, City',
    ),
  ];

  /// Get all organizations
  Future<List<Organization>> getAllOrganizations() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return List.unmodifiable(_organizations);
  }

  /// Get organization by code
  Future<Organization?> getOrganizationByCode(String code) async {
    await Future.delayed(const Duration(milliseconds: 300));
    try {
      return _organizations.firstWhere((org) => org.code == code);
    } catch (e) {
      return null;
    }
  }

  /// Get organization by ID
  Future<Organization?> getOrganizationById(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    try {
      return _organizations.firstWhere((org) => org.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Create new organization
  Future<Organization> createOrganization({
    required String name,
    required String code,
    String? logo,
    String primaryColor = '#2196F3',
    String? contactEmail,
    String? contactPhone,
    String? address,
  }) async {
    await Future.delayed(const Duration(seconds: 1));

    final org = Organization(
      id: 'org_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      code: code,
      logo: logo,
      primaryColor: primaryColor,
      contactEmail: contactEmail,
      contactPhone: contactPhone,
      address: address,
    );

    _organizations.add(org);
    return org;
  }
}

