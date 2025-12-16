import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../shared/models/global_document.dart';

/// Global Documents Repository
/// Handles CRUD operations for user-level travel documents
class GlobalDocumentsRepository {
  final SupabaseClient _client;

  GlobalDocumentsRepository({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  String? get _userId => _client.auth.currentUser?.id;

  /// Get all global documents for the current user
  Future<List<GlobalDocumentModel>> getDocuments() async {
    if (_userId == null) return [];

    try {
      final response = await _client
          .from('global_documents')
          .select()
          .eq('owner_id', _userId!)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => GlobalDocumentModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('getDocuments error: $e');
      return [];
    }
  }

  /// Get documents by type
  Future<List<GlobalDocumentModel>> getDocumentsByType(String docType) async {
    if (_userId == null) return [];

    try {
      final response = await _client
          .from('global_documents')
          .select()
          .eq('owner_id', _userId!)
          .eq('doc_type', docType)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => GlobalDocumentModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('getDocumentsByType error: $e');
      return [];
    }
  }

  /// Upload a document
  Future<GlobalDocumentModel?> uploadDocument({
    required String docType,
    required String fileName,
    required Uint8List fileBytes,
    String? mimeType,
    String? title,
    String? countryCode,
    String? documentNumber,
    DateTime? issueDate,
    DateTime? expiryDate,
    String? notes,
  }) async {
    if (_userId == null) return null;

    try {
      // Upload file to storage
      final storagePath = '$_userId/${DateTime.now().millisecondsSinceEpoch}_$fileName';
      
      await _client.storage
          .from('global_documents')
          .uploadBinary(storagePath, fileBytes,
              fileOptions: FileOptions(contentType: mimeType));

      // Create database record
      final data = {
        'owner_id': _userId,
        'doc_type': docType,
        'title': title ?? fileName,
        'country_code': countryCode,
        'document_number': documentNumber,
        'file_name': fileName,
        'mime_type': mimeType,
        'storage_path': storagePath,
        'size_bytes': fileBytes.length,
        'issue_date': issueDate?.toIso8601String().split('T').first,
        'expiry_date': expiryDate?.toIso8601String().split('T').first,
        'notes': notes,
      };

      final response = await _client
          .from('global_documents')
          .insert(data)
          .select()
          .single();

      return GlobalDocumentModel.fromJson(response);
    } catch (e) {
      print('uploadDocument error: $e');
      return null;
    }
  }

  /// Get download URL for a document
  Future<String?> getDownloadUrl(String storagePath) async {
    try {
      final url = _client.storage
          .from('global_documents')
          .getPublicUrl(storagePath);
      return url;
    } catch (e) {
      // Try creating a signed URL if public access fails
      try {
        final signedUrl = await _client.storage
            .from('global_documents')
            .createSignedUrl(storagePath, 3600); // 1 hour
        return signedUrl;
      } catch (e2) {
        print('getDownloadUrl error: $e2');
        return null;
      }
    }
  }

  /// Update document metadata
  Future<GlobalDocumentModel?> updateDocument({
    required String documentId,
    String? title,
    String? countryCode,
    String? documentNumber,
    DateTime? issueDate,
    DateTime? expiryDate,
    String? notes,
  }) async {
    if (_userId == null) return null;

    try {
      final data = <String, dynamic>{};
      if (title != null) data['title'] = title;
      if (countryCode != null) data['country_code'] = countryCode;
      if (documentNumber != null) data['document_number'] = documentNumber;
      if (issueDate != null) data['issue_date'] = issueDate.toIso8601String().split('T').first;
      if (expiryDate != null) data['expiry_date'] = expiryDate.toIso8601String().split('T').first;
      if (notes != null) data['notes'] = notes;

      final response = await _client
          .from('global_documents')
          .update(data)
          .eq('id', documentId)
          .eq('owner_id', _userId!)
          .select()
          .single();

      return GlobalDocumentModel.fromJson(response);
    } catch (e) {
      print('updateDocument error: $e');
      return null;
    }
  }

  /// Delete a document (and its file from storage)
  Future<bool> deleteDocument(String documentId, String storagePath) async {
    if (_userId == null) return false;

    try {
      // Delete from storage
      await _client.storage
          .from('global_documents')
          .remove([storagePath]);

      // Delete database record
      await _client
          .from('global_documents')
          .delete()
          .eq('id', documentId)
          .eq('owner_id', _userId!);

      return true;
    } catch (e) {
      print('deleteDocument error: $e');
      return false;
    }
  }
}
