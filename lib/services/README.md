# Services Module

This module contains all business logic and data services. Currently, all services use mock/dummy data for demonstration purposes.

## Services

- **AuthService**: Handles authentication for all user roles (Admin, Driver, Parent)
- **OrgService**: Manages organization data and branding
- **StudentService**: CRUD operations for students
- **DriverService**: Driver management operations
- **BusService**: Bus management operations
- **RouteService**: Route and stop management
- **TripService**: Active trip tracking and management
- **LocationService**: Location tracking with geolocator (mock implementation)
- **NotificationService**: Push notifications with Firebase Messaging (placeholder)

## Implementation Notes

All services currently use in-memory storage for demo purposes. In production, these would connect to a backend API or database.

## Usage

```dart
import 'package:school_bus_tracker/services/auth_service.dart';
import 'package:school_bus_tracker/services/student_service.dart';
```

