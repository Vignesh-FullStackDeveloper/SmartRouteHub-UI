import 'package:equatable/equatable.dart';

/// Student model
class Student extends Equatable {
  final String id;
  final String name;
  final String classGrade; // e.g., "Class 5"
  final String section; // e.g., "A"
  final String organizationId;
  final String? parentId;
  final String parentContact;
  final String? pickupPointId;
  final String? assignedBusId;
  final String? assignedRouteId;
  final bool isActive;

  const Student({
    required this.id,
    required this.name,
    required this.classGrade,
    required this.section,
    required this.organizationId,
    this.parentId,
    required this.parentContact,
    this.pickupPointId,
    this.assignedBusId,
    this.assignedRouteId,
    this.isActive = true,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        classGrade,
        section,
        organizationId,
        parentId,
        parentContact,
        pickupPointId,
        assignedBusId,
        assignedRouteId,
        isActive,
      ];

  Student copyWith({
    String? id,
    String? name,
    String? classGrade,
    String? section,
    String? organizationId,
    String? parentId,
    String? parentContact,
    String? pickupPointId,
    String? assignedBusId,
    String? assignedRouteId,
    bool? isActive,
  }) {
    return Student(
      id: id ?? this.id,
      name: name ?? this.name,
      classGrade: classGrade ?? this.classGrade,
      section: section ?? this.section,
      organizationId: organizationId ?? this.organizationId,
      parentId: parentId ?? this.parentId,
      parentContact: parentContact ?? this.parentContact,
      pickupPointId: pickupPointId ?? this.pickupPointId,
      assignedBusId: assignedBusId ?? this.assignedBusId,
      assignedRouteId: assignedRouteId ?? this.assignedRouteId,
      isActive: isActive ?? this.isActive,
    );
  }
}

