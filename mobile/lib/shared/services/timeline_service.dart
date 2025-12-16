import '../models/models.dart';

/// Service for processing trip items into a grouped timeline with layovers
class TimelineService {
  const TimelineService();

  /// Build a complete timeline from a list of trip items
  /// 
  /// This method:
  /// 1. Sorts items by start_time_utc, day_index, sort_index
  /// 2. Groups items by local date (using localTz)
  /// 3. Inserts layover entries between consecutive compatible transport items
  List<TimelineDay> buildTimeline(List<TripItem> items) {
    if (items.isEmpty) return [];

    // Sort items
    final sortedItems = List<TripItem>.from(items)
      ..sort(_compareItems);

    // Group by day and insert layovers
    final Map<DateTime, List<TimelineEntry>> dayGroups = {};
    
    for (int i = 0; i < sortedItems.length; i++) {
      final item = sortedItems[i];
      final dayKey = _getDayKey(item);
      
      dayGroups.putIfAbsent(dayKey, () => []);
      
      // Check for layover with previous item
      if (i > 0) {
        final prevItem = sortedItems[i - 1];
        final layover = computeLayover(prevItem, item);
        
        if (layover != null) {
          // Add layover to the appropriate day
          final layoverDayKey = _getDayKey(prevItem); // Layover starts after prev item
          dayGroups.putIfAbsent(layoverDayKey, () => []);
          dayGroups[layoverDayKey]!.add(layover);
        }
      }
      
      // Add the item
      dayGroups[dayKey]!.add(TripItemEntry(
        item: item,
        hasDocuments: item.documentCount > 0,
      ));
    }

    // Sort entries within each day
    for (final entries in dayGroups.values) {
      entries.sort((a, b) => a.sortTime.compareTo(b.sortTime));
    }

    // Convert to sorted list of TimelineDay
    final sortedDays = dayGroups.keys.toList()..sort();
    
    return sortedDays.map((date) {
      return TimelineDay(
        date: date,
        dateLabel: TimelineDay.formatDateLabel(date),
        entries: dayGroups[date]!,
      );
    }).toList();
  }

  /// Compare two trip items for sorting
  int _compareItems(TripItem a, TripItem b) {
    // First by day_index if available
    if (a.dayIndex != null && b.dayIndex != null) {
      final dayCompare = a.dayIndex!.compareTo(b.dayIndex!);
      if (dayCompare != 0) return dayCompare;
    }
    
    // Then by sort_index
    final sortCompare = a.sortIndex.compareTo(b.sortIndex);
    if (sortCompare != 0) return sortCompare;
    
    // Finally by start_time_utc
    final aTime = a.startTimeUtc;
    final bTime = b.startTimeUtc;
    if (aTime != null && bTime != null) {
      return aTime.compareTo(bTime);
    }
    if (aTime != null) return -1;
    if (bTime != null) return 1;
    
    return 0;
  }

  /// Get the day key for grouping (date portion only)
  DateTime _getDayKey(TripItem item) {
    final time = item.startTimeUtc ?? item.createdAt;
    // TODO: Use localTz for proper timezone conversion
    // For now, use the date portion in UTC
    return DateTime(time.year, time.month, time.day);
  }

  /// Compute layover between two consecutive transport items
  /// 
  /// Returns a [LayoverEntry] if:
  /// - Both items are transport type
  /// - Destination city of item A matches origin city of item B
  /// - Arrival of A is before departure of B
  /// 
  /// Returns null if layover is not applicable
  LayoverEntry? computeLayover(TripItem itemA, TripItem itemB) {
    // Both must be transport items
    if (itemA.type != TripItemType.transport || 
        itemB.type != TripItemType.transport) {
      return null;
    }
    
    final transportA = itemA.transportDetails;
    final transportB = itemB.transportDetails;
    if (transportA == null || transportB == null) return null;
    
    // Check destination of A matches origin of B (case-insensitive city match)
    final destCity = transportA.destinationCity?.toLowerCase().trim();
    final originCity = transportB.originCity?.toLowerCase().trim();
    
    if (destCity == null || originCity == null || destCity != originCity) {
      return null;
    }
    
    // Get arrival time of A and departure time of B
    final arrivalA = transportA.arrivalLocal ?? itemA.endTimeUtc;
    final departureB = transportB.departureLocal ?? itemB.startTimeUtc;
    
    if (arrivalA == null || departureB == null) return null;
    
    // Departure must be after arrival
    if (departureB.isBefore(arrivalA)) return null;
    
    final duration = departureB.difference(arrivalA);
    
    // Don't show layovers of 0 duration
    if (duration.inMinutes <= 0) return null;
    
    return LayoverEntry(
      duration: duration,
      locationCode: transportB.originAirportCode ?? transportA.destinationAirportCode,
      locationCity: transportB.originCity ?? transportA.destinationCity,
      layoverStart: arrivalA,
      layoverEnd: departureB,
    );
  }

  /// Get all transport items from a timeline for layover analysis
  List<TripItem> getTransportItems(List<TripItem> items) {
    return items
        .where((item) => item.type == TripItemType.transport)
        .toList();
  }

  /// Calculate total layover duration for a trip
  Duration getTotalLayoverDuration(List<TripItem> items) {
    final sortedItems = List<TripItem>.from(items)..sort(_compareItems);
    
    var totalDuration = Duration.zero;
    
    for (int i = 1; i < sortedItems.length; i++) {
      final layover = computeLayover(sortedItems[i - 1], sortedItems[i]);
      if (layover != null) {
        totalDuration += layover.duration;
      }
    }
    
    return totalDuration;
  }
}
