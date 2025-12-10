import 'package:equatable/equatable.dart';

/// Student model
class Student extends Equatable {
  final String id;
  final String name;
  final String classGrade; // e.g., "Class 5"
  final String section; // e.g., "A"
  final String organizationId;
  final String parentId;
  final String parentContact;
  final String? pickupPointId;
  final String? assignedBusId;
  final String? assignedRouteId;

  const Student({
    required this.id,
    required this.name,
    required this.classGrade,
    required this.section,
    required this.organizationId,
    required this.parentId,
    required this.parentContact,
    this.pickupPointId,
    this.assignedBusId,
    this.assignedRouteId,
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
    );
  }
}

