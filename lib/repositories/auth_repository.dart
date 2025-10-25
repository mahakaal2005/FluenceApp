import '../models/auth_response.dart';
import '../models/user.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import '../services/firebase_service.dart';

class AuthRepository {
  final ApiService _apiService;
  final StorageService _storageService;

  AuthRepository({
    ApiService? apiService,
    StorageService? storageService,
  })  : _apiService = apiService ?? ApiService(),
        _storageService = storageService ?? StorageService();

  /// Admin login with Firebase Authentication
  Future<AuthResponse> loginAdmin(String email, String password) async {
    print('🔐 [AUTH] Starting login process for: $email');
    
    try {
      // Step 1: Authenticate with Firebase
      print('📱 [AUTH] Step 1: Authenticating with Firebase...');
      final userCredential = await FirebaseService.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      print('✅ [AUTH] Firebase authentication successful!');
      print('   User UID: ${userCredential.user?.uid}');
      print('   Email: ${userCredential.user?.email}');
      
      // Step 2: Get Firebase ID token
      print('🔑 [AUTH] Step 2: Getting Firebase ID token...');
      final idToken = await userCredential.user?.getIdToken();
      if (idToken == null) {
        print('❌ [AUTH] Failed to get ID token');
        throw Exception('Failed to get authentication token');
      }
      print('✅ [AUTH] ID token obtained (length: ${idToken.length})');
      
      // Step 3: Send Firebase ID token to backend for verification
      print('🌐 [AUTH] Step 3: Sending ID token to backend...');
      print('   Endpoint: api/auth/firebase');
      
      final response = await _apiService.post(
        'api/auth/firebase',
        {
          'idToken': idToken,
        },
        service: ServiceType.auth,
      );
      
      print('✅ [AUTH] Backend response received');
      print('   Response keys: ${response.keys.toList()}');

      if (response['user'] != null && response['token'] != null) {
        print('📦 [AUTH] Parsing user data...');
        final user = User.fromJson(response['user']);
        print('   User ID: ${user.id}');
        print('   User Name: ${user.name}');
        print('   User Role: ${user.role}');
        
        // Check if user has admin role
        if (user.role != 'admin') {
          print('❌ [AUTH] Access denied - User is not admin');
          await FirebaseService.signOut();
          throw Exception('Access denied. Admin privileges required.');
        }
        
        print('✅ [AUTH] Admin role verified');
        
        final authResponse = AuthResponse(
          user: user,
          token: response['token'],
          needsProfileCompletion: response['needsProfileCompletion'] ?? false,
        );
        
        // Save JWT token to secure storage
        print('💾 [AUTH] Saving JWT token to secure storage...');
        await _storageService.saveToken(authResponse.token);
        print('✅ [AUTH] Login process completed successfully!');
        
        return authResponse;
      } else {
        print('❌ [AUTH] Invalid response from backend');
        print('   Response: $response');
        throw Exception(response['message'] ?? 'Authentication failed');
      }
    } catch (e) {
      print('❌ [AUTH] Login failed with error: $e');
      print('   Error type: ${e.runtimeType}');
      
      // Sign out from Firebase if backend authentication fails
      print('🔄 [AUTH] Signing out from Firebase...');
      await FirebaseService.signOut();
      
      throw Exception('Login failed: $e');
    }
  }



  /// Logout user
  Future<void> logout() async {
    try {
      // Sign out from Firebase
      await FirebaseService.signOut();
      
      // Clear JWT token from storage
      await _storageService.deleteToken();
      
      // Optional: Call backend logout endpoint
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
      // Check both Firebase auth and JWT token
      final hasFirebaseUser = FirebaseService.isSignedIn();
      final hasJwtToken = await _storageService.hasToken();
      
      return hasFirebaseUser && hasJwtToken;
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
      // If there's an error, try to get user info from Firebase
      final firebaseUser = FirebaseService.getCurrentUser();
      if (firebaseUser != null && await _storageService.hasToken()) {
        return User(
          id: firebaseUser.uid,
          name: firebaseUser.displayName ?? 'Admin User',
          email: firebaseUser.email ?? '',
          phone: firebaseUser.phoneNumber,
          role: 'admin', // Assume admin role for authenticated users
        );
      }
      return null;
    }
  }

  /// Refresh authentication token
  Future<String?> refreshToken() async {
    try {
      // Get fresh Firebase ID token
      final idToken = await FirebaseService.getIdToken();
      if (idToken == null) {
        await logout();
        return null;
      }
      
      // Send to backend for new JWT token
      final response = await _apiService.post(
        'api/auth/refresh',
        {'idToken': idToken},
        service: ServiceType.auth,
      );

      if (response['token'] != null) {
        final newToken = response['token'];
        await _storageService.saveToken(newToken);
        return newToken;
      }
      
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
      if (!await isAuthenticated()) {
        return false;
      }

      // Validate Firebase auth state
      final firebaseUser = FirebaseService.getCurrentUser();
      if (firebaseUser == null) {
        await logout();
        return false;
      }

      // Try to get fresh ID token to validate Firebase session
      final idToken = await FirebaseService.getIdToken();
      if (idToken == null) {
        await logout();
        return false;
      }

      return true;
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