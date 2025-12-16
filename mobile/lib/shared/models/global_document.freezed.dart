// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'global_document.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

GlobalDocumentModel _$GlobalDocumentModelFromJson(Map<String, dynamic> json) {
  return _GlobalDocumentModel.fromJson(json);
}

/// @nodoc
mixin _$GlobalDocumentModel {
  String get id => throw _privateConstructorUsedError;
  String get ownerId => throw _privateConstructorUsedError;
  String get docType =>
      throw _privateConstructorUsedError; // passport, visa, travel_insurance, health_card, id_card, vaccination_certificate, other
  String? get title => throw _privateConstructorUsedError;
  String? get countryCode => throw _privateConstructorUsedError;
  String? get documentNumber => throw _privateConstructorUsedError;
  String get fileName => throw _privateConstructorUsedError;
  String? get mimeType => throw _privateConstructorUsedError;
  String get storagePath => throw _privateConstructorUsedError;
  int? get sizeBytes => throw _privateConstructorUsedError;
  DateTime? get issueDate => throw _privateConstructorUsedError;
  DateTime? get expiryDate => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;

  /// Serializes this GlobalDocumentModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of GlobalDocumentModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $GlobalDocumentModelCopyWith<GlobalDocumentModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GlobalDocumentModelCopyWith<$Res> {
  factory $GlobalDocumentModelCopyWith(
    GlobalDocumentModel value,
    $Res Function(GlobalDocumentModel) then,
  ) = _$GlobalDocumentModelCopyWithImpl<$Res, GlobalDocumentModel>;
  @useResult
  $Res call({
    String id,
    String ownerId,
    String docType,
    String? title,
    String? countryCode,
    String? documentNumber,
    String fileName,
    String? mimeType,
    String storagePath,
    int? sizeBytes,
    DateTime? issueDate,
    DateTime? expiryDate,
    String? notes,
    DateTime? createdAt,
  });
}

/// @nodoc
class _$GlobalDocumentModelCopyWithImpl<$Res, $Val extends GlobalDocumentModel>
    implements $GlobalDocumentModelCopyWith<$Res> {
  _$GlobalDocumentModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of GlobalDocumentModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? ownerId = null,
    Object? docType = null,
    Object? title = freezed,
    Object? countryCode = freezed,
    Object? documentNumber = freezed,
    Object? fileName = null,
    Object? mimeType = freezed,
    Object? storagePath = null,
    Object? sizeBytes = freezed,
    Object? issueDate = freezed,
    Object? expiryDate = freezed,
    Object? notes = freezed,
    Object? createdAt = freezed,
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
            docType: null == docType
                ? _value.docType
                : docType // ignore: cast_nullable_to_non_nullable
                      as String,
            title: freezed == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String?,
            countryCode: freezed == countryCode
                ? _value.countryCode
                : countryCode // ignore: cast_nullable_to_non_nullable
                      as String?,
            documentNumber: freezed == documentNumber
                ? _value.documentNumber
                : documentNumber // ignore: cast_nullable_to_non_nullable
                      as String?,
            fileName: null == fileName
                ? _value.fileName
                : fileName // ignore: cast_nullable_to_non_nullable
                      as String,
            mimeType: freezed == mimeType
                ? _value.mimeType
                : mimeType // ignore: cast_nullable_to_non_nullable
                      as String?,
            storagePath: null == storagePath
                ? _value.storagePath
                : storagePath // ignore: cast_nullable_to_non_nullable
                      as String,
            sizeBytes: freezed == sizeBytes
                ? _value.sizeBytes
                : sizeBytes // ignore: cast_nullable_to_non_nullable
                      as int?,
            issueDate: freezed == issueDate
                ? _value.issueDate
                : issueDate // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            expiryDate: freezed == expiryDate
                ? _value.expiryDate
                : expiryDate // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            notes: freezed == notes
                ? _value.notes
                : notes // ignore: cast_nullable_to_non_nullable
                      as String?,
            createdAt: freezed == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$GlobalDocumentModelImplCopyWith<$Res>
    implements $GlobalDocumentModelCopyWith<$Res> {
  factory _$$GlobalDocumentModelImplCopyWith(
    _$GlobalDocumentModelImpl value,
    $Res Function(_$GlobalDocumentModelImpl) then,
  ) = __$$GlobalDocumentModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String ownerId,
    String docType,
    String? title,
    String? countryCode,
    String? documentNumber,
    String fileName,
    String? mimeType,
    String storagePath,
    int? sizeBytes,
    DateTime? issueDate,
    DateTime? expiryDate,
    String? notes,
    DateTime? createdAt,
  });
}

/// @nodoc
class __$$GlobalDocumentModelImplCopyWithImpl<$Res>
    extends _$GlobalDocumentModelCopyWithImpl<$Res, _$GlobalDocumentModelImpl>
    implements _$$GlobalDocumentModelImplCopyWith<$Res> {
  __$$GlobalDocumentModelImplCopyWithImpl(
    _$GlobalDocumentModelImpl _value,
    $Res Function(_$GlobalDocumentModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of GlobalDocumentModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? ownerId = null,
    Object? docType = null,
    Object? title = freezed,
    Object? countryCode = freezed,
    Object? documentNumber = freezed,
    Object? fileName = null,
    Object? mimeType = freezed,
    Object? storagePath = null,
    Object? sizeBytes = freezed,
    Object? issueDate = freezed,
    Object? expiryDate = freezed,
    Object? notes = freezed,
    Object? createdAt = freezed,
  }) {
    return _then(
      _$GlobalDocumentModelImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        ownerId: null == ownerId
            ? _value.ownerId
            : ownerId // ignore: cast_nullable_to_non_nullable
                  as String,
        docType: null == docType
            ? _value.docType
            : docType // ignore: cast_nullable_to_non_nullable
                  as String,
        title: freezed == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String?,
        countryCode: freezed == countryCode
            ? _value.countryCode
            : countryCode // ignore: cast_nullable_to_non_nullable
                  as String?,
        documentNumber: freezed == documentNumber
            ? _value.documentNumber
            : documentNumber // ignore: cast_nullable_to_non_nullable
                  as String?,
        fileName: null == fileName
            ? _value.fileName
            : fileName // ignore: cast_nullable_to_non_nullable
                  as String,
        mimeType: freezed == mimeType
            ? _value.mimeType
            : mimeType // ignore: cast_nullable_to_non_nullable
                  as String?,
        storagePath: null == storagePath
            ? _value.storagePath
            : storagePath // ignore: cast_nullable_to_non_nullable
                  as String,
        sizeBytes: freezed == sizeBytes
            ? _value.sizeBytes
            : sizeBytes // ignore: cast_nullable_to_non_nullable
                  as int?,
        issueDate: freezed == issueDate
            ? _value.issueDate
            : issueDate // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        expiryDate: freezed == expiryDate
            ? _value.expiryDate
            : expiryDate // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        notes: freezed == notes
            ? _value.notes
            : notes // ignore: cast_nullable_to_non_nullable
                  as String?,
        createdAt: freezed == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$GlobalDocumentModelImpl implements _GlobalDocumentModel {
  const _$GlobalDocumentModelImpl({
    required this.id,
    required this.ownerId,
    required this.docType,
    this.title,
    this.countryCode,
    this.documentNumber,
    required this.fileName,
    this.mimeType,
    required this.storagePath,
    this.sizeBytes,
    this.issueDate,
    this.expiryDate,
    this.notes,
    this.createdAt,
  });

  factory _$GlobalDocumentModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$GlobalDocumentModelImplFromJson(json);

  @override
  final String id;
  @override
  final String ownerId;
  @override
  final String docType;
  // passport, visa, travel_insurance, health_card, id_card, vaccination_certificate, other
  @override
  final String? title;
  @override
  final String? countryCode;
  @override
  final String? documentNumber;
  @override
  final String fileName;
  @override
  final String? mimeType;
  @override
  final String storagePath;
  @override
  final int? sizeBytes;
  @override
  final DateTime? issueDate;
  @override
  final DateTime? expiryDate;
  @override
  final String? notes;
  @override
  final DateTime? createdAt;

  @override
  String toString() {
    return 'GlobalDocumentModel(id: $id, ownerId: $ownerId, docType: $docType, title: $title, countryCode: $countryCode, documentNumber: $documentNumber, fileName: $fileName, mimeType: $mimeType, storagePath: $storagePath, sizeBytes: $sizeBytes, issueDate: $issueDate, expiryDate: $expiryDate, notes: $notes, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GlobalDocumentModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.ownerId, ownerId) || other.ownerId == ownerId) &&
            (identical(other.docType, docType) || other.docType == docType) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.countryCode, countryCode) ||
                other.countryCode == countryCode) &&
            (identical(other.documentNumber, documentNumber) ||
                other.documentNumber == documentNumber) &&
            (identical(other.fileName, fileName) ||
                other.fileName == fileName) &&
            (identical(other.mimeType, mimeType) ||
                other.mimeType == mimeType) &&
            (identical(other.storagePath, storagePath) ||
                other.storagePath == storagePath) &&
            (identical(other.sizeBytes, sizeBytes) ||
                other.sizeBytes == sizeBytes) &&
            (identical(other.issueDate, issueDate) ||
                other.issueDate == issueDate) &&
            (identical(other.expiryDate, expiryDate) ||
                other.expiryDate == expiryDate) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    ownerId,
    docType,
    title,
    countryCode,
    documentNumber,
    fileName,
    mimeType,
    storagePath,
    sizeBytes,
    issueDate,
    expiryDate,
    notes,
    createdAt,
  );

  /// Create a copy of GlobalDocumentModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GlobalDocumentModelImplCopyWith<_$GlobalDocumentModelImpl> get copyWith =>
      __$$GlobalDocumentModelImplCopyWithImpl<_$GlobalDocumentModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$GlobalDocumentModelImplToJson(this);
  }
}

abstract class _GlobalDocumentModel implements GlobalDocumentModel {
  const factory _GlobalDocumentModel({
    required final String id,
    required final String ownerId,
    required final String docType,
    final String? title,
    final String? countryCode,
    final String? documentNumber,
    required final String fileName,
    final String? mimeType,
    required final String storagePath,
    final int? sizeBytes,
    final DateTime? issueDate,
    final DateTime? expiryDate,
    final String? notes,
    final DateTime? createdAt,
  }) = _$GlobalDocumentModelImpl;

  factory _GlobalDocumentModel.fromJson(Map<String, dynamic> json) =
      _$GlobalDocumentModelImpl.fromJson;

  @override
  String get id;
  @override
  String get ownerId;
  @override
  String get docType; // passport, visa, travel_insurance, health_card, id_card, vaccination_certificate, other
  @override
  String? get title;
  @override
  String? get countryCode;
  @override
  String? get documentNumber;
  @override
  String get fileName;
  @override
  String? get mimeType;
  @override
  String get storagePath;
  @override
  int? get sizeBytes;
  @override
  DateTime? get issueDate;
  @override
  DateTime? get expiryDate;
  @override
  String? get notes;
  @override
  DateTime? get createdAt;

  /// Create a copy of GlobalDocumentModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GlobalDocumentModelImplCopyWith<_$GlobalDocumentModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
