import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/user.dart';
import '../../models/role.dart';
import '../../models/permission.dart';
import '../../services/api_user_service.dart';
import '../../services/api_role_service.dart';
import '../../services/api_permission_service.dart';
import '../../services/api_student_service.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_state.dart';
import '../../core/utils/permission_checker.dart';
import '../../core/constants/permissions.dart';
import '../../core/api/api_client.dart';
import 'dialogs/create_permission_dialog.dart';
import 'dialogs/create_role_dialog.dart';
import 'dialogs/create_user_dialog.dart';
import 'dialogs/edit_user_dialog.dart';
import 'dialogs/edit_role_dialog.dart';

/// Users, Roles, and Permissions management screen with tabs
class UsersRolesPermissionsScreen extends StatefulWidget {
  const UsersRolesPermissionsScreen({super.key});

  @override
  State<UsersRolesPermissionsScreen> createState() =>
      _UsersRolesPermissionsScreenState();
}

class _UsersRolesPermissionsScreenState
    extends State<UsersRolesPermissionsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ApiUserService _userService = ApiUserService();
  final ApiRoleService _roleService = ApiRoleService();
  final ApiPermissionService _permissionService = ApiPermissionService();
  final ApiStudentService _studentService = ApiStudentService();

  List<User> _users = [];
  List<Role> _roles = [];
  List<Permission> _permissions = [];
  bool _isLoading = false;
  String? _error;
  int _currentTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      // Rebuild FAB when tab index actually changes
      if (_tabController.index != _currentTabIndex) {
        setState(() {
          _currentTabIndex = _tabController.index;
        });
      }
    });
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final results = await Future.wait([
        _userService.getAllUsers(),
        _roleService.getAllRoles(),
        _permissionService.getAllPermissions(),
      ]);

      setState(() {
        _users = results[0] as List<User>;
        _roles = results[1] as List<Role>;
        _permissions = results[2] as List<Permission>;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Users, Roles & Permissions'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.people), text: 'Users'),
            Tab(icon: Icon(Icons.shield), text: 'Roles'),
            Tab(icon: Icon(Icons.lock), text: 'Permissions'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                      const SizedBox(height: 16),
                      Text(
                        'Error loading data',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Text(
                          _error!,
                          style: TextStyle(color: Colors.grey[600]),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: _loadData,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadData,
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildUsersTab(),
                      _buildRolesTab(),
                      _buildPermissionsTab(),
                    ],
                  ),
                ),
      floatingActionButton: _buildFloatingActionButton(context),
    );
  }

  Widget? _buildFloatingActionButton(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        if (authState is! AuthAuthenticated) {
          return const SizedBox.shrink();
        }

        final user = authState.user;
        final currentTab = _currentTabIndex;

        // Users tab - check user:create permission
        if (currentTab == 0) {
          if (!PermissionChecker.hasPermission(user, Permissions.userCreate)) {
            return const SizedBox.shrink();
          }
          return FloatingActionButton.extended(
            onPressed: () => _showCreateUserDialog(context),
            icon: const Icon(Icons.person_add),
            label: const Text('Create User'),
          );
        }

        // Roles tab - check role:create permission
        if (currentTab == 1) {
          if (!PermissionChecker.hasPermission(user, Permissions.roleCreate)) {
            return const SizedBox.shrink();
          }
          return FloatingActionButton.extended(
            onPressed: () => _showCreateRoleDialog(context),
            icon: const Icon(Icons.shield),
            label: const Text('Create Role'),
          );
        }

        // Permissions tab - check permission:create permission
        if (currentTab == 2) {
          if (!PermissionChecker.hasPermission(user, Permissions.permissionCreate)) {
            return const SizedBox.shrink();
          }
          return FloatingActionButton.extended(
            onPressed: () => _showCreatePermissionDialog(context),
            icon: const Icon(Icons.add_circle_outline),
            label: const Text('Create Permission'),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  void _showCreatePermissionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => CreatePermissionDialog(
        onCreated: (permission) {
          setState(() {
            _permissions.add(permission);
          });
        },
      ),
    );
  }

  void _showCreateRoleDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => CreateRoleDialog(
        onCreated: (role) {
          setState(() {
            _roles.add(role);
          });
        },
      ),
    );
  }

  void _showCreateUserDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => CreateUserDialog(
        onCreated: (user) {
          setState(() {
            _users.add(user);
          });
        },
      ),
    );
  }

  void _showEditUserDialog(BuildContext context, User user) {
    showDialog(
      context: context,
      builder: (context) => EditUserDialog(
        user: user,
        onUpdated: (updatedUser) {
          setState(() {
            final index = _users.indexWhere((u) => u.id == updatedUser.id);
            if (index != -1) {
              _users[index] = updatedUser;
            }
          });
        },
        onDeleted: (userId) {
          setState(() {
            _users.removeWhere((u) => u.id == userId);
          });
        },
      ),
    );
  }

  void _showDeleteUserDialog(BuildContext context, User user) async {
    // Check if user is a parent
    final isParent = user is ParentUser;
    int studentCount = 0;
    
    if (isParent) {
      // Get all students with this parent_id
      try {
        final students = await _studentService.getStudents(parentId: user.id);
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

    String confirmMessage = 'Are you sure you want to delete ${user.name}?';
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

    if (confirm == true && mounted) {
      try {
        // If parent, delete all students first
        if (isParent) {
          final students = await _studentService.getStudents(parentId: user.id);
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
        await _userService.deleteUser(user.id);
        if (mounted) {
          setState(() {
            _users.removeWhere((u) => u.id == user.id);
          });
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
      }
    }
  }

  void _showEditRoleDialog(BuildContext context, Role role) {
    showDialog(
      context: context,
      builder: (context) => EditRoleDialog(
        role: role,
        onUpdated: (updatedRole) {
          setState(() {
            final index = _roles.indexWhere((r) => r.id == updatedRole.id);
            if (index != -1) {
              _roles[index] = updatedRole;
            }
          });
        },
        onDeleted: (roleId) {
          setState(() {
            _roles.removeWhere((r) => r.id == roleId);
          });
        },
      ),
    );
  }

  void _showDeleteRoleDialog(BuildContext context, Role role) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Role'),
        content: Text('Are you sure you want to delete "${role.name}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await _roleService.deleteRole(role.id);
                if (mounted) {
                  setState(() {
                    _roles.removeWhere((r) => r.id == role.id);
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Role deleted successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  // Extract error message from ApiException
                  String errorMessage = 'Failed to delete role';
                  if (e is ApiException) {
                    errorMessage = e.message;
                  } else {
                    errorMessage = e.toString();
                  }
                  
                  // Show error in a dialog popup
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Error'),
                      content: Text(errorMessage),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('OK'),
                        ),
                      ],
                    ),
                  );
                }
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showDeletePermissionDialog(BuildContext context, Permission permission) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Permission'),
        content: Text('Are you sure you want to delete "${permission.name}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await _permissionService.deletePermission(permission.id);
                if (mounted) {
                  setState(() {
                    _permissions.removeWhere((p) => p.id == permission.id);
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Permission deleted successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to delete permission: ${e.toString()}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Widget _buildUsersTab() {
    if (_users.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No users found',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _users.length,
      itemBuilder: (context, index) {
        final user = _users[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: _getRoleColor(user.role).withOpacity(0.2),
              child: Icon(
                _getRoleIcon(user.role),
                color: _getRoleColor(user.role),
              ),
            ),
            title: Text(
              user.name,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(user.email),
                if (user.phone != null) Text(user.phone!),
                const SizedBox(height: 4),
                Chip(
                  label: Text(
                    user.role.name.toUpperCase(),
                    style: const TextStyle(fontSize: 10),
                  ),
                  backgroundColor: _getRoleColor(user.role).withOpacity(0.1),
                  padding: EdgeInsets.zero,
                ),
              ],
            ),
            trailing: BlocBuilder<AuthBloc, AuthState>(
              builder: (context, authState) {
                if (authState is! AuthAuthenticated) {
                  return const SizedBox.shrink();
                }
                final currentUser = authState.user;
                final canUpdate = PermissionChecker.hasPermission(currentUser, Permissions.userUpdate);
                final canDelete = PermissionChecker.hasPermission(currentUser, Permissions.userDelete);
                
                if (!canUpdate && !canDelete) {
                  return const SizedBox.shrink();
                }
                
                return PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert),
                  onSelected: (value) {
                    if (value == 'edit') {
                      _showEditUserDialog(context, user);
                    } else if (value == 'delete') {
                      _showDeleteUserDialog(context, user);
                    }
                  },
                  itemBuilder: (context) => [
                    if (canUpdate)
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, size: 20),
                            SizedBox(width: 8),
                            Text('Edit'),
                          ],
                        ),
                      ),
                    if (canDelete)
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, size: 20, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Delete', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                  ],
                );
              },
            ),
            onTap: () {
              final authState = context.read<AuthBloc>().state;
              if (authState is AuthAuthenticated) {
                final currentUser = authState.user;
                if (PermissionChecker.hasPermission(currentUser, Permissions.userUpdate)) {
                  _showEditUserDialog(context, user);
                }
              }
            },
          ),
        );
      },
    );
  }

  Widget _buildRolesTab() {
    if (_roles.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shield_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No roles found',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _roles.length,
      itemBuilder: (context, index) {
        final role = _roles[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ExpansionTile(
            leading: const Icon(Icons.shield, color: Colors.blue),
            title: Text(
              role.name,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Text(role.description),
            trailing: BlocBuilder<AuthBloc, AuthState>(
              builder: (context, authState) {
                if (authState is! AuthAuthenticated) {
                  return const SizedBox.shrink();
                }
                final currentUser = authState.user;
                final canUpdate = PermissionChecker.hasPermission(currentUser, Permissions.roleUpdate);
                final canDelete = PermissionChecker.hasPermission(currentUser, Permissions.roleDelete);
                
                if (!canUpdate && !canDelete) {
                  return const SizedBox.shrink();
                }
                
                return PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert),
                  onSelected: (value) {
                    if (value == 'edit') {
                      _showEditRoleDialog(context, role);
                    } else if (value == 'delete') {
                      _showDeleteRoleDialog(context, role);
                    }
                  },
                  itemBuilder: (context) => [
                    if (canUpdate)
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, size: 20),
                            SizedBox(width: 8),
                            Text('Edit'),
                          ],
                        ),
                      ),
                    if (canDelete)
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, size: 20, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Delete', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                  ],
                );
              },
            ),
            onExpansionChanged: (expanded) {
              // Allow expansion/collapse
            },
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Permissions:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (role.permissions.isEmpty)
                      Text(
                        'No permissions assigned',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      )
                    else
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: role.permissions.map((permission) {
                          return Chip(
                            label: Text(
                              permission.name,
                              style: const TextStyle(fontSize: 11),
                            ),
                            backgroundColor: Colors.green[50],
                            side: BorderSide(color: Colors.green[200]!),
                          );
                        }).toList(),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPermissionsTab() {
    if (_permissions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.lock_outline, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No permissions found',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _permissions.length,
      itemBuilder: (context, index) {
        final permission = _permissions[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.purple[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.lock, color: Colors.purple, size: 20),
            ),
            title: Text(
              permission.name,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(permission.description),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    permission.code,
                    style: TextStyle(
                      fontSize: 11,
                      fontFamily: 'monospace',
                      color: Colors.grey[700],
                    ),
                  ),
                ),
              ],
            ),
            trailing: BlocBuilder<AuthBloc, AuthState>(
              builder: (context, authState) {
                if (authState is! AuthAuthenticated) {
                  return const SizedBox.shrink();
                }
                final currentUser = authState.user;
                final canDelete = PermissionChecker.hasPermission(currentUser, Permissions.permissionDelete);
                
                if (!canDelete) {
                  return const SizedBox.shrink();
                }
                
                return PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert),
                  onSelected: (value) {
                    if (value == 'delete') {
                      _showDeletePermissionDialog(context, permission);
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, size: 20, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Delete', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }

  Color _getRoleColor(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return Colors.red;
      case UserRole.driver:
        return Colors.blue;
      case UserRole.parent:
        return Colors.green;
    }
  }

  IconData _getRoleIcon(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return Icons.admin_panel_settings;
      case UserRole.driver:
        return Icons.person;
      case UserRole.parent:
        return Icons.family_restroom;
    }
  }
}

