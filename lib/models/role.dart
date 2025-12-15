import 'package:equatable/equatable.dart';
import 'permission.dart';

/// Permission reference (simplified for role)
class PermissionRef extends Equatable {
  final String id;
  final String name;
  final String code;

  const PermissionRef({
    required this.id,
    required this.name,
    required this.code,
  });

  factory PermissionRef.fromJson(Map<String, dynamic> json) {
    return PermissionRef(
      id: json['id'] as String,
      name: json['name'] as String,
      code: json['code'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
    };
  }

  @override
  List<Object?> get props => [id, name, code];
}

/// Role model
class Role extends Equatable {
  final String id;
  final String name;
  final String description;
  final List<PermissionRef> permissions;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Role({
    required this.id,
    required this.name,
    required this.description,
    required this.permissions,
    this.createdAt,
    this.updatedAt,
  });

  factory Role.fromJson(Map<String, dynamic> json) {
    return Role(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      permissions: (json['permissions'] as List<dynamic>?)
              ?.map((p) => PermissionRef.fromJson(p as Map<String, dynamic>))
              .toList() ??
          [],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'permissions': permissions.map((p) => p.toJson()).toList(),
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [id, name, description, permissions, createdAt, updatedAt];
}

