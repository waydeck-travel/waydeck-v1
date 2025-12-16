import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/budgets_repository.dart';
import '../../../../shared/models/trip_budget.dart';

/// Repository provider
final budgetsRepositoryProvider = Provider<BudgetsRepository>((ref) {
  return BudgetsRepository();
});

/// Get all budgets for a trip
final tripBudgetsProvider = FutureProvider.family<List<TripBudget>, String>(
  (ref, tripId) async {
    final repository = ref.watch(budgetsRepositoryProvider);
    return repository.getBudgets(tripId);
  },
);

/// Get total budget for a trip
final totalBudgetProvider = FutureProvider.family<double, String>(
  (ref, tripId) async {
    final repository = ref.watch(budgetsRepositoryProvider);
    return repository.getTotalBudget(tripId);
  },
);

/// State notifier for budget form operations
class BudgetFormNotifier extends StateNotifier<AsyncValue<void>> {
  final BudgetsRepository _repository;
  final Ref _ref;

  BudgetFormNotifier(this._repository, this._ref) : super(const AsyncValue.data(null));

  Future<TripBudget?> setBudget({
    required String tripId,
    required String category,
    required double amount,
    required String currency,
  }) async {
    state = const AsyncValue.loading();
    try {
      final budget = await _repository.setBudget(
        tripId: tripId,
        category: category,
        amount: amount,
        currency: currency,
      );
      state = const AsyncValue.data(null);
      // Invalidate budget providers
      _ref.invalidate(tripBudgetsProvider(tripId));
      _ref.invalidate(totalBudgetProvider(tripId));
      return budget;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return null;
    }
  }

  Future<bool> deleteBudget(String budgetId, String tripId) async {
    state = const AsyncValue.loading();
    try {
      final success = await _repository.deleteBudget(budgetId);
      state = const AsyncValue.data(null);
      if (success) {
        _ref.invalidate(tripBudgetsProvider(tripId));
        _ref.invalidate(totalBudgetProvider(tripId));
      }
      return success;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }
}

final budgetFormProvider = StateNotifierProvider<BudgetFormNotifier, AsyncValue<void>>((ref) {
  return BudgetFormNotifier(ref.watch(budgetsRepositoryProvider), ref);
});
