import '../../models/user.dart';

/// Utility class for checking user permissions
class PermissionChecker {
  /// Check if user has a specific permission
  static bool hasPermission(User user, String permission) {
    // Check permissions for all user types (AdminUser, DriverUser, ParentUser)
    if (user.permissions.isNotEmpty) {
      return user.permissions.contains(permission);
    }
    // If no permissions list, default to role-based access
    // This is a fallback for backward compatibility
    return _hasRoleBasedAccess(user.role, permission);
  }

  /// Check if user has any of the provided permissions
  static bool hasAnyPermission(User user, List<String> permissions) {
    // Check permissions for all user types
    if (user.permissions.isNotEmpty) {
      return permissions.any((permission) => user.permissions.contains(permission));
    }
    return permissions.any((permission) => _hasRoleBasedAccess(user.role, permission));
  }

  /// Check if user has all of the provided permissions
  static bool hasAllPermissions(User user, List<String> permissions) {
    // Check permissions for all user types
    if (user.permissions.isNotEmpty) {
      return permissions.every((permission) => user.permissions.contains(permission));
    }
    return permissions.every((permission) => _hasRoleBasedAccess(user.role, permission));
  }

  /// Check if user can read a resource (has read permission)
  static bool canRead(User user, String resource) {
    return hasPermission(user, '$resource:read');
  }

  /// Check if user can create a resource (has create permission)
  static bool canCreate(User user, String resource) {
    return hasPermission(user, '$resource:create');
  }

  /// Check if user can update a resource (has update permission)
  static bool canUpdate(User user, String resource) {
    return hasPermission(user, '$resource:update');
  }

  /// Check if user can delete a resource (has delete permission)
  static bool canDelete(User user, String resource) {
    return hasPermission(user, '$resource:delete');
  }

  /// Fallback role-based access check (for backward compatibility)
  /// This assumes full access for admin role if permissions are not set
  static bool _hasRoleBasedAccess(UserRole role, String permission) {
    // If permissions are not set, default to admin having all access
    // This maintains backward compatibility
    return role == UserRole.admin;
  }
}

