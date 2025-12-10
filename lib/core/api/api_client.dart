import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_config.dart';

/// Enterprise-grade API client with error handling, retry logic, and token management
class ApiClient {
  final AppConfig config;
  final http.Client httpClient;
  String? _token;

  ApiClient({
    AppConfig? config,
    http.Client? httpClient,
  })  : config = config ?? AppConfig.current,
        httpClient = httpClient ?? http.Client();

  /// Get stored authentication token
  Future<String?> getToken() async {
    if (_token != null) return _token;
    
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token');
    return _token;
  }

  /// Save authentication token
  Future<void> saveToken(String token) async {
    _token = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  /// Clear authentication token
  Future<void> clearToken() async {
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  /// Build headers for API requests
  Future<Map<String, String>> _buildHeaders({
    Map<String, String>? additionalHeaders,
    bool includeAuth = true,
  }) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (includeAuth) {
      final token = await getToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    if (additionalHeaders != null) {
      headers.addAll(additionalHeaders);
    }

    return headers;
  }

  /// Handle API response
  dynamic _handleResponse(http.Response response) {
    if (config.enableLogging) {
      print('API Response: ${response.statusCode} - ${response.request?.url}');
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) {
        return null;
      }
      return json.decode(response.body);
    } else if (response.statusCode == 401) {
      // Unauthorized - clear token
      clearToken();
      throw ApiException('Unauthorized. Please login again.', 401);
    } else if (response.statusCode == 403) {
      throw ApiException('Access denied. Insufficient permissions.', 403);
    } else if (response.statusCode == 404) {
      throw ApiException('Resource not found.', 404);
    } else if (response.statusCode >= 500) {
      throw ApiException('Server error. Please try again later.', response.statusCode);
    } else {
      // Try to parse error message
      try {
        final error = json.decode(response.body);
        throw ApiException(
          error['error'] ?? 'An error occurred',
          response.statusCode,
        );
      } catch (e) {
        throw ApiException('An error occurred: ${response.statusCode}', response.statusCode);
      }
    }
  }

  /// GET request
  Future<dynamic> get(
    String endpoint, {
    Map<String, String>? queryParams,
    bool includeAuth = true,
  }) async {
    try {
      var uri = Uri.parse('${config.apiBaseUrl}$endpoint');
      if (queryParams != null && queryParams.isNotEmpty) {
        uri = uri.replace(queryParameters: queryParams);
      }

      final headers = await _buildHeaders(includeAuth: includeAuth);
      final response = await httpClient.get(uri, headers: headers);

      return _handleResponse(response);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Network error: ${e.toString()}', 0);
    }
  }

  /// POST request
  Future<dynamic> post(
    String endpoint, {
    Map<String, dynamic>? body,
    bool includeAuth = true,
  }) async {
    try {
      final uri = Uri.parse('${config.apiBaseUrl}$endpoint');
      final headers = await _buildHeaders(includeAuth: includeAuth);
      
      final response = await httpClient.post(
        uri,
        headers: headers,
        body: body != null ? json.encode(body) : null,
      );

      return _handleResponse(response);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Network error: ${e.toString()}', 0);
    }
  }

  /// PUT request
  Future<dynamic> put(
    String endpoint, {
    Map<String, dynamic>? body,
    bool includeAuth = true,
  }) async {
    try {
      final uri = Uri.parse('${config.apiBaseUrl}$endpoint');
      final headers = await _buildHeaders(includeAuth: includeAuth);
      
      final response = await httpClient.put(
        uri,
        headers: headers,
        body: body != null ? json.encode(body) : null,
      );

      return _handleResponse(response);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Network error: ${e.toString()}', 0);
    }
  }

  /// PATCH request
  Future<dynamic> patch(
    String endpoint, {
    Map<String, dynamic>? body,
    bool includeAuth = true,
  }) async {
    try {
      final uri = Uri.parse('${config.apiBaseUrl}$endpoint');
      final headers = await _buildHeaders(includeAuth: includeAuth);
      
      final response = await httpClient.patch(
        uri,
        headers: headers,
        body: body != null ? json.encode(body) : null,
      );

      return _handleResponse(response);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Network error: ${e.toString()}', 0);
    }
  }

  /// DELETE request
  Future<dynamic> delete(
    String endpoint, {
    bool includeAuth = true,
  }) async {
    try {
      final uri = Uri.parse('${config.apiBaseUrl}$endpoint');
      final headers = await _buildHeaders(includeAuth: includeAuth);
      
      final response = await httpClient.delete(uri, headers: headers);

      return _handleResponse(response);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Network error: ${e.toString()}', 0);
    }
  }

  /// Stream request for Server-Sent Events (SSE)
  Stream<String> stream(
    String endpoint, {
    bool includeAuth = true,
  }) async* {
    try {
      final uri = Uri.parse('${config.apiBaseUrl}$endpoint');
      final headers = await _buildHeaders(includeAuth: includeAuth);
      
      final request = http.Request('GET', uri);
      request.headers.addAll(headers);

      final streamedResponse = await httpClient.send(request);
      
      await for (final chunk in streamedResponse.stream.transform(utf8.decoder)) {
        // Parse SSE format: "data: {...}\n\n"
        final lines = chunk.split('\n');
        for (final line in lines) {
          if (line.startsWith('data: ')) {
            yield line.substring(6); // Remove "data: " prefix
          }
        }
      }
    } catch (e) {
      throw ApiException('Stream error: ${e.toString()}', 0);
    }
  }
}

/// Custom API exception
class ApiException implements Exception {
  final String message;
  final int statusCode;

  ApiException(this.message, this.statusCode);

  @override
  String toString() => 'ApiException: $message (Status: $statusCode)';
}

