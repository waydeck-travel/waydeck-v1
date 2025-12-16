import 'package:freezed_annotation/freezed_annotation.dart';

part 'trip_budget.freezed.dart';
part 'trip_budget.g.dart';

/// Trip Budget model
/// Represents a category-wise budget for a trip
@freezed
class TripBudget with _$TripBudget {
  const factory TripBudget({
    required String id,
    required String tripId,
    required String category, // transport, stay, activity, food, other
    required double budgetAmount,
    required String currency,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _TripBudget;

  factory TripBudget.fromJson(Map<String, dynamic> json) =>
      _$TripBudgetFromJson(_convertJsonKeys(json));

  static Map<String, dynamic> _convertJsonKeys(Map<String, dynamic> json) {
    return {
      'id': json['id'],
      'tripId': json['trip_id'],
      'category': json['category'],
      'budgetAmount': (json['budget_amount'] as num?)?.toDouble() ?? 0.0,
      'currency': json['currency'] ?? 'USD',
      'createdAt': json['created_at'],
      'updatedAt': json['updated_at'],
    };
  }
}
