import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_state.dart';
import '../../blocs/org/org_bloc.dart';
import '../../blocs/org/org_event.dart';
import '../../blocs/org/org_state.dart';
import '../../models/user.dart';
import '../../core/utils/permission_checker.dart';
import '../../core/constants/permissions.dart';
import '../../widgets/org_header.dart';
import '../admin/student_management_screen.dart';
import '../admin/users_roles_permissions_screen.dart';
import '../admin/live_monitoring_screen.dart';
import '../profile/profile_screen.dart';
import 'tabs/organization_tab.dart';
import 'tabs/buses_tab.dart';
import 'tabs/routes_tab.dart';
import 'tabs/students_tab.dart';
import 'tabs/children_tab.dart';

/// Unified home screen with permission-based tabs
class HomeScreen extends StatefulWidget {
  final User user;

  const HomeScreen({
    super.key,
    required this.user,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<HomeTab> _availableTabs = [];
  int _initialTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _buildAvailableTabs();
    _tabController = TabController(
      length: _availableTabs.length,
      vsync: this,
      initialIndex: _initialTabIndex,
    );
    
    // Load organization only if user has permission to view it
    if (widget.user.organizationId.isNotEmpty &&
        PermissionChecker.hasPermission(widget.user, Permissions.organizationRead)) {
      context.read<OrgBloc>().add(LoadOrganizationById(widget.user.organizationId));
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _buildAvailableTabs() {
    final tabs = <HomeTab>[];

    // Organization tab - show if user has organization read permission
    if (PermissionChecker.hasPermission(widget.user, Permissions.organizationRead)) {
      tabs.add(HomeTab(
        label: 'Organization',
        icon: Icons.business,
        widget: const OrganizationTab(),
      ));
    }

    // Students tab - show if user has student read permission
    if (PermissionChecker.hasPermission(widget.user, Permissions.studentRead)) {
      tabs.add(HomeTab(
        label: 'Students',
        icon: Icons.school,
        widget: const StudentsTab(),
      ));
    }

    // Children tab - for parents to view their children
    if (widget.user.role == UserRole.parent) {
      tabs.add(HomeTab(
        label: 'Children',
        icon: Icons.child_care,
        widget: const ChildrenTab(),
      ));
    }

    // Buses tab - show if user has bus read permission
    if (PermissionChecker.hasPermission(widget.user, Permissions.busRead)) {
      tabs.add(HomeTab(
        label: 'Buses',
        icon: Icons.directions_bus,
        widget: const BusesTab(),
      ));
    }

    // Routes tab - show if user has route read permission
    if (PermissionChecker.hasPermission(widget.user, Permissions.routeRead)) {
      tabs.add(HomeTab(
        label: 'Routes',
        icon: Icons.route,
        widget: const RoutesTab(),
      ));
    }

    // Live Monitoring tab - show if user has location read permission
    if (PermissionChecker.hasPermission(widget.user, Permissions.locationRead)) {
      tabs.add(HomeTab(
        label: 'Live Map',
        icon: Icons.location_on,
        widget: const LiveMonitoringScreen(),
      ));
    }

    // Users, Roles & Permissions tab - show if user has any of these permissions
    if (PermissionChecker.hasPermission(widget.user, Permissions.userRead) ||
        PermissionChecker.hasPermission(widget.user, Permissions.roleRead) ||
        PermissionChecker.hasPermission(widget.user, Permissions.permissionRead)) {
      tabs.add(HomeTab(
        label: 'Users & Roles',
        icon: Icons.people,
        widget: const UsersRolesPermissionsScreen(),
      ));
    }

    setState(() {
      _availableTabs = tabs;
      // Set initial tab to Organization if available, otherwise first tab
      _initialTabIndex = tabs.isNotEmpty ? 0 : 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_availableTabs.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Home'),
          actions: [
            IconButton(
              icon: const Icon(Icons.person),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ProfileScreen(),
                  ),
                );
              },
            ),
          ],
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lock_outline, size: 64, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                'No access available',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'You don\'t have permissions to access any features',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[500],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return BlocBuilder<OrgBloc, OrgState>(
      builder: (context, orgState) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('School Bus Tracker'),
            actions: [
              IconButton(
                icon: const Icon(Icons.person),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ProfileScreen(),
                    ),
                  );
                },
                tooltip: 'Profile',
              ),
            ],
            bottom: _availableTabs.length > 1
                ? TabBar(
                    controller: _tabController,
                    isScrollable: _availableTabs.length > 3,
                    tabs: _availableTabs.map((tab) {
                      return Tab(
                        icon: Icon(tab.icon),
                        text: tab.label,
                      );
                    }).toList(),
                  )
                : null,
          ),
          body: Column(
            children: [
              // Organization header (if organization is loaded)
              if (orgState is OrgLoaded && orgState.currentOrganization != null)
                OrgHeader(
                  organization: orgState.currentOrganization,
                  role: widget.user.role,
                ),
              // Tab content
              Expanded(
                child: _availableTabs.length == 1
                    ? _availableTabs[0].widget
                    : TabBarView(
                        controller: _tabController,
                        children: _availableTabs.map((tab) => tab.widget).toList(),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Model for home screen tabs
class HomeTab {
  final String label;
  final IconData icon;
  final Widget widget;

  HomeTab({
    required this.label,
    required this.icon,
    required this.widget,
  });
}

