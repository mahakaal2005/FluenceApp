import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import '../firebase_options.dart';

class FirebaseService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  
  /// Initialize Firebase
  static Future<void> initialize() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }
  
  /// Sign in with email and password
  static Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential;
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    }
  }
  
  /// Create user with email and password
  static Future<UserCredential> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential;
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    }
  }
  
  /// Get current user
  static User? getCurrentUser() {
    return _auth.currentUser;
  }
  
  /// Get Firebase ID token
  static Future<String?> getIdToken() async {
    final user = getCurrentUser();
    if (user != null) {
      return await user.getIdToken();
    }
    return null;
  }
  
  /// Sign out
  static Future<void> signOut() async {
    await _auth.signOut();
  }
  
  /// Check if user is signed in
  static bool isSignedIn() {
    return getCurrentUser() != null;
  }
  
  /// Listen to auth state changes
  static Stream<User?> get authStateChanges => _auth.authStateChanges();
  
  /// Handle Firebase Auth exceptions
  static Exception _handleFirebaseAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return Exception('No user found with this email address.');
      case 'wrong-password':
        return Exception('Incorrect password.');
      case 'invalid-email':
        return Exception('Invalid email address.');
      case 'user-disabled':
        return Exception('This user account has been disabled.');
      case 'too-many-requests':
        return Exception('Too many failed attempts. Please try again later.');
      case 'email-already-in-use':
        return Exception('An account already exists with this email address.');
      case 'weak-password':
        return Exception('Password is too weak.');
      case 'invalid-credential':
        return Exception('Invalid credentials provided.');
      default:
        return Exception('Authentication failed: ${e.message}');
    }
  }
}