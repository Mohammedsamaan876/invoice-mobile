import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Configuration layer for Supabase integration.
///
/// Uses client-safe public anonymous credentials only.
/// NEVER store or expose service-role secret keys here.
class SupabaseConfig {
  SupabaseConfig._();

  /// Supabase project URL (overridable via --dart-define=SUPABASE_URL=...)
  static const String url = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://chtcrxmsrnceffkfufhe.supabase.co',
  );

  /// Supabase public Anon/Publishable Key (overridable via --dart-define=SUPABASE_ANON_KEY=...)
  static const String anonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImNodGNyeG1zcm5jZWZma2Z1ZmhlIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODkyMDM1NTMsImV4cCI6MjEwNDc3OTU1M30.YFIxzln1NQoMcLBCvAWRVHYmakmOzbjz7qGsy3_R-t8',
  );

  /// Check whether Supabase has been initialized in the current runtime
  static bool get isInitialized {
    try {
      return Supabase.instance.isInitialized;
    } catch (_) {
      return false;
    }
  }

  /// Safe accessor for SupabaseClient, returning null if not yet initialized
  /// (e.g. during headless unit/widget tests)
  static SupabaseClient? get client {
    if (!isInitialized) return null;
    try {
      return Supabase.instance.client;
    } catch (_) {
      return null;
    }
  }

  /// Initialize Supabase on application startup
  static Future<void> initialize() async {
    if (isInitialized) return;
    try {
      await Supabase.initialize(
        url: url,
        // ignore: deprecated_member_use
        anonKey: anonKey,
        // ignore: deprecated_member_use
        authOptions: const FlutterAuthClientOptions(
          authFlowType: AuthFlowType.pkce,
        ),
        debug: kDebugMode,
      );
    } catch (e) {
      debugPrint('Supabase initialization error: $e');
    }
  }
}
