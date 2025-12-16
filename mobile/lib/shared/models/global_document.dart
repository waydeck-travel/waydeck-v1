import 'package:freezed_annotation/freezed_annotation.dart';

part 'global_document.freezed.dart';
part 'global_document.g.dart';

/// Global Document model
/// Represents a user-level travel document (passport, visa, etc.)
@freezed
class GlobalDocumentModel with _$GlobalDocumentModel {
  const factory GlobalDocumentModel({
    required String id,
    required String ownerId,
    required String docType, // passport, visa, travel_insurance, health_card, id_card, vaccination_certificate, other
    String? title,
    String? countryCode,
    String? documentNumber,
    required String fileName,
    String? mimeType,
    required String storagePath,
    int? sizeBytes,
    DateTime? issueDate,
    DateTime? expiryDate,
    String? notes,
    DateTime? createdAt,
  }) = _GlobalDocumentModel;

  factory GlobalDocumentModel.fromJson(Map<String, dynamic> json) =>
      _$GlobalDocumentModelFromJson(_convertJsonKeys(json));

  static Map<String, dynamic> _convertJsonKeys(Map<String, dynamic> json) {
    return {
      'id': json['id'],
      'ownerId': json['owner_id'],
      'docType': json['doc_type'],
      'title': json['title'],
      'countryCode': json['country_code'],
      'documentNumber': json['document_number'],
      'fileName': json['file_name'],
      'mimeType': json['mime_type'],
      'storagePath': json['storage_path'],
      'sizeBytes': json['size_bytes'],
      'issueDate': json['issue_date'],
      'expiryDate': json['expiry_date'],
      'notes': json['notes'],
      'createdAt': json['created_at'],
    };
  }
}
