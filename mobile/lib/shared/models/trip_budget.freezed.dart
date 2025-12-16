// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'trip_budget.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

TripBudget _$TripBudgetFromJson(Map<String, dynamic> json) {
  return _TripBudget.fromJson(json);
}

/// @nodoc
mixin _$TripBudget {
  String get id => throw _privateConstructorUsedError;
  String get tripId => throw _privateConstructorUsedError;
  String get category =>
      throw _privateConstructorUsedError; // transport, stay, activity, food, other
  double get budgetAmount => throw _privateConstructorUsedError;
  String get currency => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this TripBudget to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TripBudget
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TripBudgetCopyWith<TripBudget> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TripBudgetCopyWith<$Res> {
  factory $TripBudgetCopyWith(
    TripBudget value,
    $Res Function(TripBudget) then,
  ) = _$TripBudgetCopyWithImpl<$Res, TripBudget>;
  @useResult
  $Res call({
    String id,
    String tripId,
    String category,
    double budgetAmount,
    String currency,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
}

/// @nodoc
class _$TripBudgetCopyWithImpl<$Res, $Val extends TripBudget>
    implements $TripBudgetCopyWith<$Res> {
  _$TripBudgetCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TripBudget
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? tripId = null,
    Object? category = null,
    Object? budgetAmount = null,
    Object? currency = null,
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
            budgetAmount: null == budgetAmount
                ? _value.budgetAmount
                : budgetAmount // ignore: cast_nullable_to_non_nullable
                      as double,
            currency: null == currency
                ? _value.currency
                : currency // ignore: cast_nullable_to_non_nullable
                      as String,
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
abstract class _$$TripBudgetImplCopyWith<$Res>
    implements $TripBudgetCopyWith<$Res> {
  factory _$$TripBudgetImplCopyWith(
    _$TripBudgetImpl value,
    $Res Function(_$TripBudgetImpl) then,
  ) = __$$TripBudgetImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String tripId,
    String category,
    double budgetAmount,
    String currency,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
}

/// @nodoc
class __$$TripBudgetImplCopyWithImpl<$Res>
    extends _$TripBudgetCopyWithImpl<$Res, _$TripBudgetImpl>
    implements _$$TripBudgetImplCopyWith<$Res> {
  __$$TripBudgetImplCopyWithImpl(
    _$TripBudgetImpl _value,
    $Res Function(_$TripBudgetImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of TripBudget
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? tripId = null,
    Object? category = null,
    Object? budgetAmount = null,
    Object? currency = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(
      _$TripBudgetImpl(
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
        budgetAmount: null == budgetAmount
            ? _value.budgetAmount
            : budgetAmount // ignore: cast_nullable_to_non_nullable
                  as double,
        currency: null == currency
            ? _value.currency
            : currency // ignore: cast_nullable_to_non_nullable
                  as String,
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
class _$TripBudgetImpl implements _TripBudget {
  const _$TripBudgetImpl({
    required this.id,
    required this.tripId,
    required this.category,
    required this.budgetAmount,
    required this.currency,
    this.createdAt,
    this.updatedAt,
  });

  factory _$TripBudgetImpl.fromJson(Map<String, dynamic> json) =>
      _$$TripBudgetImplFromJson(json);

  @override
  final String id;
  @override
  final String tripId;
  @override
  final String category;
  // transport, stay, activity, food, other
  @override
  final double budgetAmount;
  @override
  final String currency;
  @override
  final DateTime? createdAt;
  @override
  final DateTime? updatedAt;

  @override
  String toString() {
    return 'TripBudget(id: $id, tripId: $tripId, category: $category, budgetAmount: $budgetAmount, currency: $currency, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TripBudgetImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.tripId, tripId) || other.tripId == tripId) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.budgetAmount, budgetAmount) ||
                other.budgetAmount == budgetAmount) &&
            (identical(other.currency, currency) ||
                other.currency == currency) &&
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
    budgetAmount,
    currency,
    createdAt,
    updatedAt,
  );

  /// Create a copy of TripBudget
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TripBudgetImplCopyWith<_$TripBudgetImpl> get copyWith =>
      __$$TripBudgetImplCopyWithImpl<_$TripBudgetImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TripBudgetImplToJson(this);
  }
}

abstract class _TripBudget implements TripBudget {
  const factory _TripBudget({
    required final String id,
    required final String tripId,
    required final String category,
    required final double budgetAmount,
    required final String currency,
    final DateTime? createdAt,
    final DateTime? updatedAt,
  }) = _$TripBudgetImpl;

  factory _TripBudget.fromJson(Map<String, dynamic> json) =
      _$TripBudgetImpl.fromJson;

  @override
  String get id;
  @override
  String get tripId;
  @override
  String get category; // transport, stay, activity, food, other
  @override
  double get budgetAmount;
  @override
  String get currency;
  @override
  DateTime? get createdAt;
  @override
  DateTime? get updatedAt;

  /// Create a copy of TripBudget
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TripBudgetImplCopyWith<_$TripBudgetImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
