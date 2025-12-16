import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/checklist_templates_repository.dart';
import '../../../../shared/models/checklist_template.dart';

/// Repository provider
final checklistTemplatesRepositoryProvider = Provider<ChecklistTemplatesRepository>((ref) {
  return ChecklistTemplatesRepository();
});

/// Get all templates
final checklistTemplatesProvider = FutureProvider<List<ChecklistTemplateModel>>((ref) async {
  final repository = ref.watch(checklistTemplatesRepositoryProvider);
  return repository.getTemplates();
});

/// Get template items
final templateItemsProvider = FutureProvider.family<List<ChecklistTemplateItemModel>, String>(
  (ref, templateId) async {
    final repository = ref.watch(checklistTemplatesRepositoryProvider);
    return repository.getTemplateItems(templateId);
  },
);

/// State notifier for template operations
class ChecklistTemplateFormNotifier extends StateNotifier<AsyncValue<void>> {
  final ChecklistTemplatesRepository _repository;
  final Ref _ref;

  ChecklistTemplateFormNotifier(this._repository, this._ref) 
      : super(const AsyncValue.data(null));

  Future<ChecklistTemplateModel?> createTemplate({
    required String name,
    String? description,
    String? icon,
  }) async {
    state = const AsyncValue.loading();
    try {
      final template = await _repository.createTemplate(
        name: name,
        description: description,
        icon: icon,
      );
      state = const AsyncValue.data(null);
      _ref.invalidate(checklistTemplatesProvider);
      return template;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return null;
    }
  }

  Future<ChecklistTemplateItemModel?> addItem({
    required String templateId,
    required String title,
    String? category,
    String? phase,
  }) async {
    state = const AsyncValue.loading();
    try {
      final item = await _repository.addTemplateItem(
        templateId: templateId,
        title: title,
        category: category,
        phase: phase,
      );
      state = const AsyncValue.data(null);
      _ref.invalidate(templateItemsProvider(templateId));
      return item;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return null;
    }
  }

  Future<bool> deleteTemplate(String templateId) async {
    state = const AsyncValue.loading();
    try {
      final success = await _repository.deleteTemplate(templateId);
      state = const AsyncValue.data(null);
      if (success) {
        _ref.invalidate(checklistTemplatesProvider);
      }
      return success;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  Future<bool> importToTrip(String templateId, String tripId) async {
    state = const AsyncValue.loading();
    try {
      final success = await _repository.importToTrip(
        templateId: templateId,
        tripId: tripId,
      );
      state = const AsyncValue.data(null);
      return success;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }
}

final checklistTemplateFormProvider = 
    StateNotifierProvider<ChecklistTemplateFormNotifier, AsyncValue<void>>((ref) {
  return ChecklistTemplateFormNotifier(ref.watch(checklistTemplatesRepositoryProvider), ref);
});
