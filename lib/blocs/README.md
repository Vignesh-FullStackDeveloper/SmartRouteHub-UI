# BLoCs Module

This module contains all BLoC (Business Logic Component) classes for state management using `flutter_bloc`.

## BLoCs

- **AuthBloc**: Manages authentication state (login, logout, user session)
- **OrgBloc**: Manages organization state and branding
- **AdminDashboardBloc**: Admin dashboard statistics and data
- **DriverTripBloc**: Driver trip management and location updates
- **ParentTrackingBloc**: Parent child tracking and bus status

## Structure

Each BLoC follows the standard pattern:
- `*_event.dart`: Events that trigger state changes
- `*_state.dart`: States representing different UI conditions
- `*_bloc.dart`: BLoC implementation handling events and emitting states

## Usage

```dart
BlocProvider(
  create: (context) => AuthBloc(),
  child: BlocBuilder<AuthBloc, AuthState>(
    builder: (context, state) {
      // Build UI based on state
    },
  ),
)
```

