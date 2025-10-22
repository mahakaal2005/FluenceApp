import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Service for secure storage of JWT tokens and sensitive data
class StorageService {
  static const String _tokenKey = 'jwt_token';
  
  final FlutterSecureStorage _storage;
  
  StorageService({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  /// Save JWT token to secure storage
  Future<void> saveToken(String token) async {
    try {
      await _storage.write(key: _tokenKey, value: token);
    } catch (e) {
      throw StorageException('Failed to save token: $e');
    }
  }

  /// Get JWT token from secure storage
  Future<String?> getToken() async {
    try {
      return await _storage.read(key: _tokenKey);
    } catch (e) {
      throw StorageException('Failed to get token: $e');
    }
  }

  /// Delete JWT token from secure storage
  Future<void> deleteToken() async {
    try {
      await _storage.delete(key: _tokenKey);
    } catch (e) {
      throw StorageException('Failed to delete token: $e');
    }
  }

  /// Check if JWT token exists in secure storage
  Future<bool> hasToken() async {
    try {
      final token = await _storage.read(key: _tokenKey);
      return token != null && token.isNotEmpty;
    } catch (e) {
      throw StorageException('Failed to check token: $e');
    }
  }

  /// Clear all data from secure storage
  Future<void> clearAll() async {
    try {
      await _storage.deleteAll();
    } catch (e) {
      throw StorageException('Failed to clear storage: $e');
    }
  }
}

class StorageException implements Exception {
  final String message;
  
  StorageException(this.message);
  
  @override
  String toString() => 'StorageException: $message';
}
