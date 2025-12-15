# School Bus Tracker

A comprehensive multi-tenant school bus tracking application built with Flutter, supporting Android, iOS, and Web platforms.

## Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Architecture](#architecture)
- [Technology Stack](#technology-stack)
- [Project Structure](#project-structure)
- [Getting Started](#getting-started)
- [Configuration](#configuration)
- [API Integration](#api-integration)
- [Testing](#testing)
- [Development](#development)

## Overview

SmartRouteHub is a production-ready Flutter application for school bus tracking with support for multiple organizations (schools). The app provides role-based access for three user types: Admin, Driver, and Parent, each with specific features and interfaces.

## Features

### Multi-tenant Architecture
- Each organization (school) has its own branding and data isolation
- Organization-specific color schemes and branding
- Isolated data per organization

### User Roles

#### Admin
- Dashboard with statistics (buses, students, active trips, drivers online)
- Student Management: CRUD operations for students
- Driver Management: View and manage drivers
- Bus & Route Management: Manage buses and routes with stops
- Live Monitoring: Real-time map view of all active buses
- User, Role, and Permission Management

#### Driver
- Dashboard: Driver info, assigned bus/route, trip controls
- Live Trip Screen:
  - Google Maps with current location
  - Route polyline and stop markers
  - Trip controls (Mark Arrived, Skip Stop, End Trip)
  - Location tracking integration

#### Parent
- Dashboard: List of children with bus status
- Child Tracking: Map view showing bus location, pickup point, and school
- Notifications: Real-time notifications via SSE (Server-Sent Events)

### Authentication
- Unified Login Screen with three tabs (Admin, Driver, Parent)
- Admin Login: Email/Phone + Password
- Driver Login: Phone + OTP
- Parent Login: Phone + OTP or Email + Password
- Create Organization: Flow to create new organization and admin account
- Bearer token authentication with automatic token management

## Architecture

The project follows **Clean Architecture** principles with clear separation of concerns:

```
lib/
├── core/          # Constants, theme, utilities, API client
├── models/        # Data models (immutable, using Equatable)
├── services/      # Business logic and API services
├── widgets/       # Reusable UI components
├── ui/            # Screens organized by feature
└── blocs/         # State management (flutter_bloc)
```

### Key Concepts

#### BLoC Pattern (State Management)
- **Events**: User actions (login, logout, etc.)
- **BLoC**: Processes events and emits states
- **States**: UI conditions (Loading, Success, Error)

#### Services Layer
- API services for backend communication
- Mock services available for development
- Automatic token management
- Comprehensive error handling

#### Models
- Immutable data structures using Equatable
- Type-safe data models
- JSON serialization support

## Technology Stack

- **Flutter**: 3.0.0+
- **State Management**: flutter_bloc ^8.1.3
- **Maps**: google_maps_flutter ^2.5.0
- **Location**: geolocator ^11.0.0
- **Networking**: http ^1.1.0, dio ^5.4.0
- **Firebase**: firebase_core ^3.6.0, firebase_messaging ^15.1.3
- **Local Storage**: shared_preferences ^2.2.2
- **Background Tasks**: background_fetch ^1.1.2
- **UI**: cupertino_icons, flutter_svg ^2.2.3

## Project Structure

### Core (`lib/core/`)
- **api/**: HTTP client with error handling and token management
- **config/**: Environment configuration (local/production)
- **constants/**: Application-wide constants
- **theme/**: Material 3 theme configuration
- **utils/**: Utility functions (validators, helpers)

### Models (`lib/models/`)
- `Organization`: School/institution with branding
- `User`: Base user with Admin, Driver, Parent variants
- `Student`: Student information
- `Bus`: Bus details
- `Route`: Route with ordered stops
- `Stop`: Pickup/drop point
- `Trip`: Active trip tracking
- `NotificationModel`: Notification data
- `Role`, `Permission`: Access control models

### Services (`lib/services/`)
- **API Services** (Production):
  - `ApiAuthService`: Authentication
  - `ApiOrgService`: Organization management
  - `ApiStudentService`: Student CRUD
  - `ApiBusService`: Bus management
  - `ApiRouteService`: Route & stop management
  - `ApiDriverService`: Driver management
  - `ApiTripService`: Trip tracking
  - `ApiNotificationService`: Real-time notifications (SSE)
  - `ApiUserService`: Profile management
  - `ApiMapsService`: Maps & location operations
  - `ApiAssignmentService`: Student assignments
  - `ApiSubscriptionService`: Subscription management
  - `ApiAnalyticsService`: Analytics and reporting
  - `ApiRoleService`, `ApiPermissionService`: Access control

- **Mock Services** (Development):
  - `StudentService`, `BusService`, `RouteService`, etc.
  - In-memory storage for demo purposes

### BLoCs (`lib/blocs/`)
- `AuthBloc`: Authentication state
- `OrgBloc`: Organization state
- `AdminDashboardBloc`: Admin dashboard data
- `DriverTripBloc`: Driver trip management
- `ParentTrackingBloc`: Parent tracking data

### UI (`lib/ui/`)
- **auth/**: Login, create organization
- **admin/**: Admin-specific screens
- **driver/**: Driver-specific screens
- **parent/**: Parent-specific screens
- **home/**: Unified home screen with permission-based tabs
- **profile/**: User profile management

### Widgets (`lib/widgets/`)
- `OrgHeader`: Organization branding header
- `PrimaryButton`: Primary action button
- `SecondaryButton`: Secondary action button
- `StatCard`: Statistics display card
- `InfoCard`: Information display card
- `PermissionWrapper`: Permission-based UI wrapper

## Getting Started

### Prerequisites

- Flutter SDK (3.0.0 or higher)
- Dart SDK (3.0.0 or higher)
- Android Studio / Xcode (for mobile development)
- Google Maps API Key (optional for development)

### Installation

1. **Clone the repository:**
   ```bash
   git clone <repository-url>
   cd SmartRouteHub
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Configure Google Maps (Optional):**
   - See [Google Maps Setup](#google-maps-setup) section below

4. **Run the app:**
   ```bash
   flutter run
   ```

## Configuration

### Environment Configuration

The app supports multiple environments configured in `lib/core/config/app_config.dart`:

- **Local Development**: `http://localhost:4000` (default)
- **Production**: Configurable via build flavor

To use production environment:
```bash
flutter run --dart-define=ENV=production
```

### Google Maps Setup

1. **Get Your API Key:**
   - Go to [Google Cloud Console](https://console.cloud.google.com/)
   - Create a new project or select existing
   - Enable "Maps JavaScript API"
   - Create credentials (API Key)

2. **Configure API Key:**

   **For Web:**
   - Open `web/index.html`
   - Replace `YOUR_GOOGLE_MAPS_API_KEY` with your actual API key

   **For Android:**
   - Open `android/app/src/main/AndroidManifest.xml`
   - Update the `meta-data` tag with your API key

   **For iOS:**
   - Open `ios/Runner/AppDelegate.swift`
   - Add your API key in the configuration

3. **Restart the app** after adding your API key

**Note:** Google Maps API has a free tier with $200 credit per month. For development, the app will run without a key but maps won't display.

### Firebase Setup (Optional)

For push notifications:
1. Add `google-services.json` (Android) and `GoogleService-Info.plist` (iOS)
2. Configure Firebase in your project
3. The app will work without Firebase, but notifications will be mock-only

## API Integration

### Backend Connection

The app is fully integrated with a Fastify backend API. All services use real API calls by default.

### API Services

All API services are located in `lib/services/api_*.dart`:

- **Authentication**: Login, logout, token management
- **Organizations**: CRUD operations
- **Students**: Full CRUD with filtering
- **Buses**: Management and driver assignment
- **Routes**: CRUD with stops and student assignment
- **Trips**: Start/end trips, location updates
- **Notifications**: Real-time SSE stream
- **Users**: Profile management
- **Maps**: Route calculation, geocoding, location pinning

### Bearer Token Authentication

- Tokens are automatically saved on login
- Included in all authenticated requests
- Cleared on logout
- Stored in SharedPreferences

### Real-Time Notifications

The app supports Server-Sent Events (SSE) for real-time notifications:

```dart
final notificationService = ApiNotificationService();
final stream = notificationService.startListening();
stream.listen((notification) {
  // Handle new notification
});
```

### Map Location Pinning

Save location pins directly to the database:

```dart
final mapsService = ApiMapsService();
await mapsService.saveLocationPin(
  routeId: routeId,
  name: 'Stop Name',
  latitude: lat,
  longitude: lng,
  order: stopOrder,
);
```

### Error Handling

All API calls include comprehensive error handling:
- Network errors
- Authentication errors (401)
- Server errors (500+)
- Custom API exceptions

## Testing

### Admin Login
- Organization Code: `GHS001` or `SES002` (or any valid code)
- Email/Phone: any value
- Password: any value (6+ characters)
- Click "Login as Admin"

### Driver Login
- Organization Code: Select or enter organization code
- Phone: any phone number
- OTP: `123456` (dummy OTP for development)
- Click "Login as Driver"

### Parent Login
- Organization Code: Select or enter organization code
- Choose Phone + OTP or Email + Password
- For OTP: Use `123456`
- For Password: any value (6+ characters)
- Click "Login as Parent"

### Superadmin Login (Production)
- Email: `superadmin@smartroutehub.com`
- Password: `SuperAdmin@123`
- No organization code needed

## Development

### Code Structure

The app follows these principles:
- **Clean Architecture**: Separation of concerns
- **BLoC Pattern**: State management
- **Type Safety**: Strong typing throughout
- **Error Handling**: Comprehensive error management
- **Code Reusability**: Shared widgets and utilities

### Running Backend

For local development with backend:

```bash
cd SmartRouteHub-Backend
npm install
npm run migrate
npm run seed
npm run dev  # Runs on http://localhost:4000
```

### Code Quality

The project uses:
- `flutter_lints` for code analysis
- Consistent code formatting
- Type-safe models with Equatable
- Comprehensive error handling

### Mock vs API Services

The app supports both mock and API services:
- **API Services**: Used by default (production-ready)
- **Mock Services**: Available for development/testing

To switch to mock services, update the service instantiation in BLoCs and UI screens.

## API Endpoints

### Authentication
- `POST /api/auth/login` - Login
- `GET /api/auth/verify` - Verify token
- `POST /api/auth/logout` - Logout

### Organizations
- `POST /api/organizations` - Create (public)
- `GET /api/organizations/:id` - Get by ID
- `PUT /api/organizations/:id` - Update

### Students
- `POST /api/students` - Create
- `GET /api/students` - Get all (with filters)
- `GET /api/students/:id` - Get by ID
- `PUT /api/students/:id` - Update
- `DELETE /api/students/:id` - Delete
- `GET /api/students/:id/pickup-location` - Get pickup location

### Buses
- `POST /api/buses` - Create
- `GET /api/buses` - Get all (with filters)
- `GET /api/buses/:id` - Get by ID
- `PUT /api/buses/:id` - Update
- `DELETE /api/buses/:id` - Delete
- `POST /api/buses/:id/assign-driver` - Assign driver

### Routes
- `POST /api/routes` - Create (with stops)
- `GET /api/routes` - Get all (with filters)
- `GET /api/routes/:id` - Get by ID (includes stops)
- `PUT /api/routes/:id` - Update
- `DELETE /api/routes/:id` - Delete
- `POST /api/routes/:id/assign-students` - Assign students

### Trips
- `POST /api/trips/start` - Start trip
- `POST /api/trips/:id/location` - Update location
- `POST /api/trips/:id/end` - End trip
- `GET /api/trips/active` - Get active trips
- `GET /api/trips/:id` - Get trip by ID

### Notifications
- `GET /api/notifications` - Get notifications (with filters)
- `GET /api/notifications/unread-count` - Get unread count
- `PATCH /api/notifications/:id/read` - Mark as read
- `PATCH /api/notifications/read-all` - Mark all as read
- `GET /api/notifications/stream` - SSE stream

### Users
- `POST /api/users` - Create user
- `GET /api/users` - Get all (with filters)
- `GET /api/users/:id` - Get by ID
- `PUT /api/users/:id` - Update

### Maps
- `POST /api/maps/route/calculate` - Calculate route
- `POST /api/maps/geocode` - Geocode address
- `POST /api/maps/reverse-geocode` - Reverse geocode

### Analytics
- `GET /api/analytics/students/:id/travel-history` - Student history
- `GET /api/analytics/buses/:id/travel-history` - Bus history
- `GET /api/analytics/drivers/:id/travel-history` - Driver history
- `GET /api/analytics/dashboard` - Dashboard insights

### Assignments
- `POST /api/assignments/students-to-route` - Assign students to route
- `POST /api/assignments/students-to-bus` - Assign students to bus
- `GET /api/assignments/route/:id/students` - Get route assignments
- `GET /api/assignments/bus/:id/students` - Get bus assignments

### Subscriptions
- `POST /api/subscriptions` - Create subscription
- `GET /api/subscriptions/student/:id` - Get student subscriptions
- `GET /api/subscriptions/student/:id/active` - Get active subscription
- `PUT /api/subscriptions/:id` - Update subscription
- `GET /api/subscriptions/expiring` - Get expiring subscriptions

**Note:** All endpoints (except login and create organization) require Bearer token authentication.

## Future Enhancements

- [ ] Unit and integration tests
- [ ] Internationalization (i18n)
- [ ] Offline mode with local database
- [ ] Enhanced error recovery
- [ ] Performance optimizations
- [ ] Additional analytics and reporting
- [ ] Push notification enhancements
- [ ] Background location tracking improvements

## License

[Add your license information here]

## Support

For issues and questions, please open an issue on the repository.
