import '../models/bus.dart';

/// Mock bus service
/// Manages bus data for an organization
class BusService {
  // In-memory storage
  static final List<Bus> _buses = [
    const Bus(
      id: 'bus_1',
      busNumber: 'BUS-001',
      capacity: 40,
      organizationId: 'org_1',
      driverId: 'driver_1',
      assignedRouteId: 'route_1',
      isActive: true,
    ),
    const Bus(
      id: 'bus_2',
      busNumber: 'BUS-002',
      capacity: 35,
      organizationId: 'org_1',
      driverId: 'driver_2',
      assignedRouteId: 'route_2',
      isActive: true,
    ),
    const Bus(
      id: 'bus_3',
      busNumber: 'BUS-003',
      capacity: 45,
      organizationId: 'org_1',
      isActive: false,
    ),
  ];

  /// Get all buses for an organization
  Future<List<Bus>> getBusesByOrganization(String organizationId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _buses.where((b) => b.organizationId == organizationId).toList();
  }

  /// Get bus by ID
  Future<Bus?> getBusById(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    try {
      return _buses.firstWhere((b) => b.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Add new bus
  Future<Bus> addBus(Bus bus) async {
    await Future.delayed(const Duration(seconds: 1));
    _buses.add(bus);
    return bus;
  }

  /// Update bus
  Future<Bus> updateBus(Bus bus) async {
    await Future.delayed(const Duration(seconds: 1));
    final index = _buses.indexWhere((b) => b.id == bus.id);
    if (index != -1) {
      _buses[index] = bus;
    }
    return bus;
  }

  /// Delete bus
  Future<void> deleteBus(String id) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _buses.removeWhere((b) => b.id == id);
  }
}

