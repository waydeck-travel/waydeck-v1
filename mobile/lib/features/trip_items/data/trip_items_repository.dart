import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../shared/models/models.dart';

/// Trip Items Repository
/// 
/// INTEGRATION POINT FOR INTEGRATION AGENT:
/// This repository handles all Supabase operations for trip items.
class TripItemsRepository {
  final SupabaseClient _client;

  TripItemsRepository({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  String? get _userId => _client.auth.currentUser?.id;

  /// Fetch all items for a trip with their type-specific details
  Future<List<TripItem>> getTripItems(String tripId) async {
    if (_userId == null) return [];

    try {
      // First verify trip ownership
      final tripCheck = await _client
          .from('trips')
          .select('id')
          .eq('id', tripId)
          .eq('owner_id', _userId!)
          .maybeSingle();

      if (tripCheck == null) return [];

      // Fetch items with joined type-specific data
      final response = await _client
          .from('trip_items')
          .select('''
            *,
            transport_items(*),
            stay_items(*),
            activity_items(*)
          ''')
          .eq('trip_id', tripId)
          .order('day_index')
          .order('sort_index')
          .order('start_time_utc');

      return (response as List)
          .map((json) => TripItem.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Fetch a single trip item with details
  Future<TripItem?> getTripItem(String itemId) async {
    if (_userId == null) return null;

    try {
      final response = await _client
          .from('trip_items')
          .select('''
            *,
            transport_items(*),
            stay_items(*),
            activity_items(*)
          ''')
          .eq('id', itemId)
          .single();

      return TripItem.fromJson(response);
    } catch (e) {
      return null;
    }
  }

  /// Create a transport item
  Future<TripItem?> createTransportItem({
    required String tripId,
    required String title,
    String? description,
    DateTime? startTimeUtc,
    DateTime? endTimeUtc,
    String? localTz,
    String? comment,
    required TransportMode mode,
    String? carrierName,
    String? carrierCode,
    String? transportNumber,
    String? bookingReference,
    String? originCity,
    String? originCountryCode,
    String? originAirportCode,
    String? originTerminal,
    String? destinationCity,
    String? destinationCountryCode,
    String? destinationAirportCode,
    String? destinationTerminal,
    DateTime? departureLocal,
    DateTime? arrivalLocal,
    int? passengerCount,
  }) async {
    if (_userId == null) return null;

    try {
      // Create base trip item
      final itemData = {
        'trip_id': tripId,
        'type': 'transport',
        'title': title,
        'description': description,
        'start_time_utc': startTimeUtc?.toIso8601String(),
        'end_time_utc': endTimeUtc?.toIso8601String(),
        'local_tz': localTz,
        'comment': comment,
      };

      final itemResponse = await _client
          .from('trip_items')
          .insert(itemData)
          .select()
          .single();

      final itemId = itemResponse['id'] as String;

      // Create transport details
      final transportData = {
        'trip_item_id': itemId,
        'mode': mode.name,
        'carrier_name': carrierName,
        'carrier_code': carrierCode,
        'transport_number': transportNumber,
        'booking_reference': bookingReference,
        'origin_city': originCity,
        'origin_country_code': originCountryCode,
        'origin_airport_code': originAirportCode,
        'origin_terminal': originTerminal,
        'destination_city': destinationCity,
        'destination_country_code': destinationCountryCode,
        'destination_airport_code': destinationAirportCode,
        'destination_terminal': destinationTerminal,
        'departure_local': departureLocal?.toIso8601String(),
        'arrival_local': arrivalLocal?.toIso8601String(),
        'passenger_count': passengerCount,
      };

      await _client.from('transport_items').insert(transportData);

      return getTripItem(itemId);
    } catch (e) {
      return null;
    }
  }

  /// Create a stay item
  Future<TripItem?> createStayItem({
    required String tripId,
    required String title,
    String? description,
    DateTime? startTimeUtc,
    DateTime? endTimeUtc,
    String? localTz,
    String? comment,
    required String accommodationName,
    String? address,
    String? city,
    String? countryCode,
    DateTime? checkinLocal,
    DateTime? checkoutLocal,
    bool hasBreakfast = false,
    String? confirmationNumber,
    String? bookingUrl,
  }) async {
    if (_userId == null) return null;

    try {
      final itemData = {
        'trip_id': tripId,
        'type': 'stay',
        'title': title,
        'description': description,
        'start_time_utc': startTimeUtc?.toIso8601String(),
        'end_time_utc': endTimeUtc?.toIso8601String(),
        'local_tz': localTz,
        'comment': comment,
      };

      final itemResponse = await _client
          .from('trip_items')
          .insert(itemData)
          .select()
          .single();

      final itemId = itemResponse['id'] as String;

      final stayData = {
        'trip_item_id': itemId,
        'accommodation_name': accommodationName,
        'address': address,
        'city': city,
        'country_code': countryCode,
        'checkin_local': checkinLocal?.toIso8601String(),
        'checkout_local': checkoutLocal?.toIso8601String(),
        'has_breakfast': hasBreakfast,
        'confirmation_number': confirmationNumber,
        'booking_url': bookingUrl,
      };

      await _client.from('stay_items').insert(stayData);

      return getTripItem(itemId);
    } catch (e) {
      return null;
    }
  }

  /// Create an activity item
  Future<TripItem?> createActivityItem({
    required String tripId,
    required String title,
    String? description,
    DateTime? startTimeUtc,
    DateTime? endTimeUtc,
    String? localTz,
    String? comment,
    String? category,
    String? locationName,
    String? address,
    String? city,
    String? countryCode,
    DateTime? startLocal,
    DateTime? endLocal,
    String? bookingCode,
    String? bookingUrl,
  }) async {
    if (_userId == null) return null;

    try {
      final itemData = {
        'trip_id': tripId,
        'type': 'activity',
        'title': title,
        'description': description,
        'start_time_utc': startTimeUtc?.toIso8601String(),
        'end_time_utc': endTimeUtc?.toIso8601String(),
        'local_tz': localTz,
        'comment': comment,
      };

      final itemResponse = await _client
          .from('trip_items')
          .insert(itemData)
          .select()
          .single();

      final itemId = itemResponse['id'] as String;

      final activityData = {
        'trip_item_id': itemId,
        'category': category,
        'location_name': locationName,
        'address': address,
        'city': city,
        'country_code': countryCode,
        'start_local': startLocal?.toIso8601String(),
        'end_local': endLocal?.toIso8601String(),
        'booking_code': bookingCode,
        'booking_url': bookingUrl,
      };

      await _client.from('activity_items').insert(activityData);

      return getTripItem(itemId);
    } catch (e) {
      return null;
    }
  }

  /// Create a note item
  Future<TripItem?> createNoteItem({
    required String tripId,
    required String title,
    String? description,
    DateTime? startTimeUtc,
    String? localTz,
  }) async {
    if (_userId == null) return null;

    try {
      final itemData = {
        'trip_id': tripId,
        'type': 'note',
        'title': title,
        'description': description,
        'start_time_utc': startTimeUtc?.toIso8601String(),
        'local_tz': localTz,
      };

      final response = await _client
          .from('trip_items')
          .insert(itemData)
          .select()
          .single();

      return TripItem.fromJson(response);
    } catch (e) {
      return null;
    }
  }

  /// Delete a trip item
  Future<bool> deleteTripItem(String itemId) async {
    if (_userId == null) return false;

    try {
      await _client.from('trip_items').delete().eq('id', itemId);
      return true;
    } catch (e) {
      return false;
    }
  }
}

// Provider
final tripItemsRepositoryProvider = Provider<TripItemsRepository>((ref) {
  return TripItemsRepository();
});
