# Models Module

This module contains all data models used throughout the application.

## Models

- **Organization**: Represents a school/institution with branding information
- **User**: Base user model with Admin, Driver, and Parent variants
- **Student**: Student information linked to parent, class, section, and route
- **Bus**: Bus information with capacity and assignments
- **Route**: Route with ordered stops and timing information
- **Stop**: Individual pickup/drop point with GPS coordinates
- **Trip**: Active trip tracking with location and status
- **NotificationModel**: Notification data structure

All models use `equatable` for value comparison and are immutable.

## Usage

```dart
import 'package:school_bus_tracker/models/organization.dart';
import 'package:school_bus_tracker/models/user.dart';
```

