import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../blocs/driver_trip/driver_trip_bloc.dart';
import '../../blocs/driver_trip/driver_trip_event.dart';
import '../../blocs/driver_trip/driver_trip_state.dart';
import '../../services/location_service.dart';
import '../../core/constants/app_constants.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/secondary_button.dart';
import '../../models/trip.dart';
import '../../models/stop.dart';

/// Live trip screen for drivers
class LiveTripScreen extends StatefulWidget {
  final String driverId;
  final String organizationId;

  const LiveTripScreen({
    super.key,
    required this.driverId,
    required this.organizationId,
  });

  @override
  State<LiveTripScreen> createState() => _LiveTripScreenState();
}

class _LiveTripScreenState extends State<LiveTripScreen> {
  GoogleMapController? _mapController;
  final LocationService _locationService = LocationService();
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeLocation();
  }

  Future<void> _initializeLocation() async {
    await _locationService.initialize();
    setState(() {
      _isInitialized = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DriverTripBloc()
        ..add(LoadDriverTripData(
          driverId: widget.driverId,
          organizationId: widget.organizationId,
        )),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Live Trip'),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                context.read<DriverTripBloc>().add(
                      LoadDriverTripData(
                        driverId: widget.driverId,
                        organizationId: widget.organizationId,
                      ),
                    );
              },
            ),
          ],
        ),
        body: _isInitialized
            ? BlocBuilder<DriverTripBloc, DriverTripState>(
                builder: (context, state) {
                  if (state is DriverTripLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state is DriverTripError) {
                    return Center(child: Text('Error: ${state.message}'));
                  }

                  if (state is DriverTripLoaded) {
                    if (!state.hasActiveTrip || state.currentTrip == null) {
                      return const Center(
                        child: Text('No active trip'),
                      );
                    }

                    final trip = state.currentTrip!;
                    final route = state.assignedRoute;
                    final nextStop = route?.stops.firstWhere(
                      (stop) => !stop.isCompleted,
                      orElse: () => route!.stops.first,
                    );

                    // Build markers
                    Set<Marker> markers = {};
                    Set<Polyline> polylines = {};

                    // Current location marker
                    if (trip.currentLatitude != null &&
                        trip.currentLongitude != null) {
                      markers.add(
                        Marker(
                          markerId: const MarkerId('current_location'),
                          position: LatLng(
                            trip.currentLatitude!,
                            trip.currentLongitude!,
                          ),
                          icon: BitmapDescriptor.defaultMarkerWithHue(
                            BitmapDescriptor.hueBlue,
                          ),
                          infoWindow: const InfoWindow(title: 'Current Location'),
                        ),
                      );
                    }

                    // Route stops markers
                    if (route != null) {
                      for (final stop in route.stops) {
                        markers.add(
                          Marker(
                            markerId: MarkerId(stop.id),
                            position: LatLng(stop.latitude, stop.longitude),
                            icon: BitmapDescriptor.defaultMarkerWithHue(
                              stop.isCompleted
                                  ? BitmapDescriptor.hueGreen
                                  : BitmapDescriptor.hueRed,
                            ),
                            infoWindow: InfoWindow(title: stop.name),
                          ),
                        );
                      }

                      // Route polyline
                      if (route.stops.length > 1) {
                        polylines.add(
                          Polyline(
                            polylineId: const PolylineId('route'),
                            points: route.stops
                                .map((stop) => LatLng(
                                      stop.latitude,
                                      stop.longitude,
                                    ))
                                .toList(),
                            color: Colors.blue,
                            width: 3,
                          ),
                        );
                      }
                    }

                    return Stack(
                      children: [
                        // Map
                        GoogleMap(
                          initialCameraPosition: CameraPosition(
                            target: trip.currentLatitude != null &&
                                    trip.currentLongitude != null
                                ? LatLng(
                                    trip.currentLatitude!,
                                    trip.currentLongitude!,
                                  )
                                : const LatLng(
                                    AppConstants.defaultLatitude,
                                    AppConstants.defaultLongitude,
                                  ),
                            zoom: AppConstants.defaultZoom,
                          ),
                          markers: markers,
                          polylines: polylines,
                          onMapCreated: (controller) {
                            _mapController = controller;
                          },
                          myLocationButtonEnabled: false,
                        ),
                        // Bottom sheet with trip controls
                        DraggableScrollableSheet(
                          initialChildSize: 0.3,
                          minChildSize: 0.2,
                          maxChildSize: 0.6,
                          builder: (context, scrollController) {
                            return Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(20),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 10,
                                    offset: const Offset(0, -2),
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  Container(
                                    margin: const EdgeInsets.only(top: 8),
                                    width: 40,
                                    height: 4,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[300],
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                  Expanded(
                                    child: ListView(
                                      controller: scrollController,
                                      padding: const EdgeInsets.all(16),
                                      children: [
                                        if (nextStop != null) ...[
                                          const Text(
                                            'Next Stop',
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            nextStop.name,
                                            style: const TextStyle(
                                              fontSize: 16,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            'ETA: ${_calculateETA(trip, nextStop)}',
                                            style: TextStyle(
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                          const SizedBox(height: 16),
                                        ],
                                        PrimaryButton(
                                          text: 'Mark Arrived at Stop',
                                          icon: Icons.check_circle,
                                          onPressed: () {
                                            context.read<DriverTripBloc>().add(
                                                  MarkStopArrived(trip.id),
                                                );
                                          },
                                        ),
                                        const SizedBox(height: 8),
                                        SecondaryButton(
                                          text: 'Skip Stop',
                                          icon: Icons.skip_next,
                                          onPressed: () {
                                            // Skip stop logic
                                          },
                                        ),
                                        const SizedBox(height: 8),
                                        ElevatedButton(
                                          onPressed: () {
                                            context.read<DriverTripBloc>().add(
                                                  EndTrip(trip.id),
                                                );
                                            Navigator.pop(context);
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.red,
                                            foregroundColor: Colors.white,
                                          ),
                                          child: const Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(Icons.stop),
                                              SizedBox(width: 8),
                                              Text('End Trip'),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    );
                  }

                  return const Center(child: Text('Unknown state'));
                },
              )
            : const Center(child: CircularProgressIndicator()),
      ),
    );
  }

  String _calculateETA(Trip trip, Stop nextStop) {
    // Dummy ETA calculation
    if (trip.speed != null && trip.speed! > 0) {
      return '~5 minutes';
    }
    return 'Calculating...';
  }
}

