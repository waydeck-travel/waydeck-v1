import 'package:supabase_flutter/supabase_flutter.dart';

/// Auth Repository
/// 
/// INTEGRATION POINT FOR INTEGRATION AGENT:
/// This repository handles all Supabase auth operations.
/// The implementation is complete but the Integration Agent may need to 
/// add error handling or additional features.
class AuthRepository {
  final SupabaseClient _client;

  AuthRepository({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  /// Get current user
  User? get currentUser => _client.auth.currentUser;

  /// Check if user is authenticated
  bool get isAuthenticated => currentUser != null;

  /// Listen to auth state changes
  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  /// Sign in with email and password
  /// 
  /// Returns [AuthResponse] on success, throws [AuthException] on failure
  Future<AuthResponse> signInWithPassword({
    required String email,
    required String password,
  }) async {
    return await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  /// Sign up with email and password
  /// 
  /// Returns [AuthResponse] on success, throws [AuthException] on failure
  Future<AuthResponse> signUp({
    required String email,
    required String password,
  }) async {
    return await _client.auth.signUp(
      email: email,
      password: password,
    );
  }

  /// Sign out current user
  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  /// Send password reset email
  /// 
  /// Returns void on success, throws [AuthException] on failure
  Future<void> resetPasswordForEmail(String email) async {
    await _client.auth.resetPasswordForEmail(email);
  }

  /// Update user password (when user is logged in)
  Future<UserResponse> updatePassword(String newPassword) async {
    return await _client.auth.updateUser(
      UserAttributes(password: newPassword),
    );
  }
}
