import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/api_bus_service.dart';
import '../../services/api_route_service.dart';
import '../../models/bus.dart';
import '../../models/route.dart' as models;
import '../../core/utils/validators.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_state.dart';
import '../../core/utils/permission_checker.dart';
import '../../core/constants/permissions.dart';

/// Route management screen with modern UI
class RouteManagementScreen extends StatefulWidget {
  const RouteManagementScreen({super.key});

  @override
  State<RouteManagementScreen> createState() => _RouteManagementScreenState();
}

class _RouteManagementScreenState extends State<RouteManagementScreen> {
  final ApiBusService _busService = ApiBusService();
  final ApiRouteService _routeService = ApiRouteService();
  List<models.Route> _routes = [];
  List<Bus> _buses = [];
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
      final routes = await _routeService.getRoutes();
      final buses = await _busService.getBuses();
      
      if (!mounted) return;
      setState(() {
        _routes = routes;
        _buses = buses;
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
        title: const Text('Route Management'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
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
                          const SizedBox(height: 8),
                          BlocBuilder<AuthBloc, AuthState>(
                            builder: (context, authState) {
                              if (authState is! AuthAuthenticated) {
                                return const SizedBox.shrink();
                              }
                              final user = authState.user;
                              if (!PermissionChecker.hasPermission(user, Permissions.routeCreate)) {
                                return const SizedBox.shrink();
                              }
                              return ElevatedButton.icon(
                                onPressed: () => _showAddEditRouteDialog(),
                                icon: const Icon(Icons.add),
                                label: const Text('Add First Route'),
                              );
                            },
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
            ),
      floatingActionButton: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, authState) {
          if (authState is! AuthAuthenticated) {
            return const SizedBox.shrink();
          }
          final user = authState.user;
          if (!PermissionChecker.hasPermission(user, Permissions.routeCreate)) {
            return const SizedBox.shrink();
          }
          return FloatingActionButton.extended(
            onPressed: () => _showAddEditRouteDialog(),
            icon: const Icon(Icons.add),
            label: const Text('Add Route'),
          );
        },
      ),
    );
  }

  Widget _buildRouteCard(models.Route route, int index) {
    final startTime = route.startTime.toString().substring(11, 16);
    final endTime = route.endTime.toString().substring(11, 16);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: InkWell(
        onTap: () => _showRouteDetails(route),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Theme.of(context).colorScheme.secondaryContainer.withValues(alpha: 0.3),
                Colors.white,
              ],
            ),
          ),
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Hero(
                tag: 'route_${route.id}',
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).colorScheme.secondary,
                        Theme.of(context).colorScheme.tertiary,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.route, color: Colors.white, size: 32),
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
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildRouteInfoRow(Icons.location_on_outlined, '${route.stops.length} Pickup Points'),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.access_time_outlined, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 6),
                        Text(
                          '$startTime - $endTime',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[700],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (route.assignedBusId != null) ...[
                          const SizedBox(width: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade100,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'Bus Assigned',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Colors.blue.shade800,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
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
                      if (PermissionChecker.hasPermission(user, Permissions.routeUpdate))
                        IconButton(
                          icon: Container(
                            decoration: BoxDecoration(
                              color: Colors.blue.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.edit_rounded, color: Colors.blue, size: 20),
                            padding: const EdgeInsets.all(8),
                          ),
                          onPressed: () => _showAddEditRouteDialog(route: route),
                        ),
                      if (PermissionChecker.hasPermission(user, Permissions.routeDelete))
                        IconButton(
                          icon: Container(
                            decoration: BoxDecoration(
                              color: Colors.red.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.delete_rounded, color: Colors.red, size: 20),
                            padding: const EdgeInsets.all(8),
                          ),
                          onPressed: () => _deleteRoute(route.id),
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

  Widget _buildRouteInfoRow(IconData icon, String text) {
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

  void _showAddEditRouteDialog({models.Route? route}) {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: route?.name ?? '');
    
    // Initialize times from route or use defaults
    TimeOfDay startTime = route != null
        ? TimeOfDay.fromDateTime(route.startTime)
        : const TimeOfDay(hour: 7, minute: 0);
    TimeOfDay endTime = route != null
        ? TimeOfDay.fromDateTime(route.endTime)
        : const TimeOfDay(hour: 8, minute: 30);
    
    // Only set selectedBusId if it exists in the lists and is not empty
    String? selectedBusId;
    final routeBusId = route?.assignedBusId;
    if (routeBusId != null && 
        routeBusId is String &&
        routeBusId.trim().isNotEmpty &&
        _buses.any((bus) => bus.id.trim().isNotEmpty && bus.id == routeBusId)) {
      selectedBusId = routeBusId.trim();
    }

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
                        route == null ? 'Add Route' : 'Edit Route',
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
                            labelText: 'Route Name',
                            prefixIcon: Icon(Icons.route),
                            hintText: 'e.g., Route A - Morning',
                          ),
                          validator: (value) =>
                              Validators.validateRequired(value, 'Route Name'),
                        ),
                        const SizedBox(height: 16),
                        ListTile(
                          leading: const Icon(Icons.access_time),
                          title: const Text('Start Time'),
                          subtitle: Text(
                            '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}',
                          ),
                          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                          onTap: () async {
                            final picked = await showTimePicker(
                              context: context,
                              initialTime: startTime,
                            );
                            if (picked != null) {
                              setModalState(() {
                                startTime = picked;
                              });
                            }
                          },
                        ),
                        const SizedBox(height: 16),
                        ListTile(
                          leading: const Icon(Icons.access_time),
                          title: const Text('End Time'),
                          subtitle: Text(
                            '${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}',
                          ),
                          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                          onTap: () async {
                            final picked = await showTimePicker(
                              context: context,
                              initialTime: endTime,
                            );
                            if (picked != null) {
                              setModalState(() {
                                endTime = picked;
                              });
                            }
                          },
                        ),
                        const SizedBox(height: 16),
                        Builder(
                          builder: (context) {
                            // Build items list, filtering out empty IDs and ensuring uniqueness
                            final validBuses = _buses.where((bus) => 
                                bus.id != null && 
                                bus.id.trim().isNotEmpty
                            ).toList();
                            
                            final busIds = <String>{};
                            final busItems = <DropdownMenuItem<String?>>[
                              const DropdownMenuItem<String?>(
                                value: null,
                                child: Text('None'),
                              ),
                              ...validBuses
                                  .where((bus) {
                                    // Ensure no duplicate IDs
                                    if (busIds.contains(bus.id)) return false;
                                    busIds.add(bus.id);
                                    return true;
                                  })
                                  .map((bus) => DropdownMenuItem<String?>(
                                        value: bus.id.trim(),
                                        child: Text(bus.busNumber),
                                      )),
                            ];
                            
                            // Ensure selectedBusId matches an item in the list
                            String? validBusId;
                            final busIdValue = selectedBusId;
                            if (busIdValue != null && busIdValue.trim().isNotEmpty) {
                              final trimmedId = busIdValue.trim();
                              if (busItems.any((item) => item.value == trimmedId)) {
                                validBusId = trimmedId;
                              }
                            }
                            
                            return DropdownButtonFormField<String?>(
                              value: validBusId,
                              decoration: const InputDecoration(
                                labelText: 'Assigned Bus',
                                prefixIcon: Icon(Icons.directions_bus),
                              ),
                              items: busItems,
                              onChanged: (value) {
                                setModalState(() {
                                  // Ensure we never set empty string, only null or valid value
                                  selectedBusId = (value != null && value.trim().isEmpty) ? null : value;
                                });
                              },
                            );
                          },
                        ),
                        const SizedBox(height: 32),
                        ElevatedButton(
                          onPressed: () async {
                            if (formKey.currentState!.validate()) {
                              try {
                                // Format times as HH:MM:SS
                                final startTimeStr = '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}:00';
                                final endTimeStr = '${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}:00';
                                
                                if (route == null) {
                                  await _routeService.createRoute(
                                    name: nameController.text,
                                    startTime: startTimeStr,
                                    endTime: endTimeStr,
                                    assignedBusId: selectedBusId,
                                  );
                                } else {
                                  await _routeService.updateRoute(
                                    route.id,
                                    name: nameController.text,
                                    startTime: startTimeStr,
                                    endTime: endTimeStr,
                                    assignedBusId: selectedBusId,
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
                          child: Text(route == null ? 'Add Route' : 'Update Route'),
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

  Future<void> _deleteRoute(String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Route'),
        content: const Text('Are you sure you want to delete this route?'),
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
        await _routeService.deleteRoute(id);
        if (mounted) {
          _loadData();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting route: ${e.toString()}')),
          );
        }
      }
    }
  }
}

