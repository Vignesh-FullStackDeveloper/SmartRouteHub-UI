import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../services/api_maps_service.dart';
import '../../services/api_route_service.dart';
import '../../core/constants/app_constants.dart';

/// Widget for picking and saving location pins on map
class MapLocationPicker extends StatefulWidget {
  final String routeId;
  final Function(Stop) onLocationPicked;

  const MapLocationPicker({
    super.key,
    required this.routeId,
    required this.onLocationPicked,
  });

  @override
  State<MapLocationPicker> createState() => _MapLocationPickerState();
}

class _MapLocationPickerState extends State<MapLocationPicker> {
  final ApiMapsService _mapsService = ApiMapsService();
  final ApiRouteService _routeService = ApiRouteService();
  GoogleMapController? _mapController;
  final Set<Marker> _markers = {};
  LatLng? _selectedLocation;
  final TextEditingController _nameController = TextEditingController();
  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _onMapTap(LatLng location) {
    setState(() {
      _selectedLocation = location;
      _markers.clear();
      _markers.add(
        Marker(
          markerId: const MarkerId('selected_location'),
          position: location,
          infoWindow: const InfoWindow(title: 'Selected Location'),
        ),
      );
    });

    // Show dialog to name the location
    _showLocationNameDialog(location);
  }

  Future<void> _showLocationNameDialog(LatLng location) async {
    _nameController.clear();
    
    // Get address from coordinates
    String address = 'Unknown location';
    try {
      final result = await _mapsService.reverseGeocode(
        latitude: location.latitude,
        longitude: location.longitude,
      );
      address = result['address'] as String? ?? address;
    } catch (e) {
      print('Failed to get address: $e');
    }

    if (!mounted) return;

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Location Pin'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Location Name',
                hintText: 'e.g., School Gate, Bus Stop 1',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Address: $address',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (_nameController.text.trim().isNotEmpty) {
                Navigator.pop(context, {
                  'name': _nameController.text.trim(),
                  'address': address,
                });
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (result != null && _selectedLocation != null) {
      await _saveLocationPin(
        _selectedLocation!,
        result['name'] as String,
        result['address'] as String,
      );
    }
  }

  Future<void> _saveLocationPin(
    LatLng location,
    String name,
    String address,
  ) async {
    setState(() => _isSaving = true);

    try {
      // Get current route to determine next order
      final route = await _routeService.getRouteById(widget.routeId);
      final nextOrder = route.stops.isEmpty
          ? 0
          : route.stops.map((s) => s.order).reduce((a, b) => a > b ? a : b) + 1;

      // Save location pin to database
      await _mapsService.saveLocationPin(
        routeId: widget.routeId,
        name: name,
        latitude: location.latitude,
        longitude: location.longitude,
        order: nextOrder,
        address: {
          'formatted': address,
          'components': {},
        },
      );

      // Create stop object for callback
      final stop = Stop(
        id: '', // Will be set by backend
        routeId: widget.routeId,
        name: name,
        latitude: location.latitude,
        longitude: location.longitude,
        order: nextOrder,
        address: {'formatted': address},
      );

      widget.onLocationPicked(stop);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Location "$name" saved successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save location: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GoogleMap(
          initialCameraPosition: CameraPosition(
            target: LatLng(
              AppConstants.defaultLatitude,
              AppConstants.defaultLongitude,
            ),
            zoom: AppConstants.defaultZoom,
          ),
          onMapCreated: (controller) {
            _mapController = controller;
          },
          onTap: _onMapTap,
          markers: _markers,
          myLocationEnabled: true,
          myLocationButtonEnabled: true,
        ),
        if (_isSaving)
          Container(
            color: Colors.black54,
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          ),
        Positioned(
          bottom: 16,
          left: 16,
          right: 16,
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Tap on map to add location pin',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Selected location will be saved to database',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// Import Stop model
import '../../models/stop.dart';

