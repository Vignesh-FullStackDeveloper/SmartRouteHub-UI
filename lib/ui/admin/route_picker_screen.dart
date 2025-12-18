import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_polyline_algorithm/google_polyline_algorithm.dart';
import '../../services/api_maps_service.dart';
import '../../models/stop.dart';

/// Screen for picking route with start, end, and intermediate stops on map
class RoutePickerScreen extends StatefulWidget {
  const RoutePickerScreen({super.key});

  @override
  State<RoutePickerScreen> createState() => _RoutePickerScreenState();
}

class _RoutePickerScreenState extends State<RoutePickerScreen> {
  final ApiMapsService _mapsService = ApiMapsService();
  GoogleMapController? _mapController;
  final TextEditingController _searchController = TextEditingController();
  
  LatLng? _startPoint;
  LatLng? _endPoint;
  final List<LatLng> _waypoints = [];
  String? _startPointName;
  String? _endPointName;
  final List<String> _waypointNames = [];
  final Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  
  List<Map<String, dynamic>> _searchResults = [];
  bool _isSearching = false;
  bool _isCalculatingRoute = false;
  bool _routeCalculated = false;

  // Madurai coordinates
  static const double maduraiLatitude = 9.925201;
  static const double maduraiLongitude = 78.119774;
  static const double defaultZoom = 15.0;

  @override
  void dispose() {
    _searchController.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  String get _currentStepHint {
    if (_startPoint == null) {
      return 'Search and select start point...';
    } else if (_endPoint == null) {
      return 'Search and select end point...';
    } else {
      return 'Search and add waypoints (optional)...';
    }
  }

  Future<void> _searchLocation(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });

    try {
      final result = await _mapsService.geocode(query);
      final List<Map<String, dynamic>> results = [];
      
      if (result['results'] != null) {
        final resultsList = result['results'] as List;
        for (var item in resultsList) {
          final location = item['geometry']?['location'];
          if (location != null) {
            results.add({
              'address': item['formatted_address'] ?? query,
              'latitude': location['lat']?.toDouble() ?? 0.0,
              'longitude': location['lng']?.toDouble() ?? 0.0,
            });
          }
        }
      }

      setState(() {
        _searchResults = results;
        _isSearching = false;
      });
    } catch (e) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Search failed: $e')),
        );
      }
    }
  }

  void _selectLocationFromSearch(LatLng location, String address) {
    // Enforce flow: start → end → waypoints
    if (_startPoint == null) {
      // Step 1: Select start point
      setState(() {
        _startPoint = location;
        _startPointName = address;
        _updateMarkers();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Start point selected. Now select end point.')),
      );
    } else if (_endPoint == null) {
      // Step 2: Select end point
      setState(() {
        _endPoint = location;
        _endPointName = address;
        _routeCalculated = false; // Reset route when end point changes
        _polylines = {}; // Clear existing route
        _updateMarkers();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('End point selected. Click "Show Route" to see the route.')),
      );
    } else {
      // Step 3: Add waypoints
      setState(() {
        _waypoints.add(location);
        _waypointNames.add(address);
        _routeCalculated = false; // Reset route when waypoint is added
        _polylines = {}; // Clear existing route
        _updateMarkers();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Waypoint ${_waypoints.length} added. Click "Show Route" to update.')),
      );
    }
    
    // Center map on selected location
    _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(location, 15),
    );
    
    // Clear search
    _searchController.clear();
    setState(() {
      _searchResults = [];
    });
  }

  void _updateMarkers() {
    _markers.clear();
    
    if (_startPoint != null) {
      _markers.add(
        Marker(
          markerId: const MarkerId('start'),
          position: _startPoint!,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
          infoWindow: const InfoWindow(title: 'Start Point'),
        ),
      );
    }
    
    if (_endPoint != null) {
      _markers.add(
        Marker(
          markerId: const MarkerId('end'),
          position: _endPoint!,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          infoWindow: const InfoWindow(title: 'End Point'),
        ),
      );
    }
    
    for (int i = 0; i < _waypoints.length; i++) {
      _markers.add(
        Marker(
          markerId: MarkerId('waypoint_$i'),
          position: _waypoints[i],
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          infoWindow: InfoWindow(title: 'Waypoint ${i + 1}'),
        ),
      );
    }
  }

  Future<void> _calculateAndShowRoute() async {
    if (_startPoint == null || _endPoint == null) {
      return;
    }

    setState(() {
      _isCalculatingRoute = true;
    });

    try {
      final waypoints = _waypoints.map((w) => {
        'lat': w.latitude,
        'lng': w.longitude,
      }).toList();

      final result = await _mapsService.calculateRoute(
        originLat: _startPoint!.latitude,
        originLng: _startPoint!.longitude,
        destLat: _endPoint!.latitude,
        destLng: _endPoint!.longitude,
        waypoints: waypoints.isEmpty ? null : waypoints,
      );

      // Debug: print the result structure
      print('Route calculation result keys: ${result.keys}');
      if (result['routes'] != null) {
        print('Routes array length: ${(result['routes'] as List).length}');
        if ((result['routes'] as List).isNotEmpty) {
          final route = (result['routes'] as List)[0] as Map<String, dynamic>;
          print('First route keys: ${route.keys}');
          if (route['polyline'] != null) {
            print('Polyline type: ${route['polyline'].runtimeType}');
            if (route['polyline'] is Map) {
              print('Polyline map keys: ${(route['polyline'] as Map).keys}');
            }
          }
        }
      }

      // Extract polyline from result (supports both Routes API v2 and old Directions API)
      String? polylineString;
      
      // First check for direct polyline string (service transforms it)
      if (result['polyline'] != null && result['polyline'] is String) {
        polylineString = result['polyline'] as String;
      } 
      // Then check routes array
      else if (result['routes'] != null && (result['routes'] as List).isNotEmpty) {
        final route = (result['routes'] as List)[0] as Map<String, dynamic>;
        
        // Routes API v2 format: routes[0].polyline.encodedPolyline or routes[0].polyline.points
        if (route['polyline'] != null) {
          if (route['polyline'] is String) {
            // Direct string
            polylineString = route['polyline'] as String;
          } else if (route['polyline'] is Map) {
            final polyline = route['polyline'] as Map<String, dynamic>;
            // Try encodedPolyline first (actual API response)
            polylineString = polyline['encodedPolyline'] as String?;
            // Fallback to points (service transformation)
            if (polylineString == null) {
              polylineString = polyline['points'] as String?;
            }
          }
        }
        // Old Directions API format: routes[0].overview_polyline.points
        else if (route['overview_polyline'] != null) {
          final overviewPolyline = route['overview_polyline'] as Map<String, dynamic>;
          polylineString = overviewPolyline['points'] as String?;
        }
      }

      print('Extracted polyline string length: ${polylineString?.length ?? 0}');
      if (polylineString != null && polylineString.length > 0) {
        print('First 50 chars of polyline: ${polylineString.substring(0, polylineString.length > 50 ? 50 : polylineString.length)}');
      }
      
      if (polylineString != null && polylineString.isNotEmpty) {
        print('Decoding polyline...');
        // Use google_polyline_algorithm package for reliable decoding
        final decodedCoordinates = decodePolyline(polylineString);
        final points = decodedCoordinates.map((coord) => LatLng(coord[0] as double, coord[1] as double)).toList();
        print('Decoded ${points.length} points from polyline');
        if (points.isNotEmpty) {
          print('First point: ${points.first.latitude}, ${points.first.longitude}');
          print('Last point: ${points.last.latitude}, ${points.last.longitude}');
        }
        
        // Validate decoded points
        if (points.isEmpty) {
          setState(() {
            _isCalculatingRoute = false;
          });
          print('Warning: Decoded polyline resulted in 0 points. Polyline string: $polylineString');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to decode route polyline. Please try again.')),
          );
          return;
        }
        
        // Validate coordinates are reasonable (lat: -90 to 90, lng: -180 to 180)
        final invalidPoints = points.where((p) => 
          p.latitude < -90 || p.latitude > 90 || 
          p.longitude < -180 || p.longitude > 180
        ).toList();
        
        if (invalidPoints.isNotEmpty) {
          print('Warning: Found ${invalidPoints.length} invalid points in decoded polyline');
        }
        
        // Fit bounds to show entire route
        if (points.isNotEmpty && _mapController != null) {
          double minLat = points.first.latitude;
          double maxLat = points.first.latitude;
          double minLng = points.first.longitude;
          double maxLng = points.first.longitude;
          
          for (var point in points) {
            minLat = point.latitude < minLat ? point.latitude : minLat;
            maxLat = point.latitude > maxLat ? point.latitude : maxLat;
            minLng = point.longitude < minLng ? point.longitude : minLng;
            maxLng = point.longitude > maxLng ? point.longitude : maxLng;
          }
          
          _mapController!.animateCamera(
            CameraUpdate.newLatLngBounds(
              LatLngBounds(
                southwest: LatLng(minLat, minLng),
                northeast: LatLng(maxLat, maxLng),
              ),
              100.0, // padding in pixels
            ),
          );
        }
        
        print('Setting polyline with ${points.length} points');
        setState(() {
          _polylines = {
            Polyline(
              polylineId: const PolylineId('route'),
              points: points,
              color: Colors.blue,
              width: 5,
              geodesic: true, // Important for long routes
            ),
          };
          _routeCalculated = true;
          _isCalculatingRoute = false;
        });
        
        print('Polyline set in state. Route calculated: $_routeCalculated, Polylines count: ${_polylines.length}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Route calculated with ${points.length} points. You can now confirm.'),
            duration: const Duration(seconds: 2),
          ),
        );
      } else {
        setState(() {
          _isCalculatingRoute = false;
        });
        // Debug: print the result to see what we got
        print('Route calculation result: $result');
        print('Polyline string extracted: $polylineString');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to extract route polyline. Result: ${result.toString()}'),
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isCalculatingRoute = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to calculate route: $e')),
        );
      }
    }
  }


  void _clearRoute() {
    setState(() {
      _startPoint = null;
      _endPoint = null;
      _waypoints.clear();
      _startPointName = null;
      _endPointName = null;
      _waypointNames.clear();
      _routeCalculated = false;
      _updateMarkers();
      _polylines = {};
    });
  }

  void _removeWaypoint(int index) {
    setState(() {
      _waypoints.removeAt(index);
      if (index < _waypointNames.length) {
        _waypointNames.removeAt(index);
      }
      _routeCalculated = false; // Reset route when waypoint is removed
      _polylines = {}; // Clear existing route
      _updateMarkers();
    });
  }

  List<Stop> _getStops() {
    final stops = <Stop>[];
    int order = 0;

    if (_startPoint != null) {
      stops.add(Stop(
        id: 'start',
        name: _startPointName ?? 'Start Point',
        latitude: _startPoint!.latitude,
        longitude: _startPoint!.longitude,
        order: order++,
      ));
    }

    for (int i = 0; i < _waypoints.length; i++) {
      stops.add(Stop(
        id: 'waypoint_$i',
        name: (i < _waypointNames.length) ? _waypointNames[i] : 'Waypoint ${i + 1}',
        latitude: _waypoints[i].latitude,
        longitude: _waypoints[i].longitude,
        order: order++,
      ));
    }

    if (_endPoint != null) {
      stops.add(Stop(
        id: 'end',
        name: _endPointName ?? 'End Point',
        latitude: _endPoint!.latitude,
        longitude: _endPoint!.longitude,
        order: order++,
      ));
    }

    return stops;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose Route in Map'),
        actions: [
          if (_startPoint != null || _endPoint != null || _waypoints.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: _clearRoute,
              tooltip: 'Clear Route',
            ),
        ],
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: const LatLng(maduraiLatitude, maduraiLongitude),
              zoom: defaultZoom,
            ),
            onMapCreated: (controller) {
              _mapController = controller;
            },
            markers: _markers,
            polylines: _polylines,
            myLocationButtonEnabled: true,
            zoomControlsEnabled: true,
            mapType: MapType.normal,
          ),
          // Search bar
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: _currentStepHint,
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.search),
                                    onPressed: () {
                                      if (_searchController.text.trim().isNotEmpty) {
                                        _searchLocation(_searchController.text.trim());
                                      }
                                    },
                                    tooltip: 'Search',
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.clear),
                                    onPressed: () {
                                      _searchController.clear();
                                      setState(() {
                                        _searchResults = [];
                                      });
                                    },
                                    tooltip: 'Clear',
                                  ),
                                ],
                              )
                            : null,
                        border: InputBorder.none,
                      ),
                      onChanged: (value) {
                        // Clear results when text changes, but don't search
                        if (value.isEmpty) {
                          setState(() {
                            _searchResults = [];
                          });
                        }
                      },
                      onSubmitted: (value) {
                        if (value.trim().isNotEmpty) {
                          _searchLocation(value.trim());
                        }
                      },
                    ),
                    if (_isSearching)
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: LinearProgressIndicator(),
                      ),
                    if (_searchResults.isNotEmpty)
                      Container(
                        constraints: const BoxConstraints(maxHeight: 200),
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: _searchResults.length,
                          itemBuilder: (context, index) {
                            final result = _searchResults[index];
                            return ListTile(
                              leading: const Icon(Icons.location_on),
                              title: Text(result['address'] ?? ''),
                              onTap: () {
                                _selectLocationFromSearch(
                                  LatLng(
                                    result['latitude'] as double,
                                    result['longitude'] as double,
                                  ),
                                  result['address'] as String,
                                );
                              },
                            );
                          },
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          // Instructions
          Positioned(
            bottom: 100,
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
                      'Step-by-step Instructions:',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    if (_startPoint == null) ...[
                      Text('1. Search and select START POINT', 
                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                      Text('2. Then select end point'),
                      Text('3. Then add waypoints (optional)'),
                    ] else if (_endPoint == null) ...[
                      Text('1. ✓ Start point selected', 
                        style: TextStyle(color: Colors.green)),
                      Text('2. Search and select END POINT', 
                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
                      Text('3. Then add waypoints (optional)'),
                    ] else ...[
                      Text('1. ✓ Start point selected', 
                        style: TextStyle(color: Colors.green)),
                      Text('2. ✓ End point selected', 
                        style: TextStyle(color: Colors.red)),
                      Text('3. Search and add WAYPOINTS (optional)', 
                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
                    ],
                    if (_startPoint != null || _endPoint != null || _waypoints.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Text(
                        'Selected Points:',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      if (_startPoint != null)
                        ListTile(
                          dense: true,
                          leading: const Icon(Icons.play_arrow, color: Colors.green),
                          title: const Text('Start Point'),
                          trailing: IconButton(
                            icon: const Icon(Icons.close, size: 18),
                            onPressed: () {
                              setState(() {
                                _startPoint = null;
                                _endPoint = null; // Clear end point too
                                _waypoints.clear(); // Clear waypoints too
                                _updateMarkers();
                                _polylines = {};
                              });
                            },
                          ),
                        ),
                      if (_endPoint != null)
                        ListTile(
                          dense: true,
                          leading: const Icon(Icons.stop, color: Colors.red),
                          title: const Text('End Point'),
                          trailing: IconButton(
                            icon: const Icon(Icons.close, size: 18),
                            onPressed: () {
                              setState(() {
                                _endPoint = null;
                                _waypoints.clear(); // Clear waypoints when end is removed
                                _routeCalculated = false;
                                _polylines = {};
                                _updateMarkers();
                              });
                            },
                          ),
                        ),
                      ...List.generate(_waypoints.length, (index) {
                        return ListTile(
                          dense: true,
                          leading: const Icon(Icons.location_on, color: Colors.blue),
                          title: Text('Waypoint ${index + 1}'),
                          trailing: IconButton(
                            icon: const Icon(Icons.close, size: 18),
                            onPressed: () => _removeWaypoint(index),
                          ),
                        );
                      }),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: _startPoint != null && _endPoint != null
          ? _routeCalculated
              ? FloatingActionButton.extended(
                  onPressed: () {
                    final stops = _getStops();
                    Navigator.pop(context, stops);
                  },
                  icon: const Icon(Icons.check),
                  label: const Text('Confirm Route'),
                )
              : FloatingActionButton.extended(
                  onPressed: _isCalculatingRoute ? null : _calculateAndShowRoute,
                  icon: _isCalculatingRoute
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Icon(Icons.route),
                  label: Text(_isCalculatingRoute ? 'Calculating...' : 'Show Route'),
                )
          : null,
    );
  }
}
