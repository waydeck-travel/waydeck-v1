import 'package:flutter/material.dart';

import '../../../app/theme.dart';
import '../../../shared/models/models.dart';
import '../../../shared/ui/ui.dart';

/// Trip card widget for the trip list
class TripCard extends StatelessWidget {
  final Trip trip;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onArchive;
  final VoidCallback? onDelete;

  const TripCard({
    super.key,
    required this.trip,
    this.onTap,
    this.onEdit,
    this.onArchive,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return WaydeckCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            children: [
              Expanded(
                child: Text(
                  trip.name,
                  style: WaydeckTheme.heading3,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              PopupMenuButton<String>(
                icon: Icon(
                  Icons.more_vert,
                  color: WaydeckTheme.textSecondary,
                ),
                onSelected: (value) {
                  switch (value) {
                    case 'edit':
                      onEdit?.call();
                      break;
                    case 'archive':
                      onArchive?.call();
                      break;
                    case 'delete':
                      onDelete?.call();
                      break;
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit_outlined, size: 20),
                        SizedBox(width: 8),
                        Text('Edit'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'archive',
                    child: Row(
                      children: [
                        Icon(Icons.archive_outlined, size: 20),
                        SizedBox(width: 8),
                        Text('Archive'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete_outlined, 
                            size: 20, color: WaydeckTheme.error),
                        const SizedBox(width: 8),
                        Text('Delete', 
                            style: TextStyle(color: WaydeckTheme.error)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 4),

          // Origin
          Row(
            children: [
              Icon(
                Icons.location_on_outlined,
                size: 16,
                color: WaydeckTheme.textSecondary,
              ),
              const SizedBox(width: 4),
              Text(
                trip.originString,
                style: WaydeckTheme.bodySmall,
              ),
            ],
          ),
          const SizedBox(height: 4),

          // Date range
          Row(
            children: [
              Icon(
                Icons.calendar_today_outlined,
                size: 16,
                color: WaydeckTheme.textSecondary,
              ),
              const SizedBox(width: 4),
              Text(
                trip.dateRangeString,
                style: WaydeckTheme.bodySmall,
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Item counts
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              if (trip.transportCount > 0)
                BadgeChip.transport(
                  label: '${trip.transportCount}',
                  icon: '✈️',
                ),
              if (trip.stayCount > 0)
                BadgeChip.stay(
                  label: '${trip.stayCount}',
                  icon: '🏨',
                ),
              if (trip.activityCount > 0)
                BadgeChip.activity(
                  label: '${trip.activityCount}',
                  icon: '🎟️',
                ),
              if (trip.noteCount > 0)
                BadgeChip(
                  label: '${trip.noteCount}',
                  icon: '📝',
                  backgroundColor: WaydeckTheme.noteColor.withValues(alpha: 0.1),
                  textColor: WaydeckTheme.noteColor,
                ),
            ],
          ),
        ],
      ),
    );
  }
}
