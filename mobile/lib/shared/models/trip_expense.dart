import 'package:freezed_annotation/freezed_annotation.dart';

part 'trip_expense.freezed.dart';
part 'trip_expense.g.dart';

/// Trip Expense model
/// Represents a custom/miscellaneous expense for a trip
@freezed
class TripExpense with _$TripExpense {
  const factory TripExpense({
    required String id,
    required String tripId,
    required String category, // transport, stay, activity, food, other
    required String description,
    required double amount,
    required String currency,
    @Default('not_paid') String paymentStatus, // not_paid, paid, partial
    String? paymentMethod,
    DateTime? expenseDate,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _TripExpense;

  factory TripExpense.fromJson(Map<String, dynamic> json) =>
      _$TripExpenseFromJson(_convertJsonKeys(json));

  static Map<String, dynamic> _convertJsonKeys(Map<String, dynamic> json) {
    return {
      'id': json['id'],
      'tripId': json['trip_id'],
      'category': json['category'],
      'description': json['description'],
      'amount': (json['amount'] as num?)?.toDouble() ?? 0.0,
      'currency': json['currency'] ?? 'USD',
      'paymentStatus': json['payment_status'] ?? 'not_paid',
      'paymentMethod': json['payment_method'],
      'expenseDate': json['expense_date'],
      'notes': json['notes'],
      'createdAt': json['created_at'],
      'updatedAt': json['updated_at'],
    };
  }
}
