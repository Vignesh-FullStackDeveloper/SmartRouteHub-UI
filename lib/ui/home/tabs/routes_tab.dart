import 'package:flutter/material.dart';
import '../../admin/route_management_screen.dart';

/// Routes tab - shows route management
/// Navigates to full route management screen
class RoutesTab extends StatelessWidget {
  const RoutesTab({super.key});

  @override
  Widget build(BuildContext context) {
    // Show the route management screen
    return const RouteManagementScreen();
  }
}

