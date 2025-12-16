import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../shared/models/models.dart';

/// Documents Repository
/// 
/// INTEGRATION POINT FOR INTEGRATION AGENT:
/// This repository handles document uploads and retrieval from Supabase Storage.
class DocumentsRepository {
  final SupabaseClient _client;

  DocumentsRepository({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  String? get _userId => _client.auth.currentUser?.id;

  /// Get documents for a trip
  Future<List<Document>> getTripDocuments(String tripId) async {
    if (_userId == null) return [];

    try {
      final response = await _client
          .from('documents')
          .select()
          .eq('trip_id', tripId)
          .eq('owner_id', _userId!)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => Document.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Get documents for a trip item
  Future<List<Document>> getTripItemDocuments(String tripItemId) async {
    if (_userId == null) return [];

    try {
      final response = await _client
          .from('documents')
          .select()
          .eq('trip_item_id', tripItemId)
          .eq('owner_id', _userId!)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => Document.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Get a single document
  Future<Document?> getDocument(String docId) async {
    if (_userId == null) return null;

    try {
      final response = await _client
          .from('documents')
          .select()
          .eq('id', docId)
          .eq('owner_id', _userId!)
          .single();

      final doc = Document.fromJson(response);
      
      // Get signed URL for download
      final signedUrl = await _client.storage
          .from('trip_documents')
          .createSignedUrl(doc.storagePath, 3600);

      return doc.copyWith(downloadUrl: signedUrl);
    } catch (e) {
      return null;
    }
  }

  /// Upload a document
  /// 
  /// Uploads file to Supabase Storage and creates a document record in the database.
  /// 
  /// Parameters:
  /// - [fileName]: Original file name
  /// - [fileBytes]: File content as bytes
  /// - [mimeType]: MIME type of the file (e.g., 'application/pdf', 'image/jpeg')
  /// - [docType]: Type of document (ticket, voucher, etc.)
  /// - [tripId]: Optional trip to attach to
  /// - [tripItemId]: Optional trip item to attach to
  Future<Document?> uploadDocument({
    required String fileName,
    required List<int> fileBytes,
    required String mimeType,
    required DocumentType docType,
    String? tripId,
    String? tripItemId,
  }) async {
    if (_userId == null) return null;

    try {
      // Generate unique storage path
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final sanitizedFileName = fileName.replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_');
      final folder = tripItemId ?? tripId ?? 'general';
      final storagePath = '$_userId/$folder/${timestamp}_$sanitizedFileName';

      // Upload to Supabase Storage
      await _client.storage
          .from('trip_documents')
          .uploadBinary(storagePath, Uint8List.fromList(fileBytes), 
            fileOptions: FileOptions(contentType: mimeType));

      // Create database record
      final data = {
        'owner_id': _userId,
        'trip_id': tripId,
        'trip_item_id': tripItemId,
        'doc_type': _docTypeToString(docType),
        'file_name': fileName,
        'mime_type': mimeType,
        'storage_path': storagePath,
        'size_bytes': fileBytes.length,
      };

      final response = await _client
          .from('documents')
          .insert(data)
          .select()
          .single();

      return Document.fromJson(response);
    } catch (e) {
      // Log error for debugging
      // print('Document upload error: $e');
      return null;
    }
  }

  /// Delete a document
  Future<bool> deleteDocument(String docId) async {
    if (_userId == null) return false;

    try {
      // Get document to find storage path
      final doc = await getDocument(docId);
      if (doc == null) return false;

      // Delete from storage
      await _client.storage.from('trip_documents').remove([doc.storagePath]);

      // Delete from database
      await _client.from('documents').delete().eq('id', docId);

      return true;
    } catch (e) {
      return false;
    }
  }

  String _docTypeToString(DocumentType type) {
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
}

// Provider
final documentsRepositoryProvider = Provider<DocumentsRepository>((ref) {
  return DocumentsRepository();
});
