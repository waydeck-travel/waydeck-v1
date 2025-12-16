import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Environment configuration
/// Loads values from .env file
class Env {
  // Support both Build-time (CI/CD) and Runtime (.env) configuration
  static String get supabaseUrl {
    const fromEnv = String.fromEnvironment('SUPABASE_URL');
    if (fromEnv.isNotEmpty) return fromEnv;
    return dotenv.env['SUPABASE_URL'] ?? '';
  }

  static String get supabaseAnonKey {
    const fromEnv = String.fromEnvironment('SUPABASE_ANON_KEY');
    if (fromEnv.isNotEmpty) return fromEnv;
    return dotenv.env['SUPABASE_ANON_KEY'] ?? '';
  }

  static String get googlePlacesApiKey {
    const fromEnv = String.fromEnvironment('GOOGLE_PLACES_API_KEY');
    if (fromEnv.isNotEmpty) return fromEnv;
    return dotenv.env['GOOGLE_PLACES_API_KEY'] ?? '';
  }
}
