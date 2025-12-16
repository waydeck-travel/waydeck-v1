import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme.dart';
import '../../../../shared/ui/ui.dart';
import '../../../../shared/models/enums.dart';
import '../../presentation/providers/trips_provider.dart';
import '../../../expenses/presentation/providers/expenses_provider.dart';

/// Trip Expenses Screen - Shows expense summary by category and total spent
class TripExpensesScreen extends ConsumerStatefulWidget {
  final String tripId;

  const TripExpensesScreen({super.key, required this.tripId});

  @override
  ConsumerState<TripExpensesScreen> createState() => _TripExpensesScreenState();
}

class _TripExpensesScreenState extends ConsumerState<TripExpensesScreen> {
  String _selectedCurrency = 'INR';

  @override
  Widget build(BuildContext context) {
    final tripAsync = ref.watch(tripProvider(widget.tripId));
    final expensesByCategoryAsync = ref.watch(expensesByCategoryProvider(widget.tripId));
    final totalSpentAsync = ref.watch(totalSpentProvider(widget.tripId));

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Trip Expenses'),
        actions: [
          PopupMenuButton<String>(
            initialValue: _selectedCurrency,
            icon: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: WaydeckTheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _selectedCurrency,
                style: WaydeckTheme.bodySmall.copyWith(
                  color: WaydeckTheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            onSelected: (currency) {
              setState(() => _selectedCurrency = currency);
            },
            itemBuilder: (context) => ['INR', 'USD', 'EUR', 'GBP']
                .map((c) => PopupMenuItem(value: c, child: Text(c)))
                .toList(),
          ),
        ],
      ),
      body: tripAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (trip) {
          if (trip == null) {
            return const Center(child: Text('Trip not found'));
          }

          // Get raw data from async providers with defaults
          final expensesByCategory = expensesByCategoryAsync.valueOrNull ?? <String, double>{};
          final totalSpent = totalSpentAsync.valueOrNull ?? 0.0;

          // Convert string keys to ExpenseCategory
          final categoryMap = <ExpenseCategory, double>{};
          for (final entry in expensesByCategory.entries) {
            try {
              final category = ExpenseCategory.values.firstWhere(
                (c) => c.name == entry.key,
                orElse: () => ExpenseCategory.other,
              );
              categoryMap[category] = entry.value;
            } catch (_) {
              categoryMap[ExpenseCategory.other] = (categoryMap[ExpenseCategory.other] ?? 0) + entry.value;
            }
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Total summary card
              _buildTotalCard(categoryMap, totalSpent),
              const SizedBox(height: 24),

              // Breakdown by category
              Text('Breakdown by Category', style: WaydeckTheme.heading3),
              const SizedBox(height: 12),
              ...categoryMap.entries.map((entry) => 
                _buildCategoryCard(entry.key, entry.value, totalSpent)),
              const SizedBox(height: 24),

              // Empty state for adding expenses
              if (totalSpent == 0)
                _buildEmptyState(),
            ],
          );
        },
      ),
    );
  }


  Widget _buildTotalCard(Map<ExpenseCategory, double> expensesByCategory, double totalSpent) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [WaydeckTheme.primary, WaydeckTheme.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: WaydeckTheme.shadowMd,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Total Expenses',
            style: WaydeckTheme.bodyMedium.copyWith(
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _selectedCurrency,
                style: WaydeckTheme.heading3.copyWith(
                  color: Colors.white.withValues(alpha: 0.8),
                ),
              ),
              const SizedBox(width: 4),
              Text(
                _formatAmount(totalSpent),
                style: WaydeckTheme.heading1.copyWith(
                  color: Colors.white,
                  fontSize: 36,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildStatChip('${expensesByCategory.length}', 'Categories'),
              const SizedBox(width: 12),
              _buildStatChip('${expensesByCategory.entries.where((e) => e.value > 0).length}', 'Items'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip(String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Text(
            value,
            style: WaydeckTheme.bodyMedium.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: WaydeckTheme.bodySmall.copyWith(
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(ExpenseCategory category, double amount, double totalAmount) {
    final percentage = totalAmount > 0 ? (amount / totalAmount) : 0.0;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: WaydeckCard(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: _getCategoryColor(category).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(category.icon, style: const TextStyle(fontSize: 24)),
              ),
            ),
            const SizedBox(width: 16),
            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category.displayName,
                    style: WaydeckTheme.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Progress bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: percentage,
                      backgroundColor: WaydeckTheme.surfaceVariant,
                      valueColor: AlwaysStoppedAnimation(_getCategoryColor(category)),
                      minHeight: 4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            // Amount
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '$_selectedCurrency ${_formatAmount(amount)}',
                  style: WaydeckTheme.bodyMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${(percentage * 100).toStringAsFixed(1)}%',
                  style: WaydeckTheme.caption,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: WaydeckTheme.surfaceVariant,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Text('💰', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 16),
          Text(
            'No expenses yet',
            style: WaydeckTheme.heading3,
          ),
          const SizedBox(height: 8),
          Text(
            'Add expense details when creating transport, stay, or activity items.',
            style: WaydeckTheme.bodySmall.copyWith(color: WaydeckTheme.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Color _getCategoryColor(ExpenseCategory category) {
    switch (category) {
      case ExpenseCategory.transport:
        return WaydeckTheme.transportColor;
      case ExpenseCategory.stay:
        return WaydeckTheme.stayColor;
      case ExpenseCategory.activity:
        return WaydeckTheme.activityColor;
      case ExpenseCategory.food:
        return const Color(0xFFEF4444);
      case ExpenseCategory.shopping:
        return const Color(0xFF8B5CF6);
      case ExpenseCategory.other:
        return WaydeckTheme.noteColor;
    }
  }

  String _formatAmount(double amount) {
    if (amount >= 1000) {
      return amount.toStringAsFixed(0).replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (m) => '${m[1]},',
      );
    }
    return amount.toStringAsFixed(2);
  }
}
