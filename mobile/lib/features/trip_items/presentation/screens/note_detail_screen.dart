import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme.dart';
import '../../../../shared/ui/ui.dart';
import '../providers/trip_items_provider.dart';

/// Note Detail Screen
class NoteDetailScreen extends ConsumerWidget {
  final String tripId;
  final String itemId;

  const NoteDetailScreen({
    super.key,
    required this.tripId,
    required this.itemId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemAsync = ref.watch(tripItemProvider(itemId));

    return Scaffold(
      backgroundColor: WaydeckTheme.background,
      appBar: AppBar(
        title: const Text('Note'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () =>
                context.push('/trips/$tripId/items/note/$itemId/edit'),
          ),
          PopupMenuButton<String>(
            onSelected: (value) => _handleAction(context, ref, value),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete_outlined, size: 20),
                    SizedBox(width: 8),
                    Text('Delete'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: itemAsync.when(
        loading: () => const LoadingIndicator(),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (item) {
          if (item == null) {
            return const Center(child: Text('Note not found'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Row(
                  children: [
                    const Text('📝', style: TextStyle(fontSize: 28)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        item.title,
                        style: WaydeckTheme.heading2,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Content
                if (item.description != null && item.description!.isNotEmpty)
                  WaydeckCard(
                    child: Text(
                      item.description!,
                      style: WaydeckTheme.bodyMedium.copyWith(height: 1.6),
                    ),
                  )
                else
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Text(
                        'No content',
                        style: WaydeckTheme.bodyMedium.copyWith(
                          color: WaydeckTheme.textSecondary,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _handleAction(BuildContext context, WidgetRef ref, String action) {
    if (action == 'delete') {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Delete Note'),
          content: const Text('Delete this note?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                final delete = ref.read(deleteTripItemProvider);
                final success = await delete(tripId, itemId);
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
    }
  }
}
