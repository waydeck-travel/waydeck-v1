// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trip_budget.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TripBudgetImpl _$$TripBudgetImplFromJson(Map<String, dynamic> json) =>
    _$TripBudgetImpl(
      id: json['id'] as String,
      tripId: json['tripId'] as String,
      category: json['category'] as String,
      budgetAmount: (json['budgetAmount'] as num).toDouble(),
      currency: json['currency'] as String,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$TripBudgetImplToJson(_$TripBudgetImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'tripId': instance.tripId,
      'category': instance.category,
      'budgetAmount': instance.budgetAmount,
      'currency': instance.currency,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };
