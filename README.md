# School Bus Tracker

A comprehensive multi-tenant school bus tracking application built with Flutter, supporting Android, iOS, and Web platforms.

## Features

- **Multi-tenant Architecture**: Each organization (school) has its own branding and data isolation
- **Three User Roles**:
  - **Admin**: Manage students, drivers, buses, routes, and monitor live trips
  - **Driver**: Start/end trips, navigate routes, update location
  - **Parent**: Track children's bus location and receive notifications

## Architecture

The project follows Clean Architecture principles:

```
lib/
  core/          # Constants, theme, utilities
  models/        # Data models
  services/      # Business logic and mock services
  widgets/       # Reusable UI components
  ui/            # Screens organized by feature
  blocs/         # State management using flutter_bloc
```

## Getting Started

1. Install Flutter dependencies:
   ```bash
   flutter pub get
   ```

2. For Google Maps integration, add your API key:
   - Android: `android/app/src/main/AndroidManifest.xml`
   - iOS: `ios/Runner/AppDelegate.swift`
   - Web: `web/index.html`

3. Run the app:
   ```bash
   flutter run
   ```

## Dummy Data

All services use mock data for demonstration. No backend connection is required.

## Project Structure

See individual README files in each module folder for detailed documentation.

