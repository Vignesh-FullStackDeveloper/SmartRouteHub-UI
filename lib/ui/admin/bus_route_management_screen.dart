import 'package:flutter/material.dart';
import '../../services/bus_service.dart';
import '../../services/route_service.dart';
import '../../services/driver_service.dart';
import '../../models/bus.dart';
import '../../models/route.dart' as models;
import '../../models/user.dart';
import '../../core/utils/validators.dart';

/// Bus and Route management screen with modern UI
class BusRouteManagementScreen extends StatefulWidget {
  const BusRouteManagementScreen({super.key});

  @override
  State<BusRouteManagementScreen> createState() =>
      _BusRouteManagementScreenState();
}

class _BusRouteManagementScreenState extends State<BusRouteManagementScreen>
    with SingleTickerProviderStateMixin {
  final BusService _busService = BusService();
  final RouteService _routeService = RouteService();
  final DriverService _driverService = DriverService();
  late TabController _tabController;
  List<Bus> _buses = [];
  List<models.Route> _routes = [];
  List<DriverUser> _drivers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {}); // Rebuild when tab changes to show/hide FAB
    });
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });
    final buses = await _busService.getBusesByOrganization('org_1');
    final routes = await _routeService.getRoutesByOrganization('org_1');
    final drivers = await _driverService.getDriversByOrganization('org_1');
    setState(() {
      _buses = buses;
      _routes = routes;
      _drivers = drivers;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bus & Route Management'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.directions_bus), text: 'Buses'),
            Tab(icon: Icon(Icons.route), text: 'Routes'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildBusesTab(),
                _buildRoutesTab(),
              ],
            ),
      floatingActionButton: _tabController.index == 0
          ? FloatingActionButton.extended(
              onPressed: () => _showAddEditBusDialog(),
              icon: const Icon(Icons.add),
              label: const Text('Add Bus'),
            )
          : null,
    );
  }

  Widget _buildBusesTab() {
    return RefreshIndicator(
      onRefresh: _loadData,
      child: _buses.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.directions_bus_outlined,
                      size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No buses found',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: () => _showAddEditBusDialog(),
                    icon: const Icon(Icons.add),
                    label: const Text('Add First Bus'),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _buses.length,
              itemBuilder: (context, index) {
                return TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: Duration(milliseconds: 300 + (index * 50)),
                  curve: Curves.easeOut,
                  builder: (context, value, child) {
                    return Opacity(
                      opacity: value,
                      child: Transform.translate(
                        offset: Offset(0, 20 * (1 - value)),
                        child: child,
                      ),
                    );
                  },
                  child: _buildBusCard(_buses[index], index),
                );
              },
            ),
    );
  }

  Widget _buildBusCard(Bus bus, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _showAddEditBusDialog(bus: bus),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Hero(
                tag: 'bus_${bus.id}',
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        bus.isActive ? Colors.orange : Colors.grey,
                        bus.isActive ? Colors.deepOrange : Colors.grey[700]!,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.directions_bus, color: Colors.white),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            bus.busNumber,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: bus.isActive
                                ? Colors.green[100]
                                : Colors.grey[200],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            bus.isActive ? 'Active' : 'Inactive',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: bus.isActive
                                  ? Colors.green[800]
                                  : Colors.grey[700],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.people, size: 14, color: Colors.grey[500]),
                        const SizedBox(width: 4),
                        Text(
                          'Capacity: ${bus.capacity}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    if (bus.driverId != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.person, size: 14, color: Colors.grey[500]),
                          const SizedBox(width: 4),
                          Text(
                            'Driver: ${bus.driverId}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                    if (bus.assignedRouteId != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.route, size: 14, color: Colors.grey[500]),
                          const SizedBox(width: 4),
                          Text(
                            'Route: ${bus.assignedRouteId}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.blue),
                onPressed: () => _showAddEditBusDialog(bus: bus),
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => _deleteBus(bus.id),
              ),
            ],
          ),
        ),
            ),
    );
  }

  Widget _buildRoutesTab() {
    return RefreshIndicator(
      onRefresh: _loadData,
      child: _routes.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.route_outlined, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No routes found',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _routes.length,
              itemBuilder: (context, index) {
                return TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: Duration(milliseconds: 300 + (index * 50)),
                  curve: Curves.easeOut,
                  builder: (context, value, child) {
                    return Opacity(
                      opacity: value,
                      child: Transform.translate(
                        offset: Offset(0, 20 * (1 - value)),
                        child: child,
                      ),
                    );
                  },
                  child: _buildRouteCard(_routes[index], index),
                );
              },
            ),
    );
  }

  Widget _buildRouteCard(models.Route route, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _showRouteDetails(route),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Hero(
                tag: 'route_${route.id}',
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).colorScheme.secondary,
                        Theme.of(context).colorScheme.tertiary,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.route, color: Colors.white),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
                    Text(
                      route.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.location_on, size: 14, color: Colors.grey[500]),
                        const SizedBox(width: 4),
                        Text(
                          '${route.stops.length} Stops',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.access_time, size: 14, color: Colors.grey[500]),
                        const SizedBox(width: 4),
                        Text(
                          '${route.startTime.toString().substring(11, 16)} - ${route.endTime.toString().substring(11, 16)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.info, color: Colors.blue),
                onPressed: () => _showRouteDetails(route),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddEditBusDialog({Bus? bus}) {
    final formKey = GlobalKey<FormState>();
    final busNumberController =
        TextEditingController(text: bus?.busNumber ?? '');
    final capacityController =
        TextEditingController(text: bus?.capacity.toString() ?? '');
    String? selectedDriverId = bus?.driverId;
    String? selectedRouteId = bus?.assignedRouteId;
    bool isActive = bus?.isActive ?? true;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          height: MediaQuery.of(context).size.height * 0.8,
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        bus == null ? 'Add Bus' : 'Edit Bus',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Form(
                    key: formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextFormField(
                          controller: busNumberController,
                          decoration: const InputDecoration(
                            labelText: 'Bus Number',
                            prefixIcon: Icon(Icons.confirmation_number),
                            hintText: 'e.g., BUS-001',
                          ),
                          validator: (value) =>
                              Validators.validateRequired(value, 'Bus Number'),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: capacityController,
                          decoration: const InputDecoration(
                            labelText: 'Capacity',
                            prefixIcon: Icon(Icons.people),
                            hintText: 'e.g., 40',
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Capacity is required';
                            }
                            final capacity = int.tryParse(value);
                            if (capacity == null || capacity <= 0) {
                              return 'Please enter a valid capacity';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          value: selectedDriverId,
                          decoration: const InputDecoration(
                            labelText: 'Assigned Driver',
                            prefixIcon: Icon(Icons.person),
                          ),
                          items: [
                            const DropdownMenuItem<String>(
                              value: null,
                              child: Text('None'),
                            ),
                            ..._drivers.map((driver) => DropdownMenuItem<String>(
                                  value: driver.id,
                                  child: Text('${driver.name} (${driver.driverId})'),
                                )),
                          ],
                          onChanged: (value) {
                            setModalState(() {
                              selectedDriverId = value;
                            });
                          },
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          value: selectedRouteId,
                          decoration: const InputDecoration(
                            labelText: 'Assigned Route',
                            prefixIcon: Icon(Icons.route),
                          ),
                          items: [
                            const DropdownMenuItem<String>(
                              value: null,
                              child: Text('None'),
                            ),
                            ..._routes.map((route) => DropdownMenuItem<String>(
                                  value: route.id,
                                  child: Text(route.name),
                                )),
                          ],
                          onChanged: (value) {
                            setModalState(() {
                              selectedRouteId = value;
                            });
                          },
                        ),
                        const SizedBox(height: 16),
                        SwitchListTile(
                          title: const Text('Active Status'),
                          subtitle: const Text('Enable/disable bus'),
                          value: isActive,
                          onChanged: (value) {
                            setModalState(() {
                              isActive = value;
                            });
                          },
                        ),
                        const SizedBox(height: 32),
                        ElevatedButton(
                          onPressed: () async {
                            if (formKey.currentState!.validate()) {
                              if (bus == null) {
                                final newBus = Bus(
                                  id: 'bus_${DateTime.now().millisecondsSinceEpoch}',
                                  busNumber: busNumberController.text,
                                  capacity: int.parse(capacityController.text),
                                  organizationId: 'org_1',
                                  driverId: selectedDriverId,
                                  assignedRouteId: selectedRouteId,
                                  isActive: isActive,
                                );
                                await _busService.addBus(newBus);
                              } else {
                                final updatedBus = bus.copyWith(
                                  busNumber: busNumberController.text,
                                  capacity: int.parse(capacityController.text),
                                  driverId: selectedDriverId,
                                  assignedRouteId: selectedRouteId,
                                  isActive: isActive,
                                );
                                await _busService.updateBus(updatedBus);
                              }
                              Navigator.pop(context);
                              _loadData();
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: Text(bus == null ? 'Add Bus' : 'Update Bus'),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showRouteDetails(models.Route route) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
          child: Column(
            children: [
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      route.name,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoRow(Icons.access_time, 'Start Time',
                        route.startTime.toString().substring(11, 16)),
                    const SizedBox(height: 12),
                    _buildInfoRow(Icons.access_time, 'End Time',
                        route.endTime.toString().substring(11, 16)),
                    const SizedBox(height: 12),
                    _buildInfoRow(Icons.location_on, 'Number of Stops',
                        route.stops.length.toString()),
                    const SizedBox(height: 24),
                    const Text(
                      'Stops:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...route.stops.map((stop) => Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: CircleAvatar(
                              child: Text('${stop.order}'),
                            ),
                            title: Text(stop.name),
                            subtitle: Text(
                              '${stop.latitude.toStringAsFixed(4)}, ${stop.longitude.toStringAsFixed(4)}',
                            ),
                    ),
                  )),
            ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 12),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Future<void> _deleteBus(String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Bus'),
        content: const Text('Are you sure you want to delete this bus?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _busService.deleteBus(id);
      _loadData();
    }
  }
}
