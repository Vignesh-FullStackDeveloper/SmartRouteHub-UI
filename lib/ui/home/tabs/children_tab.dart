import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../blocs/auth/auth_bloc.dart';
import '../../../blocs/auth/auth_state.dart';
import '../../../blocs/parent_tracking/parent_tracking_bloc.dart';
import '../../../blocs/parent_tracking/parent_tracking_event.dart';
import '../../../blocs/parent_tracking/parent_tracking_state.dart';
import '../../../models/user.dart';
import '../../../widgets/primary_button.dart';
import '../../parent/child_tracking_screen.dart';

/// Children tab - for parents to view their children
class ChildrenTab extends StatelessWidget {
  const ChildrenTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        if (authState is! AuthAuthenticated) {
          return const Center(child: Text('Not authenticated'));
        }

        final user = authState.user;
        if (user is! ParentUser) {
          return const Center(child: Text('This tab is only for parents'));
        }

        return BlocProvider(
          create: (context) => ParentTrackingBloc()
            ..add(LoadParentTrackingData(
              parentId: user.id,
              organizationId: user.organizationId,
            )),
          child: BlocBuilder<ParentTrackingBloc, ParentTrackingState>(
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
                if (state.children.isEmpty) {
                  return const Center(
                    child: Text('No children found'),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    context.read<ParentTrackingBloc>().add(
                          RefreshTrackingData(
                            parentId: user.id,
                            organizationId: user.organizationId,
                          ),
                        );
                  },
                  child: ListView.builder(
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
          ),
        );
      },
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

