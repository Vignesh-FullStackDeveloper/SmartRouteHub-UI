import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/parent_tracking/parent_tracking_bloc.dart';
import '../../blocs/parent_tracking/parent_tracking_event.dart';
import '../../blocs/parent_tracking/parent_tracking_state.dart';
import '../../core/constants/app_constants.dart';

/// Child tracking screen showing bus location on map
class ChildTrackingScreen extends StatefulWidget {
  final String childId;
  final String organizationId;

  const ChildTrackingScreen({
    super.key,
    required this.childId,
    required this.organizationId,
  });

  @override
  State<ChildTrackingScreen> createState() => _ChildTrackingScreenState();
}

class _ChildTrackingScreenState extends State<ChildTrackingScreen> {
  GoogleMapController? _mapController;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ParentTrackingBloc()
        ..add(LoadChildTracking(
          childId: widget.childId,
          organizationId: widget.organizationId,
        )),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Child Tracking'),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                context.read<ParentTrackingBloc>().add(
                      LoadChildTracking(
                        childId: widget.childId,
                        organizationId: widget.organizationId,
                      ),
                    );
              },
            ),
          ],
        ),
        body: BlocBuilder<ParentTrackingBloc, ParentTrackingState>(
          builder: (context, state) {
            if (state is ParentTrackingLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is ParentTrackingError) {
              return Center(child: Text('Error: ${state.message}'));
            }

            if (state is ParentTrackingLoaded && state.children.isNotEmpty) {
              final childInfo = state.children.first;
              final trip = childInfo.trip;
              final pickupPoint = childInfo.pickupPoint;

              // Build markers
              Set<Marker> markers = {};

              // Bus marker
              if (trip?.currentLatitude != null &&
                  trip?.currentLongitude != null) {
                markers.add(
                  Marker(
                    markerId: const MarkerId('bus'),
                    position: LatLng(
                      trip!.currentLatitude!,
                      trip.currentLongitude!,
                    ),
                    icon: BitmapDescriptor.defaultMarkerWithHue(
                      BitmapDescriptor.hueBlue,
                    ),
                    infoWindow: InfoWindow(
                      title: 'Bus ${childInfo.bus?.busNumber ?? 'N/A'}',
                      snippet: 'Speed: ${trip.speed?.toStringAsFixed(1) ?? '0'} km/h',
                    ),
                  ),
                );
              }

              // Pickup point marker
              if (pickupPoint != null) {
                markers.add(
                  Marker(
                    markerId: const MarkerId('pickup'),
                    position: LatLng(
                      pickupPoint.latitude,
                      pickupPoint.longitude,
                    ),
                    icon: BitmapDescriptor.defaultMarkerWithHue(
                      BitmapDescriptor.hueGreen,
                    ),
                    infoWindow: InfoWindow(title: pickupPoint.name),
                  ),
                );
              }

              // School marker (dummy location)
              markers.add(
                Marker(
                  markerId: const MarkerId('school'),
                  position: const LatLng(
                    AppConstants.defaultLatitude + 0.01,
                    AppConstants.defaultLongitude + 0.01,
                  ),
                  icon: BitmapDescriptor.defaultMarkerWithHue(
                    BitmapDescriptor.hueRed,
                  ),
                  infoWindow: const InfoWindow(title: 'School'),
                ),
              );

              return Stack(
                children: [
                  // Map
                  GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: trip?.currentLatitude != null &&
                              trip?.currentLongitude != null
                          ? LatLng(
                              trip!.currentLatitude!,
                              trip.currentLongitude!,
                            )
                          : const LatLng(
                              AppConstants.defaultLatitude,
                              AppConstants.defaultLongitude,
                            ),
                      zoom: AppConstants.defaultZoom,
                    ),
                    markers: markers,
                    onMapCreated: (controller) {
                      _mapController = controller;
                    },
                    myLocationButtonEnabled: false,
                  ),
                  // Info card
                  Positioned(
                    bottom: 16,
                    left: 16,
                    right: 16,
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              childInfo.student.name,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Status: ${_getStatusText(childInfo.status)}',
                              style: TextStyle(
                                color: _getStatusColor(childInfo.status),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (childInfo.distanceToPickup != null) ...[
                              const SizedBox(height: 8),
                              Text(
                                'Distance: ${childInfo.distanceToPickup!.toStringAsFixed(2)} km',
                              ),
                            ],
                            if (childInfo.etaToPickup != null) ...[
                              const SizedBox(height: 8),
                              Text(
                                'ETA: ${childInfo.etaToPickup!.inMinutes} minutes',
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }

            return const Center(child: Text('No tracking data available'));
          },
        ),
      ),
    );
  }

  String _getStatusText(ChildBusStatus status) {
    switch (status) {
      case ChildBusStatus.notStarted:
        return 'Not Started';
      case ChildBusStatus.started:
        return 'Trip Started';
      case ChildBusStatus.nearPickup:
        return 'Near Pickup Point';
      case ChildBusStatus.completed:
        return 'Trip Completed';
    }
  }

  Color _getStatusColor(ChildBusStatus status) {
    switch (status) {
      case ChildBusStatus.notStarted:
        return Colors.grey;
      case ChildBusStatus.started:
        return Colors.blue;
      case ChildBusStatus.nearPickup:
        return Colors.orange;
      case ChildBusStatus.completed:
        return Colors.green;
    }
  }
}

