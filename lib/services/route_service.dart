import '../models/route.dart';
import '../models/stop.dart';

/// Mock route service
/// Manages route and stop data for an organization
class RouteService {
  // In-memory storage
  static final List<Route> _routes = [
    Route(
      id: 'route_1',
      name: 'Route A - Morning',
      organizationId: 'org_1',
      startTime: DateTime(2024, 1, 1, 7, 0),
      endTime: DateTime(2024, 1, 1, 8, 30),
      stops: [
        const Stop(
          id: 'stop_1',
          name: 'Main Street Stop',
          latitude: 28.6139,
          longitude: 77.2090,
          order: 1,
        ),
        const Stop(
          id: 'stop_2',
          name: 'Park Avenue Stop',
          latitude: 28.6149,
          longitude: 77.2100,
          order: 2,
        ),
        const Stop(
          id: 'stop_3',
          name: 'School Gate',
          latitude: 28.6159,
          longitude: 77.2110,
          order: 3,
        ),
      ],
      assignedBusId: 'bus_1',
    ),
    Route(
      id: 'route_2',
      name: 'Route B - Morning',
      organizationId: 'org_1',
      startTime: DateTime(2024, 1, 1, 7, 15),
      endTime: DateTime(2024, 1, 1, 8, 45),
      stops: [
        const Stop(
          id: 'stop_4',
          name: 'Oak Street Stop',
          latitude: 28.6169,
          longitude: 77.2120,
          order: 1,
        ),
        const Stop(
          id: 'stop_5',
          name: 'Elm Street Stop',
          latitude: 28.6179,
          longitude: 77.2130,
          order: 2,
        ),
        const Stop(
          id: 'stop_6',
          name: 'School Gate',
          latitude: 28.6159,
          longitude: 77.2110,
          order: 3,
        ),
      ],
      assignedBusId: 'bus_2',
    ),
  ];

  /// Get all routes for an organization
  Future<List<Route>> getRoutesByOrganization(String organizationId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _routes.where((r) => r.organizationId == organizationId).toList();
  }

  /// Get route by ID
  Future<Route?> getRouteById(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    try {
      return _routes.firstWhere((r) => r.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Get route details with stops
  Future<Route?> getRouteDetails(String routeId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return getRouteById(routeId);
  }

  /// Add new route
  Future<Route> addRoute(Route route) async {
    await Future.delayed(const Duration(seconds: 1));
    _routes.add(route);
    return route;
  }

  /// Update route
  Future<Route> updateRoute(Route route) async {
    await Future.delayed(const Duration(seconds: 1));
    final index = _routes.indexWhere((r) => r.id == route.id);
    if (index != -1) {
      _routes[index] = route;
    }
    return route;
  }

  /// Delete route
  Future<void> deleteRoute(String id) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _routes.removeWhere((r) => r.id == id);
  }
}

