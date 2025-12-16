import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme.dart';
import '../../../../shared/models/models.dart';
import 'day_section_header.dart';
import 'timeline_item_card.dart';
import 'layover_chip.dart';

/// Timeline widget that displays trip items grouped by date.
/// Renders as a SliverList for performance.
class TimelineWidget extends StatelessWidget {
  final String tripId;
  final List<TripItem> items;

  const TimelineWidget({
    super.key,
    required this.tripId,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    // 1. Group items by local date
    final groupedItems = _groupItemsByDate(items);
    
    // 2. Flatten into a list of TimelineListItem
    final flatList = _buildFlatList(groupedItems);

    if (flatList.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    // 3. Render lazily using SliverList
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final item = flatList[index];
            
            if (item is TimelineHeaderItem) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: DaySectionHeader(date: item.date),
              );
            } else if (item is TimelineTripItem) {
              return Padding(
                padding: EdgeInsets.only(bottom: item.isLastInDay ? 16 : 0),
                child: _TimelineRow(
                  isFirst: item.isFirstInDay,
                  isLast: item.isLastInDay,
                  itemType: item.tripItem.type,
                  child: TimelineItemCard(
                    item: item.tripItem,
                    onTap: () => _navigateToDetail(context, item.tripItem),
                  ),
                ),
              );
            } else if (item is TimelineLayoverItem) {
              return _TimelineRow(
                isFirst: false,
                isLast: false,
                isLayover: true,
                child: LayoverChip(
                  duration: item.duration,
                  location: item.location,
                ),
              );
            }
            return const SizedBox.shrink();
          },
          childCount: flatList.length,
        ),
      ),
    );
  }

  Map<DateTime, List<TripItem>> _groupItemsByDate(List<TripItem> items) {
    final Map<DateTime, List<TripItem>> grouped = {};

    for (final item in items) {
      final date = item.localDate ?? DateTime.now();
      final dateKey = DateTime(date.year, date.month, date.day);

      if (!grouped.containsKey(dateKey)) {
        grouped[dateKey] = [];
      }
      grouped[dateKey]!.add(item);
    }

    // Sort days
    final sortedKeys = grouped.keys.toList()..sort();
    final Map<DateTime, List<TripItem>> sortedGrouped = {};

    for (final key in sortedKeys) {
      final dayItems = grouped[key]!;
      // Sort items within each day
      dayItems.sort((a, b) {
        final indexCompare = a.sortIndex.compareTo(b.sortIndex);
        if (indexCompare != 0) return indexCompare;

        if (a.startTimeUtc != null && b.startTimeUtc != null) {
          return a.startTimeUtc!.compareTo(b.startTimeUtc!);
        }
        return 0;
      });
      sortedGrouped[key] = dayItems;
    }

    return sortedGrouped;
  }

  List<TimelineListItem> _buildFlatList(Map<DateTime, List<TripItem>> grouped) {
    final List<TimelineListItem> list = [];

    for (final entry in grouped.entries) {
      // Add Header
      list.add(TimelineHeaderItem(entry.key));

      final dayItems = entry.value;
      for (int i = 0; i < dayItems.length; i++) {
        final item = dayItems[i];
        final isLast = i == dayItems.length - 1;

        // Add Trip Item
        list.add(TimelineTripItem(
          tripItem: item,
          isFirstInDay: i == 0,
          isLastInDay: isLast,
        ));

        // Add Layover if needed
        if (!isLast && item.type == TripItemType.transport) {
          final nextItem = dayItems[i + 1];
          if (nextItem.type == TripItemType.transport) {
            final layover = _calculateLayover(item, nextItem);
            if (layover != null) {
              list.add(TimelineLayoverItem(
                duration: layover.$1,
                location: layover.$2,
              ));
            }
          }
        }
      }
    }

    return list;
  }

  (Duration, String)? _calculateLayover(TripItem itemA, TripItem itemB) {
    final transportA = itemA.transportDetails;
    final transportB = itemB.transportDetails;

    if (transportA == null || transportB == null) return null;

    final destCity = transportA.destinationCity?.toLowerCase();
    final originCity = transportB.originCity?.toLowerCase();

    if (destCity == null || originCity == null || destCity != originCity) {
      return null;
    }

    final arrivalA = transportA.arrivalLocal;
    final departureB = transportB.departureLocal;

    if (arrivalA == null || departureB == null) return null;
    if (!arrivalA.isBefore(departureB)) return null;

    final duration = departureB.difference(arrivalA);
    final location = transportA.destinationAirportCode ?? 
                     transportA.destinationCity ?? 
                     'Unknown';

    return (duration, location);
  }

  void _navigateToDetail(BuildContext context, TripItem item) {
    final typeName = item.type.name;
    context.push('/trips/$tripId/items/${item.id}/$typeName');
  }
}

// --- Helper Classes ---

abstract class TimelineListItem {}

class TimelineHeaderItem extends TimelineListItem {
  final DateTime date;
  TimelineHeaderItem(this.date);
}

class TimelineTripItem extends TimelineListItem {
  final TripItem tripItem;
  final bool isFirstInDay;
  final bool isLastInDay;

  TimelineTripItem({
    required this.tripItem,
    required this.isFirstInDay,
    required this.isLastInDay,
  });
}

class TimelineLayoverItem extends TimelineListItem {
  final Duration duration;
  final String location;

  TimelineLayoverItem({required this.duration, required this.location});
}

/// A single row in the timeline with the vertical rail
class _TimelineRow extends StatelessWidget {
  final bool isFirst;
  final bool isLast;
  final bool isLayover;
  final TripItemType? itemType;
  final Widget child;

  const _TimelineRow({
    required this.isFirst,
    required this.isLast,
    this.isLayover = false,
    this.itemType,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Timeline rail
          SizedBox(
            width: 24,
            child: Column(
              children: [
                // Top connector
                if (!isFirst)
                  Container(
                    width: 2,
                    height: 8,
                    color: Colors.grey.shade300,
                  ),
                // Dot
                Container(
                  width: isLayover ? 8 : 12,
                  height: isLayover ? 8 : 12,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isLayover
                        ? WaydeckTheme.warning
                        : _getColorForType(itemType),
                    border: Border.all(
                      color: Colors.white,
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 2,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                ),
                // Bottom connector
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: Colors.grey.shade300,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Content
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 8),
              child: child,
            ),
          ),
        ],
      ),
    );
  }

  Color _getColorForType(TripItemType? type) {
    switch (type) {
      case TripItemType.transport:
        return WaydeckTheme.transportColor;
      case TripItemType.stay:
        return WaydeckTheme.stayColor;
      case TripItemType.activity:
        return WaydeckTheme.activityColor;
      case TripItemType.note:
        return WaydeckTheme.noteColor;
      case null:
        return Colors.grey;
    }
  }
}
