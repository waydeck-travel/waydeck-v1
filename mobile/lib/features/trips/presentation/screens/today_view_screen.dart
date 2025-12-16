import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/ui/ui.dart';
import '../widgets/today_view.dart';

/// Today View Screen - wrapper that loads active trip and shows TodayView
class TodayViewScreen extends ConsumerWidget {
  const TodayViewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeTripAsync = ref.watch(activeTripProvider);

    return activeTripAsync.when(
      loading: () => const Scaffold(
        body: LoadingIndicator(message: 'Loading...'),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(title: const Text('Today')),
        body: Center(child: Text('Error: $e')),
      ),
      data: (activeTrip) {
        if (activeTrip == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Today')),
            body: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('🌴', style: TextStyle(fontSize: 64)),
                  SizedBox(height: 16),
                  Text('No active trips'),
                  SizedBox(height: 8),
                  Text('Start a trip to see your daily itinerary'),
                ],
              ),
            ),
          );
        }

        return TodayView(
          trip: activeTrip,
          date: DateTime.now(),
        );
      },
    );
  }
}
