import '../models/models.dart';

/// A day on the timeline with grouped entries
class TimelineDay {
  final DateTime date;
  final String dateLabel;
  final List<TimelineEntry> entries;

  const TimelineDay({
    required this.date,
    required this.dateLabel,
    required this.entries,
  });

  /// Get formatted date label (e.g., "Sun, 1 Dec 2025")
  static String formatDateLabel(DateTime date) {
    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    
    final weekday = weekdays[date.weekday - 1];
    final month = months[date.month - 1];
    return '$weekday, ${date.day} $month ${date.year}';
  }
}

/// Base class for timeline entries (either a trip item or a layover)
sealed class TimelineEntry {
  DateTime get sortTime;
}

/// A trip item entry on the timeline
class TripItemEntry extends TimelineEntry {
  final TripItem item;
  final bool hasDocuments;

  TripItemEntry({
    required this.item,
    this.hasDocuments = false,
  });

  @override
  DateTime get sortTime => item.startTimeUtc ?? item.createdAt;
}

/// A layover entry between two transport segments
class LayoverEntry extends TimelineEntry {
  final Duration duration;
  final String? locationCode;
  final String? locationCity;
  final DateTime layoverStart;
  final DateTime layoverEnd;

  LayoverEntry({
    required this.duration,
    this.locationCode,
    this.locationCity,
    required this.layoverStart,
    required this.layoverEnd,
  });

  @override
  DateTime get sortTime => layoverStart;

  /// Get formatted duration string (e.g., "2h 35m")
  String get durationString {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    
    if (hours > 0 && minutes > 0) {
      return '${hours}h ${minutes}m';
    } else if (hours > 0) {
      return '${hours}h';
    } else {
      return '${minutes}m';
    }
  }

  /// Get display string (e.g., "Layover: 2h 35m at BKK")
  String get displayString {
    final location = locationCode ?? locationCity ?? '';
    if (location.isNotEmpty) {
      return 'Layover: $durationString at $location';
    }
    return 'Layover: $durationString';
  }
}
