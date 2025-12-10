# API Integration Guide

## Overview

All Flutter services have been updated to use real backend APIs instead of dummy data. The app now supports:

- ✅ **Local Development**: `http://localhost:3000`
- ✅ **Production**: Configurable via environment
- ✅ **Real-time Notifications**: SSE (Server-Sent Events)
- ✅ **Profile Management**: View and edit user profile
- ✅ **Map Location Pinning**: Save locations to database
- ✅ **Enterprise-grade Error Handling**: Comprehensive error management

## Environment Configuration

### Local Development

The app automatically uses local configuration:
- Base URL: `http://localhost:3000`
- API Version: `api`
- Logging: Enabled

### Production

To use production environment, set build flavor:
```bash
flutter run --dart-define=ENV=production
```

Or update `lib/core/config/app_config.dart`:
```dart
static AppConfig get current => production; // Force production
```

## API Services

All services now use real API calls:

### 1. Authentication (`ApiAuthService`)
- ✅ Login with email/password
- ✅ Create organization and admin
- ✅ Token management (auto-saved)
- ✅ Logout

### 2. Organization (`ApiOrgService`)
- ✅ Get organization by ID/code
- ✅ Create/update organization

### 3. Students (`ApiStudentService`)
- ✅ CRUD operations
- ✅ Get pickup location
- ✅ Filter by bus/route/class

### 4. Buses (`ApiBusService`)
- ✅ CRUD operations
- ✅ Assign driver
- ✅ Filter by status

### 5. Routes (`ApiRouteService`)
- ✅ CRUD with stops
- ✅ Assign students
- ✅ Save location pins

### 6. Trips (`ApiTripService`)
- ✅ Start/end trips
- ✅ Update location
- ✅ Get active trips

### 7. Notifications (`ApiNotificationService`)
- ✅ Get notifications
- ✅ Real-time SSE stream
- ✅ Mark as read
- ✅ Unread count

### 8. Maps (`ApiMapsService`)
- ✅ Calculate route
- ✅ Geocode/reverse geocode
- ✅ Save location pins to database

### 9. Users (`ApiUserService`)
- ✅ Get user profile
- ✅ Update profile

## Profile Screen

New profile screen at `lib/ui/profile/profile_screen.dart`:

**Features:**
- View user profile
- Edit name, email, phone
- View organization info
- Logout functionality

**Usage:**
```dart
Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => const ProfileScreen()),
);
```

## Map Location Pinning

### Save Location Pin to Database

When user taps on map to add a stop:

```dart
final mapsService = ApiMapsService();

await mapsService.saveLocationPin(
  routeId: routeId,
  name: 'Stop Name',
  latitude: lat,
  longitude: lng,
  order: stopOrder,
  address: {
    'formatted': 'Full Address',
    'components': {...}
  },
);
```

This automatically:
1. Gets current route
2. Adds new stop
3. Updates route in database
4. Returns updated route with all stops

## Real-Time Notifications

### Setup

```dart
final notificationService = ApiNotificationService();

// Start listening
final stream = notificationService.startListening();
stream.listen((notification) {
  // Handle new notification
  print('New notification: ${notification.title}');
});

// Get notifications
final notifications = await notificationService.getNotifications();

// Get unread count
final count = await notificationService.getUnreadCount();

// Mark as read
await notificationService.markAsRead(notificationId);
```

### Notification Types

- `bus_started` - Bus has started trip
- `bus_near_student` - Bus within 500m of student
- `bus_arrived_school` - Bus arrived at school

## Error Handling

All API calls include enterprise-grade error handling:

```dart
try {
  final result = await apiService.getData();
} on ApiException catch (e) {
  // Handle API errors
  print('API Error: ${e.message} (${e.statusCode})');
} catch (e) {
  // Handle other errors
  print('Error: $e');
}
```

## Token Management

Tokens are automatically:
- ✅ Saved on login
- ✅ Included in all authenticated requests
- ✅ Cleared on logout
- ✅ Stored in SharedPreferences

## Updating Existing Services

To use API services instead of mock:

### Before (Mock):
```dart
final service = StudentService();
final students = await service.getStudents();
```

### After (API):
```dart
final service = ApiStudentService();
final students = await service.getStudents();
```

## Migration Checklist

- [x] API client with environment config
- [x] All services converted to API
- [x] Profile screen added
- [x] Map location pinning
- [x] Real-time notifications
- [x] Error handling
- [x] Token management
- [ ] Update BLoCs to use API services
- [ ] Update UI screens to use API services
- [ ] Add loading states
- [ ] Add error dialogs

## Next Steps

1. **Update BLoCs**: Replace mock services with API services
2. **Update UI**: Add loading/error states
3. **Test**: Test all flows with real backend
4. **Deploy**: Configure production URLs

## Testing

### Local Backend

1. Start backend: `cd SmartRouteHub-Backend && npm run dev`
2. Run Flutter: `flutter run`
3. App connects to `http://localhost:3000`

### Production

1. Update `AppConfig.production` with production URL
2. Build with production flavor
3. Deploy

## Troubleshooting

### Connection Errors

- Check backend is running
- Verify base URL in `app_config.dart`
- Check network connectivity

### Authentication Errors

- Verify token is saved
- Check token expiration
- Re-login if needed

### Notification Stream Errors

- Check Redis is running
- Verify SSE endpoint
- Check network connectivity

