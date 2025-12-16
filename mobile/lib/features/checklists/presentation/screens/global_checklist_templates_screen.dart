import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme.dart';
import '../../../../shared/models/enums.dart';
import '../../../../shared/ui/ui.dart';

/// Global Checklist Templates Screen
/// Manage reusable checklist templates that can be imported into trip checklists
class GlobalChecklistTemplatesScreen extends ConsumerStatefulWidget {
  const GlobalChecklistTemplatesScreen({super.key});

  @override
  ConsumerState<GlobalChecklistTemplatesScreen> createState() => _GlobalChecklistTemplatesScreenState();
}

class _GlobalChecklistTemplatesScreenState extends ConsumerState<GlobalChecklistTemplatesScreen> {
  // Mock templates - in production, these would come from Supabase
  final List<ChecklistTemplate> _templates = [
    ChecklistTemplate(
      id: '1',
      name: 'Beach Vacation Essentials',
      icon: '🏖️',
      items: [
        TemplateItem(title: 'Sunscreen SPF 50+', category: ChecklistCategory.packing),
        TemplateItem(title: 'Swimsuit', category: ChecklistCategory.packing),
        TemplateItem(title: 'Beach towel', category: ChecklistCategory.packing),
        TemplateItem(title: 'Sunglasses', category: ChecklistCategory.packing),
        TemplateItem(title: 'Hat/Cap', category: ChecklistCategory.packing),
        TemplateItem(title: 'Beach bag', category: ChecklistCategory.packing),
        TemplateItem(title: 'Flip flops', category: ChecklistCategory.packing),
        TemplateItem(title: 'Book or e-reader', category: ChecklistCategory.packing),
      ],
    ),
    ChecklistTemplate(
      id: '2',
      name: 'Business Trip',
      icon: '💼',
      items: [
        TemplateItem(title: 'Laptop & charger', category: ChecklistCategory.documents),
        TemplateItem(title: 'Business cards', category: ChecklistCategory.documents),
        TemplateItem(title: 'Presentation materials', category: ChecklistCategory.documents),
        TemplateItem(title: 'Formal attire', category: ChecklistCategory.packing),
        TemplateItem(title: 'Backup shirt', category: ChecklistCategory.packing),
        TemplateItem(title: 'Meeting schedule', category: ChecklistCategory.documents),
      ],
    ),
    ChecklistTemplate(
      id: '3',
      name: 'International Flight',
      icon: '✈️',
      items: [
        TemplateItem(title: 'Valid passport', category: ChecklistCategory.documents),
        TemplateItem(title: 'Visa (if required)', category: ChecklistCategory.documents),
        TemplateItem(title: 'Travel insurance', category: ChecklistCategory.documents),
        TemplateItem(title: 'Vaccination certificates', category: ChecklistCategory.health),
        TemplateItem(title: 'Foreign currency', category: ChecklistCategory.documents),
        TemplateItem(title: 'Notify bank of travel', category: ChecklistCategory.documents),
        TemplateItem(title: 'Universal power adapter', category: ChecklistCategory.packing),
        TemplateItem(title: 'Neck pillow', category: ChecklistCategory.packing),
      ],
    ),
    ChecklistTemplate(
      id: '4',
      name: 'Camping Adventure',
      icon: '⛺',
      items: [
        TemplateItem(title: 'Tent & stakes', category: ChecklistCategory.packing),
        TemplateItem(title: 'Sleeping bag', category: ChecklistCategory.packing),
        TemplateItem(title: 'Camping mat', category: ChecklistCategory.packing),
        TemplateItem(title: 'Flashlight/headlamp', category: ChecklistCategory.packing),
        TemplateItem(title: 'First aid kit', category: ChecklistCategory.health),
        TemplateItem(title: 'Insect repellent', category: ChecklistCategory.health),
        TemplateItem(title: 'Water bottle', category: ChecklistCategory.packing),
        TemplateItem(title: 'Portable stove', category: ChecklistCategory.packing),
      ],
    ),
    ChecklistTemplate(
      id: '5',
      name: 'Winter Getaway',
      icon: '❄️',
      items: [
        TemplateItem(title: 'Warm jacket', category: ChecklistCategory.packing),
        TemplateItem(title: 'Thermal underwear', category: ChecklistCategory.packing),
        TemplateItem(title: 'Gloves', category: ChecklistCategory.packing),
        TemplateItem(title: 'Beanie/winter hat', category: ChecklistCategory.packing),
        TemplateItem(title: 'Scarf', category: ChecklistCategory.packing),
        TemplateItem(title: 'Warm socks', category: ChecklistCategory.packing),
        TemplateItem(title: 'Moisturizer', category: ChecklistCategory.health),
        TemplateItem(title: 'Lip balm', category: ChecklistCategory.health),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Checklist Templates'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showCreateTemplateSheet(context),
          ),
        ],
      ),
      body: _templates.isEmpty
          ? _buildEmptyState()
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Info card
                _buildInfoCard(),
                const SizedBox(height: 24),

                // Templates list
                ..._templates.map((template) => _buildTemplateCard(template)),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateTemplateSheet(context),
        icon: const Icon(Icons.add),
        label: const Text('Create Template'),
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
              child: const Text('📋', style: TextStyle(fontSize: 48)),
            ),
            const SizedBox(height: 24),
            Text(
              'No Templates Yet',
              style: WaydeckTheme.heading2,
            ),
            const SizedBox(height: 8),
            Text(
              'Create reusable checklist templates for different types of trips. Import them into any trip to save time.',
              style: WaydeckTheme.bodyMedium.copyWith(color: WaydeckTheme.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _showCreateTemplateSheet(context),
              icon: const Icon(Icons.add),
              label: const Text('Create First Template'),
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
              'Create templates for different trip types. Import them into any trip checklist to quickly add items.',
              style: WaydeckTheme.bodySmall.copyWith(color: WaydeckTheme.textSecondary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTemplateCard(ChecklistTemplate template) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: WaydeckCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: WaydeckTheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(template.icon, style: const TextStyle(fontSize: 24)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        template.name,
                        style: WaydeckTheme.bodyMedium.copyWith(fontWeight: FontWeight.w600),
                      ),
                      Text(
                        '${template.items.length} items',
                        style: WaydeckTheme.caption.copyWith(color: WaydeckTheme.textSecondary),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert),
                  onSelected: (action) {
                    switch (action) {
                      case 'edit':
                        // TODO: Edit template
                        break;
                      case 'delete':
                        _showDeleteConfirmation(template);
                        break;
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: 'edit', child: Text('Edit')),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Text('Delete', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Preview items
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: template.items.take(5).map((item) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: WaydeckTheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(item.category.icon, style: const TextStyle(fontSize: 12)),
                    const SizedBox(width: 4),
                    Text(item.title, style: WaydeckTheme.caption),
                  ],
                ),
              )).toList(),
            ),
            if (template.items.length > 5)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  '+${template.items.length - 5} more items',
                  style: WaydeckTheme.caption.copyWith(color: WaydeckTheme.textSecondary),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showCreateTemplateSheet(BuildContext context) {
    final nameController = TextEditingController();
    String selectedIcon = '📋';

    final icons = ['📋', '🏖️', '💼', '✈️', '⛺', '❄️', '🎿', '🏔️', '🌴', '🚗', '🛳️', '🎒'];

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
              Text('Create Template', style: WaydeckTheme.heading2),
              const SizedBox(height: 8),
              Text(
                'Create a reusable checklist template',
                style: WaydeckTheme.bodySmall.copyWith(color: WaydeckTheme.textSecondary),
              ),
              const SizedBox(height: 24),

              // Name input
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Template Name',
                  hintText: 'e.g., Beach Vacation',
                ),
              ),
              const SizedBox(height: 20),

              // Icon selection
              Text(
                'Choose Icon',
                style: WaydeckTheme.bodySmall.copyWith(
                  fontWeight: FontWeight.w500,
                  color: WaydeckTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: icons.map((icon) {
                  final isSelected = selectedIcon == icon;
                  return GestureDetector(
                    onTap: () => setSheetState(() => selectedIcon = icon),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: isSelected ? WaydeckTheme.primary.withValues(alpha: 0.2) : WaydeckTheme.surfaceVariant,
                        borderRadius: BorderRadius.circular(8),
                        border: isSelected ? Border.all(color: WaydeckTheme.primary, width: 2) : null,
                      ),
                      child: Center(child: Text(icon, style: const TextStyle(fontSize: 24))),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              // Create button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (nameController.text.trim().isEmpty) return;
                    Navigator.pop(ctx);
                    // TODO: Create template in Supabase
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Created template: ${nameController.text}'),
                        backgroundColor: WaydeckTheme.success,
                      ),
                    );
                  },
                  child: const Text('Create Template'),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmation(ChecklistTemplate template) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Template'),
        content: Text('Are you sure you want to delete "${template.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              setState(() => _templates.removeWhere((t) => t.id == template.id));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Template deleted'),
                  backgroundColor: WaydeckTheme.error,
                ),
              );
            },
            style: TextButton.styleFrom(foregroundColor: WaydeckTheme.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

/// Checklist Template model
class ChecklistTemplate {
  final String id;
  final String name;
  final String icon;
  final List<TemplateItem> items;

  ChecklistTemplate({
    required this.id,
    required this.name,
    required this.icon,
    required this.items,
  });
}

/// Template Item model
class TemplateItem {
  final String title;
  final ChecklistCategory category;

  TemplateItem({
    required this.title,
    required this.category,
  });
}
