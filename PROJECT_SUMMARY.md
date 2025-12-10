# School Bus Tracker - Project Summary

## Overview

A comprehensive multi-tenant Flutter application for school bus tracking with support for Android, iOS, and Web platforms. The app supports three user roles: Admin, Driver, and Parent, each with role-specific features and interfaces.

## Architecture

The project follows **Clean Architecture** principles with clear separation of concerns:

```
lib/
├── core/          # Constants, theme, utilities
├── models/        # Data models (immutable, using Equatable)
├── services/      # Business logic (all mock/dummy data)
├── widgets/       # Reusable UI components
├── ui/            # Screens organized by feature
└── blocs/         # State management (flutter_bloc)
```

## Key Features

### Authentication
- **Unified Login Screen** with three tabs (Admin, Driver, Parent)
- **Admin Login**: Email/Phone + Password
- **Driver Login**: Phone + OTP (dummy OTP: 123456)
- **Parent Login**: Phone + OTP or Email + Password
- **Create Organization**: Flow to create new organization and admin account

### Admin Features
- **Dashboard**: Statistics (buses, students, active trips, drivers online)
- **Student Management**: CRUD operations for students
- **Driver Management**: View and manage drivers
- **Bus & Route Management**: Manage buses and routes with stops
- **Live Monitoring**: Real-time map view of all active buses

### Driver Features
- **Dashboard**: Driver info, assigned bus/route, trip controls
- **Live Trip Screen**: 
  - Google Maps with current location
  - Route polyline and stop markers
  - Bottom sheet with trip controls (Mark Arrived, Skip Stop, End Trip)
  - Location tracking integration (mock)

### Parent Features
- **Dashboard**: List of children with bus status
- **Child Tracking**: Map view showing bus location, pickup point, and school
- **Notifications**: List of notifications (Firebase Messaging placeholder)

## Technology Stack

- **Flutter**: 3.0.0+
- **State Management**: flutter_bloc
- **Maps**: google_maps_flutter
- **Location**: geolocator
- **Notifications**: firebase_messaging (placeholder)
- **Local Storage**: shared_preferences
- **Background Tasks**: background_fetch

## Mock Data

All services use in-memory mock data:
- **Dummy OTP**: 123456 (for all OTP logins)
- **Pre-loaded Organizations**: 
  - Greenwood High School (GHS001)
  - Sunshine Elementary (SES002)
- **Sample Data**: Students, drivers, buses, routes are pre-populated

## Project Structure Details

### Models
- `Organization`: School/institution with branding
- `User`: Base user with Admin, Driver, Parent variants
- `Student`: Student information
- `Bus`: Bus details
- `Route`: Route with ordered stops
- `Stop`: Pickup/drop point
- `Trip`: Active trip tracking
- `NotificationModel`: Notification data

### Services (All Mock)
- `AuthService`: Authentication
- `OrgService`: Organization management
- `StudentService`: Student CRUD
- `DriverService`: Driver management
- `BusService`: Bus management
- `RouteService`: Route management
- `TripService`: Trip tracking
- `LocationService`: Location tracking (mock)
- `NotificationService`: Push notifications (placeholder)

### BLoCs
- `AuthBloc`: Authentication state
- `OrgBloc`: Organization state
- `AdminDashboardBloc`: Admin dashboard data
- `DriverTripBloc`: Driver trip management
- `ParentTrackingBloc`: Parent tracking data

### Widgets
- `OrgHeader`: Organization branding header
- `PrimaryButton`: Primary action button
- `SecondaryButton`: Secondary action button
- `StatCard`: Statistics display card
- `InfoCard`: Information display card

## Setup Instructions

1. Install dependencies: `flutter pub get`
2. Configure Google Maps API key in:
   - `android/app/src/main/AndroidManifest.xml`
   - `web/index.html`
   - iOS configuration (if needed)
3. Run: `flutter run`

See `SETUP.md` for detailed instructions.

## Testing

### Admin Login
- Organization Code: `GHS001` or `SES002`
- Email/Phone: any value
- Password: any value (6+ characters)

### Driver Login
- Organization Code: `GHS001` or `SES002`
- Phone: any phone number
- OTP: `123456`

### Parent Login
- Organization Code: `GHS001` or `SES002`
- Phone + OTP: Use `123456`
- OR Email + Password: any values

## Notes

- All data is in-memory (lost on app restart)
- No backend connection required
- Google Maps shows default location if API key not configured
- Firebase notifications are placeholder implementations
- Location tracking uses mock data

## Future Enhancements

- Connect to real backend API
- Implement actual location tracking
- Add real Firebase push notifications
- Add data persistence (local database)
- Add more comprehensive error handling
- Add unit and integration tests
- Add internationalization (i18n)

## Documentation

See individual README files in each module folder for detailed documentation.

