import 'package:flutter/foundation.dart';
import '../services/mock_auth_service.dart';
import '../models/app_user.dart';

class AuthProvider extends ChangeNotifier {
  AppUser? _currentUser;
  bool _isLoading = false;
  String _errorMessage = '';
  bool _usesMockAuth = false;

  AppUser? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  bool get isAuthenticated => _currentUser != null;
  bool get usesMockAuth => _usesMockAuth;

  AuthProvider() {
    // Default to mock auth to avoid Firebase config issues
    _usesMockAuth = true;
    _initializeAuth();
  }

  Future<void> _initializeAuth() async {
    try {
      // Always initialize MockAuthService as a fallback
      await MockAuthService.initialize();
      notifyListeners();
    } catch (e) {
      // MockAuthService initialization failed
      notifyListeners();
    }
  }

  Future<bool> register({
    required String email,
    required String password,
    required String displayName,
  }) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      // Ensure MockAuthService is initialized
      await MockAuthService.initialize();

      final result = await MockAuthService.register(
        email: email,
        password: password,
        displayName: displayName,
      );

      if (result.success) {
        _currentUser = result.user;
        _isLoading = false;
        _errorMessage = '';
        notifyListeners();
        return true;
      } else {
        // Registration failed
        _errorMessage = result.message;
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Error: ${e.runtimeType}: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> login({required String email, required String password}) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      // Ensure MockAuthService is initialized
      await MockAuthService.initialize();

      final result = await MockAuthService.login(
        email: email,
        password: password,
      );

      if (result.success) {
        _currentUser = result.user;
        _isLoading = false;
        _errorMessage = '';
        notifyListeners();
        return true;
      } else {
        // Authentication failed
        _errorMessage = result.message;
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Error: ${e.runtimeType}: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      await MockAuthService.logout();
      _currentUser = null;
      _errorMessage = '';
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Logout error: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = '';
    notifyListeners();
  }
}
