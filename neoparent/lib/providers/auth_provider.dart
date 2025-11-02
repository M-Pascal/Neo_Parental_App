import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

/// Provider for managing authentication state
class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();

  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  /// Current authenticated user
  UserModel? get currentUser => _currentUser;

  /// Loading state
  bool get isLoading => _isLoading;

  /// Error message
  String? get errorMessage => _errorMessage;

  /// Check if user is authenticated
  bool get isAuthenticated => _currentUser != null;

  /// Initialize auth state listener
  AuthProvider() {
    _initAuthListener();
    _checkCurrentUser();
  }

  /// Check current user on startup
  Future<void> _checkCurrentUser() async {
    _currentUser = _authService.currentUser;
    if (_currentUser != null) {
      notifyListeners();
    }
  }

  /// Listen to auth state changes
  void _initAuthListener() {
    _authService.authStateChanges.listen((UserModel? user) {
      _currentUser = user;
      notifyListeners();
    });
  }

  /// Sign in with email and password
  Future<bool> signIn({required String email, required String password}) async {
    _setLoading(true);
    _clearError();

    try {
      final normalizedEmail = email.trim().toLowerCase();
      _currentUser = await _authService.signInWithEmailAndPassword(
        email: normalizedEmail,
        password: password,
      );
      _setLoading(false);
      return true;
    } on AuthException catch (e) {
      _setError(e.message);
      _setLoading(false);
      return false;
    } catch (e) {
      _setError('An unexpected error occurred');
      _setLoading(false);
      return false;
    }
  }

  /// Register new user with email and password
  Future<bool> signUp({
    required String email,
    required String password,
    required String fullName,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final normalizedEmail = email.trim().toLowerCase();
      _currentUser = await _authService.signUpWithEmailAndPassword(
        email: normalizedEmail,
        password: password,
        fullName: fullName,
      );
      _setLoading(false);
      return true;
    } on AuthException catch (e) {
      _setError(e.message);
      _setLoading(false);
      return false;
    } catch (e) {
      _setError('An unexpected error occurred');
      _setLoading(false);
      return false;
    }
  }

  /// Sign out current user
  Future<void> signOut() async {
    _setLoading(true);
    _clearError();

    try {
      await _authService.signOut();
      _currentUser = null;
      _setLoading(false);
    } on AuthException catch (e) {
      _setError(e.message);
      _setLoading(false);
    } catch (e) {
      _setError('Failed to sign out');
      _setLoading(false);
    }
  }

  /// Send password reset email
  Future<bool> sendPasswordResetEmail(String email) async {
    _setLoading(true);
    _clearError();

    try {
      final normalizedEmail = email.trim().toLowerCase();
      await _authService.sendPasswordResetEmail(normalizedEmail);
      _setLoading(false);
      return true;
    } on AuthException catch (e) {
      _setError(e.message);
      _setLoading(false);
      return false;
    } catch (e) {
      _setError('Failed to send reset email');
      _setLoading(false);
      return false;
    }
  }

  /// Check if user exists with given email
  Future<bool> checkUserExists(String email) async {
    try {
      final normalizedEmail = email.trim().toLowerCase();
      return await _authService.checkUserExists(normalizedEmail);
    } catch (e) {
      return false;
    }
  }

  /// Set loading state
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  /// Set error message
  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  /// Clear error message
  void _clearError() {
    _errorMessage = null;
  }

  /// Clear all errors
  void clearError() {
    _clearError();
    notifyListeners();
  }
}
