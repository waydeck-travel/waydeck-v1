import 'enums.dart';

/// Trip model
class Trip {
  final String id;
  final String ownerId;
  final String name;
  final String? originCity;
  final String? originCountryCode;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? currency;
  final String? notes;
  final bool archived;
  final TripStatus status;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Computed counts (populated from joins)
  final int transportCount;
  final int stayCount;
  final int activityCount;
  final int noteCount;
  final int documentCount;

  const Trip({
    required this.id,
    required this.ownerId,
    required this.name,
    this.originCity,
    this.originCountryCode,
    this.startDate,
    this.endDate,
    this.currency,
    this.notes,
    this.archived = false,
    this.status = TripStatus.planned,
    this.startedAt,
    this.completedAt,
    required this.createdAt,
    required this.updatedAt,
    this.transportCount = 0,
    this.stayCount = 0,
    this.activityCount = 0,
    this.noteCount = 0,
    this.documentCount = 0,
  });

  /// Check if trip is currently active
  bool get isActive => status == TripStatus.active;

  /// Check if trip is completed
  bool get isCompleted => status == TripStatus.completed;

  /// Check if trip is planned
  bool get isPlanned => status == TripStatus.planned;

  /// Get formatted date range string
  String get dateRangeString {
    if (startDate == null && endDate == null) {
      return 'Dates not set';
    }
    if (startDate != null && endDate == null) {
      return 'From ${_formatDate(startDate!)}';
    }
    if (startDate == null && endDate != null) {
      return 'Until ${_formatDate(endDate!)}';
    }
    return '${_formatDate(startDate!)} – ${_formatDate(endDate!)}';
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  /// Get origin display string
  String get originString {
    if (originCity == null && originCountryCode == null) {
      return 'Origin not set';
    }
    if (originCity != null && originCountryCode != null) {
      return '$originCity, $originCountryCode';
    }
    return originCity ?? originCountryCode ?? '';
  }

  Trip copyWith({
    String? id,
    String? ownerId,
    String? name,
    String? originCity,
    String? originCountryCode,
    DateTime? startDate,
    DateTime? endDate,
    String? currency,
    String? notes,
    bool? archived,
    TripStatus? status,
    DateTime? startedAt,
    DateTime? completedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? transportCount,
    int? stayCount,
    int? activityCount,
    int? noteCount,
    int? documentCount,
  }) {
    return Trip(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      name: name ?? this.name,
      originCity: originCity ?? this.originCity,
      originCountryCode: originCountryCode ?? this.originCountryCode,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      currency: currency ?? this.currency,
      notes: notes ?? this.notes,
      archived: archived ?? this.archived,
      status: status ?? this.status,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      transportCount: transportCount ?? this.transportCount,
      stayCount: stayCount ?? this.stayCount,
      activityCount: activityCount ?? this.activityCount,
      noteCount: noteCount ?? this.noteCount,
      documentCount: documentCount ?? this.documentCount,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'owner_id': ownerId,
      'name': name,
      'origin_city': originCity,
      'origin_country_code': originCountryCode,
      'start_date': startDate?.toIso8601String().split('T').first,
      'end_date': endDate?.toIso8601String().split('T').first,
      'currency': currency,
      'notes': notes,
      'archived': archived,
      'status': status.toDbString(),
      'started_at': startedAt?.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory Trip.fromJson(Map<String, dynamic> json) {
    return Trip(
      id: json['id'] as String,
      ownerId: json['owner_id'] as String,
      name: json['name'] as String,
      originCity: json['origin_city'] as String?,
      originCountryCode: json['origin_country_code'] as String?,
      startDate: json['start_date'] != null
          ? DateTime.parse(json['start_date'] as String)
          : null,
      endDate: json['end_date'] != null
          ? DateTime.parse(json['end_date'] as String)
          : null,
      currency: json['currency'] as String?,
      notes: json['notes'] as String?,
      archived: json['archived'] as bool? ?? false,
      status: TripStatus.fromString(json['status'] as String?),
      startedAt: json['started_at'] != null
          ? DateTime.parse(json['started_at'] as String)
          : null,
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      transportCount: json['transport_count'] as int? ?? 0,
      stayCount: json['stay_count'] as int? ?? 0,
      activityCount: json['activity_count'] as int? ?? 0,
      noteCount: json['note_count'] as int? ?? 0,
      documentCount: json['document_count'] as int? ?? 0,
    );
  }
}

