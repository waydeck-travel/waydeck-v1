import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme.dart';
import '../../../../shared/ui/ui.dart';
import '../providers/documents_provider.dart';

/// Document Viewer Screen
class DocumentViewerScreen extends ConsumerWidget {
  final String docId;

  const DocumentViewerScreen({super.key, required this.docId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final docAsync = ref.watch(documentProvider(docId));

    return Scaffold(
      backgroundColor: WaydeckTheme.background,
      appBar: AppBar(
        title: docAsync.when(
          data: (doc) => Text(doc?.fileName ?? 'Document'),
          loading: () => const Text('Loading...'),
          error: (_, __) => const Text('Document'),
        ),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) => _handleAction(context, ref, value),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'download',
                child: Row(
                  children: [
                    Icon(Icons.download_outlined, size: 20),
                    SizedBox(width: 8),
                    Text('Download'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'share',
                child: Row(
                  children: [
                    Icon(Icons.share_outlined, size: 20),
                    SizedBox(width: 8),
                    Text('Share'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete_outlined, size: 20, color: WaydeckTheme.error),
                    const SizedBox(width: 8),
                    Text('Delete', style: TextStyle(color: WaydeckTheme.error)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: docAsync.when(
        loading: () => const LoadingIndicator(message: 'Loading document...'),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (doc) {
          if (doc == null) {
            return const Center(child: Text('Document not found'));
          }

          // Preview based on type
          if (doc.isImage) {
            return Center(
              child: InteractiveViewer(
                child: doc.downloadUrl != null
                    ? Image.network(
                        doc.downloadUrl!,
                        fit: BoxFit.contain,
                        loadingBuilder: (context, child, progress) {
                          if (progress == null) return child;
                          return const LoadingIndicator();
                        },
                        errorBuilder: (context, error, stack) {
                          return _buildPlaceholder(doc.fileName);
                        },
                      )
                    : _buildPlaceholder(doc.fileName),
              ),
            );
          }

          if (doc.isPdf) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('📄', style: TextStyle(fontSize: 64)),
                  const SizedBox(height: 16),
                  Text(doc.fileName, style: WaydeckTheme.heading3),
                  const SizedBox(height: 8),
                  Text(
                    doc.fileSizeString,
                    style: WaydeckTheme.bodySmall,
                  ),
                  const SizedBox(height: 24),
                  WaydeckButton(
                    onPressed: () {
                      // TODO: Open PDF viewer or download
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('PDF viewer coming soon!')),
                      );
                    },
                    width: 200,
                    child: const Text('Open PDF'),
                  ),
                ],
              ),
            );
          }

          // Generic file
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(doc.docType.icon, style: const TextStyle(fontSize: 64)),
                const SizedBox(height: 16),
                Text(doc.fileName, style: WaydeckTheme.heading3),
                const SizedBox(height: 8),
                BadgeChip(label: doc.docType.displayName),
                const SizedBox(height: 8),
                Text(doc.fileSizeString, style: WaydeckTheme.bodySmall),
                const SizedBox(height: 24),
                WaydeckButton(
                  onPressed: () {
                    // TODO: Download file
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Download coming soon!')),
                    );
                  },
                  width: 200,
                  child: const Text('Download'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPlaceholder(String fileName) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('🖼️', style: TextStyle(fontSize: 64)),
        const SizedBox(height: 16),
        Text(fileName, style: WaydeckTheme.heading3),
        const SizedBox(height: 8),
        Text(
          'Preview not available',
          style: WaydeckTheme.bodySmall.copyWith(
            color: WaydeckTheme.textSecondary,
          ),
        ),
      ],
    );
  }

  void _handleAction(BuildContext context, WidgetRef ref, String action) {
    switch (action) {
      case 'download':
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Download coming soon!')),
        );
        break;
      case 'share':
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Share coming soon!')),
        );
        break;
      case 'delete':
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Delete Document'),
            content: const Text('Delete this document?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.pop(context);
                  final success = await ref
                      .read(documentActionsProvider.notifier)
                      .deleteDocument(docId);
                  if (success && context.mounted) {
                    context.pop();
                  }
                },
                style: TextButton.styleFrom(foregroundColor: WaydeckTheme.error),
                child: const Text('Delete'),
              ),
            ],
          ),
        );
        break;
    }
  }
}
