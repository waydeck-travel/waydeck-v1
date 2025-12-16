import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme.dart';
import '../../../../shared/models/models.dart';
import '../../../../shared/ui/ui.dart';

/// Timeline item card for displaying trip items
class TimelineItemCard extends StatelessWidget {
  final TripItem item;
  final VoidCallback? onTap;

  const TimelineItemCard({
    super.key,
    required this.item,
    this.onTap,
  });

  /// Check if this activity/item is in the past (completed)
  bool get _isPast {
    final startTime = item.getStartTime();
    if (startTime == null) return false;
    return startTime.isBefore(DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    final isPastActivity = item.type == TripItemType.activity && _isPast;
    
    return Opacity(
      opacity: isPastActivity ? 0.7 : 1.0,
      child: WaydeckCard(
        onTap: onTap,
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with icon and title
            Row(
              children: [
                Text(
                  _getIcon(),
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _getTitle(),
                    style: WaydeckTheme.bodyLarge.copyWith(
                      fontWeight: FontWeight.w600,
                      decoration: isPastActivity ? TextDecoration.lineThrough : null,
                      color: isPastActivity ? WaydeckTheme.textSecondary : null,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                // Completion indicator for past activities
                if (isPastActivity)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: WaydeckTheme.success.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check_circle, size: 12, color: WaydeckTheme.success),
                        const SizedBox(width: 2),
                        Text(
                          'Done',
                          style: WaydeckTheme.caption.copyWith(
                            color: WaydeckTheme.success,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),

            // Subtitle
            Text(
              _getSubtitle(),
              style: WaydeckTheme.bodySmall.copyWith(
                color: WaydeckTheme.textSecondary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),

            // Time range
            if (_getTimeRange() != null) ...[
              const SizedBox(height: 4),
              Text(
                _getTimeRange()!,
                style: WaydeckTheme.bodySmall,
              ),
            ],

            // Badges
            if (_getBadges().isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: _getBadges(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _getIcon() {
    switch (item.type) {
      case TripItemType.transport:
        return item.transportDetails?.mode.icon ?? '✈️';
      case TripItemType.stay:
        return '🏨';
      case TripItemType.activity:
        return '🎟️';
      case TripItemType.note:
        return '📝';
    }
  }

  String _getTitle() {
    switch (item.type) {
      case TripItemType.transport:
        final details = item.transportDetails;
        if (details != null) {
          final mode = details.mode.displayName;
          final number = details.transportNumber ?? '';
          return '$mode $number'.trim();
        }
        return item.title;
      case TripItemType.stay:
        return item.stayDetails?.accommodationName ?? item.title;
      case TripItemType.activity:
      case TripItemType.note:
        return item.title;
    }
  }

  String _getSubtitle() {
    switch (item.type) {
      case TripItemType.transport:
        return item.transportDetails?.routeString ?? '';
      case TripItemType.stay:
        return item.stayDetails?.locationString ?? '';
      case TripItemType.activity:
        final details = item.activityDetails;
        if (details != null) {
          final location = details.locationString;
          final category = details.category;
          if (location.isNotEmpty && category != null) {
            return '$location • $category';
          }
          return location.isNotEmpty ? location : category ?? '';
        }
        return '';
      case TripItemType.note:
        return item.description ?? '';
    }
  }

  String? _getTimeRange() {
    final timeFormat = DateFormat('HH:mm');

    switch (item.type) {
      case TripItemType.transport:
        final details = item.transportDetails;
        if (details?.departureLocal != null && details?.arrivalLocal != null) {
          final dep = timeFormat.format(details!.departureLocal!);
          final arr = timeFormat.format(details.arrivalLocal!);
          final passengers = details.passengerCount != null
              ? ' • ${details.passengerCount} passengers'
              : '';
          return '$dep – $arr$passengers';
        }
        return null;
      case TripItemType.stay:
        final details = item.stayDetails;
        if (details?.checkinLocal != null) {
          final checkin = timeFormat.format(details!.checkinLocal!);
          final checkout = details.checkoutLocal != null
              ? timeFormat.format(details.checkoutLocal!)
              : '??:??';
          return 'Check-in $checkin • Out $checkout';
        }
        return null;
      case TripItemType.activity:
        final details = item.activityDetails;
        if (details?.startLocal != null) {
          final start = timeFormat.format(details!.startLocal!);
          if (details.endLocal != null) {
            final end = timeFormat.format(details.endLocal!);
            return '$start – $end';
          }
          return start;
        }
        return null;
      case TripItemType.note:
        return null;
    }
  }

  List<Widget> _getBadges() {
    final List<Widget> badges = [];

    switch (item.type) {
      case TripItemType.transport:
        final mode = item.transportDetails?.mode;
        if (mode != null) {
          badges.add(BadgeChip.transport(label: mode.displayName));
        }
        break;
      case TripItemType.stay:
        if (item.stayDetails?.hasBreakfast == true) {
          badges.add(BadgeChip.success(label: 'Breakfast', icon: '🍳'));
        }
        break;
      case TripItemType.activity:
        final category = item.activityDetails?.category;
        if (category != null) {
          badges.add(BadgeChip.activity(label: category));
        }
        break;
      case TripItemType.note:
        break;
    }

    // Document badge
    if (item.documentCount > 0) {
      badges.add(BadgeChip.info(label: 'Ticket', icon: '🎫'));
    }

    return badges;
  }
}
