import '../config/app_config.dart';

/// Application-wide constants
class AppConstants {
  // API Configuration
  static final String baseUrl = AppConfig.current.baseUrl;
  static final String apiBaseUrl = AppConfig.current.apiBaseUrl;
  
  // OTP (for development/testing)
  static const String dummyOtp = '123456';
  
  // Default organization code
  static const String defaultOrganizationCode = '009';
  
  // Location update interval (seconds)
  static const int locationUpdateInterval = 30;
  
  // Map settings
  static const double defaultZoom = 15.0;
  static const double defaultLatitude = 28.6139; // Default location (Delhi)
  static const double defaultLongitude = 77.2090;
  
  // Notification settings
  static const int notificationRefreshInterval = 30; // seconds
  
  // Distance thresholds (meters)
  static const double nearStudentDistance = 500.0;
  static const double nearSchoolDistance = 200.0;
}
