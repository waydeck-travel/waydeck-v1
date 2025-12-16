// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trip_expense.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TripExpenseImpl _$$TripExpenseImplFromJson(Map<String, dynamic> json) =>
    _$TripExpenseImpl(
      id: json['id'] as String,
      tripId: json['tripId'] as String,
      category: json['category'] as String,
      description: json['description'] as String,
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String,
      paymentStatus: json['paymentStatus'] as String? ?? 'not_paid',
      paymentMethod: json['paymentMethod'] as String?,
      expenseDate: json['expenseDate'] == null
          ? null
          : DateTime.parse(json['expenseDate'] as String),
      notes: json['notes'] as String?,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$TripExpenseImplToJson(_$TripExpenseImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'tripId': instance.tripId,
      'category': instance.category,
      'description': instance.description,
      'amount': instance.amount,
      'currency': instance.currency,
      'paymentStatus': instance.paymentStatus,
      'paymentMethod': instance.paymentMethod,
      'expenseDate': instance.expenseDate?.toIso8601String(),
      'notes': instance.notes,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };
