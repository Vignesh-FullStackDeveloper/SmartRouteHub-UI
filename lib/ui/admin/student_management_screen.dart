import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/api_student_service.dart';
import '../../services/api_bus_service.dart';
import '../../services/api_route_service.dart';
import '../../services/api_user_service.dart';
import '../../models/student.dart';
import '../../models/bus.dart';
import '../../models/route.dart' as models;
import '../../models/user.dart';
import '../../widgets/primary_button.dart';
import '../../core/utils/validators.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_state.dart';
import '../../core/utils/permission_checker.dart';
import '../../core/constants/permissions.dart';
import '../../widgets/permission_wrapper.dart';

/// Student management screen with modern UI
class StudentManagementScreen extends StatefulWidget {
  const StudentManagementScreen({super.key});

  @override
  State<StudentManagementScreen> createState() =>
      _StudentManagementScreenState();
}

class _StudentManagementScreenState extends State<StudentManagementScreen>
    with SingleTickerProviderStateMixin {
  final ApiStudentService _studentService = ApiStudentService();
  final ApiBusService _busService = ApiBusService();
  final ApiRouteService _routeService = ApiRouteService();
  final ApiUserService _userService = ApiUserService();
  List<Student> _students = [];
  List<Bus> _buses = [];
  List<models.Route> _routes = [];
  List<ParentUser> _parents = [];
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
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });
    try {
      final students = await _studentService.getStudents();
      final buses = await _busService.getBuses();
      final routes = await _routeService.getRoutes();
      final users = await _userService.getAllUsers();
      final parents = users.whereType<ParentUser>().toList();
      if (!mounted) return;
      setState(() {
        _students = students;
        _buses = buses;
        _routes = routes;
        _parents = parents;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading data: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Management'),
        actions: [
          BlocBuilder<AuthBloc, AuthState>(
            builder: (context, authState) {
              if (authState is! AuthAuthenticated) {
                return const SizedBox.shrink();
              }
              final user = authState.user;
              if (!PermissionChecker.hasPermission(user, Permissions.studentCreate)) {
                return const SizedBox.shrink();
              }
              return IconButton(
                icon: const Icon(Icons.add),
                onPressed: () => _showAddEditStudentDialog(),
                tooltip: 'Add Student',
              );
            },
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
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.grey[100]!,
                                  Colors.grey[50]!,
                                ],
                              ),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.school_outlined,
                                size: 64, color: Colors.grey[400]),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'No students found',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[800],
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Add your first student to get started',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          BlocBuilder<AuthBloc, AuthState>(
                            builder: (context, authState) {
                              if (authState is! AuthAuthenticated) {
                                return const SizedBox.shrink();
                              }
                              final user = authState.user;
                              if (!PermissionChecker.hasPermission(user, Permissions.studentCreate)) {
                                return const SizedBox.shrink();
                              }
                              return Container(
                                margin: const EdgeInsets.only(top: 24),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Theme.of(context).colorScheme.primary,
                                      Theme.of(context).colorScheme.secondary,
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: ElevatedButton.icon(
                                  onPressed: () => _showAddEditStudentDialog(),
                                  icon: const Icon(Icons.add_rounded),
                                  label: const Text('Add First Student', style: TextStyle(fontWeight: FontWeight.bold)),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                                  ),
                                ),
                              );
                            },
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
    return Container(
      margin: const EdgeInsets.only(bottom: 16, left: 16, right: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            Colors.grey[50]!,
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            final authState = context.read<AuthBloc>().state;
            if (authState is AuthAuthenticated) {
              final user = authState.user;
              if (PermissionChecker.hasPermission(user, Permissions.studentUpdate)) {
                _showAddEditStudentDialog(student: student);
              }
            }
          },
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Hero(
                  tag: 'student_${student.id}',
                  child: Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: student.isActive
                            ? [
                                Theme.of(context).colorScheme.primary,
                                Theme.of(context).colorScheme.secondary,
                                Theme.of(context).colorScheme.tertiary,
                              ]
                            : [
                                Colors.grey,
                                Colors.grey[700]!,
                              ],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: (student.isActive
                                  ? Theme.of(context).colorScheme.primary
                                  : Colors.grey)
                              .withValues(alpha: 0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.person, color: Colors.white, size: 32),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              student.name,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                letterSpacing: -0.5,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: student.isActive
                                    ? [Colors.green.shade400, Colors.green.shade600]
                                    : [Colors.grey.shade400, Colors.grey.shade600],
                              ),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: (student.isActive ? Colors.green : Colors.grey).withValues(alpha: 0.3),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Text(
                              student.isActive ? 'ACTIVE' : 'INACTIVE',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 1,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${student.classGrade} - Section ${student.section}',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.phone, size: 16, color: Colors.grey[600]),
                          const SizedBox(width: 6),
                          Text(
                            student.parentContact,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[700],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      if (student.assignedBusId != null) ...[
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(Icons.directions_bus, size: 16, color: Colors.grey[600]),
                            const SizedBox(width: 6),
                            Text(
                              'Bus: ${student.assignedBusId}',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[700],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, authState) {
                    if (authState is! AuthAuthenticated) {
                      return const SizedBox.shrink();
                    }
                    final user = authState.user;
                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (PermissionChecker.hasPermission(user, Permissions.studentUpdate))
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.blue.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.edit_rounded, color: Colors.blue, size: 20),
                              onPressed: () => _showAddEditStudentDialog(student: student),
                            ),
                          ),
                        const SizedBox(width: 8),
                        if (PermissionChecker.hasPermission(user, Permissions.studentDelete))
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.red.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.delete_rounded, color: Colors.red, size: 20),
                              onPressed: () => _deleteStudent(student.id),
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ],
            ),
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
    // Only set selectedRouteId if it exists in the lists and is not empty
    String? selectedRouteId;
    final studentRouteId = student?.assignedRouteId;
    if (studentRouteId != null && 
        studentRouteId.isNotEmpty &&
        _routes.any((route) => route.id == studentRouteId)) {
      selectedRouteId = studentRouteId;
    }
    // Set selected parent ID
    String? selectedParentId;
    final studentParentId = student?.parentId;
    if (studentParentId != null && 
        studentParentId.isNotEmpty &&
        _parents.any((parent) => parent.id == studentParentId)) {
      selectedParentId = studentParentId;
    }
    bool isActive = student?.isActive ?? true;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => Container(
          height: MediaQuery.of(context).size.height * 0.9,
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 16),
                width: 48,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(3),
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
                        Builder(
                          builder: (context) {
                            // Build parent items list
                            final parentItems = _parents
                                .where((parent) => parent.id.isNotEmpty)
                                .map((parent) => DropdownMenuItem<String>(
                                      value: parent.id,
                                      child: Text('${parent.name} (${parent.email})'),
                                    ))
                                .toList();
                            
                            // Ensure selectedParentId matches an item in the list
                            final validParentId = parentItems.any((item) => item.value == selectedParentId)
                                ? selectedParentId
                                : null;
                            
                            return DropdownButtonFormField<String>(
                              value: validParentId,
                              decoration: const InputDecoration(
                                labelText: 'Parent *',
                                prefixIcon: Icon(Icons.family_restroom),
                                hintText: 'Select a parent',
                              ),
                              items: parentItems.isEmpty
                                  ? [
                                      const DropdownMenuItem<String>(
                                        value: null,
                                        child: Text('No parents available'),
                                      )
                                    ]
                                  : parentItems,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please select a parent';
                                }
                                return null;
                              },
                              onChanged: (value) {
                                setDialogState(() {
                                  selectedParentId = value;
                                });
                              },
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                        Builder(
                          builder: (context) {
                            // Build items list
                            final routeItems = <DropdownMenuItem<String?>>[
                              const DropdownMenuItem<String?>(
                                value: null,
                                child: Text('None'),
                              ),
                              ..._routes
                                  .where((route) => route.id.isNotEmpty)
                                  .map((route) => DropdownMenuItem<String?>(
                                        value: route.id,
                                        child: Text(route.name),
                                      )),
                            ];
                            
                            // Ensure selectedRouteId matches an item in the list
                            final validRouteId = routeItems.any((item) => item.value == selectedRouteId)
                                ? selectedRouteId
                                : null;
                            
                            return DropdownButtonFormField<String?>(
                              value: validRouteId,
                              decoration: const InputDecoration(
                                labelText: 'Assigned Route',
                                prefixIcon: Icon(Icons.route),
                              ),
                              items: routeItems,
                              onChanged: (value) {
                                setDialogState(() {
                                  selectedRouteId = value;
                                });
                              },
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                        SwitchListTile(
                          title: const Text('Active Status'),
                          subtitle: const Text('Enable/disable student'),
                          value: isActive,
                          onChanged: (value) {
                            setDialogState(() {
                              isActive = value;
                            });
                          },
                        ),
                        const SizedBox(height: 32),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Theme.of(context).colorScheme.primary,
                              Theme.of(context).colorScheme.secondary,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: () async {
                          if (formKey.currentState!.validate()) {
                            if (selectedParentId?.isEmpty ?? true) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Please select a parent')),
                              );
                              return;
                            }
                            try {
                              if (student == null) {
                                await _studentService.createStudent(
                                  name: nameController.text,
                                  classGrade: classController.text,
                                  section: sectionController.text,
                                  parentContact: parentContactController.text,
                                  parentId: selectedParentId!,
                                  assignedRouteId: selectedRouteId,
                                  isActive: isActive,
                                );
                              } else {
                                await _studentService.updateStudent(
                                  student.id,
                                  name: nameController.text,
                                  classGrade: classController.text,
                                  section: sectionController.text,
                                  parentContact: parentContactController.text,
                                  parentId: selectedParentId!,
                                  assignedRouteId: selectedRouteId,
                                  isActive: isActive,
                                );
                              }
                              if (mounted) {
                                Navigator.pop(context);
                                _loadData();
                              }
                            } catch (e) {
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Error: ${e.toString()}')),
                                );
                              }
                            }
                          }
                        },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Text(
                            student == null ? 'Add Student' : 'Update Student',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
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

    if (confirmed == true && mounted) {
      try {
        await _studentService.deleteStudent(id);
        if (mounted) {
          _loadData();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting student: ${e.toString()}')),
          );
        }
      }
    }
  }
}
