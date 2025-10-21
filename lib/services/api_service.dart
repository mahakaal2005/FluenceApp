import 'dart:convert';
import 'package:http/http.dart' as http;

/// API Service for handling HTTP requests
/// This is a template - configure with your actual API endpoints
class ApiService {
  static const String baseUrl = 'https://your-api-url.com/api';
  
  final http.Client _client;
  
  ApiService({http.Client? client}) : _client = client ?? http.Client();

  /// GET request
  Future<Map<String, dynamic>> get(String endpoint) async {
    try {
      final response = await _client.get(
        Uri.parse('$baseUrl/$endpoint'),
        headers: _getHeaders(),
      );
      
      return _handleResponse(response);
    } catch (e) {
      throw ApiException('GET request failed: $e');
    }
  }

  /// POST request
  Future<Map<String, dynamic>> post(
    String endpoint, 
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _client.post(
        Uri.parse('$baseUrl/$endpoint'),
        headers: _getHeaders(),
        body: jsonEncode(data),
      );
      
      return _handleResponse(response);
    } catch (e) {
      throw ApiException('POST request failed: $e');
    }
  }

  /// PUT request
  Future<Map<String, dynamic>> put(
    String endpoint, 
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _client.put(
        Uri.parse('$baseUrl/$endpoint'),
        headers: _getHeaders(),
        body: jsonEncode(data),
      );
      
      return _handleResponse(response);
    } catch (e) {
      throw ApiException('PUT request failed: $e');
    }
  }

  /// DELETE request
  Future<void> delete(String endpoint) async {
    try {
      final response = await _client.delete(
        Uri.parse('$baseUrl/$endpoint'),
        headers: _getHeaders(),
      );
      
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw ApiException('DELETE request failed: ${response.statusCode}');
      }
    } catch (e) {
      throw ApiException('DELETE request failed: $e');
    }
  }

  Map<String, String> _getHeaders() {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      // Add authentication headers here if needed
      // 'Authorization': 'Bearer $token',
    };
  }

  Map<String, dynamic> _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) {
        return {};
      }
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      throw ApiException(
        'Request failed with status: ${response.statusCode}, body: ${response.body}',
      );
    }
  }

  void dispose() {
    _client.close();
  }
}

class ApiException implements Exception {
  final String message;
  
  ApiException(this.message);
  
  @override
  String toString() => 'ApiException: $message';
}