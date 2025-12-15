import 'package:equatable/equatable.dart';

/// Permission model
class Permission extends Equatable {
  final String id;
  final String name;
  final String code;
  final String description;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Permission({
    required this.id,
    required this.name,
    required this.code,
    required this.description,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Permission.fromJson(Map<String, dynamic> json) {
    return Permission(
      id: json['id'] as String,
      name: json['name'] as String,
      code: json['code'] as String,
      description: json['description'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'description': description,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [id, name, code, description, createdAt, updatedAt];
}

