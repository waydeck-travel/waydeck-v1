import 'enums.dart';

/// Document model for file attachments
class Document {
  final String id;
  final String ownerId;
  final String? tripId;
  final String? tripItemId;
  final DocumentType docType;
  final String fileName;
  final String? mimeType;
  final String storagePath;
  final int? sizeBytes;
  final DateTime createdAt;

  // Computed
  final String? downloadUrl;

  const Document({
    required this.id,
    required this.ownerId,
    this.tripId,
    this.tripItemId,
    required this.docType,
    required this.fileName,
    this.mimeType,
    required this.storagePath,
    this.sizeBytes,
    required this.createdAt,
    this.downloadUrl,
  });

  /// Check if this is an image
  bool get isImage {
    final mime = mimeType?.toLowerCase() ?? '';
    return mime.startsWith('image/');
  }

  /// Check if this is a PDF
  bool get isPdf {
    final mime = mimeType?.toLowerCase() ?? '';
    return mime == 'application/pdf';
  }

  /// Get human-readable file size
  String get fileSizeString {
    if (sizeBytes == null) return '';
    if (sizeBytes! < 1024) return '$sizeBytes B';
    if (sizeBytes! < 1024 * 1024) {
      return '${(sizeBytes! / 1024).toStringAsFixed(1)} KB';
    }
    return '${(sizeBytes! / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  Document copyWith({
    String? id,
    String? ownerId,
    String? tripId,
    String? tripItemId,
    DocumentType? docType,
    String? fileName,
    String? mimeType,
    String? storagePath,
    int? sizeBytes,
    DateTime? createdAt,
    String? downloadUrl,
  }) {
    return Document(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      tripId: tripId ?? this.tripId,
      tripItemId: tripItemId ?? this.tripItemId,
      docType: docType ?? this.docType,
      fileName: fileName ?? this.fileName,
      mimeType: mimeType ?? this.mimeType,
      storagePath: storagePath ?? this.storagePath,
      sizeBytes: sizeBytes ?? this.sizeBytes,
      createdAt: createdAt ?? this.createdAt,
      downloadUrl: downloadUrl ?? this.downloadUrl,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'owner_id': ownerId,
      'trip_id': tripId,
      'trip_item_id': tripItemId,
      'doc_type': _docTypeToString(docType),
      'file_name': fileName,
      'mime_type': mimeType,
      'storage_path': storagePath,
      'size_bytes': sizeBytes,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory Document.fromJson(Map<String, dynamic> json) {
    return Document(
      id: json['id'] as String,
      ownerId: json['owner_id'] as String,
      tripId: json['trip_id'] as String?,
      tripItemId: json['trip_item_id'] as String?,
      docType: _stringToDocType(json['doc_type'] as String),
      fileName: json['file_name'] as String,
      mimeType: json['mime_type'] as String?,
      storagePath: json['storage_path'] as String,
      sizeBytes: json['size_bytes'] as int?,
      createdAt: DateTime.parse(json['created_at'] as String),
      downloadUrl: json['download_url'] as String?,
    );
  }

  static String _docTypeToString(DocumentType type) {
    switch (type) {
      case DocumentType.passport:
        return 'passport';
      case DocumentType.visa:
        return 'visa';
      case DocumentType.insurance:
        return 'insurance';
      case DocumentType.ticket:
        return 'ticket';
      case DocumentType.hotelVoucher:
        return 'hotel_voucher';
      case DocumentType.activityVoucher:
        return 'activity_voucher';
      case DocumentType.other:
        return 'other';
    }
  }

  static DocumentType _stringToDocType(String value) {
    switch (value) {
      case 'ticket':
        return DocumentType.ticket;
      case 'hotel_voucher':
        return DocumentType.hotelVoucher;
      case 'activity_voucher':
        return DocumentType.activityVoucher;
      case 'visa':
        return DocumentType.visa;
      default:
        return DocumentType.other;
    }
  }
}
