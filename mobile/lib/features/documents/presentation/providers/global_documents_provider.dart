import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/global_documents_repository.dart';
import '../../../../shared/models/global_document.dart';

/// Repository provider
final globalDocumentsRepositoryProvider = Provider<GlobalDocumentsRepository>((ref) {
  return GlobalDocumentsRepository();
});

/// Get all global documents
final globalDocumentsProvider = FutureProvider<List<GlobalDocumentModel>>((ref) async {
  final repository = ref.watch(globalDocumentsRepositoryProvider);
  return repository.getDocuments();
});

/// Get documents by type
final globalDocumentsByTypeProvider = FutureProvider.family<List<GlobalDocumentModel>, String>(
  (ref, docType) async {
    final repository = ref.watch(globalDocumentsRepositoryProvider);
    return repository.getDocumentsByType(docType);
  },
);

/// State notifier for document operations
class GlobalDocumentFormNotifier extends StateNotifier<AsyncValue<void>> {
  final GlobalDocumentsRepository _repository;
  final Ref _ref;

  GlobalDocumentFormNotifier(this._repository, this._ref) 
      : super(const AsyncValue.data(null));

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
    state = const AsyncValue.loading();
    try {
      final document = await _repository.uploadDocument(
        docType: docType,
        fileName: fileName,
        fileBytes: fileBytes,
        mimeType: mimeType,
        title: title,
        countryCode: countryCode,
        documentNumber: documentNumber,
        issueDate: issueDate,
        expiryDate: expiryDate,
        notes: notes,
      );
      state = const AsyncValue.data(null);
      // Invalidate providers
      _ref.invalidate(globalDocumentsProvider);
      _ref.invalidate(globalDocumentsByTypeProvider(docType));
      return document;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return null;
    }
  }

  Future<bool> deleteDocument(String documentId, String storagePath, String docType) async {
    state = const AsyncValue.loading();
    try {
      final success = await _repository.deleteDocument(documentId, storagePath);
      state = const AsyncValue.data(null);
      if (success) {
        _ref.invalidate(globalDocumentsProvider);
        _ref.invalidate(globalDocumentsByTypeProvider(docType));
      }
      return success;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  Future<String?> getDownloadUrl(String storagePath) async {
    return _repository.getDownloadUrl(storagePath);
  }
}

final globalDocumentFormProvider = 
    StateNotifierProvider<GlobalDocumentFormNotifier, AsyncValue<void>>((ref) {
  return GlobalDocumentFormNotifier(ref.watch(globalDocumentsRepositoryProvider), ref);
});
