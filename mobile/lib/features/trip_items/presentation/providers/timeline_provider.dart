import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/models/models.dart';
import '../../../../shared/services/timeline_service.dart';
import 'trip_items_provider.dart';

/// City filter state for trip timeline
/// Key is tripId, value is selected city (null means no filter)
final selectedCityFilterProvider = StateProvider.family<String?, String>(
  (ref, tripId) => null,
);

/// Timeline service provider
final timelineServiceProvider = Provider<TimelineService>((ref) {
  return const TimelineService();
});

/// Timeline for a trip - provides grouped days with layovers
/// 
/// This provider:
/// 1. Watches tripItemsProvider for the raw items
/// 2. Processes them through TimelineService
/// 3. Returns a list of TimelineDay objects for the UI
final timelineProvider = FutureProvider.family<List<TimelineDay>, String>(
  (ref, tripId) async {
    final items = await ref.watch(tripItemsProvider(tripId).future);
    final service = ref.watch(timelineServiceProvider);
    
    return service.buildTimeline(items);
  },
);

/// Get total layover duration for a trip
final totalLayoverProvider = FutureProvider.family<Duration, String>(
  (ref, tripId) async {
    final items = await ref.watch(tripItemsProvider(tripId).future);
    final service = ref.watch(timelineServiceProvider);
    
    return service.getTotalLayoverDuration(items);
  },
);

/// Formatted total layover string
final totalLayoverStringProvider = FutureProvider.family<String, String>(
  (ref, tripId) async {
    final duration = await ref.watch(totalLayoverProvider(tripId).future);
    
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    
    if (hours > 0 && minutes > 0) {
      return '${hours}h ${minutes}m total layover';
    } else if (hours > 0) {
      return '${hours}h total layover';
    } else if (minutes > 0) {
      return '${minutes}m total layover';
    } else {
      return 'No layovers';
    }
  },
);

/// Extract unique cities from trip items (transports, stays, activities)
/// Deduplicates case-insensitively and normalizes city names
final tripCitiesProvider = FutureProvider.family<List<String>, String>(
  (ref, tripId) async {
    final items = await ref.watch(tripItemsProvider(tripId).future);
    final citiesMap = <String, String>{}; // lowercase -> proper cased
    
    void addCity(String? city) {
      if (city == null || city.isEmpty) return;
      // Normalize: trim whitespace, normalize to title case
      final normalized = city.trim();
      final key = normalized.toLowerCase();
      // Keep the first (or most proper) casing we encounter
      if (!citiesMap.containsKey(key)) {
        // Title case: capitalize first letter of each word
        final titleCased = normalized.split(' ')
            .map((word) => word.isEmpty 
                ? word 
                : word[0].toUpperCase() + word.substring(1).toLowerCase())
            .join(' ');
        citiesMap[key] = titleCased;
      }
    }
    
    for (final item in items) {
      // Transport cities
      if (item.transportDetails != null) {
        addCity(item.transportDetails!.originCity);
        addCity(item.transportDetails!.destinationCity);
      }
      // Stay cities
      addCity(item.stayDetails?.city);
      // Activity cities
      addCity(item.activityDetails?.city);
    }
    
    return citiesMap.values.toList()..sort();
  },
);

/// Filtered trip items based on selected city
final filteredTripItemsProvider = FutureProvider.family<List<TripItem>, String>(
  (ref, tripId) async {
    final items = await ref.watch(tripItemsProvider(tripId).future);
    final selectedCity = ref.watch(selectedCityFilterProvider(tripId));

    if (selectedCity == null) return items;

    return items.where((item) {
      // Check transport origin/destination
      if (item.transportDetails != null) {
        if (item.transportDetails!.originCity == selectedCity ||
            item.transportDetails!.destinationCity == selectedCity) {
          return true;
        }
      }
      // Check stay city
      if (item.stayDetails?.city == selectedCity) {
        return true;
      }
      // Check activity city
      if (item.activityDetails?.city == selectedCity) {
        return true;
      }
      return false;
    }).toList();
  },
);
