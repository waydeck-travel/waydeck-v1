// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'global_document.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$GlobalDocumentModelImpl _$$GlobalDocumentModelImplFromJson(
  Map<String, dynamic> json,
) => _$GlobalDocumentModelImpl(
  id: json['id'] as String,
  ownerId: json['ownerId'] as String,
  docType: json['docType'] as String,
  title: json['title'] as String?,
  countryCode: json['countryCode'] as String?,
  documentNumber: json['documentNumber'] as String?,
  fileName: json['fileName'] as String,
  mimeType: json['mimeType'] as String?,
  storagePath: json['storagePath'] as String,
  sizeBytes: (json['sizeBytes'] as num?)?.toInt(),
  issueDate: json['issueDate'] == null
      ? null
      : DateTime.parse(json['issueDate'] as String),
  expiryDate: json['expiryDate'] == null
      ? null
      : DateTime.parse(json['expiryDate'] as String),
  notes: json['notes'] as String?,
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$$GlobalDocumentModelImplToJson(
  _$GlobalDocumentModelImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'ownerId': instance.ownerId,
  'docType': instance.docType,
  'title': instance.title,
  'countryCode': instance.countryCode,
  'documentNumber': instance.documentNumber,
  'fileName': instance.fileName,
  'mimeType': instance.mimeType,
  'storagePath': instance.storagePath,
  'sizeBytes': instance.sizeBytes,
  'issueDate': instance.issueDate?.toIso8601String(),
  'expiryDate': instance.expiryDate?.toIso8601String(),
  'notes': instance.notes,
  'createdAt': instance.createdAt?.toIso8601String(),
};
