import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import 'app/app.dart';
import 'app/flavor.dart';
import 'core/env/env.dart';
import 'shared/services/notification_service.dart';

/// Bootstrap function to initialize the app with a specific flavor
Future<void> bootstrap(AppFlavor flavor) async {
  currentFlavor = flavor;

  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();

    // Load environment variables based on flavor
    // In a real scenario, you might have .env.prod and .env.dev
    // For now, we'll default to .env, but allow overriding if needed
    final envFile = flavor == AppFlavor.prod ? '.env' : '.env'; 
    await dotenv.load(fileName: envFile);

    // Initialize Supabase
    await Supabase.initialize(
      url: Env.supabaseUrl,
      anonKey: Env.supabaseAnonKey,
    );

    // Initialize notification service
    await notificationService.initialize();

    await SentryFlutter.init(
      (options) {
        options.dsn = const String.fromEnvironment('SENTRY_DSN');
        options.tracesSampleRate = 1.0;
        options.environment = flavor.name;
      },
      appRunner: () => runApp(
        const ProviderScope(
          child: WaydeckApp(),
        ),
      ),
    );
  }, (exception, stackTrace) async {
    await Sentry.captureException(exception, stackTrace: stackTrace);
  });
}
