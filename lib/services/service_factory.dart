/// Service factory to easily switch between mock and API services
/// Set USE_API_SERVICES to true to use real API services
class ServiceFactory {
  static const bool USE_API_SERVICES = true; // Set to false to use mock services

  // This factory can be used to conditionally return API or mock services
  // For now, we're using API services directly
}

