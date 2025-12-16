import 'package:supabase_flutter/supabase_flutter.dart';

/// Supabase client singleton
/// 
/// INTEGRATION POINT FOR INTEGRATION AGENT:
/// This provides the Supabase client instance used throughout the app.
/// The client is initialized in main.dart and accessed via Supabase.instance.client
class SupabaseClientProvider {
  SupabaseClientProvider._();

  /// Get the Supabase client instance
  static SupabaseClient get client => Supabase.instance.client;

  /// Get the current authenticated user
  static User? get currentUser => client.auth.currentUser;

  /// Check if user is authenticated
  static bool get isAuthenticated => currentUser != null;

  /// Get the auth state change stream
  static Stream<AuthState> get authStateChanges => client.auth.onAuthStateChange;
}
