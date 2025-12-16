import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../shared/models/trip_budget.dart';

/// Budgets Repository
/// Handles CRUD operations for trip budgets
class BudgetsRepository {
  final SupabaseClient _client;

  BudgetsRepository({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  String? get _userId => _client.auth.currentUser?.id;

  /// Get all budgets for a trip
  Future<List<TripBudget>> getBudgets(String tripId) async {
    if (_userId == null) return [];

    try {
      final response = await _client
          .from('trip_budgets')
          .select()
          .eq('trip_id', tripId)
          .order('category');

      return (response as List)
          .map((json) => TripBudget.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('getBudgets error: $e');
      return [];
    }
  }

  /// Get budget for a specific category
  Future<TripBudget?> getBudgetByCategory(String tripId, String category) async {
    if (_userId == null) return null;

    try {
      final response = await _client
          .from('trip_budgets')
          .select()
          .eq('trip_id', tripId)
          .eq('category', category)
          .maybeSingle();

      if (response == null) return null;
      return TripBudget.fromJson(response);
    } catch (e) {
      print('getBudgetByCategory error: $e');
      return null;
    }
  }

  /// Get total budget for a trip
  Future<double> getTotalBudget(String tripId) async {
    final budgets = await getBudgets(tripId);
    double total = 0.0;
    for (final b in budgets) {
      total += b.budgetAmount;
    }
    return total;
  }

  /// Create or update a budget (upsert by category)
  Future<TripBudget?> setBudget({
    required String tripId,
    required String category,
    required double amount,
    required String currency,
  }) async {
    if (_userId == null) return null;

    try {
      final data = {
        'trip_id': tripId,
        'category': category,
        'budget_amount': amount,
        'currency': currency,
      };

      // Upsert: insert or update on conflict (trip_id, category)
      final response = await _client
          .from('trip_budgets')
          .upsert(data, onConflict: 'trip_id,category')
          .select()
          .single();

      return TripBudget.fromJson(response);
    } catch (e) {
      print('setBudget error: $e');
      return null;
    }
  }

  /// Delete a budget
  Future<bool> deleteBudget(String budgetId) async {
    if (_userId == null) return false;

    try {
      await _client
          .from('trip_budgets')
          .delete()
          .eq('id', budgetId);
      return true;
    } catch (e) {
      print('deleteBudget error: $e');
      return false;
    }
  }
}
