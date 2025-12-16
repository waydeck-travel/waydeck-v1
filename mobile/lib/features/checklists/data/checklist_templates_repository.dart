import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../shared/models/checklist_template.dart';

/// Checklist Templates Repository
/// Handles CRUD operations for reusable checklist templates
class ChecklistTemplatesRepository {
  final SupabaseClient _client;

  ChecklistTemplatesRepository({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  String? get _userId => _client.auth.currentUser?.id;

  /// Get all templates for the current user
  Future<List<ChecklistTemplateModel>> getTemplates() async {
    if (_userId == null) return [];

    try {
      final response = await _client
          .from('checklist_templates')
          .select()
          .eq('owner_id', _userId!)
          .order('name');

      return (response as List)
          .map((json) => ChecklistTemplateModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('getTemplates error: $e');
      return [];
    }
  }

  /// Get a template with its items
  Future<(ChecklistTemplateModel, List<ChecklistTemplateItemModel>)?> getTemplateWithItems(String templateId) async {
    if (_userId == null) return null;

    try {
      // Get template
      final templateResponse = await _client
          .from('checklist_templates')
          .select()
          .eq('id', templateId)
          .eq('owner_id', _userId!)
          .single();

      final template = ChecklistTemplateModel.fromJson(templateResponse);

      // Get items
      final itemsResponse = await _client
          .from('checklist_template_items')
          .select()
          .eq('template_id', templateId)
          .order('sort_order');

      final items = (itemsResponse as List)
          .map((json) => ChecklistTemplateItemModel.fromJson(json as Map<String, dynamic>))
          .toList();

      return (template, items);
    } catch (e) {
      print('getTemplateWithItems error: $e');
      return null;
    }
  }

  /// Get template items
  Future<List<ChecklistTemplateItemModel>> getTemplateItems(String templateId) async {
    try {
      final response = await _client
          .from('checklist_template_items')
          .select()
          .eq('template_id', templateId)
          .order('sort_order');

      return (response as List)
          .map((json) => ChecklistTemplateItemModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('getTemplateItems error: $e');
      return [];
    }
  }

  /// Create a new template
  Future<ChecklistTemplateModel?> createTemplate({
    required String name,
    String? description,
    String? icon,
  }) async {
    if (_userId == null) return null;

    try {
      final data = {
        'owner_id': _userId,
        'name': name,
        'description': description,
        'icon': icon,
      };

      final response = await _client
          .from('checklist_templates')
          .insert(data)
          .select()
          .single();

      return ChecklistTemplateModel.fromJson(response);
    } catch (e) {
      print('createTemplate error: $e');
      return null;
    }
  }

  /// Add item to a template
  Future<ChecklistTemplateItemModel?> addTemplateItem({
    required String templateId,
    required String title,
    String? category,
    String? phase,
    int? sortOrder,
  }) async {
    if (_userId == null) return null;

    try {
      final data = {
        'template_id': templateId,
        'title': title,
        'category': category,
        'phase': phase,
        'sort_order': sortOrder ?? 0,
      };

      final response = await _client
          .from('checklist_template_items')
          .insert(data)
          .select()
          .single();

      return ChecklistTemplateItemModel.fromJson(response);
    } catch (e) {
      print('addTemplateItem error: $e');
      return null;
    }
  }

  /// Update a template
  Future<ChecklistTemplateModel?> updateTemplate({
    required String templateId,
    String? name,
    String? description,
    String? icon,
  }) async {
    if (_userId == null) return null;

    try {
      final data = <String, dynamic>{
        'updated_at': DateTime.now().toIso8601String(),
      };
      if (name != null) data['name'] = name;
      if (description != null) data['description'] = description;
      if (icon != null) data['icon'] = icon;

      final response = await _client
          .from('checklist_templates')
          .update(data)
          .eq('id', templateId)
          .eq('owner_id', _userId!)
          .select()
          .single();

      return ChecklistTemplateModel.fromJson(response);
    } catch (e) {
      print('updateTemplate error: $e');
      return null;
    }
  }

  /// Delete a template (cascade deletes items)
  Future<bool> deleteTemplate(String templateId) async {
    if (_userId == null) return false;

    try {
      await _client
          .from('checklist_templates')
          .delete()
          .eq('id', templateId)
          .eq('owner_id', _userId!);
      return true;
    } catch (e) {
      print('deleteTemplate error: $e');
      return false;
    }
  }

  /// Delete a template item
  Future<bool> deleteTemplateItem(String itemId) async {
    try {
      await _client
          .from('checklist_template_items')
          .delete()
          .eq('id', itemId);
      return true;
    } catch (e) {
      print('deleteTemplateItem error: $e');
      return false;
    }
  }

  /// Import template items to a trip checklist
  Future<bool> importToTrip({
    required String templateId,
    required String tripId,
  }) async {
    if (_userId == null) return false;

    try {
      // Get template items
      final items = await getTemplateItems(templateId);

      // Insert each item as a checklist item
      for (final item in items) {
        await _client.from('checklist_items').insert({
          'trip_id': tripId,
          'title': item.title,
          'category': item.category ?? 'custom',
          'phase': item.phase ?? 'before_trip',
          'is_checked': false,
        });
      }

      return true;
    } catch (e) {
      print('importToTrip error: $e');
      return false;
    }
  }
}
