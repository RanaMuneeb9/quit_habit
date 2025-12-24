import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// Custom exception class for authentication errors with error codes
class AuthException implements Exception {
  final String code;
  final String message;

  AuthException({required this.code, required this.message});

  @override
  String toString() => message;
}

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  FirebaseAuth get auth => _auth;
  User? get currentUser => _auth.currentUser;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Sign in with Google
  Future<UserCredential> signInWithGoogle() async {
    try {
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        // User canceled the sign-in
        throw Exception('Sign-in was canceled');
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      return await _auth.signInWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Failed to sign in with Google: ${e.toString()}');
    }
  }

  /// Sign in with Apple
  Future<UserCredential> signInWithApple() async {
    try {
      debugPrint('AuthService: Initializing Apple Auth Provider...');
      final appleProvider = AppleAuthProvider();
      appleProvider.addScope('email');
      appleProvider.addScope('name');
      
      debugPrint('AuthService: Requesting Apple Sign In...');
      final userCredential = await _auth.signInWithProvider(appleProvider);
      
      debugPrint('AuthService: Apple Sign In successful. UID: ${userCredential.user?.uid}');
      return userCredential;
    } on FirebaseAuthException catch (e) {
      debugPrint('AuthService: FirebaseAuthException during Apple Sign In: ${e.code} - ${e.message}');
      throw _handleAuthException(e);
    } catch (e, stackTrace) {
      debugPrint('AuthService: Unexpected error during Apple Sign In: $e');
      debugPrint('AuthService: Stack trace: $stackTrace');
      throw Exception('Failed to sign in with Apple: ${e.toString()}');
    }
  }

  /// Sign in with email and password
  Future<UserCredential> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  /// Sign up with email and password
  Future<UserCredential> signUpWithEmailAndPassword(
    String email,
    String password,
    String fullName,
  ) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      // Update display name
      if (userCredential.user != null && fullName.isNotEmpty) {
        await userCredential.user!.updateDisplayName(fullName);
        await userCredential.user!.reload();
      }

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      await Future.wait([
        _auth.signOut(),
        _googleSignIn.signOut(),
      ]);
    } catch (e) {
      throw Exception('Failed to sign out: ${e.toString()}');
    }
  }

  /// Get current user
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  /// Fetch sign-in methods for an email address
  /// Note: fetchSignInMethodsForEmail was deprecated in Firebase Auth for security reasons
  /// This method is kept for API compatibility but always returns empty list
  /// Provider checking is no longer possible client-side
  @Deprecated('fetchSignInMethodsForEmail was removed from Firebase Auth. This method always returns empty list.')
  Future<List<String>> fetchSignInMethodsForEmail(String email) async {
    // Method deprecated - return empty list
    // We cannot check providers client-side anymore
    return [];
  }

  /// Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Failed to send password reset email: ${e.toString()}');
    }
  }

  /// Handle Firebase Auth exceptions and return AuthException with error codes
  AuthException _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return AuthException(
          code: 'user-not-found',
          message: 'No account found with this email.',
        );
      case 'wrong-password':
        return AuthException(
          code: 'invalid-credential',
          message: 'Invalid email or password.',
        );
      case 'email-already-in-use':
        return AuthException(
          code: 'email-already-in-use',
          message: 'An account already exists with this email.',
        );
      case 'weak-password':
        return AuthException(
          code: 'weak-password',
          message: 'Password is too weak. Please use a stronger password.',
        );
      case 'invalid-email':
        return AuthException(
          code: 'invalid-email',
          message: 'Invalid email address.',
        );
      case 'user-disabled':
        return AuthException(
          code: 'user-disabled',
          message: 'This account has been disabled.',
        );
      case 'too-many-requests':
        return AuthException(
          code: 'too-many-requests',
          message: 'Too many attempts. Please try again later.',
        );
      case 'operation-not-allowed':
        return AuthException(
          code: 'operation-not-allowed',
          message: 'This sign-in method is not enabled.',
        );
      case 'network-request-failed':
        return AuthException(
          code: 'network-request-failed',
          message: 'Network error. Please check your connection and try again.',
        );
      case 'invalid-credential':
        return AuthException(
          code: 'invalid-credential',
          message: 'Invalid credentials. Please try again.',
        );
      case 'account-exists-with-different-credential':
        return AuthException(
          code: 'account-exists-with-different-credential',
          message: 'An account already exists with a different sign-in method.',
        );
      default:
        return AuthException(
          code: e.code,
          message: e.message ?? 'An error occurred during authentication.',
        );
    }
  }
}

