# UI Module

This module contains all screens and UI components organized by feature.

## Structure

- **auth/**: Authentication screens (login, create organization)
- **admin/**: Admin-specific screens (dashboard, student management, etc.)
- **driver/**: Driver-specific screens (dashboard, live trip)
- **parent/**: Parent-specific screens (dashboard, child tracking, notifications)

## Screens

### Authentication
- `LoginScreen`: Unified login with tabs for Admin, Driver, Parent
- `CreateOrganizationScreen`: Create new organization and admin account

### Admin
- `AdminDashboardScreen`: Main dashboard with statistics and quick actions
- `StudentManagementScreen`: CRUD operations for students
- `DriverManagementScreen`: Driver management
- `BusRouteManagementScreen`: Bus and route management with tabs
- `LiveMonitoringScreen`: Live map view of all active buses

### Driver
- `DriverDashboardScreen`: Driver information and trip controls
- `LiveTripScreen`: Live trip view with map, route, and stop controls

### Parent
- `ParentDashboardScreen`: List of children with bus status
- `ChildTrackingScreen`: Map view showing bus location and pickup point
- `NotificationsScreen`: List of notifications

## Navigation

Navigation is handled in `main.dart` based on authentication state and user role.

