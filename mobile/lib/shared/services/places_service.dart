import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../../core/env/env.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

/// Place prediction from Google Places Autocomplete
class PlacePrediction {
  final String placeId;
  final String description;
  final String mainText;
  final String? secondaryText;
  final List<String> types;

  const PlacePrediction({
    required this.placeId,
    required this.description,
    required this.mainText,
    this.secondaryText,
    this.types = const [],
  });

  factory PlacePrediction.fromJson(Map<String, dynamic> json) {
    final structured = json['structured_formatting'] as Map<String, dynamic>?;
    return PlacePrediction(
      placeId: json['place_id'] as String,
      description: json['description'] as String,
      mainText: structured?['main_text'] as String? ?? json['description'] as String,
      secondaryText: structured?['secondary_text'] as String?,
      types: (json['types'] as List<dynamic>?)?.cast<String>() ?? [],
    );
  }

  /// Check if this is a city
  bool get isCity => types.contains('locality') || types.contains('administrative_area_level_1');

  /// Check if this is an establishment (hotel, restaurant, etc.)
  bool get isEstablishment => types.contains('establishment');
}

/// Place details from Google Places
class PlaceDetails {
  final String placeId;
  final String name;
  final String? formattedAddress;
  final String? city;
  final String? country;
  final String? countryCode;
  final double? latitude;
  final double? longitude;
  final String? phoneNumber;
  final String? website;

  const PlaceDetails({
    required this.placeId,
    required this.name,
    this.formattedAddress,
    this.city,
    this.country,
    this.countryCode,
    this.latitude,
    this.longitude,
    this.phoneNumber,
    this.website,
  });

  factory PlaceDetails.fromJson(Map<String, dynamic> json) {
    final result = json['result'] as Map<String, dynamic>? ?? json;
    final addressComponents = result['address_components'] as List<dynamic>? ?? [];
    final geometry = result['geometry'] as Map<String, dynamic>?;
    final location = geometry?['location'] as Map<String, dynamic>?;

    String? city;
    String? country;
    String? countryCode;

    for (final component in addressComponents) {
      final types = (component['types'] as List<dynamic>?)?.cast<String>() ?? [];
      if (types.contains('locality')) {
        city = component['long_name'] as String?;
      }
      if (types.contains('country')) {
        country = component['long_name'] as String?;
        countryCode = component['short_name'] as String?;
      }
    }

    return PlaceDetails(
      placeId: result['place_id'] as String,
      name: result['name'] as String? ?? '',
      formattedAddress: result['formatted_address'] as String?,
      city: city,
      country: country,
      countryCode: countryCode,
      latitude: location?['lat'] as double?,
      longitude: location?['lng'] as double?,
      phoneNumber: result['formatted_phone_number'] as String?,
      website: result['website'] as String?,
    );
  }

  /// Get Google Maps URL for this place
  String get mapsUrl {
    if (latitude != null && longitude != null) {
      return 'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude&query_place_id=$placeId';
    }
    return 'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(formattedAddress ?? name)}';
  }
}

/// Google Places Service
class PlacesService {
  static const _baseUrl = 'https://maps.googleapis.com/maps/api/place';
  

  String get _apiKey => Env.googlePlacesApiKey;
  
  /// Get URL
  String _getUrl(String endpoint) {
    // START: Production-Readiness Change
    // Removed corsproxy.io usage for security.
    // Google Places API does not support client-side requests from Web due to CORS.
    // For Web production, you must route requests through your own backend (e.g. Supabase Edge Function).
    // For this implementation, we simply return the direct URL.
    // If running on Web, this may fail without a backend proxy.
    return '$_baseUrl$endpoint';
    // END: Production-Readiness Change
  }

  /// Autocomplete for cities
  Future<List<PlacePrediction>> autocompleteCities(String input) async {
    if (input.isEmpty) return [];
    
    if (_apiKey.isEmpty) {
      debugPrint('PlacesService: API key is empty! Check GOOGLE_PLACES_API_KEY in .env');
      return [];
    }

    try {
      final endpoint = '/autocomplete/json'
          '?input=${Uri.encodeComponent(input)}'
          '&types=(cities)'
          '&key=$_apiKey';
      
      final url = Uri.parse(_getUrl(endpoint));

      debugPrint('PlacesService: Requesting cities for "$input"');
      final response = await http.get(url);
      
      if (response.statusCode != 200) {
        debugPrint('PlacesService: Error response: ${response.body}');
        return [];
      }

      final json = jsonDecode(response.body) as Map<String, dynamic>;
      
      if (json['status'] != 'OK' && json['status'] != 'ZERO_RESULTS') {
        debugPrint('PlacesService: API error: ${json['error_message'] ?? json['status']}');
        return [];
      }
      
      final predictions = json['predictions'] as List<dynamic>? ?? [];

      return predictions
          .map((p) => PlacePrediction.fromJson(p as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('PlacesService: Exception: $e');
      return [];
    }
  }

  /// Autocomplete for addresses
  Future<List<PlacePrediction>> autocompleteAddresses(String input) async {
    if (input.isEmpty || _apiKey.isEmpty) return [];

    try {
      final endpoint = '/autocomplete/json'
          '?input=${Uri.encodeComponent(input)}'
          '&types=address'
          '&key=$_apiKey';
      
      final url = Uri.parse(_getUrl(endpoint));

      final response = await http.get(url);
      if (response.statusCode != 200) return [];

      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final predictions = json['predictions'] as List<dynamic>? ?? [];

      return predictions
          .map((p) => PlacePrediction.fromJson(p as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Autocomplete for establishments (hotels, restaurants, etc.)
  Future<List<PlacePrediction>> autocompleteEstablishments(String input, {String? type}) async {
    if (input.isEmpty || _apiKey.isEmpty) return [];

    try {
      var typeParam = 'establishment';
      if (type != null) typeParam = type;

      final endpoint = '/autocomplete/json'
          '?input=${Uri.encodeComponent(input)}'
          '&types=$typeParam'
          '&key=$_apiKey';
      
      final url = Uri.parse(_getUrl(endpoint));

      final response = await http.get(url);
      if (response.statusCode != 200) return [];

      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final predictions = json['predictions'] as List<dynamic>? ?? [];

      return predictions
          .map((p) => PlacePrediction.fromJson(p as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// General autocomplete (any type)
  Future<List<PlacePrediction>> autocomplete(String input) async {
    if (input.isEmpty || _apiKey.isEmpty) return [];

    try {
      final endpoint = '/autocomplete/json'
          '?input=${Uri.encodeComponent(input)}'
          '&key=$_apiKey';
      
      final url = Uri.parse(_getUrl(endpoint));

      final response = await http.get(url);
      if (response.statusCode != 200) return [];

      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final predictions = json['predictions'] as List<dynamic>? ?? [];

      return predictions
          .map((p) => PlacePrediction.fromJson(p as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Get place details
  Future<PlaceDetails?> getPlaceDetails(String placeId) async {
    if (placeId.isEmpty || _apiKey.isEmpty) return null;

    try {
      final url = Uri.parse(
        '$_baseUrl/details/json'
        '?place_id=$placeId'
        '&fields=place_id,name,formatted_address,address_components,geometry,formatted_phone_number,website'
        '&key=$_apiKey'
      );

      final response = await http.get(url);
      if (response.statusCode != 200) return null;

      final json = jsonDecode(response.body) as Map<String, dynamic>;
      if (json['status'] != 'OK') return null;

      return PlaceDetails.fromJson(json);
    } catch (e) {
      return null;
    }
  }

  /// Open Google Maps with directions
  static Future<void> openDirections({
    String? destinationAddress,
    double? destinationLat,
    double? destinationLng,
    String? destinationPlaceId,
  }) async {
    String url;

    if (destinationPlaceId != null) {
      url = 'https://www.google.com/maps/dir/?api=1&destination_place_id=$destinationPlaceId';
    } else if (destinationLat != null && destinationLng != null) {
      url = 'https://www.google.com/maps/dir/?api=1&destination=$destinationLat,$destinationLng';
    } else if (destinationAddress != null) {
      url = 'https://www.google.com/maps/dir/?api=1&destination=${Uri.encodeComponent(destinationAddress)}';
    } else {
      return;
    }

    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  /// Open Google Maps at a location
  static Future<void> openLocation({
    String? address,
    double? lat,
    double? lng,
    String? placeId,
  }) async {
    String url;

    if (placeId != null && lat != null && lng != null) {
      url = 'https://www.google.com/maps/search/?api=1&query=$lat,$lng&query_place_id=$placeId';
    } else if (lat != null && lng != null) {
      url = 'https://www.google.com/maps/search/?api=1&query=$lat,$lng';
    } else if (address != null) {
      url = 'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(address)}';
    } else {
      return;
    }

    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}

/// Singleton instance
final placesService = PlacesService();
