import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../models/role.dart';
import '../../../models/permission.dart';
import '../../../services/api_role_service.dart';
import '../../../services/api_permission_service.dart';
import '../../../blocs/auth/auth_bloc.dart';
import '../../../blocs/auth/auth_state.dart';
import '../../../core/utils/permission_checker.dart';
import '../../../core/constants/permissions.dart';

/// Dialog for editing an existing role
class EditRoleDialog extends StatefulWidget {
  final Role role;
  final Function(Role) onUpdated;
  final Function(String) onDeleted;

  const EditRoleDialog({
    super.key,
    required this.role,
    required this.onUpdated,
    required this.onDeleted,
  });

  @override
  State<EditRoleDialog> createState() => _EditRoleDialogState();
}

class _EditRoleDialogState extends State<EditRoleDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _roleService = ApiRoleService();
  final _permissionService = ApiPermissionService();
  
  List<Permission> _allPermissions = [];
  Set<String> _selectedPermissionIds = {};
  bool _isLoading = false;
  bool _isLoadingPermissions = true;

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.role.name;
    _descriptionController.text = widget.role.description;
    _selectedPermissionIds = widget.role.permissions.map((p) => p.id).toSet();
    _loadPermissions();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _loadPermissions() async {
    try {
      final permissions = await _permissionService.getAllPermissions();
      setState(() {
        _allPermissions = permissions;
        _isLoadingPermissions = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingPermissions = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load permissions: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _updateRole() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Use existing permissions if none selected, otherwise use selected
    final permissionIds = _selectedPermissionIds.isEmpty
        ? widget.role.permissions.map((p) => p.id).toList()
        : _selectedPermissionIds.toList();

    if (permissionIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one permission'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final updatedRole = await _roleService.updateRole(
        widget.role.id,
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        permissionIds: permissionIds,
      );

      if (mounted) {
        Navigator.of(context).pop();
        widget.onUpdated(updatedRole);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Role updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update role: ${e.toString()}'),
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

  Future<void> _deleteRole() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Role'),
        content: Text('Are you sure you want to delete "${widget.role.name}"? This action cannot be undone.'),
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
        await _roleService.deleteRole(widget.role.id);
        if (mounted) {
          Navigator.of(context).pop();
          widget.onDeleted(widget.role.id);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Role deleted successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to delete role: ${e.toString()}'),
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

  void _togglePermission(String permissionId) {
    setState(() {
      if (_selectedPermissionIds.contains(permissionId)) {
        _selectedPermissionIds.remove(permissionId);
      } else {
        _selectedPermissionIds.add(permissionId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        if (authState is! AuthAuthenticated) {
          return const SizedBox.shrink();
        }

        final currentUser = authState.user;
        final canUpdate = PermissionChecker.hasPermission(currentUser, Permissions.roleUpdate);
        final canDelete = PermissionChecker.hasPermission(currentUser, Permissions.roleDelete);

        return Dialog(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 600, maxHeight: 700),
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.edit, size: 28),
                      const SizedBox(width: 12),
                      const Text(
                        'Edit Role',
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
                      prefixIcon: Icon(Icons.label),
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
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      prefixIcon: Icon(Icons.description),
                    ),
                    maxLines: 2,
                    enabled: !_isLoading && canUpdate,
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Permissions',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Selected: ${_selectedPermissionIds.length}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: _isLoadingPermissions
                        ? const Center(child: CircularProgressIndicator())
                        : _allPermissions.isEmpty
                            ? Center(
                                child: Text(
                                  'No permissions available',
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                              )
                            : ListView.builder(
                                shrinkWrap: true,
                                itemCount: _allPermissions.length,
                                itemBuilder: (context, index) {
                                  final permission = _allPermissions[index];
                                  final isSelected =
                                      _selectedPermissionIds.contains(permission.id);
                                  return CheckboxListTile(
                                    title: Text(permission.name),
                                    subtitle: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const SizedBox(height: 4),
                                        Text(
                                          permission.code,
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontFamily: 'monospace',
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                        if (permission.description.isNotEmpty) ...[
                                          const SizedBox(height: 4),
                                          Text(
                                            permission.description,
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[500],
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                    value: isSelected,
                                    onChanged: _isLoading || !canUpdate
                                        ? null
                                        : (_) => _togglePermission(permission.id),
                                  );
                                },
                              ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (canDelete)
                        TextButton.icon(
                          onPressed: _isLoading ? null : _deleteRole,
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
                          onPressed: _isLoading ? null : _updateRole,
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
        );
      },
    );
  }
}

