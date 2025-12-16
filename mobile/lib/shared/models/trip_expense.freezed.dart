// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'trip_expense.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

TripExpense _$TripExpenseFromJson(Map<String, dynamic> json) {
  return _TripExpense.fromJson(json);
}

/// @nodoc
mixin _$TripExpense {
  String get id => throw _privateConstructorUsedError;
  String get tripId => throw _privateConstructorUsedError;
  String get category =>
      throw _privateConstructorUsedError; // transport, stay, activity, food, other
  String get description => throw _privateConstructorUsedError;
  double get amount => throw _privateConstructorUsedError;
  String get currency => throw _privateConstructorUsedError;
  String get paymentStatus =>
      throw _privateConstructorUsedError; // not_paid, paid, partial
  String? get paymentMethod => throw _privateConstructorUsedError;
  DateTime? get expenseDate => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this TripExpense to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TripExpense
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TripExpenseCopyWith<TripExpense> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TripExpenseCopyWith<$Res> {
  factory $TripExpenseCopyWith(
    TripExpense value,
    $Res Function(TripExpense) then,
  ) = _$TripExpenseCopyWithImpl<$Res, TripExpense>;
  @useResult
  $Res call({
    String id,
    String tripId,
    String category,
    String description,
    double amount,
    String currency,
    String paymentStatus,
    String? paymentMethod,
    DateTime? expenseDate,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
}

/// @nodoc
class _$TripExpenseCopyWithImpl<$Res, $Val extends TripExpense>
    implements $TripExpenseCopyWith<$Res> {
  _$TripExpenseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TripExpense
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? tripId = null,
    Object? category = null,
    Object? description = null,
    Object? amount = null,
    Object? currency = null,
    Object? paymentStatus = null,
    Object? paymentMethod = freezed,
    Object? expenseDate = freezed,
    Object? notes = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            tripId: null == tripId
                ? _value.tripId
                : tripId // ignore: cast_nullable_to_non_nullable
                      as String,
            category: null == category
                ? _value.category
                : category // ignore: cast_nullable_to_non_nullable
                      as String,
            description: null == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String,
            amount: null == amount
                ? _value.amount
                : amount // ignore: cast_nullable_to_non_nullable
                      as double,
            currency: null == currency
                ? _value.currency
                : currency // ignore: cast_nullable_to_non_nullable
                      as String,
            paymentStatus: null == paymentStatus
                ? _value.paymentStatus
                : paymentStatus // ignore: cast_nullable_to_non_nullable
                      as String,
            paymentMethod: freezed == paymentMethod
                ? _value.paymentMethod
                : paymentMethod // ignore: cast_nullable_to_non_nullable
                      as String?,
            expenseDate: freezed == expenseDate
                ? _value.expenseDate
                : expenseDate // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            notes: freezed == notes
                ? _value.notes
                : notes // ignore: cast_nullable_to_non_nullable
                      as String?,
            createdAt: freezed == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            updatedAt: freezed == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$TripExpenseImplCopyWith<$Res>
    implements $TripExpenseCopyWith<$Res> {
  factory _$$TripExpenseImplCopyWith(
    _$TripExpenseImpl value,
    $Res Function(_$TripExpenseImpl) then,
  ) = __$$TripExpenseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String tripId,
    String category,
    String description,
    double amount,
    String currency,
    String paymentStatus,
    String? paymentMethod,
    DateTime? expenseDate,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
}

/// @nodoc
class __$$TripExpenseImplCopyWithImpl<$Res>
    extends _$TripExpenseCopyWithImpl<$Res, _$TripExpenseImpl>
    implements _$$TripExpenseImplCopyWith<$Res> {
  __$$TripExpenseImplCopyWithImpl(
    _$TripExpenseImpl _value,
    $Res Function(_$TripExpenseImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of TripExpense
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? tripId = null,
    Object? category = null,
    Object? description = null,
    Object? amount = null,
    Object? currency = null,
    Object? paymentStatus = null,
    Object? paymentMethod = freezed,
    Object? expenseDate = freezed,
    Object? notes = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(
      _$TripExpenseImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        tripId: null == tripId
            ? _value.tripId
            : tripId // ignore: cast_nullable_to_non_nullable
                  as String,
        category: null == category
            ? _value.category
            : category // ignore: cast_nullable_to_non_nullable
                  as String,
        description: null == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String,
        amount: null == amount
            ? _value.amount
            : amount // ignore: cast_nullable_to_non_nullable
                  as double,
        currency: null == currency
            ? _value.currency
            : currency // ignore: cast_nullable_to_non_nullable
                  as String,
        paymentStatus: null == paymentStatus
            ? _value.paymentStatus
            : paymentStatus // ignore: cast_nullable_to_non_nullable
                  as String,
        paymentMethod: freezed == paymentMethod
            ? _value.paymentMethod
            : paymentMethod // ignore: cast_nullable_to_non_nullable
                  as String?,
        expenseDate: freezed == expenseDate
            ? _value.expenseDate
            : expenseDate // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        notes: freezed == notes
            ? _value.notes
            : notes // ignore: cast_nullable_to_non_nullable
                  as String?,
        createdAt: freezed == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        updatedAt: freezed == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$TripExpenseImpl implements _TripExpense {
  const _$TripExpenseImpl({
    required this.id,
    required this.tripId,
    required this.category,
    required this.description,
    required this.amount,
    required this.currency,
    this.paymentStatus = 'not_paid',
    this.paymentMethod,
    this.expenseDate,
    this.notes,
    this.createdAt,
    this.updatedAt,
  });

  factory _$TripExpenseImpl.fromJson(Map<String, dynamic> json) =>
      _$$TripExpenseImplFromJson(json);

  @override
  final String id;
  @override
  final String tripId;
  @override
  final String category;
  // transport, stay, activity, food, other
  @override
  final String description;
  @override
  final double amount;
  @override
  final String currency;
  @override
  @JsonKey()
  final String paymentStatus;
  // not_paid, paid, partial
  @override
  final String? paymentMethod;
  @override
  final DateTime? expenseDate;
  @override
  final String? notes;
  @override
  final DateTime? createdAt;
  @override
  final DateTime? updatedAt;

  @override
  String toString() {
    return 'TripExpense(id: $id, tripId: $tripId, category: $category, description: $description, amount: $amount, currency: $currency, paymentStatus: $paymentStatus, paymentMethod: $paymentMethod, expenseDate: $expenseDate, notes: $notes, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TripExpenseImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.tripId, tripId) || other.tripId == tripId) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.amount, amount) || other.amount == amount) &&
            (identical(other.currency, currency) ||
                other.currency == currency) &&
            (identical(other.paymentStatus, paymentStatus) ||
                other.paymentStatus == paymentStatus) &&
            (identical(other.paymentMethod, paymentMethod) ||
                other.paymentMethod == paymentMethod) &&
            (identical(other.expenseDate, expenseDate) ||
                other.expenseDate == expenseDate) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    tripId,
    category,
    description,
    amount,
    currency,
    paymentStatus,
    paymentMethod,
    expenseDate,
    notes,
    createdAt,
    updatedAt,
  );

  /// Create a copy of TripExpense
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TripExpenseImplCopyWith<_$TripExpenseImpl> get copyWith =>
      __$$TripExpenseImplCopyWithImpl<_$TripExpenseImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TripExpenseImplToJson(this);
  }
}

abstract class _TripExpense implements TripExpense {
  const factory _TripExpense({
    required final String id,
    required final String tripId,
    required final String category,
    required final String description,
    required final double amount,
    required final String currency,
    final String paymentStatus,
    final String? paymentMethod,
    final DateTime? expenseDate,
    final String? notes,
    final DateTime? createdAt,
    final DateTime? updatedAt,
  }) = _$TripExpenseImpl;

  factory _TripExpense.fromJson(Map<String, dynamic> json) =
      _$TripExpenseImpl.fromJson;

  @override
  String get id;
  @override
  String get tripId;
  @override
  String get category; // transport, stay, activity, food, other
  @override
  String get description;
  @override
  double get amount;
  @override
  String get currency;
  @override
  String get paymentStatus; // not_paid, paid, partial
  @override
  String? get paymentMethod;
  @override
  DateTime? get expenseDate;
  @override
  String? get notes;
  @override
  DateTime? get createdAt;
  @override
  DateTime? get updatedAt;

  /// Create a copy of TripExpense
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TripExpenseImplCopyWith<_$TripExpenseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
