import '../models/user_model.dart';

class AuthService {
  UserModel? _currentUser;
  final List<Map<String, String>> _registeredUsers = [];

  UserModel? get currentUser => _currentUser;

  Stream<UserModel?> get authStateChanges async* {
    yield _currentUser;
  }

  Future<UserModel> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String fullName,
  }) async {
    if (!isValidEmail(email)) {
      throw AuthException('Invalid email address');
    }

    final passwordError = validatePassword(password);
    if (passwordError != null) {
      throw AuthException(passwordError);
    }

    if (_registeredUsers.any((user) => user['email'] == email)) {
      throw AuthException('An account already exists with this email');
    }

    _registeredUsers.add({
      'email': email,
      'password': password,
      'fullName': fullName,
    });

    final user = UserModel(
      uid: DateTime.now().millisecondsSinceEpoch.toString(),
      email: email,
      displayName: fullName,
      photoUrl: null,
    );

    _currentUser = user;
    return user;
  }

  Future<UserModel> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final user = UserModel(
      uid: DateTime.now().millisecondsSinceEpoch.toString(),
      email: email,
      displayName: email.split('@')[0],
      photoUrl: null,
    );

    _currentUser = user;
    return user;
  }

  Future<void> signOut() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _currentUser = null;
  }

  Future<void> sendPasswordResetEmail(String email) async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (!isValidEmail(email)) {
      throw AuthException('Invalid email address');
    }
  }

  Future<bool> checkUserExists(String email) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _registeredUsers.any((user) => user['email'] == email);
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
