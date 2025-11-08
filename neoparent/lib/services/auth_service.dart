import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';
import '../config/api_config.dart';

class AuthService {
  UserModel? _currentUser;
  String? _accessToken;

  UserModel? get currentUser => _currentUser;
  String? get accessToken => _accessToken;

  Stream<UserModel?> get authStateChanges async* {
    yield _currentUser;
  }

  /// Sign up with email and password - connects to MongoDB backend
  /// Returns user data but does NOT auto-login
  Future<UserModel> signUpWithEmailAndPassword({
    required String username,
    required String email,
    required String password,
    required String fullName,
    String? phoneNumber,
    String? address,
  }) async {
    if (!isValidEmail(email)) {
      throw AuthException('Invalid email address');
    }

    if (username.isEmpty || username.length < 3) {
      throw AuthException('Username must be at least 3 characters');
    }

    final passwordError = validatePassword(password);
    if (passwordError != null) {
      throw AuthException(passwordError);
    }

    try {
      // Split fullName into first and last name
      final nameParts = fullName.trim().split(' ');
      final firstName = nameParts.isNotEmpty ? nameParts[0] : fullName;
      final lastName = nameParts.length > 1
          ? nameParts.sublist(1).join(' ')
          : '';

      print('🚀 Attempting registration...');
      print('   URL: ${ApiConfig.registerUrl}');
      print('   Username: $username');
      print('   Email: $email');

      final response = await http
          .post(
            Uri.parse(ApiConfig.registerUrl),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'username': username,
              'first_name': firstName,
              'last_name': lastName,
              'email': email,
              'telephone': phoneNumber ?? '',
              'address': address ?? '',
              'password': password,
            }),
          )
          .timeout(ApiConfig.requestTimeout);

      print('📩 Registration response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final user = UserModel.fromJson(data);
        // Don't set _currentUser - user must login after registration
        return user;
      } else {
        final error = jsonDecode(response.body);
        throw AuthException(error['detail'] ?? 'Registration failed');
      }
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException('Registration failed: ${e.toString()}');
    }
  }

  /// Sign in with email/username and password - connects to MongoDB backend
  Future<UserModel> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      print('🔐 Attempting login...');
      print('   URL: ${ApiConfig.loginUrl}');
      print('   Email/Username: $email');

      // The backend accepts username or email in the username field
      final response = await http
          .post(
            Uri.parse(ApiConfig.loginUrl),
            headers: {'Content-Type': 'application/x-www-form-urlencoded'},
            body: {
              'username': email, // Can be email or username
              'password': password,
            },
          )
          .timeout(ApiConfig.requestTimeout);

      print('📩 Login response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _accessToken = data['access_token'];

        // Fetch user details using the token
        final userResponse = await http
            .get(
              Uri.parse(ApiConfig.usersMeUrl),
              headers: {'Authorization': 'Bearer $_accessToken'},
            )
            .timeout(ApiConfig.requestTimeout);

        if (userResponse.statusCode == 200) {
          final userData = jsonDecode(userResponse.body);
          _currentUser = UserModel.fromJson(userData);
          return _currentUser!;
        } else {
          throw AuthException('Failed to fetch user details');
        }
      } else {
        final error = jsonDecode(response.body);
        throw AuthException(error['detail'] ?? 'Login failed');
      }
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException('Login failed: ${e.toString()}');
    }
  }

  Future<void> signOut() async {
    _currentUser = null;
    _accessToken = null;
  }

  Future<void> sendPasswordResetEmail(String email) async {
    if (!isValidEmail(email)) {
      throw AuthException('Invalid email address');
    }
    // Password reset not implemented in backend yet
    throw AuthException('Password reset not available yet');
  }

  /// Check if user exists - not available in current backend
  Future<bool> checkUserExists(String email) async {
    // This endpoint doesn't exist in the backend, so we'll skip this check
    return false;
  }

  static bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  static String? validatePassword(String password) {
    if (password.isEmpty) {
      return 'Password is required';
    }
    if (password.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }
}

class AuthException implements Exception {
  final String message;

  AuthException(this.message);

  @override
  String toString() => message;
}
