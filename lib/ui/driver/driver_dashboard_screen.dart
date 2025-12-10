import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/driver_trip/driver_trip_bloc.dart';
import '../../blocs/driver_trip/driver_trip_event.dart';
import '../../blocs/driver_trip/driver_trip_state.dart';
import '../../blocs/org/org_bloc.dart';
import '../../blocs/org/org_state.dart';
import '../../widgets/org_header.dart';
import '../../widgets/primary_button.dart';
import '../../models/user.dart';
import 'live_trip_screen.dart';

/// Driver dashboard screen
class DriverDashboardScreen extends StatelessWidget {
  final DriverUser user;

  const DriverDashboardScreen({
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
          create: (context) => DriverTripBloc()
            ..add(LoadDriverTripData(
              driverId: user.id,
              organizationId: user.organizationId,
            )),
          child: Scaffold(
            body: Column(
              children: [
                OrgHeader(
                  organization: organization,
                  role: UserRole.driver,
                ),
                Expanded(
                  child: _buildDashboardContent(context),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDashboardContent(BuildContext context) {
    return BlocBuilder<DriverTripBloc, DriverTripState>(
      builder: (context, state) {
        if (state is DriverTripLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is DriverTripError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Error: ${state.message}'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    // Reload
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (state is DriverTripLoaded) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Driver info card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Driver Information',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildInfoRow('Name', user.name),
                        _buildInfoRow('Driver ID', user.driverId ?? 'N/A'),
                        _buildInfoRow('Phone', user.phone ?? user.email),
                        if (state.assignedBus != null)
                          _buildInfoRow(
                            'Assigned Bus',
                            state.assignedBus!.busNumber,
                          ),
                        if (state.assignedRoute != null)
                          _buildInfoRow(
                            'Assigned Route',
                            state.assignedRoute!.name,
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Trip status
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Today\'s Trip',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        if (state.hasActiveTrip && state.currentTrip != null) ...[
                          _buildInfoRow(
                            'Status',
                            state.currentTrip!.status.name.toUpperCase(),
                          ),
                          _buildInfoRow(
                            'Start Time',
                            state.currentTrip!.startTime
                                    ?.toString()
                                    .substring(11, 16) ??
                                'N/A',
                          ),
                          const SizedBox(height: 16),
                          PrimaryButton(
                            text: 'View Live Trip',
                            icon: Icons.map,
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => LiveTripScreen(
                                    driverId: user.id,
                                    organizationId: user.organizationId,
                                  ),
                                ),
                              );
                            },
                          ),
                        ] else ...[
                          const Text('No active trip'),
                          const SizedBox(height: 16),
                          PrimaryButton(
                            text: 'Start Trip',
                            icon: Icons.play_arrow,
                            onPressed: () {
                              if (state.assignedBus != null &&
                                  state.assignedRoute != null) {
                                context.read<DriverTripBloc>().add(
                                      StartTrip(
                                        busId: state.assignedBus!.id,
                                        routeId: state.assignedRoute!.id,
                                        driverId: user.id,
                                        organizationId: user.organizationId,
                                        latitude: 28.6139, // Default location
                                        longitude: 77.2090,
                                      ),
                                    );
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => LiveTripScreen(
                                      driverId: user.id,
                                      organizationId: user.organizationId,
                                    ),
                                  ),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Bus or route not assigned',
                                    ),
                                  ),
                                );
                              }
                            },
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        return const Center(child: Text('Unknown state'));
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
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.grey,
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

