import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/presentation/providers/auth_provider.dart';
import '../features/auth/presentation/screens/forgot_password_screen.dart';
import '../features/auth/presentation/screens/sign_in_screen.dart';
import '../features/auth/presentation/screens/sign_up_screen.dart';
import '../features/auth/presentation/screens/splash_screen.dart';
import '../features/documents/presentation/screens/document_viewer_screen.dart';
import '../features/documents/presentation/screens/global_documents_screen.dart';
import '../features/profile/presentation/screens/profile_screen.dart';
import '../features/profile/presentation/screens/profile_edit_screen.dart';
import '../features/trip_items/presentation/screens/activity_detail_screen.dart';
import '../features/trip_items/presentation/screens/forms/activity_form_screen.dart';
import '../features/trip_items/presentation/screens/forms/note_form_screen.dart';
import '../features/trip_items/presentation/screens/forms/stay_form_screen.dart';
import '../features/trip_items/presentation/screens/forms/transport_form_screen.dart';
import '../features/trip_items/presentation/screens/note_detail_screen.dart';
import '../features/trip_items/presentation/screens/stay_detail_screen.dart';
import '../features/trip_items/presentation/screens/transport_detail_screen.dart';
import '../features/trips/presentation/screens/trip_form_screen.dart';
import '../features/trips/presentation/screens/trip_list_screen.dart';
import '../features/trips/presentation/screens/trip_overview_screen.dart';
import '../features/trips/presentation/screens/today_view_screen.dart';
import '../features/checklists/presentation/screens/checklist_screen.dart';
import '../features/checklists/presentation/screens/global_checklist_templates_screen.dart';
import '../features/travellers/presentation/screens/travellers_list_screen.dart';
import '../features/travellers/presentation/screens/traveller_form_screen.dart';
import '../features/landing/presentation/screens/landing_page.dart';

/// Router configuration provider
final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: true,
    redirect: (context, state) {
      final isLoggedIn = authState.valueOrNull != null;
      final isAuthRoute = state.matchedLocation.startsWith('/auth');
      final isSplash = state.matchedLocation == '/';
      final isLanding = state.matchedLocation == '/landing';

      // Allow splash to handle its own redirect
      if (isSplash) return null;

      // Allow landing page for everyone
      if (isLanding) return null;

      // If not logged in and not on auth route or landing, redirect to landing
      if (!isLoggedIn && !isAuthRoute) {
        return '/landing';
      }

      // If logged in and on auth route, redirect to trips
      if (isLoggedIn && isAuthRoute) {
        return '/trips';
      }

      return null;
    },
    routes: [
      // Splash screen
      GoRoute(
        path: '/',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),

      // Landing page (pre-auth)
      GoRoute(
        path: '/landing',
        name: 'landing',
        builder: (context, state) => const LandingPage(),
      ),

      // Auth routes
      GoRoute(
        path: '/auth/signin',
        name: 'signin',
        builder: (context, state) => const SignInScreen(),
      ),
      GoRoute(
        path: '/auth/signup',
        name: 'signup',
        builder: (context, state) => const SignUpScreen(),
      ),
      GoRoute(
        path: '/auth/forgot',
        name: 'forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),

      // Today view route
      GoRoute(
        path: '/today',
        name: 'today',
        builder: (context, state) => const TodayViewScreen(),
      ),

      // Trip routes
      GoRoute(
        path: '/trips',
        name: 'trips',
        builder: (context, state) => const TripListScreen(),
      ),
      GoRoute(
        path: '/trips/new',
        name: 'trip-new',
        builder: (context, state) => const TripFormScreen(isEdit: false),
      ),
      GoRoute(
        path: '/trips/:tripId',
        name: 'trip-overview',
        builder: (context, state) {
          final tripId = state.pathParameters['tripId']!;
          return TripOverviewScreen(tripId: tripId);
        },
      ),
      GoRoute(
        path: '/trips/:tripId/edit',
        name: 'trip-edit',
        builder: (context, state) {
          final tripId = state.pathParameters['tripId']!;
          return TripFormScreen(isEdit: true, tripId: tripId);
        },
      ),
      GoRoute(
        path: '/trips/:tripId/checklist',
        name: 'trip-checklist',
        builder: (context, state) {
          final tripId = state.pathParameters['tripId']!;
          return ChecklistScreen(tripId: tripId);
        },
      ),

      // Trip item detail routes
      GoRoute(
        path: '/trips/:tripId/items/:itemId/transport',
        name: 'transport-detail',
        builder: (context, state) {
          final tripId = state.pathParameters['tripId']!;
          final itemId = state.pathParameters['itemId']!;
          return TransportDetailScreen(tripId: tripId, itemId: itemId);
        },
      ),
      GoRoute(
        path: '/trips/:tripId/items/:itemId/stay',
        name: 'stay-detail',
        builder: (context, state) {
          final tripId = state.pathParameters['tripId']!;
          final itemId = state.pathParameters['itemId']!;
          return StayDetailScreen(tripId: tripId, itemId: itemId);
        },
      ),
      GoRoute(
        path: '/trips/:tripId/items/:itemId/activity',
        name: 'activity-detail',
        builder: (context, state) {
          final tripId = state.pathParameters['tripId']!;
          final itemId = state.pathParameters['itemId']!;
          return ActivityDetailScreen(tripId: tripId, itemId: itemId);
        },
      ),
      GoRoute(
        path: '/trips/:tripId/items/:itemId/note',
        name: 'note-detail',
        builder: (context, state) {
          final tripId = state.pathParameters['tripId']!;
          final itemId = state.pathParameters['itemId']!;
          return NoteDetailScreen(tripId: tripId, itemId: itemId);
        },
      ),

      // Trip item form routes
      GoRoute(
        path: '/trips/:tripId/items/transport/new',
        name: 'transport-new',
        builder: (context, state) {
          final tripId = state.pathParameters['tripId']!;
          return TransportFormScreen(tripId: tripId);
        },
      ),
      GoRoute(
        path: '/trips/:tripId/items/transport/:itemId/edit',
        name: 'transport-edit',
        builder: (context, state) {
          final tripId = state.pathParameters['tripId']!;
          final itemId = state.pathParameters['itemId']!;
          return TransportFormScreen(tripId: tripId, itemId: itemId);
        },
      ),
      GoRoute(
        path: '/trips/:tripId/items/stay/new',
        name: 'stay-new',
        builder: (context, state) {
          final tripId = state.pathParameters['tripId']!;
          return StayFormScreen(tripId: tripId);
        },
      ),
      GoRoute(
        path: '/trips/:tripId/items/stay/:itemId/edit',
        name: 'stay-edit',
        builder: (context, state) {
          final tripId = state.pathParameters['tripId']!;
          final itemId = state.pathParameters['itemId']!;
          return StayFormScreen(tripId: tripId, itemId: itemId);
        },
      ),
      GoRoute(
        path: '/trips/:tripId/items/activity/new',
        name: 'activity-new',
        builder: (context, state) {
          final tripId = state.pathParameters['tripId']!;
          return ActivityFormScreen(tripId: tripId);
        },
      ),
      GoRoute(
        path: '/trips/:tripId/items/activity/:itemId/edit',
        name: 'activity-edit',
        builder: (context, state) {
          final tripId = state.pathParameters['tripId']!;
          final itemId = state.pathParameters['itemId']!;
          return ActivityFormScreen(tripId: tripId, itemId: itemId);
        },
      ),
      GoRoute(
        path: '/trips/:tripId/items/note/new',
        name: 'note-new',
        builder: (context, state) {
          final tripId = state.pathParameters['tripId']!;
          return NoteFormScreen(tripId: tripId);
        },
      ),
      GoRoute(
        path: '/trips/:tripId/items/note/:itemId/edit',
        name: 'note-edit',
        builder: (context, state) {
          final tripId = state.pathParameters['tripId']!;
          final itemId = state.pathParameters['itemId']!;
          return NoteFormScreen(tripId: tripId, itemId: itemId);
        },
      ),

      // Document route
      GoRoute(
        path: '/documents/:docId',
        name: 'document-viewer',
        builder: (context, state) {
          final docId = state.pathParameters['docId']!;
          return DocumentViewerScreen(docId: docId);
        },
      ),

      // Profile route
      // Travellers routes
      GoRoute(
        path: '/travellers',
        name: 'travellers',
        builder: (context, state) => const TravellersListScreen(),
      ),
      GoRoute(
        path: '/travellers/new',
        name: 'traveller-new',
        builder: (context, state) => const TravellerFormScreen(),
      ),
      GoRoute(
        path: '/travellers/:travellerId',
        name: 'traveller-detail',
        builder: (context, state) {
          final travellerId = state.pathParameters['travellerId']!;
          return TravellerFormScreen(travellerId: travellerId);
        },
      ),

      // Profile
      GoRoute(
        path: '/profile',
        name: 'profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/profile/edit',
        name: 'profile-edit',
        builder: (context, state) => const ProfileEditScreen(),
      ),
      GoRoute(
        path: '/global-documents',
        name: 'global-documents',
        builder: (context, state) => const GlobalDocumentsScreen(),
      ),
      GoRoute(
        path: '/checklist-templates',
        name: 'checklist-templates',
        builder: (context, state) => const GlobalChecklistTemplatesScreen(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              'Page not found',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              state.error?.message ?? 'Unknown error',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go('/'),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    ),
  );
});
