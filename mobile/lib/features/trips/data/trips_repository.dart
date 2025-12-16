import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../shared/models/models.dart';

/// Trips Repository
/// 
/// INTEGRATION POINT FOR INTEGRATION AGENT:
/// This repository handles all Supabase operations for trips.
class TripsRepository {
  final SupabaseClient _client;

  TripsRepository({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  /// Get current user ID
  String? get _userId => _client.auth.currentUser?.id;

  /// Fetch all trips for the current user with item counts
  Future<List<Trip>> getTrips({bool includeArchived = false}) async {
    if (_userId == null) return [];

    try {
      var query = _client
          .from('trips')
          .select()
          .eq('owner_id', _userId!);
      
      if (!includeArchived) {
        query = query.eq('archived', false);
      }
      
      final response = await query.order('created_at', ascending: false);
      
      final trips = <Trip>[];
      for (final json in (response as List)) {
        final tripId = json['id'] as String;
        final counts = await _getItemCounts(tripId);
        trips.add(Trip.fromJson({
          ...json as Map<String, dynamic>,
          ...counts,
        }));
      }
      return trips;
    } catch (e) {
      return [];
    }
  }

  /// Fetch a single trip by ID with item counts
  Future<Trip?> getTrip(String tripId) async {
    if (_userId == null) return null;

    try {
      final response = await _client
          .from('trips')
          .select()
          .eq('id', tripId)
          .eq('owner_id', _userId!)
          .single();
      
      final counts = await _getItemCounts(tripId);
      return Trip.fromJson({
        ...response,
        ...counts,
      });
    } catch (e) {
      return null;
    }
  }

  /// Get item counts for a trip
  Future<Map<String, int>> _getItemCounts(String tripId) async {
    try {
      final items = await _client
          .from('trip_items')
          .select('type')
          .eq('trip_id', tripId);
      
      int transport = 0, stay = 0, activity = 0, note = 0;
      for (final item in (items as List)) {
        switch (item['type']) {
          case 'transport': transport++; break;
          case 'stay': stay++; break;
          case 'activity': activity++; break;
          case 'note': note++; break;
        }
      }
      
      // Also count documents
      final docs = await _client
          .from('documents')
          .select('id')
          .eq('trip_id', tripId);
      
      return {
        'transport_count': transport,
        'stay_count': stay,
        'activity_count': activity,
        'note_count': note,
        'document_count': (docs as List).length,
      };
    } catch (e) {
      return {
        'transport_count': 0,
        'stay_count': 0,
        'activity_count': 0,
        'note_count': 0,
        'document_count': 0,
      };
    }
  }

  /// Create a new trip
  /// 
  /// TODO: Integration Agent - implement insert
  Future<Trip?> createTrip({
    required String name,
    String? originCity,
    String? originCountryCode,
    DateTime? startDate,
    DateTime? endDate,
    String? notes,
  }) async {
    if (_userId == null) {
      print('createTrip error: userId is null - user not authenticated');
      return null;
    }

    try {
      final data = {
        'owner_id': _userId,
        'name': name,
        'origin_city': originCity,
        'origin_country_code': originCountryCode,
        'start_date': startDate?.toIso8601String().split('T').first,
        'end_date': endDate?.toIso8601String().split('T').first,
        'notes': notes,
      };

      print('createTrip: Inserting data: $data');

      final response = await _client
          .from('trips')
          .insert(data)
          .select()
          .single();

      print('createTrip: Success, response: $response');
      return Trip.fromJson(response);
    } catch (e, stack) {
      print('createTrip error: $e');
      print('Stack trace: $stack');
      return null;
    }
  }

  /// Update an existing trip
  Future<Trip?> updateTrip({
    required String tripId,
    String? name,
    String? originCity,
    String? originCountryCode,
    DateTime? startDate,
    DateTime? endDate,
    String? notes,
  }) async {
    if (_userId == null) return null;

    try {
      final data = <String, dynamic>{
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (name != null) data['name'] = name;
      if (originCity != null) data['origin_city'] = originCity;
      if (originCountryCode != null) {
        data['origin_country_code'] = originCountryCode;
      }
      if (startDate != null) {
        data['start_date'] = startDate.toIso8601String().split('T').first;
      }
      if (endDate != null) {
        data['end_date'] = endDate.toIso8601String().split('T').first;
      }
      if (notes != null) data['notes'] = notes;

      final response = await _client
          .from('trips')
          .update(data)
          .eq('id', tripId)
          .eq('owner_id', _userId!)
          .select()
          .single();

      return Trip.fromJson(response);
    } catch (e) {
      return null;
    }
  }

  /// Archive a trip
  Future<bool> archiveTrip(String tripId) async {
    if (_userId == null) return false;

    try {
      await _client
          .from('trips')
          .update({'archived': true, 'updated_at': DateTime.now().toIso8601String()})
          .eq('id', tripId)
          .eq('owner_id', _userId!);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Delete a trip permanently
  Future<bool> deleteTrip(String tripId) async {
    if (_userId == null) return false;

    try {
      await _client
          .from('trips')
          .delete()
          .eq('id', tripId)
          .eq('owner_id', _userId!);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Start a trip (set status to active)
  Future<bool> startTrip(String tripId) async {
    if (_userId == null) return false;

    try {
      await _client.from('trips').update({
        'status': 'active',
        'started_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', tripId).eq('owner_id', _userId!);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Complete a trip (set status to completed)
  Future<bool> completeTrip(String tripId) async {
    if (_userId == null) return false;

    try {
      await _client.from('trips').update({
        'status': 'completed',
        'completed_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', tripId).eq('owner_id', _userId!);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Revert trip to planned status
  Future<bool> revertTripToPlanned(String tripId) async {
    if (_userId == null) return false;

    try {
      await _client.from('trips').update({
        'status': 'planned',
        'started_at': null,
        'completed_at': null,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', tripId).eq('owner_id', _userId!);
      return true;
    } catch (e) {
      return false;
    }
  }
}
