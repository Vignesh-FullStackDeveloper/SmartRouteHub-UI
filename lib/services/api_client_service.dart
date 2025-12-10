import '../core/api/api_client.dart';
import '../core/config/app_config.dart';

/// Singleton API client service
class ApiClientService {
  static ApiClient? _instance;

  static ApiClient get instance {
    _instance ??= ApiClient(config: AppConfig.current);
    return _instance!;
  }

  static void reset() {
    _instance = null;
  }
}

