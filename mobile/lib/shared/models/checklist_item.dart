import 'enums.dart';

/// Checklist Item model
class ChecklistItem {
  final String id;
  final String tripId;
  final String title;
  final ChecklistCategory category;
  final ChecklistPhase phase;
  final bool isChecked;
  final DateTime? dueDate;
  final String? notes;
  final int sortIndex;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ChecklistItem({
    required this.id,
    required this.tripId,
    required this.title,
    required this.category,
    required this.phase,
    this.isChecked = false,
    this.dueDate,
    this.notes,
    this.sortIndex = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Create from JSON
  factory ChecklistItem.fromJson(Map<String, dynamic> json) {
    return ChecklistItem(
      id: json['id'] as String,
      tripId: json['trip_id'] as String,
      title: json['title'] as String,
      category: _stringToCategory(json['category'] as String? ?? 'custom'),
      phase: _stringToPhase(json['phase'] as String? ?? 'before_trip'),
      isChecked: json['is_checked'] as bool? ?? false,
      dueDate: json['due_date'] != null
          ? DateTime.parse(json['due_date'] as String)
          : null,
      notes: json['notes'] as String?,
      sortIndex: json['sort_index'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  /// Convert to JSON for insert/update
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'trip_id': tripId,
      'title': title,
      'category': _categoryToString(category),
      'phase': _phaseToString(phase),
      'is_checked': isChecked,
      'due_date': dueDate?.toIso8601String().substring(0, 10),
      'notes': notes,
      'sort_index': sortIndex,
    };
  }

  /// Create a copy with updated fields
  ChecklistItem copyWith({
    String? id,
    String? tripId,
    String? title,
    ChecklistCategory? category,
    ChecklistPhase? phase,
    bool? isChecked,
    DateTime? dueDate,
    String? notes,
    int? sortIndex,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ChecklistItem(
      id: id ?? this.id,
      tripId: tripId ?? this.tripId,
      title: title ?? this.title,
      category: category ?? this.category,
      phase: phase ?? this.phase,
      isChecked: isChecked ?? this.isChecked,
      dueDate: dueDate ?? this.dueDate,
      notes: notes ?? this.notes,
      sortIndex: sortIndex ?? this.sortIndex,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Helper methods for enum conversion
  static ChecklistCategory _stringToCategory(String value) {
    switch (value) {
      case 'packing':
        return ChecklistCategory.packing;
      case 'shopping':
        return ChecklistCategory.shopping;
      case 'documents':
        return ChecklistCategory.documents;
      case 'food':
        return ChecklistCategory.food;
      case 'health':
        return ChecklistCategory.health;
      case 'bookings':
        return ChecklistCategory.bookings;
      case 'transport':
        return ChecklistCategory.transport;
      default:
        return ChecklistCategory.custom;
    }
  }

  static ChecklistPhase _stringToPhase(String value) {
    switch (value) {
      case 'before_trip':
        return ChecklistPhase.beforeTrip;
      case 'during_trip':
        return ChecklistPhase.duringTrip;
      case 'after_trip':
        return ChecklistPhase.afterTrip;
      default:
        return ChecklistPhase.beforeTrip;
    }
  }

  static String _categoryToString(ChecklistCategory category) {
    switch (category) {
      case ChecklistCategory.packing:
        return 'packing';
      case ChecklistCategory.shopping:
        return 'shopping';
      case ChecklistCategory.documents:
        return 'documents';
      case ChecklistCategory.food:
        return 'food';
      case ChecklistCategory.health:
        return 'health';
      case ChecklistCategory.bookings:
        return 'bookings';
      case ChecklistCategory.transport:
        return 'transport';
      case ChecklistCategory.custom:
        return 'custom';
    }
  }

  static String _phaseToString(ChecklistPhase phase) {
    switch (phase) {
      case ChecklistPhase.beforeTrip:
        return 'before_trip';
      case ChecklistPhase.duringTrip:
        return 'during_trip';
      case ChecklistPhase.afterTrip:
        return 'after_trip';
    }
  }
}
