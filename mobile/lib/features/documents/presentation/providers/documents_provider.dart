import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/models/models.dart';
import '../../data/documents_repository.dart';

/// Documents for a trip
final tripDocumentsProvider =
    FutureProvider.family<List<Document>, String>((ref, tripId) async {
  final repo = ref.watch(documentsRepositoryProvider);
  return repo.getTripDocuments(tripId);
});

/// Documents for a trip item
final tripItemDocumentsProvider =
    FutureProvider.family<List<Document>, String>((ref, tripItemId) async {
  final repo = ref.watch(documentsRepositoryProvider);
  return repo.getTripItemDocuments(tripItemId);
});

/// Single document provider
final documentProvider =
    FutureProvider.family<Document?, String>((ref, docId) async {
  final repo = ref.watch(documentsRepositoryProvider);
  return repo.getDocument(docId);
});

/// Document actions
class DocumentActionsNotifier extends StateNotifier<AsyncValue<void>> {
  final DocumentsRepository _repo;
  final Ref _ref;

  DocumentActionsNotifier(this._repo, this._ref)
      : super(const AsyncValue.data(null));

  Future<bool> deleteDocument(String docId, {String? tripId, String? tripItemId}) async {
    state = const AsyncValue.loading();
    try {
      final success = await _repo.deleteDocument(docId);
      if (success) {
        if (tripId != null) {
          _ref.invalidate(tripDocumentsProvider(tripId));
        }
        if (tripItemId != null) {
          _ref.invalidate(tripItemDocumentsProvider(tripItemId));
        }
        state = const AsyncValue.data(null);
        return true;
      }
      state = AsyncValue.error('Failed to delete', StackTrace.current);
      return false;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }
}

final documentActionsProvider =
    StateNotifierProvider<DocumentActionsNotifier, AsyncValue<void>>((ref) {
  return DocumentActionsNotifier(ref.watch(documentsRepositoryProvider), ref);
});

/// Document upload state
class DocumentUploadState {
  final bool isUploading;
  final double? progress;
  final String? error;
  final Document? uploadedDocument;

  const DocumentUploadState({
    this.isUploading = false,
    this.progress,
    this.error,
    this.uploadedDocument,
  });

  DocumentUploadState copyWith({
    bool? isUploading,
    double? progress,
    String? error,
    Document? uploadedDocument,
  }) {
    return DocumentUploadState(
      isUploading: isUploading ?? this.isUploading,
      progress: progress,
      error: error,
      uploadedDocument: uploadedDocument,
    );
  }
}

/// Document upload notifier
class DocumentUploadNotifier extends StateNotifier<DocumentUploadState> {
  final DocumentsRepository _repo;
  final Ref _ref;

  DocumentUploadNotifier(this._repo, this._ref) 
      : super(const DocumentUploadState());

  /// Upload a document from file bytes
  /// 
  /// Returns true on success, false on failure
  Future<bool> uploadDocument({
    required String fileName,
    required List<int> fileBytes,
    required String mimeType,
    required DocumentType docType,
    String? tripId,
    String? tripItemId,
  }) async {
    state = state.copyWith(isUploading: true, error: null);

    try {
      final doc = await _repo.uploadDocument(
        fileName: fileName,
        fileBytes: fileBytes,
        mimeType: mimeType,
        docType: docType,
        tripId: tripId,
        tripItemId: tripItemId,
      );

      if (doc != null) {
        state = state.copyWith(isUploading: false, uploadedDocument: doc);
        
        // Invalidate relevant providers
        if (tripId != null) {
          _ref.invalidate(tripDocumentsProvider(tripId));
        }
        if (tripItemId != null) {
          _ref.invalidate(tripItemDocumentsProvider(tripItemId));
        }
        return true;
      } else {
        state = state.copyWith(
          isUploading: false, 
          error: 'Failed to upload document',
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(isUploading: false, error: e.toString());
      return false;
    }
  }

  void reset() {
    state = const DocumentUploadState();
  }
}

final documentUploadProvider =
    StateNotifierProvider<DocumentUploadNotifier, DocumentUploadState>((ref) {
  return DocumentUploadNotifier(ref.watch(documentsRepositoryProvider), ref);
});
