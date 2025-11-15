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
    print('🔐 [AUTH] Starting login process for: $email');
    
    try {
      // Send email and password directly to backend
      print('🌐 [AUTH] Sending login request to backend...');
      print('   Endpoint: api/auth/login');
      
      final response = await _apiService.post(
        'api/auth/login',
        {
          'email': email,
          'password': password,
        },
        service: ServiceType.auth,
      );
      
      print('✅ [AUTH] Backend response received');
      print('   Response keys: ${response.keys.toList()}');

      // Check if response has success flag and required fields
      if (response['success'] == true && response['user'] != null && response['token'] != null) {
        print('📦 [AUTH] Parsing user data...');
        final user = User.fromJson(response['user']);
        print('   User ID: ${user.id}');
        print('   User Name: ${user.name}');
        print('   User Email: ${user.email}');
        print('   User Role: ${user.role}');
        print('   User Status: ${response['user']['status'] ?? 'N/A'}');
        
        // Check if user has admin role
        if (user.role != 'admin') {
          print('❌ [AUTH] Access denied - User is not admin');
          throw Exception('Access denied. Admin privileges required.');
        }
        
        // Check if account is blocked
        if (response['user']['status'] == 'blocked') {
          print('❌ [AUTH] Account is blocked');
          throw Exception('Account is blocked. Please contact administrator.');
        }
        
        print('✅ [AUTH] Admin role verified');
        
        final authResponse = AuthResponse(
          user: user,
          token: response['token'],
          needsProfileCompletion: false, // Direct login doesn't need profile completion
        );
        
        // Save JWT token to secure storage
        print('💾 [AUTH] Saving JWT token to secure storage...');
        await _storageService.saveToken(authResponse.token);
        print('✅ [AUTH] Login process completed successfully!');
        
        return authResponse;
      } else {
        print('❌ [AUTH] Invalid response from backend');
        print('   Response: $response');
        throw Exception(response['error'] ?? response['message'] ?? 'Authentication failed');
      }
    } catch (e) {
      print('❌ [AUTH] Login failed with error: $e');
      print('   Error type: ${e.runtimeType}');
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
        print('⚠️ [AUTH] Logout endpoint not available or failed: $e');
      }
      
      print('✅ [AUTH] Logout completed');
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
      print('⚠️ [AUTH] Failed to get current user: $e');
      return null;
    }
  }

  /// Refresh authentication token
  /// Note: Backend may not have a refresh endpoint - user will need to login again when token expires
  Future<String?> refreshToken() async {
    try {
      // Check if refresh endpoint exists on backend
      // For now, return null - user will need to login again when token expires
      print('⚠️ [AUTH] Token refresh not implemented - user needs to login again');
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
        print('⚠️ [AUTH] Token validation failed: $e');
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