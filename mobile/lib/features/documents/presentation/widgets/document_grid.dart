import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';

import '../../../../app/theme.dart';
import '../../../../shared/models/models.dart';
import '../../../../shared/ui/ui.dart';
import '../providers/documents_provider.dart';

/// Document grid widget for displaying documents
class DocumentGrid extends ConsumerStatefulWidget {
  final String? tripId;
  final String? tripItemId;
  final DocumentType? defaultDocType;

  const DocumentGrid({
    super.key,
    this.tripId,
    this.tripItemId,
    this.defaultDocType,
  });

  @override
  ConsumerState<DocumentGrid> createState() => _DocumentGridState();
}

class _DocumentGridState extends ConsumerState<DocumentGrid> {
  bool _isUploading = false;

  @override
  Widget build(BuildContext context) {
    final docsAsync = widget.tripItemId != null
        ? ref.watch(tripItemDocumentsProvider(widget.tripItemId!))
        : widget.tripId != null
            ? ref.watch(tripDocumentsProvider(widget.tripId!))
            : const AsyncValue<List<Document>>.data([]);

    return docsAsync.when(
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: CircularProgressIndicator(),
        ),
      ),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (docs) {
        if (docs.isEmpty) {
          return _buildEmptyState(context);
        }

        return Column(
          children: [
            ...docs.map((doc) => _DocumentTile(
                  doc: doc,
                  onTap: () => context.push('/documents/${doc.id}'),
                )),
            const SizedBox(height: 8),
            _buildAddButton(context),
          ],
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return WaydeckCard(
      child: Column(
        children: [
          const Text('📎', style: TextStyle(fontSize: 32)),
          const SizedBox(height: 8),
          Text(
            'No documents attached',
            style: WaydeckTheme.bodySmall.copyWith(
              color: WaydeckTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          _buildAddButton(context),
        ],
      ),
    );
  }

  Widget _buildAddButton(BuildContext context) {
    if (_isUploading) {
      return const Padding(
        padding: EdgeInsets.all(8),
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    return OutlinedButton.icon(
      onPressed: _pickAndUploadDocument,
      icon: const Icon(Icons.add, size: 18),
      label: const Text('Add Document'),
    );
  }

  Future<void> _pickAndUploadDocument() async {
    // Pick file
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png', 'webp'],
      withData: true,
    );

    if (result == null || result.files.isEmpty) return;

    final file = result.files.first;
    if (file.bytes == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not read file')),
        );
      }
      return;
    }

    // Determine document type (use default or show picker)
    DocumentType? docType = widget.defaultDocType;
    if (docType == null && mounted) {
      docType = await _showDocTypeDialog();
      if (docType == null) return; // User cancelled
    }

    // Upload document
    setState(() => _isUploading = true);

    final success = await ref.read(documentUploadProvider.notifier).uploadDocument(
      fileName: file.name,
      fileBytes: file.bytes!,
      mimeType: _getMimeType(file.name),
      docType: docType!,
      tripId: widget.tripId,
      tripItemId: widget.tripItemId,
    );

    setState(() => _isUploading = false);

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${file.name} uploaded successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to upload document'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<DocumentType?> _showDocTypeDialog() async {
    return showDialog<DocumentType>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Document Type'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: DocumentType.values.map((type) => ListTile(
            leading: Text(type.icon, style: const TextStyle(fontSize: 24)),
            title: Text(type.displayName),
            onTap: () => Navigator.pop(context, type),
          )).toList(),
        ),
      ),
    );
  }

  String _getMimeType(String fileName) {
    final ext = fileName.split('.').last.toLowerCase();
    switch (ext) {
      case 'pdf':
        return 'application/pdf';
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'webp':
        return 'image/webp';
      default:
        return 'application/octet-stream';
    }
  }
}

class _DocumentTile extends StatelessWidget {
  final Document doc;
  final VoidCallback? onTap;

  const _DocumentTile({required this.doc, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: WaydeckCard(
        onTap: onTap,
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: WaydeckTheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  _getIcon(),
                  style: const TextStyle(fontSize: 20),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    doc.fileName,
                    style: WaydeckTheme.bodyMedium.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Row(
                    children: [
                      BadgeChip(
                        label: doc.docType.displayName,
                        small: true,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        doc.fileSizeString,
                        style: WaydeckTheme.caption,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: WaydeckTheme.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  String _getIcon() {
    if (doc.isPdf) return '📄';
    if (doc.isImage) return '🖼️';
    return doc.docType.icon;
  }
}
