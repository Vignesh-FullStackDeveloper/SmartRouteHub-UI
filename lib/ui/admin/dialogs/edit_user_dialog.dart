import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../models/user.dart';
import '../../../models/role.dart';
import '../../../services/api_user_service.dart';
import '../../../services/api_role_service.dart';
import '../../../services/api_student_service.dart';
import '../../../core/utils/validators.dart';
import '../../../blocs/auth/auth_bloc.dart';
import '../../../blocs/auth/auth_state.dart';
import '../../../core/utils/permission_checker.dart';
import '../../../core/constants/permissions.dart';

/// Dialog for editing an existing user
class EditUserDialog extends StatefulWidget {
  final User user;
  final Function(User) onUpdated;
  final Function(String) onDeleted;

  const EditUserDialog({
    super.key,
    required this.user,
    required this.onUpdated,
    required this.onDeleted,
  });

  @override
  State<EditUserDialog> createState() => _EditUserDialogState();
}

class _EditUserDialogState extends State<EditUserDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _userService = ApiUserService();
  final _roleService = ApiRoleService();
  final _studentService = ApiStudentService();
  
  List<Role> _allRoles = [];
  Role? _selectedRole;
  bool? _isActive;
  bool _isLoading = false;
  bool _isLoadingRoles = true;

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.user.name;
    _emailController.text = widget.user.email;
    _phoneController.text = widget.user.phone ?? '';
    // Check if user has isActive property (DriverUser has it, but API may return it for all)
    _isActive = widget.user is DriverUser 
        ? (widget.user as DriverUser).isActive 
        : true; // Default to true for other user types
    _loadRoles();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _loadRoles() async {
    try {
      final roles = await _roleService.getAllRoles();
      setState(() {
        _allRoles = roles;
        _isLoadingRoles = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingRoles = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load roles: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _updateUser() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final updatedUser = await _userService.updateUser(
        widget.user.id,
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim().isEmpty
            ? null
            : _phoneController.text.trim(),
        isActive: _isActive,
        roleId: _selectedRole?.id,
      );

      if (mounted) {
        Navigator.of(context).pop();
        widget.onUpdated(updatedUser);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('User updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update user: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _deleteUser() async {
    // Check if user is a parent
    final isParent = widget.user is ParentUser;
    int studentCount = 0;
    
    if (isParent) {
      // Get all students with this parent_id
      try {
        final students = await _studentService.getStudents(parentId: widget.user.id);
        studentCount = students.length;
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to check students: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }
    }

    String confirmMessage = 'Are you sure you want to delete ${widget.user.name}?';
    if (isParent && studentCount > 0) {
      confirmMessage += '\n\nThis will also delete $studentCount student(s) associated with this parent. This action cannot be undone.';
    } else {
      confirmMessage += ' This will deactivate the user.';
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete User'),
        content: Text(confirmMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() {
        _isLoading = true;
      });

      try {
        // If parent, delete all students first
        if (isParent) {
          final students = await _studentService.getStudents(parentId: widget.user.id);
          for (final student in students) {
            try {
              await _studentService.deleteStudent(student.id);
            } catch (e) {
              // Log error but continue with other students
              print('Failed to delete student ${student.id}: $e');
            }
          }
        }

        // Then delete the user
        await _userService.deleteUser(widget.user.id);
        if (mounted) {
          Navigator.of(context).pop();
          widget.onDeleted(widget.user.id);
          String successMessage = 'User deleted successfully';
          if (isParent && studentCount > 0) {
            successMessage += '. $studentCount student(s) also deleted.';
          }
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(successMessage),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to delete user: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        if (authState is! AuthAuthenticated) {
          return const SizedBox.shrink();
        }

        final currentUser = authState.user;
        final canUpdate = PermissionChecker.hasPermission(currentUser, Permissions.userUpdate);
        final canDelete = PermissionChecker.hasPermission(currentUser, Permissions.userDelete);

        return Dialog(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 500),
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.edit, size: 28),
                        const SizedBox(width: 12),
                        const Text(
                          'Edit User',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Name',
                        prefixIcon: Icon(Icons.person),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Name is required';
                        }
                        return null;
                      },
                      enabled: !_isLoading && canUpdate,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.email),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: Validators.validateEmail,
                      enabled: !_isLoading && canUpdate,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _phoneController,
                      decoration: const InputDecoration(
                        labelText: 'Phone',
                        prefixIcon: Icon(Icons.phone),
                      ),
                      keyboardType: TextInputType.phone,
                      enabled: !_isLoading && canUpdate,
                    ),
                    const SizedBox(height: 16),
                    SwitchListTile(
                      title: const Text('Active'),
                      subtitle: const Text('User account status'),
                      value: _isActive ?? true,
                      onChanged: _isLoading || !canUpdate
                          ? null
                          : (value) {
                              setState(() {
                                _isActive = value;
                              });
                            },
                    ),
                    const SizedBox(height: 16),
                    _isLoadingRoles
                        ? const Center(child: CircularProgressIndicator())
                        : DropdownButtonFormField<Role>(
                            value: _selectedRole,
                            decoration: const InputDecoration(
                              labelText: 'Role',
                              prefixIcon: Icon(Icons.shield),
                              helperText: 'Change user role (optional)',
                            ),
                            items: _allRoles.map((role) {
                              return DropdownMenuItem<Role>(
                                value: role,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(role.name),
                                    Text(
                                      role.description,
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                            onChanged: _isLoading || !canUpdate
                                ? null
                                : (value) {
                                    setState(() {
                                      _selectedRole = value;
                                    });
                                  },
                          ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (canDelete)
                          TextButton.icon(
                            onPressed: _isLoading ? null : _deleteUser,
                            icon: const Icon(Icons.delete),
                            label: const Text('Delete'),
                            style: TextButton.styleFrom(foregroundColor: Colors.red),
                          ),
                        if (canDelete) const SizedBox(width: 8),
                        TextButton(
                          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
                          child: const Text('Cancel'),
                        ),
                        const SizedBox(width: 8),
                        if (canUpdate)
                          ElevatedButton(
                            onPressed: _isLoading ? null : _updateUser,
                            child: _isLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : const Text('Update'),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

