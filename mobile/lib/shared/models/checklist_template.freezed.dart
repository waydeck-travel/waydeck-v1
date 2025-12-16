// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'checklist_template.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

ChecklistTemplateModel _$ChecklistTemplateModelFromJson(
  Map<String, dynamic> json,
) {
  return _ChecklistTemplateModel.fromJson(json);
}

/// @nodoc
mixin _$ChecklistTemplateModel {
  String get id => throw _privateConstructorUsedError;
  String get ownerId => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  String? get icon => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this ChecklistTemplateModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ChecklistTemplateModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ChecklistTemplateModelCopyWith<ChecklistTemplateModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ChecklistTemplateModelCopyWith<$Res> {
  factory $ChecklistTemplateModelCopyWith(
    ChecklistTemplateModel value,
    $Res Function(ChecklistTemplateModel) then,
  ) = _$ChecklistTemplateModelCopyWithImpl<$Res, ChecklistTemplateModel>;
  @useResult
  $Res call({
    String id,
    String ownerId,
    String name,
    String? description,
    String? icon,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
}

/// @nodoc
class _$ChecklistTemplateModelCopyWithImpl<
  $Res,
  $Val extends ChecklistTemplateModel
>
    implements $ChecklistTemplateModelCopyWith<$Res> {
  _$ChecklistTemplateModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ChecklistTemplateModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? ownerId = null,
    Object? name = null,
    Object? description = freezed,
    Object? icon = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            ownerId: null == ownerId
                ? _value.ownerId
                : ownerId // ignore: cast_nullable_to_non_nullable
                      as String,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            description: freezed == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String?,
            icon: freezed == icon
                ? _value.icon
                : icon // ignore: cast_nullable_to_non_nullable
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
abstract class _$$ChecklistTemplateModelImplCopyWith<$Res>
    implements $ChecklistTemplateModelCopyWith<$Res> {
  factory _$$ChecklistTemplateModelImplCopyWith(
    _$ChecklistTemplateModelImpl value,
    $Res Function(_$ChecklistTemplateModelImpl) then,
  ) = __$$ChecklistTemplateModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String ownerId,
    String name,
    String? description,
    String? icon,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
}

/// @nodoc
class __$$ChecklistTemplateModelImplCopyWithImpl<$Res>
    extends
        _$ChecklistTemplateModelCopyWithImpl<$Res, _$ChecklistTemplateModelImpl>
    implements _$$ChecklistTemplateModelImplCopyWith<$Res> {
  __$$ChecklistTemplateModelImplCopyWithImpl(
    _$ChecklistTemplateModelImpl _value,
    $Res Function(_$ChecklistTemplateModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ChecklistTemplateModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? ownerId = null,
    Object? name = null,
    Object? description = freezed,
    Object? icon = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(
      _$ChecklistTemplateModelImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        ownerId: null == ownerId
            ? _value.ownerId
            : ownerId // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        description: freezed == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String?,
        icon: freezed == icon
            ? _value.icon
            : icon // ignore: cast_nullable_to_non_nullable
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
class _$ChecklistTemplateModelImpl implements _ChecklistTemplateModel {
  const _$ChecklistTemplateModelImpl({
    required this.id,
    required this.ownerId,
    required this.name,
    this.description,
    this.icon,
    this.createdAt,
    this.updatedAt,
  });

  factory _$ChecklistTemplateModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$ChecklistTemplateModelImplFromJson(json);

  @override
  final String id;
  @override
  final String ownerId;
  @override
  final String name;
  @override
  final String? description;
  @override
  final String? icon;
  @override
  final DateTime? createdAt;
  @override
  final DateTime? updatedAt;

  @override
  String toString() {
    return 'ChecklistTemplateModel(id: $id, ownerId: $ownerId, name: $name, description: $description, icon: $icon, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ChecklistTemplateModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.ownerId, ownerId) || other.ownerId == ownerId) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.icon, icon) || other.icon == icon) &&
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
    ownerId,
    name,
    description,
    icon,
    createdAt,
    updatedAt,
  );

  /// Create a copy of ChecklistTemplateModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ChecklistTemplateModelImplCopyWith<_$ChecklistTemplateModelImpl>
  get copyWith =>
      __$$ChecklistTemplateModelImplCopyWithImpl<_$ChecklistTemplateModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ChecklistTemplateModelImplToJson(this);
  }
}

abstract class _ChecklistTemplateModel implements ChecklistTemplateModel {
  const factory _ChecklistTemplateModel({
    required final String id,
    required final String ownerId,
    required final String name,
    final String? description,
    final String? icon,
    final DateTime? createdAt,
    final DateTime? updatedAt,
  }) = _$ChecklistTemplateModelImpl;

  factory _ChecklistTemplateModel.fromJson(Map<String, dynamic> json) =
      _$ChecklistTemplateModelImpl.fromJson;

  @override
  String get id;
  @override
  String get ownerId;
  @override
  String get name;
  @override
  String? get description;
  @override
  String? get icon;
  @override
  DateTime? get createdAt;
  @override
  DateTime? get updatedAt;

  /// Create a copy of ChecklistTemplateModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ChecklistTemplateModelImplCopyWith<_$ChecklistTemplateModelImpl>
  get copyWith => throw _privateConstructorUsedError;
}

ChecklistTemplateItemModel _$ChecklistTemplateItemModelFromJson(
  Map<String, dynamic> json,
) {
  return _ChecklistTemplateItemModel.fromJson(json);
}

/// @nodoc
mixin _$ChecklistTemplateItemModel {
  String get id => throw _privateConstructorUsedError;
  String get templateId => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String? get category =>
      throw _privateConstructorUsedError; // packing, documents, shopping, etc.
  String? get phase =>
      throw _privateConstructorUsedError; // before_trip, during_trip, after_trip
  int? get sortOrder => throw _privateConstructorUsedError;

  /// Serializes this ChecklistTemplateItemModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ChecklistTemplateItemModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ChecklistTemplateItemModelCopyWith<ChecklistTemplateItemModel>
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ChecklistTemplateItemModelCopyWith<$Res> {
  factory $ChecklistTemplateItemModelCopyWith(
    ChecklistTemplateItemModel value,
    $Res Function(ChecklistTemplateItemModel) then,
  ) =
      _$ChecklistTemplateItemModelCopyWithImpl<
        $Res,
        ChecklistTemplateItemModel
      >;
  @useResult
  $Res call({
    String id,
    String templateId,
    String title,
    String? category,
    String? phase,
    int? sortOrder,
  });
}

/// @nodoc
class _$ChecklistTemplateItemModelCopyWithImpl<
  $Res,
  $Val extends ChecklistTemplateItemModel
>
    implements $ChecklistTemplateItemModelCopyWith<$Res> {
  _$ChecklistTemplateItemModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ChecklistTemplateItemModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? templateId = null,
    Object? title = null,
    Object? category = freezed,
    Object? phase = freezed,
    Object? sortOrder = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            templateId: null == templateId
                ? _value.templateId
                : templateId // ignore: cast_nullable_to_non_nullable
                      as String,
            title: null == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String,
            category: freezed == category
                ? _value.category
                : category // ignore: cast_nullable_to_non_nullable
                      as String?,
            phase: freezed == phase
                ? _value.phase
                : phase // ignore: cast_nullable_to_non_nullable
                      as String?,
            sortOrder: freezed == sortOrder
                ? _value.sortOrder
                : sortOrder // ignore: cast_nullable_to_non_nullable
                      as int?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ChecklistTemplateItemModelImplCopyWith<$Res>
    implements $ChecklistTemplateItemModelCopyWith<$Res> {
  factory _$$ChecklistTemplateItemModelImplCopyWith(
    _$ChecklistTemplateItemModelImpl value,
    $Res Function(_$ChecklistTemplateItemModelImpl) then,
  ) = __$$ChecklistTemplateItemModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String templateId,
    String title,
    String? category,
    String? phase,
    int? sortOrder,
  });
}

/// @nodoc
class __$$ChecklistTemplateItemModelImplCopyWithImpl<$Res>
    extends
        _$ChecklistTemplateItemModelCopyWithImpl<
          $Res,
          _$ChecklistTemplateItemModelImpl
        >
    implements _$$ChecklistTemplateItemModelImplCopyWith<$Res> {
  __$$ChecklistTemplateItemModelImplCopyWithImpl(
    _$ChecklistTemplateItemModelImpl _value,
    $Res Function(_$ChecklistTemplateItemModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ChecklistTemplateItemModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? templateId = null,
    Object? title = null,
    Object? category = freezed,
    Object? phase = freezed,
    Object? sortOrder = freezed,
  }) {
    return _then(
      _$ChecklistTemplateItemModelImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        templateId: null == templateId
            ? _value.templateId
            : templateId // ignore: cast_nullable_to_non_nullable
                  as String,
        title: null == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        category: freezed == category
            ? _value.category
            : category // ignore: cast_nullable_to_non_nullable
                  as String?,
        phase: freezed == phase
            ? _value.phase
            : phase // ignore: cast_nullable_to_non_nullable
                  as String?,
        sortOrder: freezed == sortOrder
            ? _value.sortOrder
            : sortOrder // ignore: cast_nullable_to_non_nullable
                  as int?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ChecklistTemplateItemModelImpl implements _ChecklistTemplateItemModel {
  const _$ChecklistTemplateItemModelImpl({
    required this.id,
    required this.templateId,
    required this.title,
    this.category,
    this.phase,
    this.sortOrder,
  });

  factory _$ChecklistTemplateItemModelImpl.fromJson(
    Map<String, dynamic> json,
  ) => _$$ChecklistTemplateItemModelImplFromJson(json);

  @override
  final String id;
  @override
  final String templateId;
  @override
  final String title;
  @override
  final String? category;
  // packing, documents, shopping, etc.
  @override
  final String? phase;
  // before_trip, during_trip, after_trip
  @override
  final int? sortOrder;

  @override
  String toString() {
    return 'ChecklistTemplateItemModel(id: $id, templateId: $templateId, title: $title, category: $category, phase: $phase, sortOrder: $sortOrder)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ChecklistTemplateItemModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.templateId, templateId) ||
                other.templateId == templateId) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.phase, phase) || other.phase == phase) &&
            (identical(other.sortOrder, sortOrder) ||
                other.sortOrder == sortOrder));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    templateId,
    title,
    category,
    phase,
    sortOrder,
  );

  /// Create a copy of ChecklistTemplateItemModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ChecklistTemplateItemModelImplCopyWith<_$ChecklistTemplateItemModelImpl>
  get copyWith =>
      __$$ChecklistTemplateItemModelImplCopyWithImpl<
        _$ChecklistTemplateItemModelImpl
      >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ChecklistTemplateItemModelImplToJson(this);
  }
}

abstract class _ChecklistTemplateItemModel
    implements ChecklistTemplateItemModel {
  const factory _ChecklistTemplateItemModel({
    required final String id,
    required final String templateId,
    required final String title,
    final String? category,
    final String? phase,
    final int? sortOrder,
  }) = _$ChecklistTemplateItemModelImpl;

  factory _ChecklistTemplateItemModel.fromJson(Map<String, dynamic> json) =
      _$ChecklistTemplateItemModelImpl.fromJson;

  @override
  String get id;
  @override
  String get templateId;
  @override
  String get title;
  @override
  String? get category; // packing, documents, shopping, etc.
  @override
  String? get phase; // before_trip, during_trip, after_trip
  @override
  int? get sortOrder;

  /// Create a copy of ChecklistTemplateItemModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ChecklistTemplateItemModelImplCopyWith<_$ChecklistTemplateItemModelImpl>
  get copyWith => throw _privateConstructorUsedError;
}
