import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/admin_dashboard/admin_dashboard_bloc.dart';
import '../../blocs/admin_dashboard/admin_dashboard_event.dart';
import '../../blocs/admin_dashboard/admin_dashboard_state.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_state.dart';
import '../../blocs/org/org_bloc.dart';
import '../../blocs/org/org_event.dart';
import '../../blocs/org/org_state.dart';
import '../../widgets/org_header.dart';
import '../../widgets/stat_card.dart';
import '../../models/user.dart';
import '../../core/utils/permission_checker.dart';
import '../../core/constants/permissions.dart';
import 'student_management_screen.dart';
import 'driver_management_screen.dart';
import 'bus_management_screen.dart';
import 'route_management_screen.dart';
import 'live_monitoring_screen.dart';
import 'users_roles_permissions_screen.dart';
import '../profile/profile_screen.dart';

/// Admin dashboard screen
class AdminDashboardScreen extends StatelessWidget {
  final User user;

  const AdminDashboardScreen({
    super.key,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OrgBloc, OrgState>(
      builder: (context, orgState) {
        // Handle error state
        if (orgState is OrgError) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Dashboard'),
            ),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(
                      'Error loading organization',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      orgState.message,
                      style: TextStyle(color: Colors.grey[600]),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    if (user.organizationId.isNotEmpty)
                      Text(
                        'Organization ID: ${user.organizationId}',
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 12,
                        ),
                      ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () {
                        // Retry loading organization
                        if (user.organizationId.isNotEmpty) {
                          context.read<OrgBloc>().add(
                                LoadOrganizationById(user.organizationId),
                              );
                        }
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        final organization = orgState is OrgLoaded
            ? orgState.currentOrganization
            : null;

        if (organization == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return BlocProvider(
          create: (context) => AdminDashboardBloc()
            ..add(LoadDashboardData(organization.id)),
          child: Scaffold(
            appBar: AppBar(
              title: const Text('Dashboard'),
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
            ),
            body: Column(
              children: [
                OrgHeader(
                  organization: organization,
                  role: UserRole.admin,
                ),
                Expanded(
                  child: _buildDashboardContent(context, organization.id),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDashboardContent(BuildContext context, String organizationId) {
    return BlocBuilder<AdminDashboardBloc, AdminDashboardState>(
      builder: (context, state) {
        if (state is AdminDashboardLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is AdminDashboardError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Error: ${state.message}'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    context.read<AdminDashboardBloc>().add(
                          LoadDashboardData(organizationId),
                        );
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (state is AdminDashboardLoaded) {
          return RefreshIndicator(
            onRefresh: () async {
              context.read<AdminDashboardBloc>().add(
                    RefreshDashboard(organizationId),
                  );
            },
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 600),
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
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Stats grid
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 1.5,
                      children: [
                        TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0.0, end: 1.0),
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeOut,
                          builder: (context, value, child) {
                            return Opacity(
                              opacity: value,
                              child: Transform.scale(
                                scale: 0.8 + (0.2 * value),
                                child: child,
                              ),
                            );
                          },
                          child: StatCard(
                            title: 'Total Buses',
                            value: state.totalBuses.toString(),
                            icon: Icons.directions_bus,
                            color: Colors.blue,
                          ),
                        ),
                        TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0.0, end: 1.0),
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeOut,
                          builder: (context, value, child) {
                            return Opacity(
                              opacity: value,
                              child: Transform.scale(
                                scale: 0.8 + (0.2 * value),
                                child: child,
                              ),
                            );
                          },
                          child: StatCard(
                            title: 'Total Students',
                            value: state.totalStudents.toString(),
                            icon: Icons.people,
                            color: Colors.green,
                          ),
                        ),
                        TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0.0, end: 1.0),
                          duration: const Duration(milliseconds: 600),
                          curve: Curves.easeOut,
                          builder: (context, value, child) {
                            return Opacity(
                              opacity: value,
                              child: Transform.scale(
                                scale: 0.8 + (0.2 * value),
                                child: child,
                              ),
                            );
                          },
                          child: StatCard(
                            title: 'Active Trips',
                            value: state.activeTrips.toString(),
                            icon: Icons.route,
                            color: Colors.orange,
                          ),
                        ),
                        TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0.0, end: 1.0),
                          duration: const Duration(milliseconds: 700),
                          curve: Curves.easeOut,
                          builder: (context, value, child) {
                            return Opacity(
                              opacity: value,
                              child: Transform.scale(
                                scale: 0.8 + (0.2 * value),
                                child: child,
                              ),
                            );
                          },
                          child: StatCard(
                            title: 'Drivers Online',
                            value: state.driversOnline.toString(),
                            icon: Icons.person,
                            color: Colors.purple,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    // Quick actions
                    Text(
                      'Quick Actions',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                        color: Colors.grey[900],
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildPermissionBasedActions(context),
                  const SizedBox(height: 16),
                  // Active trips
                  if (state.tripsInProgress.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Active Trips',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                        color: Colors.grey[900],
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...state.tripsInProgress.map((trip) => Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Colors.white,
                                Colors.orange.withValues(alpha: 0.03),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.06),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                                spreadRadius: 0,
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const LiveMonitoringScreen(),
                                  ),
                                );
                              },
                              borderRadius: BorderRadius.circular(20),
                              child: Padding(
                                padding: const EdgeInsets.all(20),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            Colors.orange,
                                            Colors.deepOrange,
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      child: const Icon(Icons.directions_bus, 
                                          color: Colors.white, size: 24),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Bus ${trip.busId}',
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Started: ${trip.startTime?.toString().substring(11, 16) ?? 'N/A'}',
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Icon(Icons.arrow_forward_ios_rounded, 
                                        color: Colors.grey[400], size: 16),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        )),
                  ],
                ],
              ),
            ),
              ),
            );
          }

        return const Center(child: Text('Unknown state'));
      },
    );
  }

  Widget _buildPermissionBasedActions(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        if (authState is! AuthAuthenticated) {
          return const SizedBox.shrink();
        }

        final user = authState.user;
        final actions = <Widget>[];

        // Student Management - requires any student permission
        if (PermissionChecker.hasAnyPermission(
            user, Permissions.studentManagement)) {
          actions.add(
            _buildActionCard(
              context,
              'Student Management',
              Icons.school,
              Colors.blue,
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const StudentManagementScreen(),
                  ),
                );
              },
            ),
          );
        }

        // Driver Management - requires user read permission
        if (PermissionChecker.hasPermission(user, Permissions.userRead)) {
          actions.add(
            _buildActionCard(
              context,
              'Driver Management',
              Icons.person,
              Colors.green,
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const DriverManagementScreen(),
                  ),
                );
              },
            ),
          );
        }

        // Bus Management - requires bus permission
        if (PermissionChecker.hasAnyPermission(user, Permissions.busManagement)) {
          actions.add(
            _buildActionCard(
              context,
              'Bus Management',
              Icons.directions_bus,
              Colors.orange,
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const BusManagementScreen(),
                  ),
                );
              },
            ),
          );
        }

        // Route Management - requires route permission
        if (PermissionChecker.hasAnyPermission(user, Permissions.routeManagement)) {
          actions.add(
            _buildActionCard(
              context,
              'Route Management',
              Icons.route,
              Colors.deepOrange,
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const RouteManagementScreen(),
                  ),
                );
              },
            ),
          );
        }

        // Live Monitoring - requires location read permission
        if (PermissionChecker.hasPermission(user, Permissions.locationRead)) {
          actions.add(
            _buildActionCard(
              context,
              'Live Monitoring',
              Icons.location_on,
              Colors.red,
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LiveMonitoringScreen(),
                  ),
                );
              },
            ),
          );
        }

        // Users, Roles & Permissions - requires user, role, or permission read
        if (PermissionChecker.hasPermission(user, Permissions.userRead) ||
            PermissionChecker.hasPermission(user, Permissions.roleRead) ||
            PermissionChecker.hasPermission(user, Permissions.permissionRead)) {
          actions.add(
            _buildActionCard(
              context,
              'Users, Roles & Permissions',
              Icons.people,
              Colors.purple,
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        const UsersRolesPermissionsScreen(),
                  ),
                );
              },
            ),
          );
        }

        if (actions.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: Text(
                'No actions available with your current permissions',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        return Column(children: actions);
      },
    );
  }

  Widget _buildActionCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(20 * (1 - value), 0),
            child: child,
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              color.withValues(alpha: 0.03),
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
              color: color.withValues(alpha: 0.1),
              blurRadius: 12,
              offset: const Offset(0, 4),
              spreadRadius: 0,
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(24),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          color,
                          color.withValues(alpha: 0.7),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: color.withValues(alpha: 0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(icon, color: Colors.white, size: 28),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.arrow_forward_ios_rounded, 
                        color: Colors.grey[600], size: 16),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

