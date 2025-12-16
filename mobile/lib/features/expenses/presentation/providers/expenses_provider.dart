import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/expenses_repository.dart';
import '../../../../shared/models/trip_expense.dart';

/// Repository provider
final expensesRepositoryProvider = Provider<ExpensesRepository>((ref) {
  return ExpensesRepository();
});

/// Get all expenses for a trip
final tripExpensesProvider = FutureProvider.family<List<TripExpense>, String>(
  (ref, tripId) async {
    final repository = ref.watch(expensesRepositoryProvider);
    return repository.getExpenses(tripId);
  },
);

/// Get expenses grouped by category for a trip
final expensesByCategoryProvider = FutureProvider.family<Map<String, double>, String>(
  (ref, tripId) async {
    final repository = ref.watch(expensesRepositoryProvider);
    return repository.getExpensesByCategory(tripId);
  },
);

/// Get total spent for a trip
final totalSpentProvider = FutureProvider.family<double, String>(
  (ref, tripId) async {
    final repository = ref.watch(expensesRepositoryProvider);
    return repository.getTotalSpent(tripId);
  },
);

/// State notifier for expense form operations
class ExpenseFormNotifier extends StateNotifier<AsyncValue<void>> {
  final ExpensesRepository _repository;
  final Ref _ref;

  ExpenseFormNotifier(this._repository, this._ref) : super(const AsyncValue.data(null));

  Future<TripExpense?> createExpense({
    required String tripId,
    required String category,
    required String description,
    required double amount,
    required String currency,
    String paymentStatus = 'not_paid',
    String? paymentMethod,
    DateTime? expenseDate,
    String? notes,
  }) async {
    state = const AsyncValue.loading();
    try {
      final expense = await _repository.createExpense(
        tripId: tripId,
        category: category,
        description: description,
        amount: amount,
        currency: currency,
        paymentStatus: paymentStatus,
        paymentMethod: paymentMethod,
        expenseDate: expenseDate,
        notes: notes,
      );
      state = const AsyncValue.data(null);
      // Invalidate expense providers
      _ref.invalidate(tripExpensesProvider(tripId));
      _ref.invalidate(expensesByCategoryProvider(tripId));
      _ref.invalidate(totalSpentProvider(tripId));
      return expense;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return null;
    }
  }

  Future<bool> deleteExpense(String expenseId, String tripId) async {
    state = const AsyncValue.loading();
    try {
      final success = await _repository.deleteExpense(expenseId);
      state = const AsyncValue.data(null);
      if (success) {
        _ref.invalidate(tripExpensesProvider(tripId));
        _ref.invalidate(expensesByCategoryProvider(tripId));
        _ref.invalidate(totalSpentProvider(tripId));
      }
      return success;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }
}

final expenseFormProvider = StateNotifierProvider<ExpenseFormNotifier, AsyncValue<void>>((ref) {
  return ExpenseFormNotifier(ref.watch(expensesRepositoryProvider), ref);
});
