import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../services/api_trip_service.dart';
import '../../services/api_bus_service.dart';
import '../../services/api_route_service.dart';
import '../../services/api_student_service.dart';
import '../../models/trip.dart';
import '../../models/bus.dart';
import '../../models/route.dart' as models;
import '../../core/constants/app_constants.dart';

/// Live monitoring screen with map showing active buses
class LiveMonitoringScreen extends StatefulWidget {
  const LiveMonitoringScreen({super.key});

  @override
  State<LiveMonitoringScreen> createState() => _LiveMonitoringScreenState();
}

class _LiveMonitoringScreenState extends State<LiveMonitoringScreen> {
  final ApiTripService _tripService = ApiTripService();
  final ApiBusService _busService = ApiBusService();
  final ApiRouteService _routeService = ApiRouteService();
  final ApiStudentService _studentService = ApiStudentService();
  GoogleMapController? _mapController;
  List<Trip> _activeTrips = [];
  List<Bus> _allBuses = [];
  Set<Marker> _markers = {};
  Trip? _selectedTrip;
  Bus? _selectedBus;
  models.Route? _selectedRoute;
  int _passengerCount = 0;
  bool _isLoading = true;
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    _initializeData();
    // Auto-refresh every 5 seconds
    _startAutoRefresh();
  }

  void _startAutoRefresh() {
    if (_isDisposed) return;
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted && !_isDisposed) {
        _loadActiveTrips();
        _startAutoRefresh();
      }
    });
  }

  @override
  void dispose() {
    _isDisposed = true;
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _initializeData() async {
    await _loadAllBuses();
    await _loadActiveTrips();
  }

  // Removed dummy trip creation - only use real data from API

  Future<void> _loadAllBuses() async {
    try {
      final buses = await _busService.getBuses();
      if (!mounted || _isDisposed) return;
      setState(() {
        _allBuses = buses;
      });
    } catch (e) {
      if (!mounted || _isDisposed) return;
      // Silently fail for buses - not critical for live monitoring
    }
  }

  Future<void> _loadActiveTrips() async {
    if (!mounted || _isDisposed) return;
    setState(() {
      _isLoading = true;
    });
    try {
      final trips = await _tripService.getActiveTrips();
      if (!mounted || _isDisposed) return;
      setState(() {
        _activeTrips = trips;
        _isLoading = false;
      });
      _updateMarkers();
      if (_selectedTrip != null) {
        final updatedTrip = trips.firstWhere(
          (t) => t.id == _selectedTrip!.id,
          orElse: () => _selectedTrip!,
        );
        if (updatedTrip != _selectedTrip) {
          _selectTrip(updatedTrip);
        }
      }
    } catch (e) {
      if (!mounted || _isDisposed) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _selectBus(Bus? bus) async {
    if (bus == null) {
      if (!mounted || _isDisposed) return;
      setState(() {
        _selectedBus = null;
        _selectedTrip = null;
        _selectedRoute = null;
        _passengerCount = 0;
      });
      _updateMarkers();
      return;
    }

    if (!mounted || _isDisposed) return;
    setState(() {
      _selectedBus = bus;
    });

    // Find active trip for this bus
    final trip = _activeTrips.firstWhere(
      (t) => t.busId == bus.id,
      orElse: () => Trip(
        id: 'dummy',
        busId: bus.id,
        routeId: bus.assignedRouteId ?? '',
        driverId: bus.driverId ?? '',
        organizationId: '',
        status: TripStatus.notStarted,
        currentLatitude: AppConstants.defaultLatitude,
        currentLongitude: AppConstants.defaultLongitude,
      ),
    );

    if (trip.id != 'dummy') {
      _selectTrip(trip);
    } else {
      // Load route and passenger info even if no active trip
      if (bus.assignedRouteId != null) {
        try {
          final route = await _routeService.getRouteById(bus.assignedRouteId!);
          final students = await _studentService.getStudents();
          final passengers = students.where((s) => s.assignedBusId == bus.id).length;
          
          if (!mounted || _isDisposed) return;
          setState(() {
            _selectedRoute = route;
            _passengerCount = passengers;
          });
        } catch (e) {
          // Silently fail - not critical
        }
      }
    }
  }

  Future<void> _selectTrip(Trip trip) async {
    if (!mounted || _isDisposed) return;
    setState(() {
      _selectedTrip = trip;
    });

    // Load bus details
    final bus = await _busService.getBusById(trip.busId);
    if (!mounted || _isDisposed) return;
    setState(() {
      _selectedBus = bus;
    });

    // Load route details
    if (trip.routeId.isNotEmpty) {
      final route = await _routeService.getRouteById(trip.routeId);
      if (!mounted || _isDisposed) return;
      setState(() {
        _selectedRoute = route;
      });
    }

    // Load passenger count
    try {
      final students = await _studentService.getStudents();
      final passengers = students.where((s) => s.assignedBusId == trip.busId).length;
      if (!mounted || _isDisposed) return;
      setState(() {
        _passengerCount = passengers;
      });
    } catch (e) {
      // Silently fail - not critical
    }

    // Center map on trip location
    if (trip.currentLatitude != null && trip.currentLongitude != null) {
      _centerMapOnLocation(
        LatLng(trip.currentLatitude!, trip.currentLongitude!),
      );
    }

    _updateMarkers();
  }

  void _updateMarkers() {
    _markers.clear();
    
    for (final trip in _activeTrips) {
      if (trip.currentLatitude != null && trip.currentLongitude != null) {
        final isSelected = _selectedTrip?.id == trip.id;
        _markers.add(
          Marker(
            markerId: MarkerId(trip.id),
            position: LatLng(
              trip.currentLatitude!,
              trip.currentLongitude!,
            ),
            icon: BitmapDescriptor.defaultMarkerWithHue(
              isSelected ? BitmapDescriptor.hueBlue : BitmapDescriptor.hueRed,
            ),
            infoWindow: InfoWindow(
              title: 'Bus ${trip.busId}',
              snippet: 'Speed: ${trip.speed?.toStringAsFixed(1) ?? '0'} km/h',
            ),
            onTap: () {
              _selectTrip(trip);
            },
          ),
        );
      }
    }
  }

  void _centerMapOnLocation(LatLng location) {
    if (_mapController != null) {
      _mapController!.animateCamera(
        CameraUpdate.newLatLngZoom(location, 16),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Live Bus Monitoring'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadActiveTrips,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Column(
        children: [
          // Bus Selection Dropdown
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Select Bus',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<Bus>(
                  value: _selectedBus,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.grey[50],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(Icons.directions_bus),
                  ),
                  hint: const Text('All Buses'),
                  items: [
                    const DropdownMenuItem<Bus>(
                      value: null,
                      child: Text('All Buses'),
                    ),
                    ..._allBuses.map((bus) => DropdownMenuItem<Bus>(
                          value: bus,
                          child: Text('${bus.busNumber} ${bus.isActive ? '(Active)' : ''}'),
                        )),
                  ],
                  onChanged: (bus) => _selectBus(bus),
                ),
              ],
            ),
          ),
          // Map
          Expanded(
            flex: 2,
            child: Stack(
              children: [
                GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: LatLng(
                      AppConstants.defaultLatitude,
                      AppConstants.defaultLongitude,
                    ),
                    zoom: AppConstants.defaultZoom,
                  ),
                  markers: _markers,
                  onMapCreated: (controller) {
                    _mapController = controller;
                  },
                  myLocationButtonEnabled: false,
                  mapType: MapType.normal,
                ),
                if (_isLoading)
                  Container(
                    color: Colors.white.withOpacity(0.7),
                    child: const Center(child: CircularProgressIndicator()),
                  ),
              ],
            ),
          ),
          // Bus Details Panel
          if (_selectedBus != null)
            Expanded(
              flex: 1,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Theme.of(context).colorScheme.primary,
                                  Theme.of(context).colorScheme.secondary,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.directions_bus,
                              color: Colors.white,
                              size: 32,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _selectedBus!.busNumber,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: _selectedBus!.isActive
                                        ? Colors.green[100]
                                        : Colors.grey[200],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    _selectedBus!.isActive ? 'Active' : 'Inactive',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: _selectedBus!.isActive
                                          ? Colors.green[800]
                                          : Colors.grey[700],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      if (_selectedRoute != null) ...[
                        _buildDetailRow(
                          Icons.route,
                          'Route',
                          _selectedRoute!.name,
                        ),
                        const SizedBox(height: 12),
                        _buildDetailRow(
                          Icons.access_time,
                          'Start Time',
                          _selectedRoute!.startTime.toString().substring(11, 16),
                        ),
                        const SizedBox(height: 12),
                        _buildDetailRow(
                          Icons.access_time,
                          'Approx End Time',
                          _selectedRoute!.endTime.toString().substring(11, 16),
                        ),
                        const SizedBox(height: 12),
                        _buildDetailRow(
                          Icons.location_on,
                          'Stops',
                          '${_selectedRoute!.stops.length} stops',
                        ),
                        const SizedBox(height: 12),
                      ],
                      _buildDetailRow(
                        Icons.people,
                        'Passengers',
                        '$_passengerCount / ${_selectedBus!.capacity}',
                      ),
                      if (_selectedTrip != null && _selectedTrip!.status == TripStatus.inProgress) ...[
                        const SizedBox(height: 12),
                        _buildDetailRow(
                          Icons.speed,
                          'Current Speed',
                          '${_selectedTrip!.speed?.toStringAsFixed(1) ?? '0'} km/h',
                        ),
                        const SizedBox(height: 12),
                        _buildDetailRow(
                          Icons.play_circle,
                          'Trip Started',
                          _selectedTrip!.startTime?.toString().substring(11, 16) ?? 'N/A',
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            )
          else
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.info_outline, size: 48, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    Text(
                      'Select a bus to view details',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
