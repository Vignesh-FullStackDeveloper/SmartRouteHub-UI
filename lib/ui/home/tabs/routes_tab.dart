import 'package:flutter/material.dart';
import '../../admin/bus_route_management_screen.dart';

/// Routes tab - shows route management
/// Navigates to full bus route management screen
class RoutesTab extends StatelessWidget {
  const RoutesTab({super.key});

  @override
  Widget build(BuildContext context) {
    // Show the full bus route management screen
    // It has its own tabs for buses and routes
    return const BusRouteManagementScreen();
  }
}

