import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme.dart';
import '../../../../shared/models/models.dart';
import '../../../../shared/ui/ui.dart';
import '../providers/trips_provider.dart';
import '../../../trips/widgets/trip_card.dart';
import '../widgets/today_view.dart';

/// Trip List Screen - Main screen after login
class TripListScreen extends ConsumerWidget {
  const TripListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tripsAsync = ref.watch(tripsListProvider);
    final activeTripAsync = ref.watch(activeTripProvider);

    return Scaffold(
      backgroundColor: WaydeckTheme.background,
      appBar: AppBar(
        title: const Text('My Trips'),
        centerTitle: false,
        actions: [
          // Today button if active trip exists
          activeTripAsync.when(
            loading: () => const SizedBox(),
            error: (_, __) => const SizedBox(),
            data: (activeTrip) => activeTrip != null
                ? IconButton(
                    icon: const Icon(Icons.today),
                    onPressed: () => context.push('/today'),
                    tooltip: 'Today\'s Itinerary',
                  )
                : const SizedBox(),
          ),
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () => context.push('/profile'),
            tooltip: 'Profile',
          ),
        ],
      ),
      body: tripsAsync.when(
        loading: () => const LoadingIndicator(message: 'Loading trips...'),
        error: (error, stack) => _buildErrorState(context, ref, error),
        data: (trips) {
          if (trips.isEmpty) {
            return _buildEmptyState(context);
          }
          
          // Check for active trip and show banner
          return activeTripAsync.when(
            loading: () => _buildTripsList(context, ref, trips, null),
            error: (_, __) => _buildTripsList(context, ref, trips, null),
            data: (activeTrip) => _buildTripsList(context, ref, trips, activeTrip),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/trips/new'),
        icon: const Icon(Icons.add),
        label: const Text('New Trip'),
        backgroundColor: WaydeckTheme.primary,
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Large illustrated icon
            Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    WaydeckTheme.primary.withValues(alpha: 0.1),
                    WaydeckTheme.secondary.withValues(alpha: 0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(32),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned(
                    top: 20,
                    right: 25,
                    child: Text('✈️', style: TextStyle(fontSize: 32, color: WaydeckTheme.primary.withValues(alpha: 0.5))),
                  ),
                  const Text('🌍', style: TextStyle(fontSize: 64)),
                  Positioned(
                    bottom: 20,
                    left: 25,
                    child: Text('🏖️', style: TextStyle(fontSize: 28, color: WaydeckTheme.activityColor.withValues(alpha: 0.5))),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            
            // Engaging headline
            Text(
              'Your next adventure awaits',
              style: WaydeckTheme.heading2.copyWith(
                color: WaydeckTheme.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            
            // Supportive description
            Text(
              'Create your first trip and start organizing\nflights, hotels, and activities in one place.',
              style: WaydeckTheme.bodyMedium.copyWith(
                color: WaydeckTheme.textSecondary,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            
            // Single clear CTA
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => context.push('/trips/new'),
                icon: const Icon(Icons.add_circle_outline),
                label: const Text('Create Your First Trip'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: WaydeckTheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  textStyle: WaydeckTheme.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 48),
            
            // Feature hints
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildFeatureHint('✈️', 'Flights'),
                _buildFeatureHint('🏨', 'Hotels'),
                _buildFeatureHint('📍', 'Activities'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureHint(String emoji, String label) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: WaydeckTheme.surfaceVariant,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(emoji, style: const TextStyle(fontSize: 24)),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: WaydeckTheme.caption.copyWith(
            color: WaydeckTheme.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState(BuildContext context, WidgetRef ref, Object error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: WaydeckTheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load trips',
              style: WaydeckTheme.heading3,
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              style: WaydeckTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            WaydeckButton(
              onPressed: () => ref.invalidate(tripsListProvider),
              isOutlined: true,
              width: 150,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTripsList(
    BuildContext context,
    WidgetRef ref,
    List<Trip> trips,
    Trip? activeTrip,
  ) {
    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(tripsListProvider);
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: trips.length + (activeTrip != null ? 1 : 0),
        itemBuilder: (context, index) {
          // Show Today banner at the top if active trip exists
          if (activeTrip != null && index == 0) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Card(
                color: WaydeckTheme.primary.withValues(alpha: 0.1),
                child: InkWell(
                  onTap: () => context.push('/today'),
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: WaydeckTheme.primary,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.today, color: Colors.white, size: 24),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '📍 Today\'s Itinerary',
                                style: WaydeckTheme.heading3,
                              ),
                              Text(
                                'View your schedule for ${activeTrip.name}',
                                style: WaydeckTheme.bodySmall.copyWith(color: WaydeckTheme.textSecondary),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_right),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }
          
          final tripIndex = activeTrip != null ? index - 1 : index;
          final trip = trips[tripIndex];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: TripCard(
              trip: trip,
              onTap: () => context.push('/trips/${trip.id}'),
              onEdit: () => context.push('/trips/${trip.id}/edit'),
              onArchive: () => _showArchiveDialog(context, ref, trip),
              onDelete: () => _showDeleteDialog(context, ref, trip),
            ),
          );
        },
      ),
    );
  }

  void _showArchiveDialog(BuildContext context, WidgetRef ref, Trip trip) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Archive Trip'),
        content: Text('Archive "${trip.name}"? You can find it later in archived trips.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await ref.read(tripActionsProvider.notifier).archiveTrip(trip.id);
            },
            child: const Text('Archive'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref, Trip trip) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Trip'),
        content: Text(
          'Delete "${trip.name}"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await ref.read(tripActionsProvider.notifier).deleteTrip(trip.id);
            },
            style: TextButton.styleFrom(foregroundColor: WaydeckTheme.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
