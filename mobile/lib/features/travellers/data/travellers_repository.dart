import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../shared/models/models.dart';

/// Travellers Repository
/// 
/// Handles CRUD operations for travellers and trip-traveller assignments
class TravellersRepository {
  final SupabaseClient _client;

  TravellersRepository({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  String? get _userId => _client.auth.currentUser?.id;

  // ============== Travellers CRUD ==============

  /// Get all travellers for the current user
  Future<List<Traveller>> getTravellers() async {
    if (_userId == null) return [];

    try {
      final response = await _client
          .from('travellers')
          .select()
          .eq('owner_id', _userId!)
          .order('full_name');

      return (response as List)
          .map((json) => Traveller.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Get a single traveller
  Future<Traveller?> getTraveller(String travellerId) async {
    if (_userId == null) return null;

    try {
      final response = await _client
          .from('travellers')
          .select()
          .eq('id', travellerId)
          .eq('owner_id', _userId!)
          .single();

      return Traveller.fromJson(response);
    } catch (e) {
      return null;
    }
  }

  /// Create a new traveller
  Future<Traveller?> createTraveller({
    required String fullName,
    String? email,
    String? phone,
    String? passportNumber,
    DateTime? passportExpiry,
    String? nationality,
    DateTime? dateOfBirth,
    String? notes,
    String? avatarUrl,
  }) async {
    if (_userId == null) return null;

    try {
      final data = {
        'owner_id': _userId,
        'full_name': fullName,
        'email': email,
        'phone': phone,
        'passport_number': passportNumber,
        'passport_expiry': passportExpiry?.toIso8601String().substring(0, 10),
        'nationality': nationality,
        'date_of_birth': dateOfBirth?.toIso8601String().substring(0, 10),
        'notes': notes,
        'avatar_url': avatarUrl,
      };

      final response = await _client
          .from('travellers')
          .insert(data)
          .select()
          .single();

      return Traveller.fromJson(response);
    } catch (e) {
      return null;
    }
  }

  /// Update a traveller
  Future<Traveller?> updateTraveller({
    required String travellerId,
    String? fullName,
    String? email,
    String? phone,
    String? passportNumber,
    DateTime? passportExpiry,
    String? nationality,
    DateTime? dateOfBirth,
    String? notes,
    String? avatarUrl,
  }) async {
    if (_userId == null) return null;

    try {
      final data = <String, dynamic>{};
      if (fullName != null) data['full_name'] = fullName;
      if (email != null) data['email'] = email;
      if (phone != null) data['phone'] = phone;
      if (passportNumber != null) data['passport_number'] = passportNumber;
      if (passportExpiry != null) data['passport_expiry'] = passportExpiry.toIso8601String().substring(0, 10);
      if (nationality != null) data['nationality'] = nationality;
      if (dateOfBirth != null) data['date_of_birth'] = dateOfBirth.toIso8601String().substring(0, 10);
      if (notes != null) data['notes'] = notes;
      if (avatarUrl != null) data['avatar_url'] = avatarUrl;

      if (data.isEmpty) return null;

      final response = await _client
          .from('travellers')
          .update(data)
          .eq('id', travellerId)
          .eq('owner_id', _userId!)
          .select()
          .single();

      return Traveller.fromJson(response);
    } catch (e) {
      return null;
    }
  }

  /// Delete a traveller
  Future<bool> deleteTraveller(String travellerId) async {
    if (_userId == null) return false;

    try {
      await _client
          .from('travellers')
          .delete()
          .eq('id', travellerId)
          .eq('owner_id', _userId!);
      return true;
    } catch (e) {
      return false;
    }
  }

  // ============== Trip Travellers ==============

  /// Get travellers for a trip
  Future<List<TripTraveller>> getTripTravellers(String tripId) async {
    if (_userId == null) return [];

    try {
      final response = await _client
          .from('trip_travellers')
          .select('*, travellers(*)')
          .eq('trip_id', tripId)
          .order('is_primary', ascending: false);

      return (response as List)
          .map((json) => TripTraveller.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Add a traveller to a trip
  Future<bool> addTravellerToTrip({
    required String tripId,
    required String travellerId,
    bool isPrimary = false,
  }) async {
    if (_userId == null) return false;

    try {
      await _client.from('trip_travellers').insert({
        'trip_id': tripId,
        'traveller_id': travellerId,
        'is_primary': isPrimary,
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Remove a traveller from a trip
  Future<bool> removeTravellerFromTrip({
    required String tripId,
    required String travellerId,
  }) async {
    if (_userId == null) return false;

    try {
      await _client
          .from('trip_travellers')
          .delete()
          .eq('trip_id', tripId)
          .eq('traveller_id', travellerId);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Set primary traveller for a trip
  Future<bool> setPrimaryTraveller({
    required String tripId,
    required String travellerId,
  }) async {
    if (_userId == null) return false;

    try {
      // Reset all to non-primary
      await _client
          .from('trip_travellers')
          .update({'is_primary': false})
          .eq('trip_id', tripId);

      // Set the new primary
      await _client
          .from('trip_travellers')
          .update({'is_primary': true})
          .eq('trip_id', tripId)
          .eq('traveller_id', travellerId);

      return true;
    } catch (e) {
      return false;
    }
  }
}

// Provider
final travellersRepositoryProvider = Provider<TravellersRepository>((ref) {
  return TravellersRepository();
});
