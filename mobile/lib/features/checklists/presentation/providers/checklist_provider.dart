import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/models/models.dart';
import '../../data/checklist_repository.dart';

/// Provider for checklist items of a trip
final checklistItemsProvider = FutureProvider.autoDispose.family<List<ChecklistItem>, String>(
  (ref, tripId) async {
    final repo = ref.watch(checklistRepositoryProvider);
    return repo.getChecklistItems(tripId);
  },
);

/// Provider for checklist statistics
final checklistStatsProvider = FutureProvider.autoDispose.family<Map<String, int>, String>(
  (ref, tripId) async {
    final repo = ref.watch(checklistRepositoryProvider);
    return repo.getChecklistStats(tripId);
  },
);

/// Checklist form state
class ChecklistFormState {
  final bool isLoading;
  final String? error;
  final ChecklistItem? savedItem;

  const ChecklistFormState({
    this.isLoading = false,
    this.error,
    this.savedItem,
  });

  ChecklistFormState copyWith({
    bool? isLoading,
    String? error,
    ChecklistItem? savedItem,
  }) {
    return ChecklistFormState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      savedItem: savedItem,
    );
  }
}

/// Checklist form notifier for creating/updating items
class ChecklistFormNotifier extends StateNotifier<ChecklistFormState> {
  final ChecklistRepository _repo;
  final Ref _ref;

  ChecklistFormNotifier(this._repo, this._ref) : super(const ChecklistFormState());

  Future<bool> createItem({
    required String tripId,
    required String title,
    ChecklistCategory category = ChecklistCategory.custom,
    ChecklistPhase phase = ChecklistPhase.beforeTrip,
    DateTime? dueDate,
    String? notes,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final item = await _repo.createChecklistItem(
        tripId: tripId,
        title: title,
        category: category,
        phase: phase,
        dueDate: dueDate,
        notes: notes,
      );

      if (item != null) {
        state = state.copyWith(isLoading: false, savedItem: item);
        _ref.invalidate(checklistItemsProvider(tripId));
        _ref.invalidate(checklistStatsProvider(tripId));
        return true;
      } else {
        state = state.copyWith(isLoading: false, error: 'Failed to create item');
        return false;
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> toggleItem(String itemId, String tripId, bool isChecked) async {
    try {
      final success = await _repo.toggleChecklistItem(itemId, isChecked);
      if (success) {
        _ref.invalidate(checklistItemsProvider(tripId));
        _ref.invalidate(checklistStatsProvider(tripId));
      }
      return success;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteItem(String itemId, String tripId) async {
    try {
      final success = await _repo.deleteChecklistItem(itemId);
      if (success) {
        _ref.invalidate(checklistItemsProvider(tripId));
        _ref.invalidate(checklistStatsProvider(tripId));
      }
      return success;
    } catch (e) {
      return false;
    }
  }

  void reset() {
    state = const ChecklistFormState();
  }
}

final checklistFormProvider = StateNotifierProvider.autoDispose<ChecklistFormNotifier, ChecklistFormState>(
  (ref) => ChecklistFormNotifier(
    ref.watch(checklistRepositoryProvider),
    ref,
  ),
);
