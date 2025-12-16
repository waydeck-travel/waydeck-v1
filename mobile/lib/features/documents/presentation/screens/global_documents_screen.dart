
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:go_router/go_router.dart';
import 'package:waydeck/shared/models/global_document.dart';

import '../../../../app/theme.dart';
import '../../../../shared/ui/ui.dart';
import '../../../../shared/models/enums.dart';
import '../providers/global_documents_provider.dart';

/// Global Documents Screen - Manage user-level travel documents
class GlobalDocumentsScreen extends ConsumerStatefulWidget {
  const GlobalDocumentsScreen({super.key});

  @override
  ConsumerState<GlobalDocumentsScreen> createState() => _GlobalDocumentsScreenState();
}

class _GlobalDocumentsScreenState extends ConsumerState<GlobalDocumentsScreen> {
  @override
  Widget build(BuildContext context) {
    final documentsAsync = ref.watch(globalDocumentsProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Global Documents'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddDocumentSheet(context),
          ),
        ],
      ),
      body: documentsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Error: $e')),
        data: (documents) {
          if (documents.isEmpty) {
            return _buildEmptyState();
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Info card
              _buildInfoCard(),
              const SizedBox(height: 24),

              // Documents by type
              ...GlobalDocumentType.values.map((type) {
                // Filter docs that match this type
                final docs = documents.where((d) => 
                  d.docType.toLowerCase().replaceAll('_', '') == type.name.toLowerCase().replaceAll('_', '')
                ).toList();

                if (docs.isEmpty) return const SizedBox.shrink();
                return _buildTypeSection(type, docs);
              }),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddDocumentSheet(context),
        icon: const Icon(Icons.upload_file),
        label: const Text('Add Document'),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: WaydeckTheme.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Text('📁', style: TextStyle(fontSize: 48)),
            ),
            const SizedBox(height: 24),
            Text(
              'No Global Documents',
              style: WaydeckTheme.heading2,
            ),
            const SizedBox(height: 8),
            Text(
              'Add your passport, visa, insurance, and other travel documents here. They\'ll be accessible across all your trips.',
              style: WaydeckTheme.bodyMedium.copyWith(color: WaydeckTheme.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _showAddDocumentSheet(context),
              icon: const Icon(Icons.upload_file),
              label: const Text('Add Your First Document'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: WaydeckTheme.info.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: WaydeckTheme.info.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: WaydeckTheme.info),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Global documents are available across all your trips. Upload important travel documents once and access them anywhere.',
              style: WaydeckTheme.bodySmall.copyWith(color: WaydeckTheme.textSecondary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeSection(GlobalDocumentType type, List<GlobalDocumentModel> docs) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(type.icon, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Text(type.displayName, style: WaydeckTheme.heading3),
              const Spacer(),
              Text(
                '${docs.length} ${docs.length == 1 ? 'doc' : 'docs'}',
                style: WaydeckTheme.caption,
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...docs.map((doc) => _buildDocumentCard(doc)),
        ],
      ),
    );
  }

  Widget _buildDocumentCard(GlobalDocumentModel doc) {
    final isExpiring = doc.expiryDate != null &&
        doc.expiryDate!.difference(DateTime.now()).inDays < 90;
    final isExpired = doc.expiryDate != null &&
        doc.expiryDate!.isBefore(DateTime.now());

    // Map doc string back to enum for icon
    GlobalDocumentType? typeEnum;
    try {
      typeEnum = GlobalDocumentType.values.firstWhere(
        (e) => e.name.toLowerCase().replaceAll('_', '') == doc.docType.toLowerCase().replaceAll('_', '')
      );
    } catch (_) {
      typeEnum = GlobalDocumentType.other;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: WaydeckCard(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: WaydeckTheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(typeEnum.icon, style: const TextStyle(fontSize: 24)),
              ),
            ),
            const SizedBox(width: 16),
            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    doc.title ?? doc.fileName,
                    style: WaydeckTheme.bodyMedium.copyWith(fontWeight: FontWeight.w600),
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (doc.documentNumber != null)
                    Text(
                      doc.documentNumber!,
                      style: WaydeckTheme.bodySmall.copyWith(color: WaydeckTheme.textSecondary),
                    ),
                  if (doc.expiryDate != null)
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: isExpired
                            ? WaydeckTheme.error.withValues(alpha: 0.1)
                            : isExpiring
                                ? WaydeckTheme.warning.withValues(alpha: 0.1)
                                : WaydeckTheme.success.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        isExpired
                            ? '❌ Expired'
                            : isExpiring
                                ? '⚠️ Expires soon'
                                : '✓ Valid until ${_formatDate(doc.expiryDate!)}',
                        style: WaydeckTheme.caption.copyWith(
                          color: isExpired
                              ? WaydeckTheme.error
                              : isExpiring
                                  ? WaydeckTheme.warning
                                  : WaydeckTheme.success,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            // Actions
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              onSelected: (action) {
                switch (action) {
                  case 'view':
                    context.push('/documents/${doc.id}');
                    break;
                  case 'download':
                    _downloadDocument(doc);
                    break;
                  case 'delete':
                    _showDeleteConfirmation(doc);
                    break;
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(value: 'view', child: Text('View')),
                const PopupMenuItem(value: 'download', child: Text('Download')),
                const PopupMenuItem(
                  value: 'delete',
                  child: Text('Delete', style: TextStyle(color: Colors.red)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _downloadDocument(GlobalDocumentModel doc) async {
      // Get URL from provider
      final url = await ref.read(globalDocumentFormProvider.notifier).getDownloadUrl(doc.storagePath);
      if (url != null && mounted) {
        // In a real app, this would trigger a download. 
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Opening document...')),
        );
        // context.push('/documents/viewer?url=$url'); // or similar
      } else {
         if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Could not get download link')),
            );
         }
      }
  }


  void _showAddDocumentSheet(BuildContext context) {
    GlobalDocumentType? selectedType;
    bool isUploading = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setSheetState) => Padding(
          padding: EdgeInsets.fromLTRB(
            24, 24, 24,
            24 + MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Add Document', style: WaydeckTheme.heading2),
              const SizedBox(height: 8),
              if (isUploading)
                 const LinearProgressIndicator(),
              if (!isUploading)
                Text(
                  'Select document type and upload a file',
                  style: WaydeckTheme.bodySmall.copyWith(color: WaydeckTheme.textSecondary),
                ),
              const SizedBox(height: 24),

              // Document type selection
              Text(
                'Document Type',
                style: WaydeckTheme.bodySmall.copyWith(
                  fontWeight: FontWeight.w500,
                  color: WaydeckTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: GlobalDocumentType.values.map((type) {
                  final isSelected = selectedType == type;
                  return ChoiceChip(
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(type.icon),
                        const SizedBox(width: 4),
                        Text(type.displayName),
                      ],
                    ),
                    selected: isSelected,
                    onSelected: (selected) {
                      setSheetState(() => selectedType = selected ? type : null);
                    },
                    selectedColor: WaydeckTheme.primary.withValues(alpha: 0.2),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              // Upload button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: (selectedType == null || isUploading)
                      ? null
                      : () async {
                          final result = await FilePicker.platform.pickFiles(
                            type: FileType.custom,
                            allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png', 'webp'],
                            withData: true, // Need bytes for upload
                          );

                          if (result != null && result.files.isNotEmpty) {
                            setSheetState(() => isUploading = true);
                            
                            final file = result.files.first;
                            if (file.bytes == null) {
                               setSheetState(() => isUploading = false);
                               if (ctx.mounted) {
                                  ScaffoldMessenger.of(ctx).showSnackBar(
                                    const SnackBar(content: Text('Failed to read file data')),
                                  );
                               }
                               return;
                            }

                            final success = await ref.read(globalDocumentFormProvider.notifier).uploadDocument(
                              docType: selectedType!.name, // Use enum name as type key
                              fileName: file.name,
                              fileBytes: file.bytes!,
                              mimeType: 'application/octet-stream', // Or infer from extension
                            );
                            
                            if (!ctx.mounted) return;
                            Navigator.pop(ctx);
                            ScaffoldMessenger.of(ctx).showSnackBar(
                              SnackBar(
                                content: Text(success != null ? 'Uploaded ${file.name}' : 'Upload failed'),
                                backgroundColor: success != null ? WaydeckTheme.success : Colors.red,
                              ),
                            );
                          }
                        },
                  icon: isUploading 
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) 
                      : const Icon(Icons.upload_file),
                  label: Text(isUploading ? 'Uploading...' : 'Choose File'),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmation(GlobalDocumentModel doc) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Document'),
        content: Text('Are you sure you want to delete "${doc.fileName}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              
              final success = await ref.read(globalDocumentFormProvider.notifier).deleteDocument(
                  doc.id, 
                  doc.storagePath,
                  doc.docType
              );

              if (!mounted) return;
              if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Document deleted'),
                      backgroundColor: WaydeckTheme.error,
                    ),
                  );
              } else {
                   ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Failed to delete document'),
                      backgroundColor: Colors.red,
                    ),
                  );
              }
            },
            style: TextButton.styleFrom(foregroundColor: WaydeckTheme.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}
