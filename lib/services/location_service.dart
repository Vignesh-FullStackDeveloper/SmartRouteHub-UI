import 'package:geolocator/geolocator.dart';
import '../models/trip.dart';

/// Mock location service
/// Handles location tracking and updates (mock implementation)
class LocationService {
  // Mock current position
  static Position? _currentPosition;
  static bool _isTracking = false;

  /// Initialize location service
  Future<void> initialize() async {
    // In real app, request permissions and set up location tracking
    await Future.delayed(const Duration(milliseconds: 300));
  }

  /// Get current location
  Future<Position?> getCurrentLocation() async {
    await Future.delayed(const Duration(milliseconds: 500));

    // Return mock position if available, otherwise return default
    if (_currentPosition != null) {
      return _currentPosition;
    }

    // Default mock location (Delhi)
    return Position(
      latitude: 28.6139,
      longitude: 77.2090,
      timestamp: DateTime.now(),
      accuracy: 10.0,
      altitude: 0.0,
      heading: 0.0,
      speed: 0.0,
      speedAccuracy: 0.0,
      altitudeAccuracy: 0.0,
      headingAccuracy: 0.0,
    );
  }

  /// Start location tracking
  Future<void> startTracking() async {
    _isTracking = true;
    // In real app, this would start background location updates
    // For now, we'll simulate location updates
    _simulateLocationUpdates();
  }

  /// Stop location tracking
  Future<void> stopTracking() async {
    _isTracking = false;
  }

  /// Update trip location
  Future<Trip> updateTripLocation({
    required Trip trip,
    required double latitude,
    required double longitude,
    double? speed,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));

    _currentPosition = Position(
      latitude: latitude,
      longitude: longitude,
      timestamp: DateTime.now(),
      accuracy: 10.0,
      altitude: 0.0,
      heading: 0.0,
      speed: speed ?? 0.0,
      speedAccuracy: 0.0,
      altitudeAccuracy: 0.0,
      headingAccuracy: 0.0,
    );

    return trip.copyWith(
      currentLatitude: latitude,
      currentLongitude: longitude,
      speed: speed,
      lastUpdateTime: DateTime.now(),
    );
  }

  /// Simulate location updates (for demo)
  void _simulateLocationUpdates() {
    // This would be replaced with actual location stream in production
    // For demo, we just update the mock position periodically
  }

  /// Calculate distance between two points (in km)
  double calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2) / 1000;
  }

  /// Check if location services are enabled
  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  /// Request location permissions
  Future<bool> requestPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    return permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always;
  }
}

