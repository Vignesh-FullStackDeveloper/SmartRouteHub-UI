import '../models/student.dart';

/// Mock student service
/// Manages student data for an organization
class StudentService {
  // In-memory storage
  static final List<Student> _students = [
    const Student(
      id: 'student_1',
      name: 'John Doe',
      classGrade: 'Class 5',
      section: 'A',
      organizationId: 'org_1',
      parentId: 'parent_1',
      parentContact: '+1234567890',
      pickupPointId: 'stop_1',
      assignedBusId: 'bus_1',
      assignedRouteId: 'route_1',
    ),
    const Student(
      id: 'student_2',
      name: 'Jane Smith',
      classGrade: 'Class 6',
      section: 'B',
      organizationId: 'org_1',
      parentId: 'parent_2',
      parentContact: '+1234567891',
      pickupPointId: 'stop_2',
      assignedBusId: 'bus_1',
      assignedRouteId: 'route_1',
    ),
    const Student(
      id: 'student_3',
      name: 'Bob Johnson',
      classGrade: 'Class 4',
      section: 'A',
      organizationId: 'org_1',
      parentId: 'parent_3',
      parentContact: '+1234567892',
      pickupPointId: 'stop_3',
      assignedBusId: 'bus_2',
      assignedRouteId: 'route_2',
    ),
  ];

  /// Get all students for an organization
  Future<List<Student>> getStudentsByOrganization(String organizationId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _students
        .where((s) => s.organizationId == organizationId)
        .toList();
  }

  /// Get student by ID
  Future<Student?> getStudentById(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    try {
      return _students.firstWhere((s) => s.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Add new student
  Future<Student> addStudent(Student student) async {
    await Future.delayed(const Duration(seconds: 1));
    _students.add(student);
    return student;
  }

  /// Update student
  Future<Student> updateStudent(Student student) async {
    await Future.delayed(const Duration(seconds: 1));
    final index = _students.indexWhere((s) => s.id == student.id);
    if (index != -1) {
      _students[index] = student;
    }
    return student;
  }

  /// Delete student
  Future<void> deleteStudent(String id) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _students.removeWhere((s) => s.id == id);
  }
}

