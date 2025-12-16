import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';

import '../../../../app/theme.dart';
import '../../../../shared/models/models.dart';
import '../../../../shared/ui/ui.dart';
import '../../../../shared/services/trip_share_service.dart';
import '../../../trip_items/presentation/providers/timeline_provider.dart';
import '../../../documents/presentation/providers/documents_provider.dart';
import '../providers/trips_provider.dart';
import '../../widgets/timeline/timeline_widget.dart';

/// Trip Overview Screen with summary and timeline
class TripOverviewScreen extends ConsumerWidget {
  final String tripId;

  const TripOverviewScreen({super.key, required this.tripId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tripAsync = ref.watch(tripProvider(tripId));

    return Scaffold(
      backgroundColor: WaydeckTheme.background,
      body: tripAsync.when(
        loading: () => const Scaffold(
          body: LoadingIndicator(message: 'Loading trip...'),
        ),
        error: (error, stack) => Scaffold(
          appBar: AppBar(),
          body: Center(
            child: Text('Error: $error'),
          ),
        ),
        data: (trip) {
          if (trip == null) {
            return Scaffold(
              appBar: AppBar(),
              body: const Center(
                child: Text('Trip not found'),
              ),
            );
          }

          return CustomScrollView(
            slivers: [
              // App Bar
              SliverAppBar(
                title: Text(trip.name),
                floating: true,
                actions: [
                  IconButton(
                    icon: const Icon(Icons.share_outlined),
                    onPressed: () => _showShareDialog(context, trip),
                    tooltip: 'Share Trip',
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit_outlined),
                    onPressed: () => context.push('/trips/$tripId/edit'),
                    tooltip: 'Edit Trip',
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) =>
                        _handleMenuAction(context, ref, value, trip),
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'archive',
                        child: Row(
                          children: [
                            Icon(Icons.archive_outlined, size: 20),
                            SizedBox(width: 8),
                            Text('Archive'),
                          ],
                        ),
                      ),
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

              // Trip Summary Card
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: _buildSummaryCard(trip),
                ),
              ),

              // Timeline section header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Text(
                    'Timeline',
                    style: WaydeckTheme.heading3,
                  ),
                ),
              ),

              // Timeline
              // Timeline Filter Header
              Consumer(
                builder: (context, ref, _) {
                  final filteredAsync = ref.watch(filteredTripItemsProvider(tripId));
                  final selectedCity = ref.watch(selectedCityFilterProvider(tripId));

                  if (selectedCity == null) {
                    return const SliverToBoxAdapter(child: SizedBox.shrink());
                  }

                  return filteredAsync.when(
                    data: (items) => SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: WaydeckTheme.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: WaydeckTheme.primary.withValues(alpha: 0.3)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.filter_list, size: 16, color: WaydeckTheme.primary),
                                const SizedBox(width: 6),
                                Text(
                                  'Showing ${items.length} items in $selectedCity',
                                  style: WaydeckTheme.caption.copyWith(
                                    color: WaydeckTheme.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                GestureDetector(
                                  onTap: () => ref.read(selectedCityFilterProvider(tripId).notifier).state = null,
                                  child: Container(
                                    padding: const EdgeInsets.all(2),
                                    decoration: BoxDecoration(
                                      color: WaydeckTheme.primary,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.close, size: 12, color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    loading: () => const SliverToBoxAdapter(child: SizedBox.shrink()),
                    error: (_, __) => const SliverToBoxAdapter(child: SizedBox.shrink()),
                  );
                },
              ),

              // Timeline List
              Consumer(
                builder: (context, ref, _) {
                  final filteredAsync = ref.watch(filteredTripItemsProvider(tripId));
                  final selectedCity = ref.watch(selectedCityFilterProvider(tripId));

                  return filteredAsync.when(
                    loading: () => const SliverFillRemaining(
                      child: LoadingIndicator(message: 'Loading items...'),
                    ),
                    error: (error, stack) => SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text('Error: $error'),
                      ),
                    ),
                    data: (items) {
                      if (items.isEmpty) {
                        return SliverToBoxAdapter(
                          child: selectedCity != null
                              ? _buildEmptyFilterResult(context, selectedCity, ref)
                              : _buildEmptyTimeline(context),
                        );
                      }
                      
                      return TimelineWidget(
                        tripId: tripId,
                        items: items,
                      );
                    },
                  );
                },
              ),

              // Bottom padding
              const SliverToBoxAdapter(
                child: SizedBox(height: 100),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddItemSheet(context),
        backgroundColor: WaydeckTheme.primary,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSummaryCard(Trip trip) {
    return WaydeckCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Origin
          Row(
            children: [
              Icon(
                Icons.location_on_outlined,
                size: 18,
                color: WaydeckTheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                trip.originString,
                style: WaydeckTheme.bodyMedium,
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Dates
          Row(
            children: [
              Icon(
                Icons.calendar_today_outlined,
                size: 18,
                color: WaydeckTheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                trip.dateRangeString,
                style: WaydeckTheme.bodyMedium,
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Status badge
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _getStatusColor(trip.status).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(trip.status.icon, style: const TextStyle(fontSize: 12)),
                    const SizedBox(width: 4),
                    Text(
                      trip.status.displayName,
                      style: WaydeckTheme.caption.copyWith(
                        color: _getStatusColor(trip.status),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              // Status action button
              Builder(
                builder: (context) => _buildStatusActionButton(context, trip),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Item counts
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildCountBadge('✈️', trip.transportCount, 'flights'),
              _buildCountBadge('🏨', trip.stayCount, 'stays'),
              _buildCountBadge('🎟️', trip.activityCount, 'activities'),
              _buildCountBadge('📝', trip.noteCount, 'notes'),
              if (trip.documentCount > 0)
                _buildCountBadge('📎', trip.documentCount, 'documents'),
            ],
          ),

          // Cities covered
          Consumer(
            builder: (context, ref, _) {
              final citiesAsync = ref.watch(tripCitiesProvider(tripId));
              final selectedCity = ref.watch(selectedCityFilterProvider(tripId));
              return citiesAsync.when(
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
                data: (cities) {
                  if (cities.isEmpty) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Cities',
                              style: WaydeckTheme.caption.copyWith(
                                color: WaydeckTheme.textSecondary,
                              ),
                            ),
                            if (selectedCity != null) ...[
                              const SizedBox(width: 8),
                              GestureDetector(
                                onTap: () => ref.read(selectedCityFilterProvider(tripId).notifier).state = null,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: WaydeckTheme.primary.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        'Filtering: $selectedCity',
                                        style: WaydeckTheme.bodySmall.copyWith(
                                          color: WaydeckTheme.primary,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Icon(Icons.close, size: 12, color: WaydeckTheme.primary),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: cities.map((city) {
                            final isSelected = selectedCity == city;
                            return Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {
                                // Toggle filter
                                final notifier = ref.read(selectedCityFilterProvider(tripId).notifier);
                                if (isSelected) {
                                  notifier.state = null; // Clear filter
                                } else {
                                  notifier.state = city; // Set filter
                                }
                              },
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: isSelected ? WaydeckTheme.primary : WaydeckTheme.surfaceVariant,
                                  borderRadius: BorderRadius.circular(12),
                                  border: isSelected ? Border.all(color: WaydeckTheme.primary, width: 1.5) : null,
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.location_city, size: 12, 
                                      color: isSelected ? Colors.white : WaydeckTheme.textSecondary),
                                    const SizedBox(width: 4),
                                    Text(city, style: WaydeckTheme.caption.copyWith(
                                      color: isSelected ? Colors.white : null,
                                      fontWeight: isSelected ? FontWeight.w600 : null,
                                    )),
                                    const SizedBox(width: 4),
                                    Icon(isSelected ? Icons.check : Icons.chevron_right, size: 12, 
                                      color: isSelected ? Colors.white : WaydeckTheme.textSecondary),
                                  ],
                                ),
                              ),
                            ),
                          );}).toList(),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),

          // Notes preview - improved UI
          if (trip.notes != null && trip.notes!.isNotEmpty) ...[
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 8),
            Builder(
              builder: (context) => InkWell(
              onTap: () => _showNotesSheet(context, trip),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: WaydeckTheme.surfaceVariant.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: WaydeckTheme.surfaceVariant),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Colors.amber.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Center(
                        child: Text('📝', style: TextStyle(fontSize: 16)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Trip Notes',
                            style: WaydeckTheme.bodySmall.copyWith(
                              fontWeight: FontWeight.w600,
                              color: WaydeckTheme.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            trip.notes!,
                            style: WaydeckTheme.bodySmall.copyWith(
                              color: WaydeckTheme.textPrimary,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.chevron_right,
                      color: WaydeckTheme.textSecondary,
                      size: 18,
                    ),
                  ],
                ),
              ),
              ),
            ),
          ],

          // Checklist button
          const SizedBox(height: 12),
          const Divider(),
          const SizedBox(height: 8),
          Builder(
            builder: (context) => InkWell(
              onTap: () => context.push('/trips/$tripId/checklist'),
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: WaydeckTheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Center(
                        child: Text('📋', style: TextStyle(fontSize: 16)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Checklist',
                        style: WaydeckTheme.bodyMedium.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.chevron_right,
                      color: WaydeckTheme.textSecondary,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Documents section
          const SizedBox(height: 8),
          Consumer(
            builder: (context, ref, _) {
              final docsAsync = ref.watch(tripDocumentsProvider(tripId));
              return docsAsync.when(
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
                data: (docs) {
                  return InkWell(
                    onTap: () => _showDocumentsSheet(context, ref, tripId, docs),
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: WaydeckTheme.warning.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Center(
                              child: Text('📎', style: TextStyle(fontSize: 16)),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Documents',
                                  style: WaydeckTheme.bodyMedium.copyWith(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  docs.isEmpty 
                                      ? 'Passport, visa, insurance...' 
                                      : '${docs.length} file${docs.length > 1 ? 's' : ''}',
                                  style: WaydeckTheme.caption.copyWith(
                                    color: WaydeckTheme.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            docs.isEmpty ? Icons.add : Icons.chevron_right,
                            color: docs.isEmpty ? WaydeckTheme.primary : WaydeckTheme.textSecondary,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCountBadge(String icon, int count, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(icon, style: const TextStyle(fontSize: 14)),
        const SizedBox(width: 4),
        Text(
          '$count $label',
          style: WaydeckTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _buildEmptyTimeline(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: WaydeckTheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Center(
              child: Text(
                '📅',
                style: TextStyle(fontSize: 36),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No items yet',
            style: WaydeckTheme.heading3,
          ),
          const SizedBox(height: 8),
          Text(
            'Add your first transport, stay, or activity.',
            style: WaydeckTheme.bodyMedium.copyWith(
              color: WaydeckTheme.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyFilterResult(BuildContext context, String city, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: WaydeckTheme.secondary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Center(
              child: Text(
                '🔍',
                style: TextStyle(fontSize: 36),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No items in $city',
            style: WaydeckTheme.heading3,
          ),
          const SizedBox(height: 8),
          Text(
            'Try selecting a different city or clear the filter.',
            style: WaydeckTheme.bodyMedium.copyWith(
              color: WaydeckTheme.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          TextButton.icon(
            onPressed: () => ref.read(selectedCityFilterProvider(tripId).notifier).state = null,
            icon: const Icon(Icons.clear),
            label: const Text('Clear Filter'),
          ),
        ],
      ),
    );
  }

  void _showAddItemSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Add to Timeline',
                style: WaydeckTheme.heading3,
              ),
              const SizedBox(height: 16),
              _buildAddOption(
                context,
                icon: '✈️',
                label: 'Transport',
                subtitle: 'Flight, train, bus, car...',
                color: WaydeckTheme.transportColor,
                onTap: () {
                  Navigator.pop(context);
                  context.push('/trips/$tripId/items/transport/new');
                },
              ),
              _buildAddOption(
                context,
                icon: '🏨',
                label: 'Stay',
                subtitle: 'Hotel, hostel, apartment...',
                color: WaydeckTheme.stayColor,
                onTap: () {
                  Navigator.pop(context);
                  context.push('/trips/$tripId/items/stay/new');
                },
              ),
              _buildAddOption(
                context,
                icon: '🎟️',
                label: 'Activity',
                subtitle: 'Tour, museum, restaurant...',
                color: WaydeckTheme.activityColor,
                onTap: () {
                  Navigator.pop(context);
                  context.push('/trips/$tripId/items/activity/new');
                },
              ),
              _buildAddOption(
                context,
                icon: '📝',
                label: 'Note',
                subtitle: 'Reminders, tips, info...',
                color: WaydeckTheme.noteColor,
                onTap: () {
                  Navigator.pop(context);
                  context.push('/trips/$tripId/items/note/new');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAddOption(
    BuildContext context, {
    required String icon,
    required String label,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(icon, style: const TextStyle(fontSize: 22)),
        ),
      ),
      title: Text(label, style: WaydeckTheme.bodyLarge),
      subtitle: Text(
        subtitle,
        style: WaydeckTheme.bodySmall,
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: WaydeckTheme.textSecondary,
      ),
    );
  }

  void _showNotesSheet(BuildContext context, Trip trip) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.amber.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(
                    child: Text('📝', style: TextStyle(fontSize: 18)),
                  ),
                ),
                const SizedBox(width: 12),
                Text('Trip Notes', style: WaydeckTheme.heading3),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  onPressed: () {
                    Navigator.pop(ctx);
                    // Navigate to edit trip screen
                    context.push('/trips/${trip.id}/edit');
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: WaydeckTheme.surfaceVariant.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: SelectableText(
                trip.notes ?? 'No notes yet',
                style: WaydeckTheme.bodyMedium.copyWith(
                  height: 1.6,
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showDocumentsSheet(
    BuildContext context,
    WidgetRef ref,
    String tripId,
    List<Document> docs,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.5,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.only(top: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Text('Documents', style: WaydeckTheme.heading3),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: () => _showUploadDocumentSheet(context, tripId),
                    icon: const Icon(Icons.add, size: 20),
                    label: const Text('Upload'),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            // Documents list or empty state
            Expanded(
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.all(16),
                children: [
                  // Trip Documents Section
                  if (docs.isNotEmpty) ...[
                    Text('Trip Documents', style: WaydeckTheme.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    ...docs.map((doc) => _buildDocumentTile(context, doc)),
                    const SizedBox(height: 24),
                  ],

                  // Global Documents Section (read-only)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: WaydeckTheme.surfaceVariant,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.public, size: 20, color: WaydeckTheme.primary),
                            const SizedBox(width: 8),
                            Text('Global Documents', style: WaydeckTheme.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Your passport, visa, and other travel documents',
                          style: WaydeckTheme.bodySmall.copyWith(color: WaydeckTheme.textSecondary),
                        ),
                        const SizedBox(height: 12),
                        // Mock global documents - in real implementation, fetch from provider
                        _buildGlobalDocPreview('🛂', 'Passport', 'AB1234567'),
                        _buildGlobalDocPreview('🛡️', 'Travel Insurance', 'INS-2025-001'),
                        const SizedBox(height: 8),
                        Center(
                          child: TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                              context.push('/global-documents');
                            },
                            child: const Text('View All Global Documents'),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Empty state for trip documents
                  if (docs.isEmpty)
                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.folder_open, size: 48, color: Colors.grey[400]),
                          const SizedBox(height: 12),
                          Text(
                            'No trip-specific documents yet',
                            style: WaydeckTheme.bodyMedium.copyWith(
                              color: WaydeckTheme.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton.icon(
                            onPressed: () => _showUploadDocumentSheet(context, tripId),
                            icon: const Icon(Icons.upload, size: 18),
                            label: const Text('Upload Document'),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showUploadDocumentSheet(BuildContext context, String tripId) {
    final categories = [
      ('🛂', 'Passport', DocumentType.passport),
      ('📜', 'Visa', DocumentType.visa),
      ('🛡️', 'Travel Insurance', DocumentType.insurance),
      ('🎫', 'Flight Ticket', DocumentType.ticket),
      ('🏨', 'Hotel Voucher', DocumentType.hotelVoucher),
      ('📋', 'Other', DocumentType.other),
    ];

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetContext) => Consumer(
        builder: (context, ref, _) {
          final uploadState = ref.watch(documentUploadProvider);
          
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Upload Document', style: WaydeckTheme.heading3),
                const SizedBox(height: 8),
                Text(
                  'Select document type:',
                  style: WaydeckTheme.bodySmall.copyWith(color: WaydeckTheme.textSecondary),
                ),
                const SizedBox(height: 16),
                if (uploadState.isUploading) ...[
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: Column(
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 16),
                          Text('Uploading document...'),
                        ],
                      ),
                    ),
                  ),
                ] else
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: categories.map((cat) => InkWell(
                      onTap: () async {
                        await _pickAndUploadDocument(
                          context: context,
                          sheetContext: sheetContext,
                          ref: ref,
                          tripId: tripId,
                          docType: cat.$3,
                          docTypeName: cat.$2,
                        );
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: WaydeckTheme.surfaceVariant,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(cat.$1, style: const TextStyle(fontSize: 20)),
                            const SizedBox(width: 8),
                            Text(cat.$2, style: WaydeckTheme.bodyMedium),
                          ],
                        ),
                      ),
                    )).toList(),
                  ),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _pickAndUploadDocument({
    required BuildContext context,
    required BuildContext sheetContext,
    required WidgetRef ref,
    required String tripId,
    required DocumentType docType,
    required String docTypeName,
  }) async {
    // Import file_picker
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png', 'webp'],
        withData: true, // Important: get file bytes
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        
        if (file.bytes == null) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Could not read file data')),
            );
          }
          return;
        }

        // Determine MIME type
        String mimeType = 'application/octet-stream';
        final ext = file.extension?.toLowerCase();
        if (ext == 'pdf') {
          mimeType = 'application/pdf';
        } else if (ext == 'jpg' || ext == 'jpeg') {
          mimeType = 'image/jpeg';
        } else if (ext == 'png') {
          mimeType = 'image/png';
        } else if (ext == 'webp') {
          mimeType = 'image/webp';
        }

        // Upload using the provider
        final success = await ref.read(documentUploadProvider.notifier).uploadDocument(
          fileName: file.name,
          fileBytes: file.bytes!,
          mimeType: mimeType,
          docType: docType,
          tripId: tripId,
        );

        // Close the sheet
        if (sheetContext.mounted) {
          Navigator.pop(sheetContext);
        }

        // Show result feedback
        if (context.mounted) {
          if (success) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('✓ $docTypeName uploaded successfully'),
                backgroundColor: WaydeckTheme.success,
              ),
            );
            // Refresh documents list
            ref.invalidate(tripDocumentsProvider(tripId));
          } else {
            final error = ref.read(documentUploadProvider).error;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Upload failed: ${error ?? 'Unknown error'}'),
                backgroundColor: WaydeckTheme.error,
              ),
            );
          }
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: WaydeckTheme.error,
          ),
        );
      }
    }
  }

  Widget _buildDocumentTile(BuildContext context, Document doc) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: WaydeckTheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              doc.docType.icon,
              style: const TextStyle(fontSize: 20),
            ),
          ),
        ),
        title: Text(doc.fileName),
        subtitle: Text(doc.docType.displayName),
        trailing: const Icon(Icons.chevron_right),
        contentPadding: const EdgeInsets.symmetric(horizontal: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: WaydeckTheme.surfaceVariant),
        ),
        onTap: () {
          Navigator.pop(context);
          context.push('/documents/${doc.id}');
        },
      ),
    );
  }

  Widget _buildGlobalDocPreview(String icon, String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: WaydeckTheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(child: Text(icon, style: const TextStyle(fontSize: 18))),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: WaydeckTheme.bodySmall.copyWith(fontWeight: FontWeight.w500)),
                Text(subtitle, style: WaydeckTheme.caption.copyWith(color: WaydeckTheme.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _handleMenuAction(
    BuildContext context,
    WidgetRef ref,
    String action,
    Trip trip,
  ) {
    switch (action) {
      case 'archive':
        _showArchiveDialog(context, ref, trip);
        break;
      case 'delete':
        _showDeleteDialog(context, ref, trip);
        break;
    }
  }

  void _showArchiveDialog(BuildContext context, WidgetRef ref, Trip trip) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Archive Trip'),
        content: Text('Archive "${trip.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await ref
                  .read(tripActionsProvider.notifier)
                  .archiveTrip(trip.id);
              if (success && context.mounted) {
                context.go('/trips');
              }
            },
            child: const Text('Archive'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref, Trip trip) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Trip'),
        content: Text('Delete "${trip.name}"? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await ref
                  .read(tripActionsProvider.notifier)
                  .deleteTrip(trip.id);
              if (success && context.mounted) {
                context.go('/trips');
              }
            },
            style: TextButton.styleFrom(foregroundColor: WaydeckTheme.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(TripStatus status) {
    switch (status) {
      case TripStatus.planned:
        return WaydeckTheme.textSecondary;
      case TripStatus.active:
        return WaydeckTheme.primary;
      case TripStatus.completed:
        return WaydeckTheme.success;
    }
  }

  Widget _buildStatusActionButton(BuildContext context, Trip trip) {
    switch (trip.status) {
      case TripStatus.planned:
        return OutlinedButton.icon(
          onPressed: () => _showStartTripDialog(context, trip),
          icon: Icon(Icons.play_arrow, size: 16, color: WaydeckTheme.primary),
          label: Text('Start Trip', style: TextStyle(color: WaydeckTheme.primary)),
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: WaydeckTheme.primary),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          ),
        );
      case TripStatus.active:
        return OutlinedButton.icon(
          onPressed: () => _showCompleteTripDialog(context, trip),
          icon: Icon(Icons.check_circle_outline, size: 16, color: WaydeckTheme.success),
          label: Text('Complete', style: TextStyle(color: WaydeckTheme.success)),
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: WaydeckTheme.success),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          ),
        );
      case TripStatus.completed:
        return TextButton.icon(
          onPressed: () => _showRevertTripDialog(context, trip),
          icon: Icon(Icons.replay, size: 16, color: WaydeckTheme.textSecondary),
          label: Text('Revert', style: TextStyle(color: WaydeckTheme.textSecondary)),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 8),
          ),
        );
    }
  }

  void _showStartTripDialog(BuildContext context, Trip trip) {
    showDialog(
      context: context,
      builder: (ctx) => Consumer(
        builder: (context, ref, _) => AlertDialog(
          title: const Text('Start Trip'),
          content: Text('Start "${trip.name}"? This will mark the trip as active.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(ctx);
                await ref.read(tripActionsProvider.notifier).startTrip(trip.id);
              },
              child: const Text('Start Trip'),
            ),
          ],
        ),
      ),
    );
  }

  void _showCompleteTripDialog(BuildContext context, Trip trip) {
    showDialog(
      context: context,
      builder: (ctx) => Consumer(
        builder: (context, ref, _) => AlertDialog(
          title: const Text('Complete Trip'),
          content: Text('Complete "${trip.name}"? This will mark the trip as finished.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(ctx);
                await ref.read(tripActionsProvider.notifier).completeTrip(trip.id);
              },
              style: ElevatedButton.styleFrom(backgroundColor: WaydeckTheme.success),
              child: const Text('Complete'),
            ),
          ],
        ),
      ),
    );
  }

  void _showRevertTripDialog(BuildContext context, Trip trip) {
    showDialog(
      context: context,
      builder: (ctx) => Consumer(
        builder: (context, ref, _) => AlertDialog(
          title: const Text('Revert Trip'),
          content: Text('Revert "${trip.name}" to planned status?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(ctx);
                await ref.read(tripActionsProvider.notifier).revertToPlanned(trip.id);
              },
              child: const Text('Revert'),
            ),
          ],
        ),
      ),
    );
  }

  void _showShareDialog(BuildContext context, Trip trip) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Share Trip', style: WaydeckTheme.heading2),
            const SizedBox(height: 8),
            Text(
              'Share "${trip.name}" with friends and family',
              style: WaydeckTheme.bodySmall.copyWith(color: WaydeckTheme.textSecondary),
            ),
            const SizedBox(height: 24),
            
            // Share via system share sheet
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: WaydeckTheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.share, color: WaydeckTheme.primary),
              ),
              title: const Text('Share Trip'),
              subtitle: const Text('Send via WhatsApp, Email, etc.'),
              onTap: () async {
                Navigator.pop(ctx);
                // Get share position for iOS
                final box = context.findRenderObject() as RenderBox?;
                final sharePositionOrigin = box != null 
                    ? box.localToGlobal(Offset.zero) & box.size
                    : null;
                await tripShareService.shareTrip(
                  tripName: trip.name,
                  shareCode: trip.id, // Use trip ID as fallback
                  sharePositionOrigin: sharePositionOrigin,
                );
              },
            ),
            const Divider(),
            
            // Copy link - instant, no network call
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.link, color: Colors.blue),
              ),
              title: const Text('Copy Link'),
              subtitle: const Text('Copy shareable link to clipboard'),
              onTap: () async {
                Navigator.pop(ctx);
                // Copy link immediately without network call
                final link = 'https://waydeck.app/trip/${trip.id}';
                await Clipboard.setData(ClipboardData(text: link));
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('✓ Link copied to clipboard'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              },
            ),
            
            // Copy trip summary
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.content_copy, color: Colors.green),
              ),
              title: const Text('Copy Summary'),
              subtitle: const Text('Copy trip details as text'),
              onTap: () async {
                Navigator.pop(ctx);
                final summary = _generateShareText(trip);
                await Clipboard.setData(ClipboardData(text: summary));
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('✓ Trip summary copied'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  String _generateShareText(Trip trip) {
    final buffer = StringBuffer();
    buffer.writeln('🧳 ${trip.name}');
    if (trip.startDate != null && trip.endDate != null) {
      buffer.writeln('📅 ${_formatDateRange(trip.startDate!, trip.endDate!)}');
    } else if (trip.startDate != null) {
      buffer.writeln('📅 From ${_formatSingleDate(trip.startDate!)}');
    }
    if (trip.originCity != null) {
      buffer.writeln('📍 From ${trip.originCity}');
    }
    buffer.writeln();
    buffer.writeln('View on Waydeck: https://waydeck.app/trip/${trip.id}');
    return buffer.toString();
  }

  String _formatDateRange(DateTime start, DateTime end) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    if (start.year == end.year && start.month == end.month) {
      return '${start.day}-${end.day} ${months[start.month - 1]} ${start.year}';
    } else if (start.year == end.year) {
      return '${start.day} ${months[start.month - 1]} - ${end.day} ${months[end.month - 1]} ${start.year}';
    }
    return '${start.day} ${months[start.month - 1]} ${start.year} - ${end.day} ${months[end.month - 1]} ${end.year}';
  }

  String _formatSingleDate(DateTime date) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}
