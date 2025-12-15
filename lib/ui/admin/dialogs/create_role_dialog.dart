import 'package:flutter/material.dart';
import '../../../models/role.dart';
import '../../../models/permission.dart';
import '../../../services/api_role_service.dart';
import '../../../services/api_permission_service.dart';

/// Dialog for creating a new role
class CreateRoleDialog extends StatefulWidget {
  final Function(Role) onCreated;

  const CreateRoleDialog({
    super.key,
    required this.onCreated,
  });

  @override
  State<CreateRoleDialog> createState() => _CreateRoleDialogState();
}

class _CreateRoleDialogState extends State<CreateRoleDialog> {
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

  Future<void> _createRole() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedPermissionIds.isEmpty) {
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
      final role = await _roleService.createRole(
        name: _nameController.text.trim(),
        permissionIds: _selectedPermissionIds.toList(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
      );

      if (mounted) {
        Navigator.of(context).pop();
        widget.onCreated(role);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Role created successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create role: ${e.toString()}'),
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
                  const Icon(Icons.shield, size: 28),
                  const SizedBox(width: 12),
                  const Text(
                    'Create Role',
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
                  labelText: 'Name *',
                  hintText: 'e.g., Fleet Manager',
                  prefixIcon: Icon(Icons.label),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Name is required';
                  }
                  return null;
                },
                enabled: !_isLoading,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  hintText: 'Optional description',
                  prefixIcon: Icon(Icons.description),
                ),
                maxLines: 2,
                enabled: !_isLoading,
              ),
              const SizedBox(height: 24),
              const Text(
                'Select Permissions *',
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
                                onChanged: _isLoading
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
                  TextButton(
                    onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _createRole,
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Create'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

