import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme.dart';
import '../../../../shared/ui/ui.dart';
import '../../../../shared/services/places_service.dart';
import '../../../documents/presentation/widgets/document_grid.dart';
import '../providers/trip_items_provider.dart';

/// Activity Detail Screen
class ActivityDetailScreen extends ConsumerWidget {
  final String tripId;
  final String itemId;

  const ActivityDetailScreen({
    super.key,
    required this.tripId,
    required this.itemId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemAsync = ref.watch(tripItemProvider(itemId));

    return Scaffold(
      backgroundColor: WaydeckTheme.background,
      appBar: AppBar(
        title: const Text('Activity Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () =>
                context.push('/trips/$tripId/items/activity/$itemId/edit'),
          ),
          PopupMenuButton<String>(
            onSelected: (value) => _handleAction(context, ref, value),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete_outlined, size: 20),
                    SizedBox(width: 8),
                    Text('Delete'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: itemAsync.when(
        loading: () => const LoadingIndicator(),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (item) {
          if (item == null) {
            return const Center(child: Text('Item not found'));
          }
          final details = item.activityDetails;

          final dateFormat = DateFormat('EEE, d MMM yyyy');
          final timeFormat = DateFormat('HH:mm');

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header card
                WaydeckCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text('🎟️', style: TextStyle(fontSize: 32)),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(item.title, style: WaydeckTheme.heading2),
                                if (details?.category != null)
                                  BadgeChip.activity(label: details!.category!),
                                if (details?.locationString.isNotEmpty == true)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: Text(
                                      details!.locationString,
                                      style: WaydeckTheme.bodySmall.copyWith(
                                        color: WaydeckTheme.textSecondary,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      // Get Directions button
                      if (details?.locationString.isNotEmpty == true) ...[
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () {
                              final address = [
                                details?.locationName,
                                details?.address,
                                details?.city,
                                details?.countryCode,
                              ].where((s) => s != null && s.isNotEmpty).join(', ');
                              PlacesService.openDirections(destinationAddress: address);
                            },
                            icon: const Icon(Icons.directions, size: 18),
                            label: const Text('Get Directions'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: WaydeckTheme.primary,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Schedule
                if (details?.startLocal != null) ...[
                  Text('Schedule', style: WaydeckTheme.heading3),
                  const SizedBox(height: 8),
                  WaydeckCard(
                    child: Column(
                      children: [
                        _buildRow('Date', dateFormat.format(details!.startLocal!)),
                        _buildRow('Start', timeFormat.format(details.startLocal!)),
                        if (details.endLocal != null)
                          _buildRow('End', timeFormat.format(details.endLocal!)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Booking
                if (details?.bookingCode != null ||
                    details?.bookingUrl != null) ...[
                  Text('Booking', style: WaydeckTheme.heading3),
                  const SizedBox(height: 8),
                  WaydeckCard(
                    child: Column(
                      children: [
                        if (details?.bookingCode != null)
                          _buildRow('Booking Code', details!.bookingCode!),
                        if (details?.bookingUrl != null)
                          _buildRow('Booking URL', details!.bookingUrl!,
                              isUrl: true),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Documents
                Text('Documents', style: WaydeckTheme.heading3),
                const SizedBox(height: 8),
                DocumentGrid(tripItemId: itemId),

                // Comments
                if (item.comment != null && item.comment!.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  Text('Comments', style: WaydeckTheme.heading3),
                  const SizedBox(height: 8),
                  WaydeckCard(
                    child: Text(item.comment!, style: WaydeckTheme.bodyMedium),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildRow(String label, String value, {bool isUrl = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: WaydeckTheme.bodySmall),
          Text(
            value,
            style: WaydeckTheme.bodyMedium.copyWith(
              fontWeight: FontWeight.w500,
              color: isUrl ? WaydeckTheme.primary : null,
            ),
          ),
        ],
      ),
    );
  }

  void _handleAction(BuildContext context, WidgetRef ref, String action) {
    if (action == 'delete') {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Delete Activity'),
          content: const Text('Delete this activity?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                final delete = ref.read(deleteTripItemProvider);
                final success = await delete(tripId, itemId);
                if (success && context.mounted) {
                  context.pop();
                }
              },
              style: TextButton.styleFrom(foregroundColor: WaydeckTheme.error),
              child: const Text('Delete'),
            ),
          ],
        ),
      );
    }
  }
}
