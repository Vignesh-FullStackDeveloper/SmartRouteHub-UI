/// Permission constants for type-safe permission checking
class Permissions {
  // Student permissions
  static const String studentRead = 'student:read';
  static const String studentCreate = 'student:create';
  static const String studentUpdate = 'student:update';
  static const String studentDelete = 'student:delete';

  // Bus permissions
  static const String busRead = 'bus:read';
  static const String busCreate = 'bus:create';
  static const String busUpdate = 'bus:update';
  static const String busDelete = 'bus:delete';

  // Route permissions
  static const String routeRead = 'route:read';
  static const String routeCreate = 'route:create';
  static const String routeUpdate = 'route:update';
  static const String routeDelete = 'route:delete';

  // Trip permissions
  static const String tripRead = 'trip:read';
  static const String tripCreate = 'trip:create';
  static const String tripUpdate = 'trip:update';
  static const String tripDelete = 'trip:delete';

  // Location permissions
  static const String locationRead = 'location:read';
  static const String locationUpdate = 'location:update';

  // Organization permissions
  static const String organizationRead = 'organization:read';
  static const String organizationUpdate = 'organization:update';

  // User permissions
  static const String userRead = 'user:read';
  static const String userCreate = 'user:create';
  static const String userUpdate = 'user:update';
  static const String userDelete = 'user:delete';

  // Permission permissions
  static const String permissionCreate = 'permission:create';
  static const String permissionRead = 'permission:read';
  static const String permissionDelete = 'permission:delete';

  // Role permissions
  static const String roleCreate = 'role:create';
  static const String roleRead = 'role:read';
  static const String roleUpdate = 'role:update';
  static const String roleDelete = 'role:delete';

  // Permission groups for common checks
  static const List<String> studentManagement = [
    studentRead,
    studentCreate,
    studentUpdate,
    studentDelete,
  ];

  static const List<String> busManagement = [
    busRead,
    busCreate,
    busUpdate,
    busDelete,
  ];

  static const List<String> routeManagement = [
    routeRead,
    routeCreate,
    routeUpdate,
    routeDelete,
  ];

  static const List<String> userManagement = [
    userRead,
    userCreate,
    userUpdate,
    userDelete,
  ];

  static const List<String> roleManagement = [
    roleRead,
    roleCreate,
    roleUpdate,
    roleDelete,
  ];

  static const List<String> permissionManagement = [
    permissionRead,
    permissionCreate,
    permissionDelete,
  ];
}

