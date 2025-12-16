import 'enums.dart';

/// Base Trip Item model
class TripItem {
  final String id;
  final String tripId;
  final TripItemType type;
  final String title;
  final String? description;
  final DateTime? startTimeUtc;
  final DateTime? endTimeUtc;
  final String? localTz;
  final int? dayIndex;
  final int sortIndex;
  final String? comment;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Related data (populated from joins)
  final TransportItemDetails? transportDetails;
  final StayItemDetails? stayDetails;
  final ActivityItemDetails? activityDetails;
  final int documentCount;

  const TripItem({
    required this.id,
    required this.tripId,
    required this.type,
    required this.title,
    this.description,
    this.startTimeUtc,
    this.endTimeUtc,
    this.localTz,
    this.dayIndex,
    this.sortIndex = 0,
    this.comment,
    required this.createdAt,
    required this.updatedAt,
    this.transportDetails,
    this.stayDetails,
    this.activityDetails,
    this.documentCount = 0,
  });

  /// Get the local date for grouping
  DateTime? get localDate {
    if (startTimeUtc == null) return null;
    // TODO: Use localTz for proper timezone conversion
    return DateTime(startTimeUtc!.year, startTimeUtc!.month, startTimeUtc!.day);
  }

  /// Get the start time for notifications (uses type-specific local time)
  DateTime? getStartTime() {
    switch (type) {
      case TripItemType.transport:
        // Use departure time for transport
        return transportDetails?.departureLocal ?? startTimeUtc;
      case TripItemType.stay:
        // Use check-in time for stays
        return stayDetails?.checkinLocal ?? startTimeUtc;
      case TripItemType.activity:
        // Use activity start time
        return activityDetails?.startLocal ?? startTimeUtc;
      case TripItemType.note:
        // Notes don't have meaningful start times for notifications
        return null;
    }
  }

  TripItem copyWith({
    String? id,
    String? tripId,
    TripItemType? type,
    String? title,
    String? description,
    DateTime? startTimeUtc,
    DateTime? endTimeUtc,
    String? localTz,
    int? dayIndex,
    int? sortIndex,
    String? comment,
    DateTime? createdAt,
    DateTime? updatedAt,
    TransportItemDetails? transportDetails,
    StayItemDetails? stayDetails,
    ActivityItemDetails? activityDetails,
    int? documentCount,
  }) {
    return TripItem(
      id: id ?? this.id,
      tripId: tripId ?? this.tripId,
      type: type ?? this.type,
      title: title ?? this.title,
      description: description ?? this.description,
      startTimeUtc: startTimeUtc ?? this.startTimeUtc,
      endTimeUtc: endTimeUtc ?? this.endTimeUtc,
      localTz: localTz ?? this.localTz,
      dayIndex: dayIndex ?? this.dayIndex,
      sortIndex: sortIndex ?? this.sortIndex,
      comment: comment ?? this.comment,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      transportDetails: transportDetails ?? this.transportDetails,
      stayDetails: stayDetails ?? this.stayDetails,
      activityDetails: activityDetails ?? this.activityDetails,
      documentCount: documentCount ?? this.documentCount,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'trip_id': tripId,
      'type': type.name,
      'title': title,
      'description': description,
      'start_time_utc': startTimeUtc?.toIso8601String(),
      'end_time_utc': endTimeUtc?.toIso8601String(),
      'local_tz': localTz,
      'day_index': dayIndex,
      'sort_index': sortIndex,
      'comment': comment,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory TripItem.fromJson(Map<String, dynamic> json) {
    return TripItem(
      id: json['id'] as String,
      tripId: json['trip_id'] as String,
      type: TripItemType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => TripItemType.note,
      ),
      title: json['title'] as String,
      description: json['description'] as String?,
      startTimeUtc: json['start_time_utc'] != null
          ? DateTime.parse(json['start_time_utc'] as String)
          : null,
      endTimeUtc: json['end_time_utc'] != null
          ? DateTime.parse(json['end_time_utc'] as String)
          : null,
      localTz: json['local_tz'] as String?,
      dayIndex: json['day_index'] as int?,
      sortIndex: json['sort_index'] as int? ?? 0,
      comment: json['comment'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      transportDetails: json['transport_items'] != null
          ? TransportItemDetails.fromJson(
              json['transport_items'] as Map<String, dynamic>)
          : null,
      stayDetails: json['stay_items'] != null
          ? StayItemDetails.fromJson(json['stay_items'] as Map<String, dynamic>)
          : null,
      activityDetails: json['activity_items'] != null
          ? ActivityItemDetails.fromJson(
              json['activity_items'] as Map<String, dynamic>)
          : null,
      documentCount: json['document_count'] as int? ?? 0,
    );
  }
}

/// Transport item details
class TransportItemDetails {
  final TransportMode mode;
  final String? carrierName;
  final String? carrierCode;
  final String? transportNumber;
  final String? bookingReference;
  final String? originCity;
  final String? originCountryCode;
  final String? originAirportCode;
  final String? originTerminal;
  final String? destinationCity;
  final String? destinationCountryCode;
  final String? destinationAirportCode;
  final String? destinationTerminal;
  final DateTime? departureLocal;
  final DateTime? arrivalLocal;
  final int? passengerCount;
  final Map<String, dynamic>? passengerDetails;
  final double? price;
  final String? currency;

  const TransportItemDetails({
    required this.mode,
    this.carrierName,
    this.carrierCode,
    this.transportNumber,
    this.bookingReference,
    this.originCity,
    this.originCountryCode,
    this.originAirportCode,
    this.originTerminal,
    this.destinationCity,
    this.destinationCountryCode,
    this.destinationAirportCode,
    this.destinationTerminal,
    this.departureLocal,
    this.arrivalLocal,
    this.passengerCount,
    this.passengerDetails,
    this.price,
    this.currency,
  });

  /// Get route display string (e.g., "PNQ → BOM")
  String get routeString {
    final origin = originAirportCode ?? originCity ?? '???';
    final dest = destinationAirportCode ?? destinationCity ?? '???';
    return '$origin → $dest';
  }

  /// Get carrier display string
  String get carrierString {
    if (carrierName != null && carrierCode != null) {
      return '$carrierName ($carrierCode)';
    }
    return carrierName ?? carrierCode ?? '';
  }

  Map<String, dynamic> toJson() {
    return {
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
      'passenger_details': passengerDetails,
      'price': price,
      'currency': currency,
    };
  }

  factory TransportItemDetails.fromJson(Map<String, dynamic> json) {
    return TransportItemDetails(
      mode: TransportMode.values.firstWhere(
        (e) => e.name == json['mode'],
        orElse: () => TransportMode.other,
      ),
      carrierName: json['carrier_name'] as String?,
      carrierCode: json['carrier_code'] as String?,
      transportNumber: json['transport_number'] as String?,
      bookingReference: json['booking_reference'] as String?,
      originCity: json['origin_city'] as String?,
      originCountryCode: json['origin_country_code'] as String?,
      originAirportCode: json['origin_airport_code'] as String?,
      originTerminal: json['origin_terminal'] as String?,
      destinationCity: json['destination_city'] as String?,
      destinationCountryCode: json['destination_country_code'] as String?,
      destinationAirportCode: json['destination_airport_code'] as String?,
      destinationTerminal: json['destination_terminal'] as String?,
      departureLocal: json['departure_local'] != null
          ? DateTime.parse(json['departure_local'] as String)
          : null,
      arrivalLocal: json['arrival_local'] != null
          ? DateTime.parse(json['arrival_local'] as String)
          : null,
      passengerCount: json['passenger_count'] as int?,
      passengerDetails: json['passenger_details'] as Map<String, dynamic>?,
      price: (json['price'] as num?)?.toDouble(),
      currency: json['currency'] as String?,
    );
  }
}

/// Stay item details
class StayItemDetails {
  final String accommodationName;
  final String? address;
  final String? city;
  final String? countryCode;
  final DateTime? checkinLocal;
  final DateTime? checkoutLocal;
  final bool hasBreakfast;
  final String? confirmationNumber;
  final String? bookingUrl;
  final double? latitude;
  final double? longitude;

  const StayItemDetails({
    required this.accommodationName,
    this.address,
    this.city,
    this.countryCode,
    this.checkinLocal,
    this.checkoutLocal,
    this.hasBreakfast = false,
    this.confirmationNumber,
    this.bookingUrl,
    this.latitude,
    this.longitude,
  });

  /// Get location display string
  String get locationString {
    if (city != null && countryCode != null) {
      return '$city, $countryCode';
    }
    return city ?? countryCode ?? '';
  }

  Map<String, dynamic> toJson() {
    return {
      'accommodation_name': accommodationName,
      'address': address,
      'city': city,
      'country_code': countryCode,
      'checkin_local': checkinLocal?.toIso8601String(),
      'checkout_local': checkoutLocal?.toIso8601String(),
      'has_breakfast': hasBreakfast,
      'confirmation_number': confirmationNumber,
      'booking_url': bookingUrl,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  factory StayItemDetails.fromJson(Map<String, dynamic> json) {
    return StayItemDetails(
      accommodationName: json['accommodation_name'] as String,
      address: json['address'] as String?,
      city: json['city'] as String?,
      countryCode: json['country_code'] as String?,
      checkinLocal: json['checkin_local'] != null
          ? DateTime.parse(json['checkin_local'] as String)
          : null,
      checkoutLocal: json['checkout_local'] != null
          ? DateTime.parse(json['checkout_local'] as String)
          : null,
      hasBreakfast: json['has_breakfast'] as bool? ?? false,
      confirmationNumber: json['confirmation_number'] as String?,
      bookingUrl: json['booking_url'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
    );
  }
}

/// Activity item details
class ActivityItemDetails {
  final String? category;
  final String? locationName;
  final String? address;
  final String? city;
  final String? countryCode;
  final DateTime? startLocal;
  final DateTime? endLocal;
  final String? bookingCode;
  final String? bookingUrl;
  final double? latitude;
  final double? longitude;

  const ActivityItemDetails({
    this.category,
    this.locationName,
    this.address,
    this.city,
    this.countryCode,
    this.startLocal,
    this.endLocal,
    this.bookingCode,
    this.bookingUrl,
    this.latitude,
    this.longitude,
  });

  /// Get location display string
  String get locationString {
    if (city != null && countryCode != null) {
      return '$city, $countryCode';
    }
    return city ?? locationName ?? '';
  }

  Map<String, dynamic> toJson() {
    return {
      'category': category,
      'location_name': locationName,
      'address': address,
      'city': city,
      'country_code': countryCode,
      'start_local': startLocal?.toIso8601String(),
      'end_local': endLocal?.toIso8601String(),
      'booking_code': bookingCode,
      'booking_url': bookingUrl,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  factory ActivityItemDetails.fromJson(Map<String, dynamic> json) {
    return ActivityItemDetails(
      category: json['category'] as String?,
      locationName: json['location_name'] as String?,
      address: json['address'] as String?,
      city: json['city'] as String?,
      countryCode: json['country_code'] as String?,
      startLocal: json['start_local'] != null
          ? DateTime.parse(json['start_local'] as String)
          : null,
      endLocal: json['end_local'] != null
          ? DateTime.parse(json['end_local'] as String)
          : null,
      bookingCode: json['booking_code'] as String?,
      bookingUrl: json['booking_url'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
    );
  }
}
