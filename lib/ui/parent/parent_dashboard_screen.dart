import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/parent_tracking/parent_tracking_bloc.dart';
import '../../blocs/parent_tracking/parent_tracking_event.dart';
import '../../blocs/parent_tracking/parent_tracking_state.dart';
import '../../blocs/org/org_bloc.dart';
import '../../blocs/org/org_state.dart';
import '../../widgets/org_header.dart';
import '../../widgets/primary_button.dart';
import '../../models/user.dart';
import 'child_tracking_screen.dart';
import 'notifications_screen.dart';

/// Parent dashboard screen
class ParentDashboardScreen extends StatelessWidget {
  final ParentUser user;

  const ParentDashboardScreen({
    super.key,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OrgBloc, OrgState>(
      builder: (context, orgState) {
        final organization = orgState is OrgLoaded
            ? orgState.currentOrganization
            : null;

        if (organization == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return BlocProvider(
          create: (context) => ParentTrackingBloc()
            ..add(LoadParentTrackingData(
              parentId: user.id,
              organizationId: user.organizationId,
            )),
          child: Scaffold(
            body: Column(
              children: [
                OrgHeader(
                  organization: organization,
                  role: UserRole.parent,
                ),
                Expanded(
                  child: _buildDashboardContent(context),
                ),
              ],
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const NotificationsScreen(),
                  ),
                );
              },
              child: const Icon(Icons.notifications),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDashboardContent(BuildContext context) {
    return BlocBuilder<ParentTrackingBloc, ParentTrackingState>(
      builder: (context, state) {
        if (state is ParentTrackingLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is ParentTrackingError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Error: ${state.message}'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    context.read<ParentTrackingBloc>().add(
                          RefreshTrackingData(
                            parentId: user.id,
                            organizationId: user.organizationId,
                          ),
                        );
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (state is ParentTrackingLoaded) {
          return RefreshIndicator(
            onRefresh: () async {
              context.read<ParentTrackingBloc>().add(
                    RefreshTrackingData(
                      parentId: user.id,
                      organizationId: user.organizationId,
                    ),
                  );
            },
            child: state.children.isEmpty
                ? const Center(child: Text('No children found'))
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: state.children.length,
                    itemBuilder: (context, index) {
                      final childInfo = state.children[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const CircleAvatar(
                                    child: Icon(Icons.person),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          childInfo.student.name,
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          '${childInfo.student.classGrade} - Section ${childInfo.student.section}',
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  _buildStatusChip(childInfo.status),
                                ],
                              ),
                              const SizedBox(height: 16),
                              if (childInfo.bus != null)
                                _buildInfoRow(
                                  'Bus',
                                  childInfo.bus!.busNumber,
                                ),
                              if (childInfo.distanceToPickup != null)
                                _buildInfoRow(
                                  'Distance to Pickup',
                                  '${childInfo.distanceToPickup!.toStringAsFixed(2)} km',
                                ),
                              if (childInfo.etaToPickup != null)
                                _buildInfoRow(
                                  'ETA',
                                  '${childInfo.etaToPickup!.inMinutes} minutes',
                                ),
                              const SizedBox(height: 16),
                              PrimaryButton(
                                text: 'View Live Location',
                                icon: Icons.map,
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          ChildTrackingScreen(
                                        childId: childInfo.student.id,
                                        organizationId: user.organizationId,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          );
        }

        return const Center(child: Text('Unknown state'));
      },
    );
  }

  Widget _buildStatusChip(ChildBusStatus status) {
    Color color;
    String text;

    switch (status) {
      case ChildBusStatus.notStarted:
        color = Colors.grey;
        text = 'Not Started';
        break;
      case ChildBusStatus.started:
        color = Colors.blue;
        text = 'Started';
        break;
      case ChildBusStatus.nearPickup:
        color = Colors.orange;
        text = 'Near Pickup';
        break;
      case ChildBusStatus.completed:
        color = Colors.green;
        text = 'Completed';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

