import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme.dart';
import '../providers/auth_provider.dart';

/// Splash screen with auth check
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    // Wait a moment to show the splash
    await Future.delayed(const Duration(milliseconds: 1500));

    if (!mounted) return;

    final user = ref.read(currentUserProvider);
    if (user != null) {
      context.go('/trips');
    } else {
      context.go('/auth/signin');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WaydeckTheme.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo placeholder
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: WaydeckTheme.primary,
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Center(
                child: Text(
                  '✈️',
                  style: TextStyle(fontSize: 48),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Waydeck',
              style: WaydeckTheme.heading1.copyWith(
                color: WaydeckTheme.primary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your travel companion',
              style: WaydeckTheme.bodyMedium.copyWith(
                color: WaydeckTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 48),
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(WaydeckTheme.primary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
