import 'package:flutter/material.dart';
import '../../services/driver_service.dart';
import '../../services/bus_service.dart';
import '../../services/route_service.dart';
import '../../models/user.dart';
import '../../models/bus.dart';
import '../../models/route.dart' as models;
import '../../core/utils/validators.dart';

/// Driver management screen with modern UI
class DriverManagementScreen extends StatefulWidget {
  const DriverManagementScreen({super.key});

  @override
  State<DriverManagementScreen> createState() =>
      _DriverManagementScreenState();
}

class _DriverManagementScreenState extends State<DriverManagementScreen>
    with SingleTickerProviderStateMixin {
  final DriverService _driverService = DriverService();
  final BusService _busService = BusService();
  final RouteService _routeService = RouteService();
  List<DriverUser> _drivers = [];
  List<Bus> _buses = [];
  List<models.Route> _routes = [];
  bool _isLoading = true;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _loadData();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });
    final drivers = await _driverService.getDriversByOrganization('org_1');
    final buses = await _busService.getBusesByOrganization('org_1');
    final routes = await _routeService.getRoutesByOrganization('org_1');
    setState(() {
      _drivers = drivers;
      _buses = buses;
      _routes = routes;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Driver Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddEditDriverDialog(),
            tooltip: 'Add Driver',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: _drivers.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.person_outline,
                              size: 64, color: Colors.grey[400]),
                          const SizedBox(height: 16),
                          Text(
                            'No drivers found',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton.icon(
                            onPressed: () => _showAddEditDriverDialog(),
                            icon: const Icon(Icons.add),
                            label: const Text('Add First Driver'),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _drivers.length,
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
                          child: _buildDriverCard(_drivers[index], index),
                        );
                      },
                    ),
            ),
    );
  }

  Widget _buildDriverCard(DriverUser driver, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _showAddEditDriverDialog(driver: driver),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Hero(
                tag: 'driver_${driver.id}',
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        driver.isActive ? Colors.green : Colors.grey,
                        driver.isActive ? Colors.teal : Colors.grey[700]!,
                      ],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.person, color: Colors.white),
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
                            driver.name,
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
                            color: driver.isActive
                                ? Colors.green[100]
                                : Colors.grey[200],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            driver.isActive ? 'Active' : 'Inactive',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: driver.isActive
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
                        Icon(Icons.badge, size: 14, color: Colors.grey[500]),
                        const SizedBox(width: 4),
                        Text(
                          'ID: ${driver.driverId ?? 'N/A'}',
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
                        Icon(Icons.phone, size: 14, color: Colors.grey[500]),
                        const SizedBox(width: 4),
                        Text(
                          driver.phone ?? driver.email,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    if (driver.assignedBusId != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.directions_bus,
                              size: 14, color: Colors.grey[500]),
                          const SizedBox(width: 4),
                          Text(
                            'Bus: ${driver.assignedBusId}',
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
                onPressed: () => _showAddEditDriverDialog(driver: driver),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddEditDriverDialog({DriverUser? driver}) {
    final formKey = GlobalKey<FormState>();
    final nameController =
        TextEditingController(text: driver?.name ?? '');
    final emailController =
        TextEditingController(text: driver?.email ?? '');
    final phoneController =
        TextEditingController(text: driver?.phone ?? '');
    final driverIdController =
        TextEditingController(text: driver?.driverId ?? '');
    String? selectedBusId = driver?.assignedBusId;
    String? selectedRouteId = driver?.assignedRouteId;
    bool isActive = driver?.isActive ?? true;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          height: MediaQuery.of(context).size.height * 0.9,
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
                        driver == null ? 'Add Driver' : 'Edit Driver',
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
                          controller: nameController,
                          decoration: const InputDecoration(
                            labelText: 'Driver Name',
                            prefixIcon: Icon(Icons.person),
                          ),
                          validator: (value) =>
                              Validators.validateRequired(value, 'Name'),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: driverIdController,
                          decoration: const InputDecoration(
                            labelText: 'Driver ID',
                            prefixIcon: Icon(Icons.badge),
                            hintText: 'e.g., DRV001',
                          ),
                          validator: (value) =>
                              Validators.validateRequired(value, 'Driver ID'),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: emailController,
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            prefixIcon: Icon(Icons.email),
                            hintText: 'driver@example.com',
                          ),
                          keyboardType: TextInputType.emailAddress,
                          validator: Validators.validateEmail,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: phoneController,
                          decoration: const InputDecoration(
                            labelText: 'Phone Number',
                            prefixIcon: Icon(Icons.phone),
                            hintText: '+1234567890',
                          ),
                          keyboardType: TextInputType.phone,
                          validator: Validators.validatePhone,
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          value: selectedBusId,
                          decoration: const InputDecoration(
                            labelText: 'Assigned Bus',
                            prefixIcon: Icon(Icons.directions_bus),
                          ),
                          items: [
                            const DropdownMenuItem<String>(
                              value: null,
                              child: Text('None'),
                            ),
                            ..._buses.map((bus) => DropdownMenuItem<String>(
                                  value: bus.id,
                                  child: Text(bus.busNumber),
                                )),
                          ],
                          onChanged: (value) {
                            setModalState(() {
                              selectedBusId = value;
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
                          subtitle: const Text('Enable/disable driver'),
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
                              if (driver == null) {
                                final newDriver = DriverUser(
                                  id: 'driver_${DateTime.now().millisecondsSinceEpoch}',
                                  name: nameController.text,
                                  email: emailController.text,
                                  phone: phoneController.text,
                                  organizationId: 'org_1',
                                  driverId: driverIdController.text,
                                  assignedBusId: selectedBusId,
                                  assignedRouteId: selectedRouteId,
                                  isActive: isActive,
                                );
                                await _driverService.addDriver(newDriver);
                              } else {
                                final updatedDriver = DriverUser(
                                  id: driver.id,
                                  name: nameController.text,
                                  email: emailController.text,
                                  phone: phoneController.text,
                                  organizationId: driver.organizationId,
                                  driverId: driverIdController.text,
                                  assignedBusId: selectedBusId,
                                  assignedRouteId: selectedRouteId,
                                  isActive: isActive,
                                );
                                await _driverService.updateDriver(updatedDriver);
                              }
                              Navigator.pop(context);
                              _loadData();
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: Text(driver == null ? 'Add Driver' : 'Update Driver'),
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
}
