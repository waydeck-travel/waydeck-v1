import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme.dart';
import '../../../../shared/models/models.dart';
import '../../../../shared/ui/ui.dart';
import '../providers/travellers_provider.dart';

/// Travellers List Screen
class TravellersListScreen extends ConsumerWidget {
  const TravellersListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final travellersAsync = ref.watch(travellersProvider);

    return Scaffold(
      backgroundColor: WaydeckTheme.background,
      appBar: AppBar(
        title: const Text('Travellers'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.push('/travellers/new'),
          ),
        ],
      ),
      body: travellersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (travellers) => _buildContent(context, ref, travellers),
      ),
    );
  }

  Widget _buildContent(BuildContext context, WidgetRef ref, List<Traveller> travellers) {
    if (travellers.isEmpty) {
      return _buildEmptyState(context);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: travellers.length,
      itemBuilder: (context, index) {
        final traveller = travellers[index];
        return _TravellerCard(
          traveller: traveller,
          onTap: () => context.push('/travellers/${traveller.id}'),
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('👤', style: TextStyle(fontSize: 64)),
          const SizedBox(height: 16),
          Text(
            'No travellers yet',
            style: WaydeckTheme.heading3,
          ),
          const SizedBox(height: 8),
          Text(
            'Add travellers to easily assign them to trips',
            style: WaydeckTheme.bodyMedium.copyWith(
              color: WaydeckTheme.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => context.push('/travellers/new'),
            icon: const Icon(Icons.add),
            label: const Text('Add Traveller'),
          ),
        ],
      ),
    );
  }
}

class _TravellerCard extends StatelessWidget {
  final Traveller traveller;
  final VoidCallback? onTap;

  const _TravellerCard({required this.traveller, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: WaydeckCard(
        onTap: onTap,
        child: Row(
          children: [
            // Avatar
            CircleAvatar(
              radius: 24,
              backgroundColor: WaydeckTheme.primary.withValues(alpha: 0.1),
              child: Text(
                traveller.initials,
                style: WaydeckTheme.bodyLarge.copyWith(
                  color: WaydeckTheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 16),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    traveller.fullName,
                    style: WaydeckTheme.bodyLarge.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (traveller.email != null || traveller.phone != null)
                    Text(
                      traveller.email ?? traveller.phone ?? '',
                      style: WaydeckTheme.bodySmall.copyWith(
                        color: WaydeckTheme.textSecondary,
                      ),
                    ),
                  if (traveller.passportNumber != null)
                    Row(
                      children: [
                        Text(
                          '🛂 ${traveller.passportNumber}',
                          style: WaydeckTheme.caption,
                        ),
                        if (traveller.isPassportExpired)
                          Padding(
                            padding: const EdgeInsets.only(left: 4),
                            child: BadgeChip(
                              label: 'Expired',
                              backgroundColor: Colors.red.withValues(alpha: 0.1),
                              textColor: Colors.red,
                              small: true,
                            ),
                          )
                        else if (traveller.isPassportExpiringSoon)
                          Padding(
                            padding: const EdgeInsets.only(left: 4),
                            child: BadgeChip(
                              label: 'Expires Soon',
                              backgroundColor: Colors.orange.withValues(alpha: 0.1),
                              textColor: Colors.orange,
                              small: true,
                            ),
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
}
