/// Application configuration for different environments
class AppConfig {
  final String baseUrl;
  final String apiVersion;
  final bool isProduction;
  final bool enableLogging;

  const AppConfig({
    required this.baseUrl,
    required this.apiVersion,
    required this.isProduction,
    required this.enableLogging,
  });

  // Local development configuration
  static const AppConfig local = AppConfig(
    baseUrl: 'http://localhost:3000',
    apiVersion: 'api',
    isProduction: false,
    enableLogging: true,
  );

  // Production configuration
  static const AppConfig production = AppConfig(
    baseUrl: 'https://api.smartroutehub.com',
    apiVersion: 'api',
    isProduction: true,
    enableLogging: false,
  );

  // Get current environment (can be set via build flavor or environment variable)
  static AppConfig get current {
    // Check environment variable or build flavor
    const String env = String.fromEnvironment('ENV', defaultValue: 'local');
    
    switch (env.toLowerCase()) {
      case 'production':
      case 'prod':
        return production;
      case 'local':
      case 'dev':
      default:
        return local;
    }
  }

  String get apiBaseUrl => '$baseUrl/$apiVersion';
  
  String get authUrl => '$apiBaseUrl/auth';
  String get organizationsUrl => '$apiBaseUrl/organizations';
  String get studentsUrl => '$apiBaseUrl/students';
  String get busesUrl => '$apiBaseUrl/buses';
  String get routesUrl => '$apiBaseUrl/routes';
  String get driversUrl => '$apiBaseUrl/drivers';
  String get tripsUrl => '$apiBaseUrl/trips';
  String get notificationsUrl => '$apiBaseUrl/notifications';
  String get usersUrl => '$apiBaseUrl/users';
  String get mapsUrl => '$apiBaseUrl/maps';
  String get analyticsUrl => '$apiBaseUrl/analytics';
  String get assignmentsUrl => '$apiBaseUrl/assignments';
  String get subscriptionsUrl => '$apiBaseUrl/subscriptions';
}

