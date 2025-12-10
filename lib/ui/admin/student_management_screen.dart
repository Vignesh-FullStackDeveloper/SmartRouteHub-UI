import 'package:flutter/material.dart';
import '../../services/student_service.dart';
import '../../services/bus_service.dart';
import '../../services/route_service.dart';
import '../../models/student.dart';
import '../../models/bus.dart';
import '../../models/route.dart' as models;
import '../../widgets/primary_button.dart';
import '../../core/utils/validators.dart';

/// Student management screen with modern UI
class StudentManagementScreen extends StatefulWidget {
  const StudentManagementScreen({super.key});

  @override
  State<StudentManagementScreen> createState() =>
      _StudentManagementScreenState();
}

class _StudentManagementScreenState extends State<StudentManagementScreen>
    with SingleTickerProviderStateMixin {
  final StudentService _studentService = StudentService();
  final BusService _busService = BusService();
  final RouteService _routeService = RouteService();
  List<Student> _students = [];
  List<Bus> _buses = [];
  List<models.Route> _routes = [];
  bool _isLoading = true;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _loadData();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });
    final students = await _studentService.getStudentsByOrganization('org_1');
    final buses = await _busService.getBusesByOrganization('org_1');
    final routes = await _routeService.getRoutesByOrganization('org_1');
    setState(() {
      _students = students;
      _buses = buses;
      _routes = routes;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddEditStudentDialog(),
            tooltip: 'Add Student',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: _students.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.school_outlined,
                              size: 64, color: Colors.grey[400]),
                          const SizedBox(height: 16),
                          Text(
                            'No students found',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton.icon(
                            onPressed: () => _showAddEditStudentDialog(),
                            icon: const Icon(Icons.add),
                            label: const Text('Add First Student'),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _students.length,
                      itemBuilder: (context, index) {
                        return TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0.0, end: 1.0),
                          duration: Duration(milliseconds: 300 + (index * 50)),
                          curve: Curves.easeOut,
                          builder: (context, value, child) {
                            return Opacity(
                              opacity: value,
                              child: Transform.translate(
                                offset: Offset(0, 20 * (1 - value)),
                                child: child,
                              ),
                            );
                          },
                          child: _buildStudentCard(_students[index], index),
                        );
                      },
                    ),
            ),
    );
  }

  Widget _buildStudentCard(Student student, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _showAddEditStudentDialog(student: student),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Hero(
                tag: 'student_${student.id}',
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).colorScheme.primary,
                        Theme.of(context).colorScheme.secondary,
                      ],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.person, color: Colors.white),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      student.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${student.classGrade} - Section ${student.section}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.phone, size: 14, color: Colors.grey[500]),
                        const SizedBox(width: 4),
                        Text(
                          student.parentContact,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    if (student.assignedBusId != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.directions_bus,
                              size: 14, color: Colors.grey[500]),
                          const SizedBox(width: 4),
                          Text(
                            'Bus: ${student.assignedBusId}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.blue),
                onPressed: () => _showAddEditStudentDialog(student: student),
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => _deleteStudent(student.id),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddEditStudentDialog({Student? student}) {
    final formKey = GlobalKey<FormState>();
    final nameController =
        TextEditingController(text: student?.name ?? '');
    final classController =
        TextEditingController(text: student?.classGrade ?? '');
    final sectionController =
        TextEditingController(text: student?.section ?? '');
    final parentContactController =
        TextEditingController(text: student?.parentContact ?? '');
    String? selectedBusId = student?.assignedBusId;
    String? selectedRouteId = student?.assignedRouteId;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.9,
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      student == null ? 'Add Student' : 'Edit Student',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Form(
                  key: formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextFormField(
                        controller: nameController,
                        decoration: const InputDecoration(
                          labelText: 'Student Name',
                          prefixIcon: Icon(Icons.person),
                        ),
                        validator: (value) =>
                            Validators.validateRequired(value, 'Name'),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: classController,
                        decoration: const InputDecoration(
                          labelText: 'Class/Grade',
                          prefixIcon: Icon(Icons.class_),
                          hintText: 'e.g., Class 5',
                        ),
                        validator: (value) =>
                            Validators.validateRequired(value, 'Class'),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: sectionController,
                        decoration: const InputDecoration(
                          labelText: 'Section',
                          prefixIcon: Icon(Icons.abc),
                          hintText: 'e.g., A, B, C',
                        ),
                        validator: (value) =>
                            Validators.validateRequired(value, 'Section'),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: parentContactController,
                        decoration: const InputDecoration(
                          labelText: 'Parent Contact',
                          prefixIcon: Icon(Icons.phone),
                          hintText: '+1234567890',
                        ),
                        keyboardType: TextInputType.phone,
                        validator: Validators.validatePhone,
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: selectedBusId,
                        decoration: const InputDecoration(
                          labelText: 'Assigned Bus',
                          prefixIcon: Icon(Icons.directions_bus),
                        ),
                        items: [
                          const DropdownMenuItem<String>(
                            value: null,
                            child: Text('None'),
                          ),
                          ..._buses.map((bus) => DropdownMenuItem<String>(
                                value: bus.id,
                                child: Text(bus.busNumber),
                              )),
                        ],
                        onChanged: (value) {
                          setState(() {
                            selectedBusId = value;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: selectedRouteId,
                        decoration: const InputDecoration(
                          labelText: 'Assigned Route',
                          prefixIcon: Icon(Icons.route),
                        ),
                        items: [
                          const DropdownMenuItem<String>(
                            value: null,
                            child: Text('None'),
                          ),
                          ..._routes.map((route) => DropdownMenuItem<String>(
                                value: route.id,
                                child: Text(route.name),
                              )),
                        ],
                        onChanged: (value) {
                          setState(() {
                            selectedRouteId = value;
                          });
                        },
                      ),
                      const SizedBox(height: 32),
                      ElevatedButton(
                        onPressed: () async {
                          if (formKey.currentState!.validate()) {
                            if (student == null) {
                              final newStudent = Student(
                                id: 'student_${DateTime.now().millisecondsSinceEpoch}',
                                name: nameController.text,
                                classGrade: classController.text,
                                section: sectionController.text,
                                organizationId: 'org_1',
                                parentId: 'parent_${DateTime.now().millisecondsSinceEpoch}',
                                parentContact: parentContactController.text,
                                assignedBusId: selectedBusId,
                                assignedRouteId: selectedRouteId,
                              );
                              await _studentService.addStudent(newStudent);
                            } else {
                              final updatedStudent = student.copyWith(
                                name: nameController.text,
                                classGrade: classController.text,
                                section: sectionController.text,
                                parentContact: parentContactController.text,
                                assignedBusId: selectedBusId,
                                assignedRouteId: selectedRouteId,
                              );
                              await _studentService.updateStudent(updatedStudent);
                            }
                            Navigator.pop(context);
                            _loadData();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: Text(student == null ? 'Add Student' : 'Update Student'),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteStudent(String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Student'),
        content: const Text('Are you sure you want to delete this student?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _studentService.deleteStudent(id);
      _loadData();
    }
  }
}
