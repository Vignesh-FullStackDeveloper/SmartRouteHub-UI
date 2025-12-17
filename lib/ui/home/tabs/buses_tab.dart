import 'package:flutter/material.dart';
import '../../admin/bus_management_screen.dart';

/// Buses tab - shows bus management
/// Navigates to full bus management screen
class BusesTab extends StatelessWidget {
  const BusesTab({super.key});

  @override
  Widget build(BuildContext context) {
    // Show the bus management screen
    return const BusManagementScreen();
  }
}

