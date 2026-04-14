import 'package:firebase_auth/firebase_auth.dart';
import '../models/app_user.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  FirebaseAuth? _firebaseAuth;
  User? _currentUser;
  bool _isInitialized = false;

  FirebaseAuth get firebaseAuth {
    try {
      _firebaseAuth ??= FirebaseAuth.instance;
      return _firebaseAuth!;
    } catch (e) {
      // Firebase not initialized - rethrow
      rethrow;
    }
  }

  factory AuthService() {
    return _instance;
  }

  AuthService._internal();

  User? get currentUser => _currentUser;
  bool get isInitialized => _isInitialized;

  // Initialize Firebase (call this once at app startup)
  Future<void> initializeFirebase() async {
    try {
      // Check if Firebase is already initialized
      if (!_isInitialized) {
        // Firebase should already be initialized in main()
        // Just verify that it's ready and get the current user
        _currentUser = firebaseAuth.currentUser;
        _isInitialized = true;
      }
    } catch (e) {
      // Firebase initialization failed - will use mock auth
      _isInitialized = false;
      rethrow;
    }
  }

  // Register with email and password
  Future<AuthResult> register({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      final UserCredential userCredential = await firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password);

      // Update display name
      await userCredential.user?.updateDisplayName(displayName);
      await userCredential.user?.reload();

      _currentUser = userCredential.user;

      return AuthResult(
        success: true,
        message: 'Registration successful',
        user: _userToAppUser(userCredential.user),
      );
    } on FirebaseAuthException catch (e) {
      return AuthResult(success: false, message: _getErrorMessage(e.code));
    }
  }

  // Login with email and password
  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    try {
      final UserCredential userCredential = await firebaseAuth
          .signInWithEmailAndPassword(email: email, password: password);

      _currentUser = userCredential.user;

      return AuthResult(
        success: true,
        message: 'Login successful',
        user: _userToAppUser(userCredential.user),
      );
    } on FirebaseAuthException catch (e) {
      return AuthResult(success: false, message: _getErrorMessage(e.code));
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      await firebaseAuth.signOut();
      _currentUser = null;
    } catch (e) {
      // Error logging out - continue anyway
    }
  }

  // Check if user is authenticated
  bool isAuthenticated() {
    return _currentUser != null;
  }

  // Get current user stream
  Stream<User?> get authStateChanges => firebaseAuth.authStateChanges();

  // Public converter from Firebase User to AppUser
  AppUser? firebaseAuthToAppUser(User? firebaseUser) {
    return _userToAppUser(firebaseUser);
  }

  AppUser? _userToAppUser(User? firebaseUser) {
    if (firebaseUser == null) return null;
    return AppUser(
      id: firebaseUser.uid,
      email: firebaseUser.email ?? '',
      displayName: firebaseUser.displayName ?? 'User',
      createdAt: firebaseUser.metadata.creationTime ?? DateTime.now(),
    );
  }

  String _getErrorMessage(String code) {
    switch (code) {
      case 'weak-password':
        return 'The password provided is too weak.';
      case 'email-already-in-use':
        return 'The account already exists for that email.';
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'user-not-found':
        return 'No user found for that email.';
      case 'wrong-password':
        return 'Wrong password provided for that user.';
      case 'user-disabled':
        return 'User account has been disabled.';
      case 'too-many-requests':
        return 'Too many login attempts. Try again later.';
      default:
        return 'An authentication error occurred';
    }
  }
}

class AuthResult {
  final bool success;
  final String message;
  final AppUser? user;

  AuthResult({required this.success, required this.message, this.user});
}
