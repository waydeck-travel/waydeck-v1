import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../shared/models/trip_expense.dart';

/// Expenses Repository
/// Handles CRUD operations for trip expenses
class ExpensesRepository {
  final SupabaseClient _client;

  ExpensesRepository({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  String? get _userId => _client.auth.currentUser?.id;

  /// Get all expenses for a trip
  Future<List<TripExpense>> getExpenses(String tripId) async {
    if (_userId == null) return [];

    try {
      final response = await _client
          .from('trip_expenses')
          .select()
          .eq('trip_id', tripId)
          .order('expense_date', ascending: false);

      return (response as List)
          .map((json) => TripExpense.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('getExpenses error: $e');
      return [];
    }
  }

  /// Get total expenses by category for a trip
  Future<Map<String, double>> getExpensesByCategory(String tripId) async {
    final expenses = await getExpenses(tripId);
    final byCategory = <String, double>{};

    for (final expense in expenses) {
      byCategory[expense.category] = 
          (byCategory[expense.category] ?? 0) + expense.amount;
    }

    return byCategory;
  }

  /// Get total spent for a trip
  Future<double> getTotalSpent(String tripId) async {
    final expenses = await getExpenses(tripId);
    double total = 0.0;
    for (final e in expenses) {
      total += e.amount;
    }
    return total;
  }

  /// Create a new expense
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
    if (_userId == null) return null;

    try {
      final data = {
        'trip_id': tripId,
        'category': category,
        'description': description,
        'amount': amount,
        'currency': currency,
        'payment_status': paymentStatus,
        'payment_method': paymentMethod,
        'expense_date': expenseDate?.toIso8601String().split('T').first,
        'notes': notes,
      };

      final response = await _client
          .from('trip_expenses')
          .insert(data)
          .select()
          .single();

      return TripExpense.fromJson(response);
    } catch (e) {
      print('createExpense error: $e');
      return null;
    }
  }

  /// Update an expense
  Future<TripExpense?> updateExpense({
    required String expenseId,
    String? category,
    String? description,
    double? amount,
    String? currency,
    String? paymentStatus,
    String? paymentMethod,
    DateTime? expenseDate,
    String? notes,
  }) async {
    if (_userId == null) return null;

    try {
      final data = <String, dynamic>{
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (category != null) data['category'] = category;
      if (description != null) data['description'] = description;
      if (amount != null) data['amount'] = amount;
      if (currency != null) data['currency'] = currency;
      if (paymentStatus != null) data['payment_status'] = paymentStatus;
      if (paymentMethod != null) data['payment_method'] = paymentMethod;
      if (expenseDate != null) {
        data['expense_date'] = expenseDate.toIso8601String().split('T').first;
      }
      if (notes != null) data['notes'] = notes;

      final response = await _client
          .from('trip_expenses')
          .update(data)
          .eq('id', expenseId)
          .select()
          .single();

      return TripExpense.fromJson(response);
    } catch (e) {
      print('updateExpense error: $e');
      return null;
    }
  }

  /// Delete an expense
  Future<bool> deleteExpense(String expenseId) async {
    if (_userId == null) return false;

    try {
      await _client
          .from('trip_expenses')
          .delete()
          .eq('id', expenseId);
      return true;
    } catch (e) {
      print('deleteExpense error: $e');
      return false;
    }
  }
}
