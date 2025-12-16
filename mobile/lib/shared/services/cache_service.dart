import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/models.dart';

/// Cache service for offline data persistence
/// 
/// Caches trip data locally using SharedPreferences for offline access.
/// The cache is read on startup while fetching fresh data from the server.
class CacheService {
  static const String _tripsKey = 'cached_trips';
  static const String _tripItemsPrefix = 'cached_trip_items_';
  static const String _lastTripIdKey = 'last_viewed_trip_id';
  static const String _cacheTimestampKey = 'cache_timestamp';

  SharedPreferences? _prefs;

  /// Initialize the cache service
  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  /// Ensure prefs is initialized
  Future<SharedPreferences> _getPrefs() async {
    if (_prefs == null) {
      await init();
    }
    return _prefs!;
  }

  // ============ Trips Cache ============

  /// Cache a list of trips
  Future<void> cacheTrips(List<Trip> trips) async {
    final prefs = await _getPrefs();
    final tripsJson = trips.map((t) => t.toJson()).toList();
    await prefs.setString(_tripsKey, jsonEncode(tripsJson));
    await prefs.setInt(_cacheTimestampKey, DateTime.now().millisecondsSinceEpoch);
  }

  /// Get cached trips
  Future<List<Trip>?> getCachedTrips() async {
    final prefs = await _getPrefs();
    final tripsString = prefs.getString(_tripsKey);
    if (tripsString == null) return null;

    try {
      final tripsList = jsonDecode(tripsString) as List;
      return tripsList
          .map((json) => Trip.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      // Invalid cache data
      return null;
    }
  }

  // ============ Trip Items Cache ============

  /// Cache items for a specific trip
  Future<void> cacheTripItems(String tripId, List<TripItem> items) async {
    final prefs = await _getPrefs();
    final itemsJson = items.map((i) => i.toJson()).toList();
    await prefs.setString('$_tripItemsPrefix$tripId', jsonEncode(itemsJson));
  }

  /// Get cached items for a trip
  Future<List<TripItem>?> getCachedTripItems(String tripId) async {
    final prefs = await _getPrefs();
    final itemsString = prefs.getString('$_tripItemsPrefix$tripId');
    if (itemsString == null) return null;

    try {
      final itemsList = jsonDecode(itemsString) as List;
      return itemsList
          .map((json) => TripItem.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      // Invalid cache data
      return null;
    }
  }

  // ============ Last Viewed Trip ============

  /// Save the last viewed trip ID
  Future<void> setLastViewedTripId(String tripId) async {
    final prefs = await _getPrefs();
    await prefs.setString(_lastTripIdKey, tripId);
  }

  /// Get the last viewed trip ID
  Future<String?> getLastViewedTripId() async {
    final prefs = await _getPrefs();
    return prefs.getString(_lastTripIdKey);
  }

  // ============ Cache Management ============

  /// Get cache timestamp
  Future<DateTime?> getCacheTimestamp() async {
    final prefs = await _getPrefs();
    final timestamp = prefs.getInt(_cacheTimestampKey);
    if (timestamp == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(timestamp);
  }

  /// Check if cache is stale (older than given duration)
  Future<bool> isCacheStale(Duration maxAge) async {
    final timestamp = await getCacheTimestamp();
    if (timestamp == null) return true;
    return DateTime.now().difference(timestamp) > maxAge;
  }

  /// Clear all cached data (e.g., on sign out)
  Future<void> clearCache() async {
    final prefs = await _getPrefs();
    final keys = prefs.getKeys().where((key) =>
        key == _tripsKey ||
        key.startsWith(_tripItemsPrefix) ||
        key == _lastTripIdKey ||
        key == _cacheTimestampKey);
    
    for (final key in keys) {
      await prefs.remove(key);
    }
  }

  /// Clear trip items cache for a specific trip
  Future<void> clearTripItemsCache(String tripId) async {
    final prefs = await _getPrefs();
    await prefs.remove('$_tripItemsPrefix$tripId');
  }
}
