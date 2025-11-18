import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:quit_habit/services/auth_service.dart';
import 'package:quit_habit/services/user_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final UserService _userService = UserService();

  User? _user;
  bool _isLoading = true;
  bool _hasCompletedQuestionnaire = false;

  User? get user => _user;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null;
  bool get hasCompletedQuestionnaire => _hasCompletedQuestionnaire;
  AuthService get authService => _authService;
  UserService get userService => _userService;

  AuthProvider() {
    _init();
  }

  Future<void> _init() async {
    _authService.authStateChanges.listen((User? user) async {
      _user = user;
      if (user != null) {
        // Check questionnaire status
        await _checkQuestionnaireStatus(user.uid);
      } else {
        _hasCompletedQuestionnaire = false;
      }
      _isLoading = false;
      notifyListeners();
    });
  }

  Future<void> _checkQuestionnaireStatus(String uid) async {
    try {
      _hasCompletedQuestionnaire =
          await _userService.hasCompletedQuestionnaire(uid);
      notifyListeners();
    } catch (e) {
      // If check fails, assume not completed
      _hasCompletedQuestionnaire = false;
      notifyListeners();
    }
  }

  /// Sign in with Google
  Future<void> signInWithGoogle() async {
    try {
      _isLoading = true;
      notifyListeners();

      final userCredential = await _authService.signInWithGoogle();
      final user = userCredential.user;

      if (user != null) {
        // Create user document if it doesn't exist
        await _userService.createUserDocument(user);
        // Check questionnaire status
        await _checkQuestionnaireStatus(user.uid);
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  /// Sign in with email and password
  Future<void> signInWithEmailAndPassword(String email, String password) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _authService.signInWithEmailAndPassword(email, password);
      final user = _authService.currentUser;

      if (user != null) {
        await _checkQuestionnaireStatus(user.uid);
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  /// Sign up with email and password
  Future<void> signUpWithEmailAndPassword(
    String email,
    String password,
    String fullName,
  ) async {
    try {
      _isLoading = true;
      notifyListeners();

      final userCredential =
          await _authService.signUpWithEmailAndPassword(email, password, fullName);
      final user = userCredential.user;

      if (user != null) {
        // Create user document
        await _userService.createUserDocument(user, fullName: fullName);
        // New users haven't completed questionnaire
        _hasCompletedQuestionnaire = false;
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      _isLoading = true;
      notifyListeners();

      await _authService.signOut();
      _user = null;
      _hasCompletedQuestionnaire = false;

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  /// Refresh questionnaire status
  Future<void> refreshQuestionnaireStatus() async {
    if (_user != null) {
      await _checkQuestionnaireStatus(_user!.uid);
    }
  }
}

