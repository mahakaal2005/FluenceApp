import 'dart:convert';
import 'package:http/http.dart' as http;
import 'storage_service.dart';

/// Enum for different microservices
enum ServiceType {
  auth,
  cashback,
  merchant,
  notification,
  points,
  referral,
  social,
}

/// API Service for handling HTTP requests to multiple microservices
class ApiService {
  // ============================================
  // 🚀 PRODUCTION DEPLOYMENT CONFIGURATION
  // ============================================
  // TO DEPLOY TO PRODUCTION:
  // 1. Change BASE_URL below to your production server IP or domain
  // 2. Rebuild the app: flutter build apk --release (Android) or flutter build ios --release (iOS)
  // 3. That's it! All microservices will automatically use the new URL
  //
  // EXAMPLES:
  // Development (Local):     'http://192.168.0.180'
  // Development (Emulator):  'http://10.0.2.2'
  // Staging Server:          'http://staging.fluencepay.com'
  // Production Server:       'https://api.fluencepay.com'
  //
  // NOTE: Do NOT include port numbers or trailing slashes in BASE_URL
  // ============================================
  
  static const String BASE_URL = 'http://192.168.0.180'; // 👈 CHANGE THIS FOR PRODUCTION
  
  // Service ports (these remain constant across all environments)
  static const Map<ServiceType, int> _servicePorts = {
    ServiceType.auth: 4001,
    ServiceType.cashback: 4002,
    ServiceType.merchant: 4003,
    ServiceType.notification: 4004,
    ServiceType.points: 4005,
    ServiceType.referral: 4006,
    ServiceType.social: 4007,
  };
  
  /// Get the full URL for a specific service
  static String _getServiceUrl(ServiceType service) {
    final port = _servicePorts[service]!;
    return '$BASE_URL:$port';
  }
  
  final http.Client _client;
  final StorageService _storageService;
  
  ApiService({
    http.Client? client,
    StorageService? storageService,
  })  : _client = client ?? http.Client(),
        _storageService = storageService ?? StorageService();

  /// GET request
  Future<Map<String, dynamic>> get(
    String endpoint, {
    required ServiceType service,
  }) async {
    try {
      final baseUrl = _getServiceUrl(service);
      final fullUrl = '$baseUrl/$endpoint';
      
      print('🌐 [API] GET Request');
      print('   URL: $fullUrl');
      print('   Service: $service');
      
      final headers = await _getHeaders();
      print('   Headers: ${headers.keys.toList()}');
      
      final response = await _client.get(
        Uri.parse(fullUrl),
        headers: headers,
      ).timeout(const Duration(seconds: 30));
      
      print('✅ [API] Response received');
      print('   Status: ${response.statusCode}');
      print('   Body length: ${response.body.length}');
      print('   Body preview: ${response.body.substring(0, response.body.length > 200 ? 200 : response.body.length)}');
      
      return _handleResponse(response);
    } catch (e) {
      print('❌ [API] GET Request failed: $e');
      print('   Error type: ${e.runtimeType}');
      throw _handleError(e);
    }
  }

  /// POST request
  Future<Map<String, dynamic>> post(
    String endpoint, 
    Map<String, dynamic> data, {
    required ServiceType service,
  }) async {
    try {
      final baseUrl = _getServiceUrl(service);
      final fullUrl = '$baseUrl/$endpoint';
      
      print('🌐 [API] POST Request');
      print('   URL: $fullUrl');
      print('   Service: $service');
      
      final headers = await _getHeaders();
      print('   Headers: ${headers.keys.toList()}');
      
      final response = await _client.post(
        Uri.parse(fullUrl),
        headers: headers,
        body: jsonEncode(data),
      ).timeout(const Duration(seconds: 30));
      
      print('✅ [API] Response received');
      print('   Status: ${response.statusCode}');
      print('   Body length: ${response.body.length}');
      
      return _handleResponse(response);
    } catch (e) {
      print('❌ [API] Request failed: $e');
      print('   Error type: ${e.runtimeType}');
      throw _handleError(e);
    }
  }

  /// PUT request
  Future<Map<String, dynamic>> put(
    String endpoint, 
    Map<String, dynamic> data, {
    required ServiceType service,
  }) async {
    try {
      final baseUrl = _getServiceUrl(service);
      final headers = await _getHeaders();
      
      final response = await _client.put(
        Uri.parse('$baseUrl/$endpoint'),
        headers: headers,
        body: jsonEncode(data),
      ).timeout(const Duration(seconds: 30));
      
      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// DELETE request
  Future<void> delete(
    String endpoint, {
    required ServiceType service,
  }) async {
    try {
      final baseUrl = _getServiceUrl(service);
      final headers = await _getHeaders();
      
      final response = await _client.delete(
        Uri.parse('$baseUrl/$endpoint'),
        headers: headers,
      ).timeout(const Duration(seconds: 30));
      
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw ApiException(
          'DELETE request failed',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Get headers with JWT token if available
  Future<Map<String, String>> _getHeaders() async {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    
    // Add JWT token if available
    final token = await _storageService.getToken();
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    
    return headers;
  }

  /// Handle HTTP response with proper error handling
  Map<String, dynamic> _handleResponse(http.Response response) {
    // Success responses (200-299)
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) {
        return {'success': true};
      }
      try {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } catch (e) {
        throw ApiException(
          'Failed to parse response',
          statusCode: response.statusCode,
        );
      }
    }
    
    // Handle specific error status codes
    switch (response.statusCode) {
      case 401:
        // Unauthorized - token expired or invalid
        // Clear token and throw exception
        _storageService.deleteToken();
        throw UnauthorizedException(
          'Session expired. Please login again.',
          statusCode: 401,
        );
        
      case 403:
        // Forbidden - insufficient permissions
        throw ForbiddenException(
          'You don\'t have permission to perform this action.',
          statusCode: 403,
        );
        
      case 404:
        // Not found - could be endpoint doesn't exist yet
        String message = 'Endpoint not found';
        try {
          final body = jsonDecode(response.body);
          if (body['error'] != null) {
            message = body['error'];
          } else if (body['message'] != null) {
            message = body['message'];
          }
        } catch (_) {}
        throw NotFoundException(message, statusCode: 404);
        
      case 422:
        // Validation error
        String message = 'Validation error';
        try {
          final body = jsonDecode(response.body);
          if (body['error'] != null) {
            message = body['error'];
          } else if (body['message'] != null) {
            message = body['message'];
          }
        } catch (_) {}
        throw ValidationException(message, statusCode: 422);
        
      case 500:
      case 502:
      case 503:
        // Server errors
        throw ServerException(
          'Server error. Please try again later.',
          statusCode: response.statusCode,
        );
        
      default:
        // Other errors
        String message = 'Request failed';
        try {
          final body = jsonDecode(response.body);
          if (body['error'] != null) {
            message = body['error'];
          } else if (body['message'] != null) {
            message = body['message'];
          }
        } catch (_) {}
        
        throw ApiException(
          message,
          statusCode: response.statusCode,
        );
    }
  }
  
  /// Handle errors from HTTP requests
  Exception _handleError(dynamic error) {
    if (error is ApiException) {
      return error;
    }
    
    // Network/timeout errors
    if (error.toString().contains('SocketException') ||
        error.toString().contains('TimeoutException')) {
      return NetworkException(
        'Connection failed. Please check your internet connection.',
      );
    }
    
    // Generic error
    return ApiException('Request failed: ${error.toString()}');
  }

  void dispose() {
    _client.close();
  }
}

/// Base API Exception
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  
  ApiException(this.message, {this.statusCode});
  
  @override
  String toString() => 'ApiException: $message';
}

/// Unauthorized Exception (401)
class UnauthorizedException extends ApiException {
  UnauthorizedException(super.message, {super.statusCode});
  
  @override
  String toString() => 'UnauthorizedException: $message';
}

/// Forbidden Exception (403)
class ForbiddenException extends ApiException {
  ForbiddenException(super.message, {super.statusCode});
  
  @override
  String toString() => 'ForbiddenException: $message';
}

/// Not Found Exception (404)
class NotFoundException extends ApiException {
  NotFoundException(super.message, {super.statusCode});
  
  @override
  String toString() => 'NotFoundException: $message';
}

/// Validation Exception (422)
class ValidationException extends ApiException {
  ValidationException(super.message, {super.statusCode});
  
  @override
  String toString() => 'ValidationException: $message';
}

/// Server Exception (500+)
class ServerException extends ApiException {
  ServerException(super.message, {super.statusCode});
  
  @override
  String toString() => 'ServerException: $message';
}

/// Network Exception (connection issues)
class NetworkException extends ApiException {
  NetworkException(super.message);
  
  @override
  String toString() => 'NetworkException: $message';
}