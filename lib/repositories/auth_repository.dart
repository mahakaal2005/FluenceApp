import '../models/auth_response.dart';
import '../models/user.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';

class AuthRepository {
  final ApiService _apiService;
  final StorageService _storageService;

  AuthRepository({
    ApiService? apiService,
    StorageService? storageService,
  })  : _apiService = apiService ?? ApiService(),
        _storageService = storageService ?? StorageService();

  /// Admin login with direct database authentication
  Future<AuthResponse> loginAdmin(String email, String password) async {
    try {
      final response = await _apiService.post(
        'api/auth/login',
        {
          'email': email,
          'password': password,
        },
        service: ServiceType.auth,
      );

      // Check if response has success flag and required fields
      if (response['success'] == true && response['user'] != null && response['token'] != null) {
        final user = User.fromJson(response['user']);
        
        // Check if user has admin role
        if (user.role != 'admin') {
          throw Exception('Access denied. Admin privileges required.');
        }
        
        // Check if account is blocked
        if (response['user']['status'] == 'blocked') {
          throw Exception('Account is blocked. Please contact administrator.');
        }
        
        final authResponse = AuthResponse(
          user: user,
          token: response['token'],
          needsProfileCompletion: false,
        );
        
        // Save JWT token to secure storage
        await _storageService.saveToken(authResponse.token);
        
        return authResponse;
      } else {
        throw Exception(response['error'] ?? response['message'] ?? 'Authentication failed');
      }
    } catch (e) {
      print('[ERROR] [AUTH] Login failed: $e');
      throw Exception('Login failed: $e');
    }
  }



  /// Logout user
  Future<void> logout() async {
    try {
      // Clear JWT token from storage
      await _storageService.deleteToken();
      
      // Optional: Call backend logout endpoint if it exists
      try {
        await _apiService.post(
          'api/auth/logout',
          {},
          service: ServiceType.auth,
        );
      } catch (e) {
        // Ignore logout endpoint errors - tokens are already cleared
      }
    } catch (e) {
      throw Exception('Logout failed: $e');
    }
  }

  /// Check if user is authenticated
  Future<bool> isAuthenticated() async {
    try {
      // Check if JWT token exists
      final hasJwtToken = await _storageService.hasToken();
      return hasJwtToken;
    } catch (e) {
      return false;
    }
  }

  /// Get current user info
  Future<User?> getCurrentUser() async {
    try {
      if (!await isAuthenticated()) {
        return null;
      }

      final response = await _apiService.get(
        'api/auth/profile',
        service: ServiceType.auth,
      );

      if (response['user'] != null) {
        return User.fromJson(response['user']);
      }
      
      return null;
    } catch (e) {
      print('[WARNING] [AUTH] Failed to get current user: $e');
      return null;
    }
  }

  /// Refresh authentication token
  /// Note: Backend may not have a refresh endpoint - user will need to login again when token expires
  Future<String?> refreshToken() async {
    try {
      // Check if refresh endpoint exists on backend
      // For now, return null - user will need to login again when token expires
      await logout();
      return null;
    } catch (e) {
      // If refresh fails, user needs to login again
      await logout();
      return null;
    }
  }

  /// Validate current token
  Future<bool> validateToken() async {
    try {
      // Check if JWT token exists
      if (!await isAuthenticated()) {
        return false;
      }

      // Optionally validate token with backend by calling profile endpoint
      try {
        final response = await _apiService.get(
          'api/auth/profile',
          service: ServiceType.auth,
        );
        // If profile call succeeds, token is valid
        return response['user'] != null;
      } catch (e) {
        // If profile call fails (401), token is invalid
        print('[WARNING] [AUTH] Token validation failed: $e');
        await logout();
        return false;
      }
    } catch (e) {
      // If validation fails, clear auth state
      await logout();
      return false;
    }
  }

  void dispose() {
    _apiService.dispose();
  }
}