import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme.dart';
import '../../../../shared/models/models.dart';
import '../../../../shared/ui/ui.dart';
import '../../../../shared/services/places_service.dart';
import '../../../trip_items/presentation/providers/trip_items_provider.dart';
import '../providers/trips_provider.dart';

/// Provider for detecting active trip (where today falls within trip dates)
final activeTripProvider = FutureProvider.autoDispose<Trip?>((ref) async {
  final trips = await ref.watch(tripsListProvider.future);
  final today = DateTime.now();
  final todayDate = DateTime(today.year, today.month, today.day);

  for (final trip in trips) {
    if (trip.startDate == null) continue;
    final startDate = DateTime(trip.startDate!.year, trip.startDate!.month, trip.startDate!.day);
    final endDate = trip.endDate != null 
        ? DateTime(trip.endDate!.year, trip.endDate!.month, trip.endDate!.day)
        : startDate;
    
    if (!todayDate.isBefore(startDate) && !todayDate.isAfter(endDate)) {
      return trip;
    }
  }
  return null;
});

/// Today View Widget showing daily itinerary for active trip
class TodayView extends ConsumerWidget {
  final Trip trip;
  final DateTime date;

  const TodayView({
    super.key,
    required this.trip,
    required this.date,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemsAsync = ref.watch(tripItemsProvider(trip.id));
    final dateFormat = DateFormat('EEEE, MMM d');
    final timeFormat = DateFormat('HH:mm');

    return Scaffold(
      backgroundColor: WaydeckTheme.background,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '📍 Today in ${_getCurrentCity(itemsAsync)}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            Text(
              dateFormat.format(date),
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ],
        ),
        actions: [
          TextButton.icon(
            onPressed: () => context.push('/trips/${trip.id}'),
            icon: const Icon(Icons.map, size: 18),
            label: const Text('Full Trip'),
          ),
        ],
      ),
      body: itemsAsync.when(
        loading: () => const LoadingIndicator(),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (items) {
          final todayItems = _filterTodayItems(items, date);
          final currentStay = _getCurrentStay(items, date);

          if (todayItems.isEmpty && currentStay == null) {
            return _buildEmptyDay(context);
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Today's Activities
              if (todayItems.isNotEmpty) ...[
                _buildSectionHeader('Today\'s Itinerary'),
                const SizedBox(height: 12),
                ...todayItems.map((item) => _buildItemCard(context, item, timeFormat)),
              ],

              // Current Stay
              if (currentStay != null) ...[
                const SizedBox(height: 24),
                _buildSectionHeader('Your Stay'),
                const SizedBox(height: 12),
                _buildStayCard(context, currentStay),
              ],

              // Navigation buttons
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton.icon(
                    onPressed: () => _navigateToDay(context, -1),
                    icon: const Icon(Icons.chevron_left),
                    label: const Text('Yesterday'),
                  ),
                  TextButton.icon(
                    onPressed: () => _navigateToDay(context, 1),
                    icon: const Icon(Icons.chevron_right),
                    label: const Text('Tomorrow'),
                  ),
                ],
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddActivitySheet(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  String _getCurrentCity(AsyncValue<List<TripItem>> itemsAsync) {
    final items = itemsAsync.valueOrNull ?? [];
    
    // Try to get city from today's stay
    for (final item in items) {
      if (item.type == TripItemType.stay && item.stayDetails != null) {
        final stay = item.stayDetails!;
        if (stay.checkinLocal != null && stay.checkoutLocal != null) {
          if (!date.isBefore(stay.checkinLocal!) && !date.isAfter(stay.checkoutLocal!)) {
            return stay.city ?? trip.originCity ?? 'Unknown';
          }
        }
      }
    }
    
    return trip.originCity ?? 'Your Trip';
  }

  List<TripItem> _filterTodayItems(List<TripItem> items, DateTime date) {
    final todayStart = DateTime(date.year, date.month, date.day);
    final todayEnd = todayStart.add(const Duration(days: 1));

    return items.where((item) {
      // Activities
      if (item.type == TripItemType.activity && item.activityDetails?.startLocal != null) {
        final start = item.activityDetails!.startLocal!;
        return start.isAfter(todayStart.subtract(const Duration(seconds: 1))) &&
               start.isBefore(todayEnd);
      }
      
      // Transports
      if (item.type == TripItemType.transport && item.transportDetails?.departureLocal != null) {
        final departure = item.transportDetails!.departureLocal!;
        return departure.isAfter(todayStart.subtract(const Duration(seconds: 1))) &&
               departure.isBefore(todayEnd);
      }

      return false;
    }).toList()
      ..sort((a, b) {
        final aTime = a.activityDetails?.startLocal ?? a.transportDetails?.departureLocal;
        final bTime = b.activityDetails?.startLocal ?? b.transportDetails?.departureLocal;
        if (aTime == null) return 1;
        if (bTime == null) return -1;
        return aTime.compareTo(bTime);
      });
  }

  TripItem? _getCurrentStay(List<TripItem> items, DateTime date) {
    for (final item in items) {
      if (item.type == TripItemType.stay && item.stayDetails != null) {
        final stay = item.stayDetails!;
        if (stay.checkinLocal != null && stay.checkoutLocal != null) {
          final checkIn = DateTime(stay.checkinLocal!.year, stay.checkinLocal!.month, stay.checkinLocal!.day);
          final checkOut = DateTime(stay.checkoutLocal!.year, stay.checkoutLocal!.month, stay.checkoutLocal!.day);
          final today = DateTime(date.year, date.month, date.day);
          
          if (!today.isBefore(checkIn) && !today.isAfter(checkOut)) {
            return item;
          }
        }
      }
    }
    return null;
  }

  Widget _buildSectionHeader(String title) {
    return Text(title, style: WaydeckTheme.heading3);
  }

  Widget _buildItemCard(BuildContext context, TripItem item, DateFormat timeFormat) {
    final isActivity = item.type == TripItemType.activity;
    final isTransport = item.type == TripItemType.transport;

    String time = '';
    String location = '';
    String? subtitle;
    IconData icon = Icons.event;

    if (isActivity && item.activityDetails != null) {
      final details = item.activityDetails!;
      time = details.startLocal != null ? timeFormat.format(details.startLocal!) : '';
      if (details.endLocal != null) {
        time += ' - ${timeFormat.format(details.endLocal!)}';
      }
      location = details.locationString;
      icon = Icons.local_activity;
    } else if (isTransport && item.transportDetails != null) {
      final details = item.transportDetails!;
      time = details.departureLocal != null ? timeFormat.format(details.departureLocal!) : '';
      location = '${details.originCity ?? ''} → ${details.destinationCity ?? ''}';
      subtitle = details.carrierString;
      icon = _getTransportIcon(details.mode);
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _navigateToDetail(context, item),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: WaydeckTheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icon, color: WaydeckTheme.primary, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.title, style: WaydeckTheme.bodyLarge.copyWith(fontWeight: FontWeight.w600)),
                        if (subtitle != null)
                          Text(subtitle, style: WaydeckTheme.caption),
                      ],
                    ),
                  ),
                  Text(time, style: WaydeckTheme.bodyMedium.copyWith(fontWeight: FontWeight.w500)),
                ],
              ),
              if (location.isNotEmpty) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.location_on, size: 16, color: WaydeckTheme.textSecondary),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(location, style: WaydeckTheme.bodySmall.copyWith(color: WaydeckTheme.textSecondary)),
                    ),
                    TextButton.icon(
                      onPressed: () => PlacesService.openDirections(destinationAddress: location),
                      icon: const Icon(Icons.directions, size: 16),
                      label: const Text('Directions'),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStayCard(BuildContext context, TripItem item) {
    final details = item.stayDetails!;
    final dateFormat = DateFormat('MMM d');

    return Card(
      child: InkWell(
        onTap: () => context.push('/trips/${trip.id}/items/${item.id}/stay'),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Text('🏨', style: TextStyle(fontSize: 32)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(details.accommodationName, style: WaydeckTheme.bodyLarge.copyWith(fontWeight: FontWeight.w600)),
                    Text(details.locationString, style: WaydeckTheme.caption),
                    const SizedBox(height: 4),
                    Text(
                      '${dateFormat.format(details.checkinLocal!)} - ${dateFormat.format(details.checkoutLocal!)}',
                      style: WaydeckTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.directions),
                onPressed: () {
                  final address = [details.accommodationName, details.address, details.city]
                      .where((s) => s != null && s.isNotEmpty)
                      .join(', ');
                  PlacesService.openDirections(destinationAddress: address);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyDay(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🏖️', style: TextStyle(fontSize: 64)),
          const SizedBox(height: 16),
          Text('Free Day!', style: WaydeckTheme.heading2),
          const SizedBox(height: 8),
          Text('No activities scheduled', style: WaydeckTheme.bodySmall),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _showAddActivitySheet(context),
            icon: const Icon(Icons.add),
            label: const Text('Add Activity'),
          ),
        ],
      ),
    );
  }

  IconData _getTransportIcon(TransportMode mode) {
    switch (mode) {
      case TransportMode.flight:
        return Icons.flight;
      case TransportMode.train:
        return Icons.train;
      case TransportMode.bus:
        return Icons.directions_bus;
      case TransportMode.car:
        return Icons.directions_car;
      case TransportMode.ferry:
        return Icons.directions_boat;
      case TransportMode.bike:
        return Icons.directions_bike;
      case TransportMode.cruise:
        return Icons.directions_boat;
      case TransportMode.metro:
        return Icons.subway;
      default:
        return Icons.commute;
    }
  }

  void _navigateToDetail(BuildContext context, TripItem item) {
    final type = item.type.name;
    context.push('/trips/${trip.id}/items/${item.id}/$type');
  }

  void _navigateToDay(BuildContext context, int days) {
    // For now, just show a snackbar. Could implement proper day navigation later.
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(days < 0 ? 'View yesterday' : 'View tomorrow')),
    );
  }

  void _showAddActivitySheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.local_activity),
                title: const Text('Add Activity'),
                onTap: () {
                  Navigator.pop(ctx);
                  context.push('/trips/${trip.id}/items/activity/new');
                },
              ),
              ListTile(
                leading: const Icon(Icons.flight),
                title: const Text('Add Transport'),
                onTap: () {
                  Navigator.pop(ctx);
                  context.push('/trips/${trip.id}/items/transport/new');
                },
              ),
              ListTile(
                leading: const Icon(Icons.hotel),
                title: const Text('Add Stay'),
                onTap: () {
                  Navigator.pop(ctx);
                  context.push('/trips/${trip.id}/items/stay/new');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
