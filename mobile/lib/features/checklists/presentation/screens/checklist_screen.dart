import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme.dart';
import '../../../../shared/models/models.dart';
import '../../../../shared/ui/ui.dart';
import '../providers/checklist_provider.dart';

/// Checklist Screen
class ChecklistScreen extends ConsumerStatefulWidget {
  final String tripId;

  const ChecklistScreen({super.key, required this.tripId});

  @override
  ConsumerState<ChecklistScreen> createState() => _ChecklistScreenState();
}

class _ChecklistScreenState extends ConsumerState<ChecklistScreen> {
  final _newItemController = TextEditingController();
  ChecklistPhase _selectedPhase = ChecklistPhase.beforeTrip;
  ChecklistCategory _selectedCategory = ChecklistCategory.packing;

  @override
  void dispose() {
    _newItemController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final itemsAsync = ref.watch(checklistItemsProvider(widget.tripId));

    return Scaffold(
      backgroundColor: WaydeckTheme.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text('Checklist'),
        actions: [
          IconButton(
            icon: const Icon(Icons.file_download_outlined),
            tooltip: 'Import from Template',
            onPressed: () => _showImportTemplateSheet(context),
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddDialog,
          ),
        ],
      ),
      body: itemsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (items) => _buildContent(items),
      ),
    );
  }

  Widget _buildContent(List<ChecklistItem> items) {
    if (items.isEmpty) {
      return _buildEmptyState();
    }

    // Group by phase
    final grouped = <ChecklistPhase, List<ChecklistItem>>{};
    for (final phase in ChecklistPhase.values) {
      grouped[phase] = items.where((i) => i.phase == phase).toList();
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Progress bar
        _buildProgressBar(items),
        const SizedBox(height: 24),

        // Grouped items
        for (final phase in ChecklistPhase.values)
          if (grouped[phase]!.isNotEmpty)
            _buildPhaseSection(phase, grouped[phase]!),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('📋', style: TextStyle(fontSize: 64)),
          const SizedBox(height: 16),
          Text(
            'No checklist items yet',
            style: WaydeckTheme.heading3,
          ),
          const SizedBox(height: 8),
          Text(
            'Add items to keep track of your trip preparations',
            style: WaydeckTheme.bodyMedium.copyWith(
              color: WaydeckTheme.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _showAddDialog,
            icon: const Icon(Icons.add),
            label: const Text('Add First Item'),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar(List<ChecklistItem> items) {
    final total = items.length;
    final checked = items.where((i) => i.isChecked).length;
    final progress = total > 0 ? checked / total : 0.0;

    return WaydeckCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Progress',
                style: WaydeckTheme.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '$checked / $total completed',
                style: WaydeckTheme.bodySmall.copyWith(
                  color: WaydeckTheme.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: WaydeckTheme.surfaceVariant,
              valueColor: AlwaysStoppedAnimation(
                progress == 1.0 ? Colors.green : WaydeckTheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhaseSection(ChecklistPhase phase, List<ChecklistItem> items) {
    // Group by category within phase
    final byCategory = <ChecklistCategory, List<ChecklistItem>>{};
    for (final item in items) {
      byCategory.putIfAbsent(item.category, () => []).add(item);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: [
              Text(phase.icon, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Text(
                phase.displayName,
                style: WaydeckTheme.heading3,
              ),
              const SizedBox(width: 8),
              BadgeChip(
                label: '${items.where((i) => i.isChecked).length}/${items.length}',
                small: true,
              ),
            ],
          ),
        ),
        ...byCategory.entries.map((entry) => _buildCategoryGroup(entry.key, entry.value)),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildCategoryGroup(ChecklistCategory category, List<ChecklistItem> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, top: 8, bottom: 4),
          child: Row(
            children: [
              Text(category.icon, style: const TextStyle(fontSize: 16)),
              const SizedBox(width: 6),
              Text(
                category.displayName,
                style: WaydeckTheme.bodySmall.copyWith(
                  fontWeight: FontWeight.w600,
                  color: WaydeckTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
        ...items.map((item) => _buildChecklistItem(item)),
      ],
    );
  }

  Widget _buildChecklistItem(ChecklistItem item) {
    return Dismissible(
      key: Key(item.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        color: Colors.red,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) {
        ref.read(checklistFormProvider.notifier).deleteItem(item.id, widget.tripId);
      },
      child: CheckboxListTile(
        title: Text(
          item.title,
          style: WaydeckTheme.bodyMedium.copyWith(
            decoration: item.isChecked ? TextDecoration.lineThrough : null,
            color: item.isChecked ? WaydeckTheme.textTertiary : null,
          ),
        ),
        subtitle: item.notes != null
            ? Text(
                item.notes!,
                style: WaydeckTheme.caption.copyWith(
                  color: WaydeckTheme.textSecondary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              )
            : null,
        value: item.isChecked,
        onChanged: (value) {
          ref.read(checklistFormProvider.notifier).toggleItem(
                item.id,
                widget.tripId,
                value ?? false,
              );
        },
        controlAffinity: ListTileControlAffinity.leading,
        activeColor: WaydeckTheme.primary,
      ),
    );
  }

  void _showAddDialog() {
    _newItemController.clear();
    _selectedPhase = ChecklistPhase.beforeTrip;
    _selectedCategory = ChecklistCategory.packing;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => AlertDialog(
          title: const Text('Add Item'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _newItemController,
                decoration: const InputDecoration(
                  labelText: 'Item',
                  hintText: 'e.g., Pack passport',
                ),
                autofocus: true,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<ChecklistPhase>(
                initialValue: _selectedPhase,
                decoration: const InputDecoration(labelText: 'Phase'),
                items: ChecklistPhase.values.map((phase) => DropdownMenuItem(
                  value: phase,
                  child: Row(
                    children: [
                      Text(phase.icon),
                      const SizedBox(width: 8),
                      Text(phase.displayName),
                    ],
                  ),
                )).toList(),
                onChanged: (value) => setDialogState(() => _selectedPhase = value!),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<ChecklistCategory>(
                initialValue: _selectedCategory,
                decoration: const InputDecoration(labelText: 'Category'),
                items: ChecklistCategory.values.map((cat) => DropdownMenuItem(
                  value: cat,
                  child: Row(
                    children: [
                      Text(cat.icon),
                      const SizedBox(width: 8),
                      Text(cat.displayName),
                    ],
                  ),
                )).toList(),
                onChanged: (value) => setDialogState(() => _selectedCategory = value!),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (_newItemController.text.trim().isEmpty) return;

                // Read notifier before closing dialog
                final notifier = ref.read(checklistFormProvider.notifier);
                final tripId = widget.tripId;
                final title = _newItemController.text.trim();
                final phase = _selectedPhase;
                final category = _selectedCategory;
                
                // Close dialog first
                Navigator.pop(dialogContext);
                
                // Then perform async operation
                await notifier.createItem(
                  tripId: tripId,
                  title: title,
                  phase: phase,
                  category: category,
                );
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  void _showImportTemplateSheet(BuildContext context) {
    // Mock templates - in production, fetch from provider
    final templates = [
      ('🏖️', 'Beach Vacation Essentials', 8),
      ('💼', 'Business Trip', 6),
      ('✈️', 'International Flight', 8),
      ('⛺', 'Camping Adventure', 8),
      ('❄️', 'Winter Getaway', 8),
    ];

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.file_download_outlined, color: WaydeckTheme.primary),
                const SizedBox(width: 8),
                Text('Import from Template', style: WaydeckTheme.heading3),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Add items from a template to your checklist',
              style: WaydeckTheme.bodySmall.copyWith(color: WaydeckTheme.textSecondary),
            ),
            const SizedBox(height: 16),
            ...templates.map((t) => ListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: WaydeckTheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(child: Text(t.$1, style: const TextStyle(fontSize: 20))),
              ),
              title: Text(t.$2),
              subtitle: Text('${t.$3} items'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Imported ${t.$3} items from "${t.$2}"'),
                    backgroundColor: WaydeckTheme.success,
                  ),
                );
                // TODO: Actually import items via provider
              },
            )),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: () {
                Navigator.pop(ctx);
                context.push('/checklist-templates');
              },
              icon: const Icon(Icons.settings_outlined, size: 18),
              label: const Text('Manage Templates'),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
