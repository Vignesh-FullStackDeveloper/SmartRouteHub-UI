import 'package:flutter/material.dart';
import '../../admin/bus_route_management_screen.dart';

/// Buses tab - shows bus management
/// Navigates to full bus management screen
class BusesTab extends StatelessWidget {
  const BusesTab({super.key});

  @override
  Widget build(BuildContext context) {
    // Show the full bus route management screen
    // It has its own tabs for buses and routes
    return const BusRouteManagementScreen();
  }
}

