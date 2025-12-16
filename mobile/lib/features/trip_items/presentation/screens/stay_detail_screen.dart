import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme.dart';
import '../../../../shared/ui/ui.dart';
import '../../../../shared/services/places_service.dart';
import '../../../documents/presentation/widgets/document_grid.dart';
import '../providers/trip_items_provider.dart';

/// Stay Detail Screen
class StayDetailScreen extends ConsumerWidget {
  final String tripId;
  final String itemId;

  const StayDetailScreen({
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
        title: const Text('Stay Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () =>
                context.push('/trips/$tripId/items/stay/$itemId/edit'),
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
          final details = item.stayDetails;
          if (details == null) {
            return const Center(child: Text('Stay details not found'));
          }

          final dateFormat = DateFormat('EEE, d MMM');
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
                          const Text('🏨', style: TextStyle(fontSize: 32)),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  details.accommodationName,
                                  style: WaydeckTheme.heading2,
                                ),
                                if (details.address != null)
                                  Text(
                                    details.address!,
                                    style: WaydeckTheme.bodySmall,
                                  ),
                                Text(
                                  details.locationString,
                                  style: WaydeckTheme.bodySmall.copyWith(
                                    color: WaydeckTheme.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Get Directions button
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () {
                            final address = [
                              details.accommodationName,
                              details.address,
                              details.city,
                              details.countryCode,
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
                  ),
                ),
                const SizedBox(height: 24),

                // Check-in/out
                Text('Check-in / Check-out', style: WaydeckTheme.heading3),
                const SizedBox(height: 8),
                WaydeckCard(
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Check-in', style: WaydeckTheme.caption),
                                if (details.checkinLocal != null) ...[
                                  Text(
                                    timeFormat.format(details.checkinLocal!),
                                    style: WaydeckTheme.heading3,
                                  ),
                                  Text(
                                    dateFormat.format(details.checkinLocal!),
                                    style: WaydeckTheme.bodySmall,
                                  ),
                                ],
                              ],
                            ),
                          ),
                          Container(
                            width: 1,
                            height: 50,
                            color: Colors.grey.shade300,
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text('Check-out', style: WaydeckTheme.caption),
                                if (details.checkoutLocal != null) ...[
                                  Text(
                                    timeFormat.format(details.checkoutLocal!),
                                    style: WaydeckTheme.heading3,
                                  ),
                                  Text(
                                    dateFormat.format(details.checkoutLocal!),
                                    style: WaydeckTheme.bodySmall,
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Amenities
                if (details.hasBreakfast) ...[
                  Text('Amenities', style: WaydeckTheme.heading3),
                  const SizedBox(height: 8),
                  WaydeckCard(
                    child: Row(
                      children: [
                        BadgeChip.success(label: 'Breakfast Included', icon: '🍳'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Booking details
                if (details.confirmationNumber != null ||
                    details.bookingUrl != null) ...[
                  Text('Booking', style: WaydeckTheme.heading3),
                  const SizedBox(height: 8),
                  WaydeckCard(
                    child: Column(
                      children: [
                        if (details.confirmationNumber != null)
                          _buildRow('Confirmation', details.confirmationNumber!),
                        if (details.bookingUrl != null)
                          _buildRow('Booking URL', details.bookingUrl!, isUrl: true),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: WaydeckTheme.bodySmall),
          const SizedBox(width: 16),
          Flexible(
            child: Text(
              value,
              style: WaydeckTheme.bodyMedium.copyWith(
                fontWeight: FontWeight.w500,
                color: isUrl ? WaydeckTheme.primary : null,
              ),
              textAlign: TextAlign.end,
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
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
          title: const Text('Delete Stay'),
          content: const Text('Delete this stay item?'),
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
