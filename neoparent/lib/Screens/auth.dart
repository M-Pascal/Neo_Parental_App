// This file is no longer used - replaced by lib/services/auth_service.dart
// The original Firebase-based authentication has been removed
//
// NOTE: The new auth service in lib/services/auth_service.dart provides
// a simple mock authentication that allows any email/password to work
// without actual registration or Firebase dependencies.
//
// You can safely delete this file if needed.

/*
// === ORIGINAL FIREBASE AUTH CODE (COMMENTED OUT) ===

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Auth state changes stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign up with email and password
  Future<UserCredential?> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String fullName,
  }) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update user profile with display name
      await result.user?.updateDisplayName(fullName);
      await result.user?.reload();
      // Debug: log created user info
      try {
        print(
          'Auth: user created uid=${result.user?.uid} email=${result.user?.email}',
        );
      } catch (_) {}

      return result;
    } on FirebaseAuthException catch (e) {
      // Log exception for debugging
      print('Auth signUp error: code=${e.code} message=${e.message}');
      throw _handleAuthException(e);
    } catch (e) {
      throw 'An unexpected error occurred. Please try again.';
    }
  }

  // Sign in with email and password
  Future<UserCredential?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      // Debug: log signed-in user info
      try {
        print(
          'Auth: user signed in uid=${result.user?.uid} email=${result.user?.email}',
        );
      } catch (_) {}
      return result;
    } on FirebaseAuthException catch (e) {
      // Log exception for debugging
      print('Auth signIn error: code=${e.code} message=${e.message}');
      throw _handleAuthException(e);
    } catch (e) {
      throw 'An unexpected error occurred. Please try again.';
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw 'Error signing out. Please try again.';
    }
  }

  // Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'An unexpected error occurred. Please try again.';
    }
  }

  // Check if user exists with email
  Future<bool> checkUserExists(String email) async {
    try {
      return false;
    } catch (e) {
      print('Auth checkUserExists error for $email: $e');
      return false;
    }
  }

  // Handle Firebase Auth exceptions
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'The password provided is too weak.';
      case 'email-already-in-use':
        return 'An account already exists for this email.';
      case 'user-not-found':
        return 'No user found for this email. Please register first.';
      case 'wrong-password':
        return 'Wrong password provided.';
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'user-disabled':
        return 'This user account has been disabled.';
      case 'too-many-requests':
        return 'Too many unsuccessful attempts. Please try again later.';
      case 'operation-not-allowed':
        return 'Email/password accounts are not enabled.';
      case 'invalid-credential':
        return 'Invalid email or password. Please check your credentials.';
      default:
        return 'Authentication failed: ${e.message}';
    }
  }

  // Validate email format
  static bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  // Check if user is already registered
  Future<bool> isUserRegistered(String email) async {
    try {
      // Note: fetchSignInMethodsForEmail is deprecated in newer Firebase versions
      // Returning false as a safe default - user existence is better checked during sign-in/sign-up
      return false;
    } catch (e) {
      print('Auth isUserRegistered error for $email: $e');
      return false;
    }
  }

  // Validate password strength
  static String? validatePassword(String password) {
    if (password.length < 6) {
      return 'Password must be at least 6 characters long';
    }
    if (!password.contains(RegExp(r'[A-Z]'))) {
      return 'Password must contain at least one uppercase letter';
    }
    if (!password.contains(RegExp(r'[a-z]'))) {
      return 'Password must contain at least one lowercase letter';
    }
    if (!password.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain at least one number';
    }
    return null;
  }

  // Show authentication error dialog
  static void showAuthError(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Authentication Error'),
          content: Text(message),
          actions: [
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // Show success message
  static void showSuccessMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
*/
