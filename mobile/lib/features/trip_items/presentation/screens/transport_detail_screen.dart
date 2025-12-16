import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme.dart';
import '../../../../shared/models/models.dart';
import '../../../../shared/ui/ui.dart';
import '../../../../shared/services/places_service.dart';
import '../../../documents/presentation/widgets/document_grid.dart';
import '../providers/trip_items_provider.dart';

/// Transport Detail Screen
class TransportDetailScreen extends ConsumerWidget {
  final String tripId;
  final String itemId;

  const TransportDetailScreen({
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
        title: const Text('Transport Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => context.push(
              '/trips/$tripId/items/transport/$itemId/edit',
            ),
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
        data: (item) => item == null
            ? const Center(child: Text('Item not found'))
            : _buildContent(context, item),
      ),
    );
  }

  Widget _buildContent(BuildContext context, TripItem item) {
    final details = item.transportDetails;
    if (details == null) {
      return const Center(child: Text('Transport details not found'));
    }

    final timeFormat = DateFormat('HH:mm');
    final dateFormat = DateFormat('EEE, d MMM yyyy');

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Route visualization card
          WaydeckCard(
            child: Column(
              children: [
                Text(
                  '${details.mode.icon} ${details.mode.displayName}',
                  style: WaydeckTheme.heading3,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            details.originAirportCode ?? details.originCity ?? '---',
                            style: WaydeckTheme.heading2,
                          ),
                          Text(
                            details.originCity ?? '',
                            style: WaydeckTheme.bodySmall,
                          ),
                          if (details.departureLocal != null)
                            Text(
                              timeFormat.format(details.departureLocal!),
                              style: WaydeckTheme.bodyLarge.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          if (details.originTerminal != null)
                            Text(
                              'Terminal ${details.originTerminal}',
                              style: WaydeckTheme.caption,
                            ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          const Text('────────→', style: TextStyle(fontSize: 18)),
                          if (_getDuration(details) != null)
                            Text(
                              _getDuration(details)!,
                              style: WaydeckTheme.caption,
                            ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            details.destinationAirportCode ??
                                details.destinationCity ??
                                '---',
                            style: WaydeckTheme.heading2,
                          ),
                          Text(
                            details.destinationCity ?? '',
                            style: WaydeckTheme.bodySmall,
                          ),
                          if (details.arrivalLocal != null)
                            Text(
                              timeFormat.format(details.arrivalLocal!),
                              style: WaydeckTheme.bodyLarge.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          if (details.destinationTerminal != null)
                            Text(
                              'Terminal ${details.destinationTerminal}',
                              style: WaydeckTheme.caption,
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Get Directions button for destination
                if (details.destinationCity != null)
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        final address = [
                          details.destinationAirportCode,
                          details.destinationCity,
                        ].where((s) => s != null && s.isNotEmpty).join(', ');
                        PlacesService.openDirections(destinationAddress: address);
                      },
                      icon: const Icon(Icons.directions, size: 18),
                      label: const Text('Get Directions to Destination'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: WaydeckTheme.primary,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Details section
          _buildSection('Details', [
            if (details.carrierName != null || details.carrierCode != null)
              _buildDetailRow('Carrier', details.carrierString),
            if (details.transportNumber != null)
              _buildDetailRow('${details.mode.displayName} Number', details.transportNumber!),
            if (details.bookingReference != null)
              _buildDetailRow('Booking Reference', details.bookingReference!),
            if (details.passengerCount != null)
              _buildDetailRow('Passengers', '${details.passengerCount}'),
          ]),

          if (details.departureLocal != null) ...[
            const SizedBox(height: 16),
            _buildSection('Date & Time', [
              _buildDetailRow('Date', dateFormat.format(details.departureLocal!)),
              _buildDetailRow(
                'Departure',
                '${timeFormat.format(details.departureLocal!)} (local)',
              ),
              if (details.arrivalLocal != null)
                _buildDetailRow(
                  'Arrival',
                  '${timeFormat.format(details.arrivalLocal!)} (local)',
                ),
            ]),
          ],

          // Documents
          const SizedBox(height: 24),
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
  }

  Widget _buildSection(String title, List<Widget> rows) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: WaydeckTheme.heading3),
        const SizedBox(height: 8),
        WaydeckCard(
          child: Column(
            children: rows,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: WaydeckTheme.bodySmall),
          Text(value, style: WaydeckTheme.bodyMedium.copyWith(
            fontWeight: FontWeight.w500,
          )),
        ],
      ),
    );
  }

  String? _getDuration(TransportItemDetails details) {
    if (details.departureLocal == null || details.arrivalLocal == null) {
      return null;
    }
    final duration = details.arrivalLocal!.difference(details.departureLocal!);
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    if (hours > 0) return '${hours}h ${minutes}m';
    return '${minutes}m';
  }

  void _handleAction(BuildContext context, WidgetRef ref, String action) {
    if (action == 'delete') {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Delete Transport'),
          content: const Text('Delete this transport item?'),
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
