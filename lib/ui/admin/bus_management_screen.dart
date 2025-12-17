import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/api_bus_service.dart';
import '../../services/api_route_service.dart';
import '../../services/api_driver_service.dart';
import '../../models/bus.dart';
import '../../models/route.dart' as models;
import '../../models/user.dart';
import '../../core/utils/validators.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_state.dart';
import '../../core/utils/permission_checker.dart';
import '../../core/constants/permissions.dart';

/// Bus management screen with modern UI
class BusManagementScreen extends StatefulWidget {
  const BusManagementScreen({super.key});

  @override
  State<BusManagementScreen> createState() => _BusManagementScreenState();
}

class _BusManagementScreenState extends State<BusManagementScreen> {
  final ApiBusService _busService = ApiBusService();
  final ApiRouteService _routeService = ApiRouteService();
  final ApiDriverService _driverService = ApiDriverService();
  List<Bus> _buses = [];
  List<models.Route> _routes = [];
  List<DriverUser> _drivers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });
    try {
      final buses = await _busService.getBuses();
      final routes = await _routeService.getRoutes();
      
      // Load drivers separately to handle potential backend errors
      List<DriverUser> drivers = [];
      try {
        drivers = await _driverService.getDrivers();
      } catch (driverError) {
        // If drivers fail to load, continue with buses
        // but show a warning
        if (mounted) {
          final errorMsg = driverError.toString();
          if (errorMsg.contains('is_active') || errorMsg.contains('Undefined column')) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Warning: Could not load drivers. Backend database schema issue detected. '
                  'Please check backend: users table missing is_active column.',
                ),
                duration: Duration(seconds: 5),
                backgroundColor: Colors.orange,
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error loading drivers: ${driverError.toString()}'),
                backgroundColor: Colors.orange,
              ),
            );
          }
        }
      }
      
      if (!mounted) return;
      setState(() {
        _buses = buses;
        _routes = routes;
        _drivers = drivers;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading data: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bus Management'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
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
                          BlocBuilder<AuthBloc, AuthState>(
                            builder: (context, authState) {
                              if (authState is! AuthAuthenticated) {
                                return const SizedBox.shrink();
                              }
                              final user = authState.user;
                              if (!PermissionChecker.hasPermission(user, Permissions.busCreate)) {
                                return const SizedBox.shrink();
                              }
                              return ElevatedButton.icon(
                                onPressed: () => _showAddEditBusDialog(),
                                icon: const Icon(Icons.add),
                                label: const Text('Add First Bus'),
                              );
                            },
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
            ),
      floatingActionButton: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, authState) {
          if (authState is! AuthAuthenticated) {
            return const SizedBox.shrink();
          }
          final user = authState.user;
          if (!PermissionChecker.hasPermission(user, Permissions.busCreate)) {
            return const SizedBox.shrink();
          }
          return FloatingActionButton.extended(
            onPressed: () => _showAddEditBusDialog(),
            icon: const Icon(Icons.add),
            label: const Text('Add Bus'),
          );
        },
      ),
    );
  }

  Widget _buildBusCard(Bus bus, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: InkWell(
        onTap: () {
          final authState = context.read<AuthBloc>().state;
          if (authState is AuthAuthenticated) {
            final user = authState.user;
            if (PermissionChecker.hasPermission(user, Permissions.busUpdate)) {
              _showAddEditBusDialog(bus: bus);
            }
          }
        },
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                bus.isActive 
                  ? Colors.orange.shade50 
                  : Colors.grey.shade50,
                Colors.white,
              ],
            ),
          ),
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Hero(
                tag: 'bus_${bus.id}',
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        bus.isActive ? Colors.orange : Colors.grey,
                        bus.isActive ? Colors.deepOrange : Colors.grey[700]!,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: (bus.isActive ? Colors.orange : Colors.grey).withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.directions_bus, color: Colors.white, size: 32),
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
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: bus.isActive
                                  ? [Colors.green.shade400, Colors.green.shade600]
                                  : [Colors.grey.shade400, Colors.grey.shade600],
                            ),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: (bus.isActive ? Colors.green : Colors.grey).withValues(alpha: 0.3),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Text(
                            bus.isActive ? 'ACTIVE' : 'INACTIVE',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _buildBusInfoRow(Icons.people_outline, 'Capacity: ${bus.capacity} passengers'),
                    if (bus.driverId != null) ...[
                      const SizedBox(height: 6),
                      _buildBusInfoRow(Icons.person_outline, 'Driver assigned'),
                    ],
                    if (bus.assignedRouteId != null) ...[
                      const SizedBox(height: 6),
                      _buildBusInfoRow(Icons.route_outlined, 'Route assigned'),
                    ],
                  ],
                ),
              ),
              BlocBuilder<AuthBloc, AuthState>(
                builder: (context, authState) {
                  if (authState is! AuthAuthenticated) {
                    return const SizedBox.shrink();
                  }
                  final user = authState.user;
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (PermissionChecker.hasPermission(user, Permissions.busUpdate))
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => _showAddEditBusDialog(bus: bus),
                        ),
                      if (PermissionChecker.hasPermission(user, Permissions.busDelete))
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteBus(bus.id),
                        ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBusInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  void _showAddEditBusDialog({Bus? bus}) {
    final formKey = GlobalKey<FormState>();
    final busNumberController =
        TextEditingController(text: bus?.busNumber ?? '');
    final capacityController =
        TextEditingController(text: bus?.capacity.toString() ?? '');
    // Only set selectedDriverId/selectedRouteId if they exist in the lists and are not empty
    String? selectedDriverId;
    final busDriverId = bus?.driverId;
    if (busDriverId != null && 
        busDriverId is String &&
        busDriverId.trim().isNotEmpty &&
        _drivers.any((driver) => driver.id.trim().isNotEmpty && driver.id == busDriverId)) {
      selectedDriverId = busDriverId.trim();
    }
    
    String? selectedRouteId;
    final busRouteId = bus?.assignedRouteId;
    if (busRouteId != null && 
        busRouteId is String &&
        busRouteId.trim().isNotEmpty &&
        _routes.any((route) => route.id.trim().isNotEmpty && route.id == busRouteId)) {
      selectedRouteId = busRouteId.trim();
    }
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
                        Builder(
                          builder: (context) {
                            // Build items list, filtering out empty IDs and ensuring uniqueness
                            final validDrivers = _drivers.where((driver) => 
                                driver.id != null && 
                                driver.id.trim().isNotEmpty
                            ).toList();
                            
                            final driverIds = <String>{};
                            final driverItems = <DropdownMenuItem<String?>>[
                              const DropdownMenuItem<String?>(
                                value: null,
                                child: Text('None'),
                              ),
                              ...validDrivers
                                  .where((driver) {
                                    // Ensure no duplicate IDs
                                    if (driverIds.contains(driver.id)) return false;
                                    driverIds.add(driver.id);
                                    return true;
                                  })
                                  .map((driver) => DropdownMenuItem<String?>(
                                        value: driver.id.trim(),
                                        child: Text('${driver.name} (${driver.driverId ?? ''})'),
                                      )),
                            ];
                            
                            // Ensure selectedDriverId matches an item in the list
                            String? validDriverId;
                            final driverIdValue = selectedDriverId;
                            if (driverIdValue != null && driverIdValue.trim().isNotEmpty) {
                              final trimmedId = driverIdValue.trim();
                              if (driverItems.any((item) => item.value == trimmedId)) {
                                validDriverId = trimmedId;
                              }
                            }
                            
                            return DropdownButtonFormField<String?>(
                              value: validDriverId,
                              decoration: const InputDecoration(
                                labelText: 'Assigned Driver',
                                prefixIcon: Icon(Icons.person),
                              ),
                              items: driverItems,
                              onChanged: (value) {
                                setModalState(() {
                                  // Ensure we never set empty string, only null or valid value
                                  selectedDriverId = (value != null && value.trim().isEmpty) ? null : value;
                                });
                              },
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                        Builder(
                          builder: (context) {
                            // Build items list, filtering out empty IDs and ensuring uniqueness
                            final validRoutes = _routes.where((route) => 
                                route.id != null && 
                                route.id.trim().isNotEmpty
                            ).toList();
                            
                            final routeIds = <String>{};
                            final routeItems = <DropdownMenuItem<String?>>[
                              const DropdownMenuItem<String?>(
                                value: null,
                                child: Text('None'),
                              ),
                              ...validRoutes
                                  .where((route) {
                                    // Ensure no duplicate IDs
                                    if (routeIds.contains(route.id)) return false;
                                    routeIds.add(route.id);
                                    return true;
                                  })
                                  .map((route) => DropdownMenuItem<String?>(
                                        value: route.id.trim(),
                                        child: Text(route.name),
                                      )),
                            ];
                            
                            // Ensure selectedRouteId matches an item in the list
                            String? validRouteId;
                            final routeIdValue = selectedRouteId;
                            if (routeIdValue != null && routeIdValue.trim().isNotEmpty) {
                              final trimmedId = routeIdValue.trim();
                              if (routeItems.any((item) => item.value == trimmedId)) {
                                validRouteId = trimmedId;
                              }
                            }
                            
                            return DropdownButtonFormField<String?>(
                              value: validRouteId,
                              decoration: const InputDecoration(
                                labelText: 'Assigned Route',
                                prefixIcon: Icon(Icons.route),
                              ),
                              items: routeItems,
                              onChanged: (value) {
                                setModalState(() {
                                  // Ensure we never set empty string, only null or valid value
                                  selectedRouteId = (value != null && value.trim().isEmpty) ? null : value;
                                });
                              },
                            );
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
                              try {
                                if (bus == null) {
                                  await _busService.createBus(
                                    busNumber: busNumberController.text,
                                    capacity: int.parse(capacityController.text),
                                    driverId: selectedDriverId,
                                    assignedRouteId: selectedRouteId,
                                    isActive: isActive,
                                  );
                                } else {
                                  await _busService.updateBus(
                                    bus.id,
                                    busNumber: busNumberController.text,
                                    capacity: int.parse(capacityController.text),
                                    driverId: selectedDriverId,
                                    assignedRouteId: selectedRouteId,
                                    isActive: isActive,
                                  );
                                }
                                if (mounted) {
                                  Navigator.pop(context);
                                  _loadData();
                                }
                              } catch (e) {
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Error: ${e.toString()}')),
                                  );
                                }
                              }
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

    if (confirmed == true && mounted) {
      try {
        await _busService.deleteBus(id);
        if (mounted) {
          _loadData();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting bus: ${e.toString()}')),
          );
        }
      }
    }
  }
}

