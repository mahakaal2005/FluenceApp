import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' show kIsWeb;
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
  // 🚀 SMART PLATFORM DETECTION
  // ============================================
  // Automatically detects platform and uses correct URL:
  // - Web: http://localhost (same machine)
  // - Android Emulator: http://10.0.2.2 (host machine)
  // - Android Device: http://192.168.0.180 (local network)
  // - Remote Backend: https://161.248.37.235 (nginx reverse proxy, no ports)
  // - Production: https://api.fluencepay.com
  // ============================================
  
  // Remote Backend Configuration (nginx reverse proxy)
  static const String REMOTE_BACKEND_URL = 'https://161.248.37.235';
  static const bool USE_REMOTE_BACKEND = true; // 👈 Set to true to use remote backend (no ports needed)
  
  // Production URL (set this when deploying to production)
  static const String PRODUCTION_URL = 'https://api.fluencepay.com';
  static const bool USE_PRODUCTION = false; // 👈 Set to true for production
  
  // Development URLs (for localhost development)
  static const String WEB_DEV_URL = 'http://localhost';
  static const String ANDROID_EMULATOR_URL = 'http://10.0.2.2';
  static const String ANDROID_DEVICE_URL = 'http://192.168.0.180'; // Your local IP
  
  /// Get base URL based on platform
  /// Automatically detects and returns the correct URL
  static String get BASE_URL {
    // Priority 1: Remote Backend (nginx reverse proxy - no ports needed)
    if (USE_REMOTE_BACKEND) {
      print('🌐 [API] Using REMOTE BACKEND URL: $REMOTE_BACKEND_URL');
      print('   Note: No ports needed - nginx routes via /api/ paths');
      return REMOTE_BACKEND_URL;
    }
    
    // Priority 2: Production URL
    if (USE_PRODUCTION) {
      print('🌐 [API] Using PRODUCTION URL: $PRODUCTION_URL');
      return PRODUCTION_URL;
    }
    
    // Priority 3: Development mode - auto-detect platform
    if (kIsWeb) {
      // Running on web browser (Chrome, Edge, etc.)
      print('🌐 [API] Platform: WEB - Using: $WEB_DEV_URL');
      return WEB_DEV_URL;
    } else {
      // Running on Android/iOS
      // Note: If using Android Emulator, change ANDROID_DEVICE_URL to ANDROID_EMULATOR_URL above
      print('🌐 [API] Platform: MOBILE - Using: $ANDROID_DEVICE_URL');
      return ANDROID_DEVICE_URL;
    }
  }
  
  // Service ports (only used for localhost development)
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
  /// When using remote backend, no ports are needed - nginx routes via /api/ paths
  static String _getServiceUrl(ServiceType service) {
    // If using remote backend, return base URL without port
    // Backend uses nginx reverse proxy that routes based on /api/ paths
    if (USE_REMOTE_BACKEND) {
      return BASE_URL; // No port needed - nginx handles routing
    }
    
    // For localhost development, append port number
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
      // Ensure endpoint doesn't start with / to avoid double slashes
      final cleanEndpoint = endpoint.startsWith('/') ? endpoint.substring(1) : endpoint;
      final fullUrl = '$baseUrl/$cleanEndpoint';
      
      print('🌐 [API] GET Request');
      print('   URL: $fullUrl');
      print('   Service: $service');
      print('   Endpoint: $cleanEndpoint');
      
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
      print('   Error details: ${e.toString()}');
      
      // Provide more detailed error information for web CORS/SSL issues
      final errorString = e.toString().toLowerCase();
      if (errorString.contains('failed to fetch') || 
          errorString.contains('cors') ||
          errorString.contains('network') ||
          errorString.contains('socketexception')) {
        print('⚠️ [API] This looks like a CORS or network connectivity issue.');
        print('   Possible causes:');
        print('   1. CORS not configured on backend - Backend needs to allow your origin');
        print('   2. SSL certificate issue - Backend may be using self-signed certificate');
        print('   3. Network connectivity - Server may not be reachable');
        print('   Check browser console (F12) for more details');
      }
      
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
      // Ensure endpoint doesn't start with / to avoid double slashes
      final cleanEndpoint = endpoint.startsWith('/') ? endpoint.substring(1) : endpoint;
      final fullUrl = '$baseUrl/$cleanEndpoint';
      
      print('🌐 [API] POST Request');
      print('   URL: $fullUrl');
      print('   Service: $service');
      print('   Endpoint: $cleanEndpoint');
      
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
      print('❌ [API] POST Request failed: $e');
      print('   Error type: ${e.runtimeType}');
      print('   Error details: ${e.toString()}');
      
      // Provide more detailed error information for web CORS/SSL issues
      final errorString = e.toString().toLowerCase();
      if (errorString.contains('failed to fetch') || 
          errorString.contains('cors') ||
          errorString.contains('network') ||
          errorString.contains('socketexception')) {
        print('⚠️ [API] This looks like a CORS or network connectivity issue.');
        print('   Possible causes:');
        print('   1. CORS not configured on backend - Backend needs to allow your origin');
        print('   2. SSL certificate issue - Backend may be using self-signed certificate');
        print('   3. Network connectivity - Server may not be reachable');
        print('   Check browser console (F12) for more details');
      }
      
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
    
    final errorString = error.toString().toLowerCase();
    
    // CORS or network connectivity errors (common in web)
    if (errorString.contains('failed to fetch') ||
        errorString.contains('cors') ||
        errorString.contains('networkerror') ||
        errorString.contains('socketexception')) {
      return NetworkException(
        'Connection failed. This could be due to:\n'
        '1. CORS not configured on backend (backend needs to allow your origin)\n'
        '2. SSL certificate issue (check browser console for details)\n'
        '3. Server not reachable\n\n'
        'Error: ${error.toString()}',
      );
    }
    
    // Network/timeout errors
    if (errorString.contains('timeoutexception')) {
      return NetworkException(
        'Request timed out. Please check your internet connection and try again.',
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