import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/auth/auth_bloc.dart';
import '../blocs/auth/auth_state.dart';
import '../models/user.dart';
import '../core/utils/permission_checker.dart';

/// Widget that shows child only if user has required permission
class PermissionWrapper extends StatelessWidget {
  final Widget child;
  final String permission;
  final List<String>? anyPermissions;
  final List<String>? allPermissions;
  final Widget? fallback;

  PermissionWrapper({
    super.key,
    required this.child,
    this.permission = '',
    this.anyPermissions,
    this.allPermissions,
    this.fallback,
  }) : assert(
          permission.isNotEmpty || anyPermissions != null || allPermissions != null,
          'Must provide either permission, anyPermissions, or allPermissions',
        );

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is! AuthAuthenticated) {
          return fallback ?? const SizedBox.shrink();
        }

        final user = state.user;
        bool hasAccess = false;

        if (permission.isNotEmpty) {
          hasAccess = PermissionChecker.hasPermission(user, permission);
        } else if (anyPermissions != null && anyPermissions!.isNotEmpty) {
          hasAccess = PermissionChecker.hasAnyPermission(user, anyPermissions!);
        } else if (allPermissions != null && allPermissions!.isNotEmpty) {
          hasAccess = PermissionChecker.hasAllPermissions(user, allPermissions!);
        }

        return hasAccess ? child : (fallback ?? const SizedBox.shrink());
      },
    );
  }
}

/// Extension to easily check permissions in widgets
extension PermissionExtension on BuildContext {
  /// Check if current user has a permission
  bool hasPermission(String permission) {
    final authState = read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      return PermissionChecker.hasPermission(authState.user, permission);
    }
    return false;
  }

  /// Check if current user has any of the permissions
  bool hasAnyPermission(List<String> permissions) {
    final authState = read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      return PermissionChecker.hasAnyPermission(authState.user, permissions);
    }
    return false;
  }

  /// Get current authenticated user
  User? get currentUser {
    final authState = read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      return authState.user;
    }
    return null;
  }
}

