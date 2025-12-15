import 'package:equatable/equatable.dart';

/// User role enum
enum UserRole {
  admin,
  driver,
  parent,
}

/// Base user model
class User extends Equatable {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final UserRole role;
  final String organizationId;
  final List<String> permissions;

  const User({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    required this.role,
    required this.organizationId,
    this.permissions = const [],
  });

  @override
  List<Object?> get props => [id, name, email, phone, role, organizationId, permissions];
}

/// Admin user model
class AdminUser extends User {
  const AdminUser({
    required super.id,
    required super.name,
    required super.email,
    super.phone,
    required super.organizationId,
    super.permissions = const [],
  }) : super(role: UserRole.admin);
}

/// Driver user model
class DriverUser extends User {
  final String? driverId;
  final String? assignedBusId;
  final String? assignedRouteId;
  final bool isActive;

  const DriverUser({
    required super.id,
    required super.name,
    required super.email,
    super.phone,
    required super.organizationId,
    this.driverId,
    this.assignedBusId,
    this.assignedRouteId,
    this.isActive = true,
    super.permissions = const [],
  }) : super(role: UserRole.driver);

  @override
  List<Object?> get props => [
        ...super.props,
        driverId,
        assignedBusId,
        assignedRouteId,
        isActive,
      ];
}

/// Parent user model
class ParentUser extends User {
  final List<String> childrenIds;

  const ParentUser({
    required super.id,
    required super.name,
    required super.email,
    super.phone,
    required super.organizationId,
    this.childrenIds = const [],
    super.permissions = const [],
  }) : super(role: UserRole.parent);

  @override
  List<Object?> get props => [...super.props, childrenIds];
}

