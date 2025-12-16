/// Traveller model
class Traveller {
  final String id;
  final String ownerId;
  final String fullName;
  final String? email;
  final String? phone;
  final String? passportNumber;
  final DateTime? passportExpiry;
  final String? nationality;
  final DateTime? dateOfBirth;
  final String? notes;
  final String? avatarUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Traveller({
    required this.id,
    required this.ownerId,
    required this.fullName,
    this.email,
    this.phone,
    this.passportNumber,
    this.passportExpiry,
    this.nationality,
    this.dateOfBirth,
    this.notes,
    this.avatarUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Create from JSON
  factory Traveller.fromJson(Map<String, dynamic> json) {
    return Traveller(
      id: json['id'] as String,
      ownerId: json['owner_id'] as String,
      fullName: json['full_name'] as String,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      passportNumber: json['passport_number'] as String?,
      passportExpiry: json['passport_expiry'] != null
          ? DateTime.parse(json['passport_expiry'] as String)
          : null,
      nationality: json['nationality'] as String?,
      dateOfBirth: json['date_of_birth'] != null
          ? DateTime.parse(json['date_of_birth'] as String)
          : null,
      notes: json['notes'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  /// Convert to JSON for insert/update
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'owner_id': ownerId,
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
  }

  /// Create a copy with updated fields
  Traveller copyWith({
    String? id,
    String? ownerId,
    String? fullName,
    String? email,
    String? phone,
    String? passportNumber,
    DateTime? passportExpiry,
    String? nationality,
    DateTime? dateOfBirth,
    String? notes,
    String? avatarUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Traveller(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      passportNumber: passportNumber ?? this.passportNumber,
      passportExpiry: passportExpiry ?? this.passportExpiry,
      nationality: nationality ?? this.nationality,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      notes: notes ?? this.notes,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Initials for avatar
  String get initials {
    final parts = fullName.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return fullName.isNotEmpty ? fullName[0].toUpperCase() : '?';
  }

  /// Check if passport is expiring soon (within 6 months)
  bool get isPassportExpiringSoon {
    if (passportExpiry == null) return false;
    final sixMonthsFromNow = DateTime.now().add(const Duration(days: 180));
    return passportExpiry!.isBefore(sixMonthsFromNow);
  }

  /// Check if passport is expired
  bool get isPassportExpired {
    if (passportExpiry == null) return false;
    return passportExpiry!.isBefore(DateTime.now());
  }
}

/// Trip Traveller junction model
class TripTraveller {
  final String id;
  final String tripId;
  final String travellerId;
  final bool isPrimary;
  final DateTime createdAt;
  final Traveller? traveller; // Populated from join

  const TripTraveller({
    required this.id,
    required this.tripId,
    required this.travellerId,
    this.isPrimary = false,
    required this.createdAt,
    this.traveller,
  });

  factory TripTraveller.fromJson(Map<String, dynamic> json) {
    return TripTraveller(
      id: json['id'] as String,
      tripId: json['trip_id'] as String,
      travellerId: json['traveller_id'] as String,
      isPrimary: json['is_primary'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      traveller: json['travellers'] != null
          ? Traveller.fromJson(json['travellers'] as Map<String, dynamic>)
          : null,
    );
  }
}
