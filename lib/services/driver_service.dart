import '../models/user.dart';
import '../models/bus.dart';

/// Mock driver service
/// Manages driver data for an organization
class DriverService {
  // In-memory storage
  static final List<DriverUser> _drivers = [
    const DriverUser(
      id: 'driver_1',
      name: 'Mike Wilson',
      email: 'mike.wilson@example.com',
      phone: '+1234567890',
      organizationId: 'org_1',
      driverId: 'DRV001',
      assignedBusId: 'bus_1',
      assignedRouteId: 'route_1',
      isActive: true,
    ),
    const DriverUser(
      id: 'driver_2',
      name: 'Sarah Brown',
      email: 'sarah.brown@example.com',
      phone: '+1234567891',
      organizationId: 'org_1',
      driverId: 'DRV002',
      assignedBusId: 'bus_2',
      assignedRouteId: 'route_2',
      isActive: true,
    ),
  ];

  /// Get all drivers for an organization
  Future<List<DriverUser>> getDriversByOrganization(
      String organizationId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _drivers
        .where((d) => d.organizationId == organizationId)
        .toList();
  }

  /// Get driver by ID
  Future<DriverUser?> getDriverById(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    try {
      return _drivers.firstWhere((d) => d.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Add new driver
  Future<DriverUser> addDriver(DriverUser driver) async {
    await Future.delayed(const Duration(seconds: 1));
    _drivers.add(driver);
    return driver;
  }

  /// Update driver
  Future<DriverUser> updateDriver(DriverUser driver) async {
    await Future.delayed(const Duration(seconds: 1));
    final index = _drivers.indexWhere((d) => d.id == driver.id);
    if (index != -1) {
      _drivers[index] = driver;
    }
    return driver;
  }

  /// Get driver's assigned bus
  Future<Bus?> getDriverBus(String driverId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final driver = await getDriverById(driverId);
    if (driver?.assignedBusId != null) {
      // This would typically fetch from BusService
      return const Bus(
        id: 'bus_1',
        busNumber: 'BUS-001',
        capacity: 40,
        organizationId: 'org_1',
        driverId: 'driver_1',
        assignedRouteId: 'route_1',
      );
    }
    return null;
  }
}

