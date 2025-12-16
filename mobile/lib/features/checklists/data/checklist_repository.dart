import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../shared/models/models.dart';

/// Checklist Repository
/// 
/// Handles CRUD operations for checklist items
class ChecklistRepository {
  final SupabaseClient _client;

  ChecklistRepository({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  String? get _userId => _client.auth.currentUser?.id;

  /// Get all checklist items for a trip
  Future<List<ChecklistItem>> getChecklistItems(String tripId) async {
    if (_userId == null) return [];

    try {
      final response = await _client
          .from('checklist_items')
          .select()
          .eq('trip_id', tripId)
          .order('phase')
          .order('category')
          .order('sort_index');

      return (response as List)
          .map((json) => ChecklistItem.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Create a new checklist item
  Future<ChecklistItem?> createChecklistItem({
    required String tripId,
    required String title,
    ChecklistCategory category = ChecklistCategory.custom,
    ChecklistPhase phase = ChecklistPhase.beforeTrip,
    DateTime? dueDate,
    String? notes,
  }) async {
    if (_userId == null) return null;

    try {
      final data = {
        'trip_id': tripId,
        'title': title,
        'category': _categoryToString(category),
        'phase': _phaseToString(phase),
        'is_checked': false,
        'due_date': dueDate?.toIso8601String().substring(0, 10),
        'notes': notes,
      };

      final response = await _client
          .from('checklist_items')
          .insert(data)
          .select()
          .single();

      return ChecklistItem.fromJson(response);
    } catch (e) {
      return null;
    }
  }

  /// Toggle checked status
  Future<bool> toggleChecklistItem(String itemId, bool isChecked) async {
    if (_userId == null) return false;

    try {
      await _client
          .from('checklist_items')
          .update({'is_checked': isChecked})
          .eq('id', itemId);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Update a checklist item
  Future<ChecklistItem?> updateChecklistItem({
    required String itemId,
    String? title,
    ChecklistCategory? category,
    ChecklistPhase? phase,
    bool? isChecked,
    DateTime? dueDate,
    String? notes,
  }) async {
    if (_userId == null) return null;

    try {
      final data = <String, dynamic>{};
      if (title != null) data['title'] = title;
      if (category != null) data['category'] = _categoryToString(category);
      if (phase != null) data['phase'] = _phaseToString(phase);
      if (isChecked != null) data['is_checked'] = isChecked;
      if (dueDate != null) data['due_date'] = dueDate.toIso8601String().substring(0, 10);
      if (notes != null) data['notes'] = notes;

      if (data.isEmpty) return null;

      final response = await _client
          .from('checklist_items')
          .update(data)
          .eq('id', itemId)
          .select()
          .single();

      return ChecklistItem.fromJson(response);
    } catch (e) {
      return null;
    }
  }

  /// Delete a checklist item
  Future<bool> deleteChecklistItem(String itemId) async {
    if (_userId == null) return false;

    try {
      await _client
          .from('checklist_items')
          .delete()
          .eq('id', itemId);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Get checklist statistics for a trip
  Future<Map<String, int>> getChecklistStats(String tripId) async {
    if (_userId == null) return {'total': 0, 'checked': 0};

    try {
      final response = await _client
          .from('checklist_items')
          .select()
          .eq('trip_id', tripId);

      final items = response as List;
      final total = items.length;
      final checked = items.where((i) => i['is_checked'] == true).length;

      return {'total': total, 'checked': checked};
    } catch (e) {
      return {'total': 0, 'checked': 0};
    }
  }

  // Helper methods for enum conversion
  String _categoryToString(ChecklistCategory category) {
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

  String _phaseToString(ChecklistPhase phase) {
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

// Provider
final checklistRepositoryProvider = Provider<ChecklistRepository>((ref) {
  return ChecklistRepository();
});
