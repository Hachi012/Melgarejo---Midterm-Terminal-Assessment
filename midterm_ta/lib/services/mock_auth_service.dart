import '../models/app_user.dart';

// Mock user database for demo/testing
class MockAuthService {
  static final Map<String, _MockUser> _users = {};
  static _MockUser? _currentUser;

  static Future<void> initialize() async {
    // Add demo users
    _users['demo@example.com'] = _MockUser(
      id: 'user_1',
      email: 'demo@example.com',
      password: 'password123',
      displayName: 'Demo User',
      createdAt: DateTime.now(),
    );
    _users['test@example.com'] = _MockUser(
      id: 'user_2',
      email: 'test@example.com',
      password: 'test123',
      displayName: 'Test User',
      createdAt: DateTime.now(),
    );
  }

  static Future<MockAuthResult> register({
    required String email,
    required String password,
    required String displayName,
  }) async {
    if (_users.containsKey(email)) {
      return MockAuthResult(
        success: false,
        message: 'The account already exists for that email.',
      );
    }

    if (password.length < 6) {
      return MockAuthResult(
        success: false,
        message: 'The password provided is too weak.',
      );
    }

    final newUser = _MockUser(
      id: 'user_${DateTime.now().millisecondsSinceEpoch}',
      email: email,
      password: password,
      displayName: displayName,
      createdAt: DateTime.now(),
    );

    _users[email] = newUser;
    _currentUser = newUser;

    return MockAuthResult(
      success: true,
      message: 'Registration successful',
      user: AppUser(
        id: newUser.id,
        email: newUser.email,
        displayName: newUser.displayName,
        createdAt: newUser.createdAt,
      ),
    );
  }

  static Future<MockAuthResult> login({
    required String email,
    required String password,
  }) async {
    if (!_users.containsKey(email)) {
      return MockAuthResult(
        success: false,
        message: 'No user found for that email.',
      );
    }

    final user = _users[email]!;
    if (user.password != password) {
      return MockAuthResult(
        success: false,
        message: 'Wrong password provided for that user.',
      );
    }

    _currentUser = user;

    return MockAuthResult(
      success: true,
      message: 'Login successful',
      user: AppUser(
        id: user.id,
        email: user.email,
        displayName: user.displayName,
        createdAt: user.createdAt,
      ),
    );
  }

  static Future<void> logout() async {
    _currentUser = null;
  }

  static AppUser? getCurrentUser() {
    if (_currentUser == null) return null;
    return AppUser(
      id: _currentUser!.id,
      email: _currentUser!.email,
      displayName: _currentUser!.displayName,
      createdAt: _currentUser!.createdAt,
    );
  }

  static bool isAuthenticated() {
    return _currentUser != null;
  }
}

class _MockUser {
  final String id;
  final String email;
  final String password;
  final String displayName;
  final DateTime createdAt;

  _MockUser({
    required this.id,
    required this.email,
    required this.password,
    required this.displayName,
    required this.createdAt,
  });
}

class MockAuthResult {
  final bool success;
  final String message;
  final AppUser? user;

  MockAuthResult({required this.success, required this.message, this.user});
}
