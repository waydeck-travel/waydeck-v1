import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../../app/theme.dart';
import '../../../../../shared/ui/ui.dart';
import '../../providers/trip_items_provider.dart';

/// Note Form Screen
class NoteFormScreen extends ConsumerStatefulWidget {
  final String tripId;
  final String? itemId;

  const NoteFormScreen({super.key, required this.tripId, this.itemId});

  bool get isEdit => itemId != null;

  @override
  ConsumerState<NoteFormScreen> createState() => _NoteFormScreenState();
}

class _NoteFormScreenState extends ConsumerState<NoteFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await ref.read(tripItemFormProvider.notifier).createNoteItem(
      tripId: widget.tripId,
      title: _titleController.text,
      description: _contentController.text.isEmpty ? null : _contentController.text,
    );

    if (success && mounted) {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(tripItemFormProvider);

    return Scaffold(
      backgroundColor: WaydeckTheme.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
        title: Text(widget.isEdit ? 'Edit Note' : 'Add Note'),
        actions: [
          TextButton(
            onPressed: formState.isLoading ? null : _handleSave,
            child: formState.isLoading
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('Save'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            WaydeckInput(
              controller: _titleController,
              label: 'Title *',
              hintText: 'e.g., Buy SIM at BKK Airport',
              validator: (v) => v?.isEmpty == true ? 'Required' : null,
            ),
            const SizedBox(height: 24),
            WaydeckInput(
              controller: _contentController,
              label: 'Content',
              hintText: 'Write your note here...',
              maxLines: 10,
            ),
          ],
        ),
      ),
    );
  }
}
