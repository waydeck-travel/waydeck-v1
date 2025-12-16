import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme.dart';
import '../../../../shared/ui/ui.dart';
import '../../../../shared/models/enums.dart';
import '../../../../shared/models/trip_budget.dart';
import '../../../../shared/models/trip_expense.dart';
import '../../presentation/providers/trips_provider.dart';
import '../../../budgets/presentation/providers/budgets_provider.dart';
import '../../../expenses/presentation/providers/expenses_provider.dart';

/// Trip Budget Screen - Shows per-category budget with progress bars
class TripBudgetScreen extends ConsumerStatefulWidget {
  final String tripId;

  const TripBudgetScreen({super.key, required this.tripId});

  @override
  ConsumerState<TripBudgetScreen> createState() => _TripBudgetScreenState();
}

class _TripBudgetScreenState extends ConsumerState<TripBudgetScreen> {
  final String _selectedCurrency = 'INR'; // TODO: Get from Trip settings

  @override
  Widget build(BuildContext context) {
    final tripAsync = ref.watch(tripProvider(widget.tripId));
    final budgetsAsync = ref.watch(tripBudgetsProvider(widget.tripId));
    final expensesAsync = ref.watch(tripExpensesProvider(widget.tripId));

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Trip Budget'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Budget editing coming soon!')),
              );
            },
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

          return budgetsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Error loading budgets: $e')),
            data: (budgets) {
              return expensesAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Error loading expenses: $e')),
                data: (expenses) {
                  final (budgetMap, totalBudget, totalSpent) = _calculateBudgetInfo(budgets, expenses);
                  final remaining = totalBudget - totalSpent;
                  final overBudget = remaining < 0 && totalBudget > 0;

                  return ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      // Overview card
                      _buildOverviewCard(totalBudget, totalSpent, remaining, overBudget),
                      const SizedBox(height: 24),

                      // Category budgets
                      Text('Category Budgets', style: WaydeckTheme.heading3),
                      const SizedBox(height: 12),
                      if (budgetMap.isEmpty)
                         const Text('No budgets set. Add expenses or set limits.'),

                      ...ExpenseCategory.values.map((cat) {
                        final info = budgetMap[cat];
                        if (info == null && !_hasExpense(expenses, cat)) return const SizedBox.shrink();
                        
                        // If we have expenses but no budget, show it as 0 budget
                        final effectiveInfo = info ?? BudgetInfo(budget: 0, spent: _calculateSpent(expenses, cat));
                         
                        // Only show if there is either a budget or spent amount
                        if (effectiveInfo.budget == 0 && effectiveInfo.spent == 0) return const SizedBox.shrink();

                        return _buildCategoryBudgetCard(cat, effectiveInfo);
                      }),
                      const SizedBox(height: 24),

                      // Tips/suggestions
                      _buildTipsCard(),
                    ],
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  bool _hasExpense(List<TripExpense> expenses, ExpenseCategory category) {
      return expenses.any((e) => e.category.toLowerCase() == category.name.toLowerCase());
  }

  double _calculateSpent(List<TripExpense> expenses, ExpenseCategory category) {
      return expenses
        .where((e) => e.category.toLowerCase() == category.name.toLowerCase())
        .fold(0.0, (sum, e) => sum + e.amount);
  }

  (Map<ExpenseCategory, BudgetInfo>, double, double) _calculateBudgetInfo(
      List<TripBudget> budgets, List<TripExpense> expenses) {
    
    final map = <ExpenseCategory, BudgetInfo>{};
    double totalBudget = 0.0;
    double totalSpent = 0.0;

    // Process budgets
    for (final b in budgets) {
       // Find category enum
       final cat = ExpenseCategory.values.firstWhere(
         (c) => c.name.toLowerCase() == b.category.toLowerCase(),
         orElse: () => ExpenseCategory.other
       );
       
       totalBudget += b.budgetAmount;
       
       // Calculate spent for this category
       final spent = _calculateSpent(expenses, cat);
       
       map[cat] = BudgetInfo(budget: b.budgetAmount, spent: spent);
    }
    
    // Process expenses that might not have a budget set
    for (final e in expenses) {
        totalSpent += e.amount;
        
        final cat = ExpenseCategory.values.firstWhere(
           (c) => c.name.toLowerCase() == e.category.toLowerCase(),
           orElse: () => ExpenseCategory.other
        );

        if (!map.containsKey(cat)) {
           // No budget set for this category
           map[cat] = BudgetInfo(budget: 0, spent: _calculateSpent(expenses, cat));
        }
    }

    return (map, totalBudget, totalSpent);
  }

  Widget _buildOverviewCard(double totalBudget, double totalSpent, double remaining, bool overBudget) {
    // Prevent div by zero
    final percentage = totalBudget > 0 ? (totalSpent / totalBudget) : (totalSpent > 0 ? 1.0 : 0.0);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: overBudget 
              ? [WaydeckTheme.error, const Color(0xFFB91C1C)]
              : [WaydeckTheme.success, const Color(0xFF15803D)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: WaydeckTheme.shadowMd,
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildOverviewStat('Budget', totalBudget),
              _buildOverviewStat('Spent', totalSpent),
              _buildOverviewStat(
                overBudget ? 'Over' : 'Remaining',
                remaining.abs(),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Overall progress
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Budget Usage',
                    style: WaydeckTheme.bodySmall.copyWith(
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                  Text(
                    '${(percentage * 100).toStringAsFixed(0)}%',
                    style: WaydeckTheme.bodyMedium.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: percentage.clamp(0.0, 1.0),
                  backgroundColor: Colors.white.withValues(alpha: 0.3),
                  valueColor: const AlwaysStoppedAnimation(Colors.white),
                  minHeight: 8,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewStat(String label, double value) {
    return Column(
      children: [
        Text(
          label,
          style: WaydeckTheme.caption.copyWith(
            color: Colors.white.withValues(alpha: 0.8),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '$_selectedCurrency ${_formatAmount(value)}',
          style: WaydeckTheme.bodyMedium.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryBudgetCard(ExpenseCategory category, BudgetInfo info) {
    final percentage = info.budget > 0 ? (info.spent / info.budget) : (info.spent > 0 ? 1.0 : 0.0);
    final isOverBudget = info.budget > 0 && percentage > 1.0;
    final remaining = info.budget - info.spent;

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
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _getCategoryColor(category).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(category.icon, style: const TextStyle(fontSize: 20)),
                  ),
                ),
                const SizedBox(width: 12),
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
                      if (info.budget > 0)
                        Text(
                            isOverBudget
                                ? 'Over by $_selectedCurrency ${_formatAmount(-remaining)}'
                                : 'Remaining: $_selectedCurrency ${_formatAmount(remaining)}',
                            style: WaydeckTheme.caption.copyWith(
                            color: isOverBudget ? WaydeckTheme.error : WaydeckTheme.success,
                            ),
                        )
                      else
                        Text(
                            'No Limit',
                            style: WaydeckTheme.caption.copyWith(color: WaydeckTheme.textSecondary),
                        ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${_formatAmount(info.spent)} / ${_formatAmount(info.budget)}',
                      style: WaydeckTheme.bodySmall.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '${(percentage * 100).toStringAsFixed(0)}%',
                      style: WaydeckTheme.caption.copyWith(
                        color: isOverBudget ? WaydeckTheme.error : null,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: percentage.clamp(0.0, 1.0),
                backgroundColor: WaydeckTheme.surfaceVariant,
                valueColor: AlwaysStoppedAnimation(
                  isOverBudget ? WaydeckTheme.error : _getCategoryColor(category),
                ),
                minHeight: 6,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTipsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: WaydeckTheme.info.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: WaydeckTheme.info.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.lightbulb_outline, color: WaydeckTheme.info),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Budget Tip',
                  style: WaydeckTheme.bodySmall.copyWith(
                    fontWeight: FontWeight.w600,
                    color: WaydeckTheme.info,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Set realistic budgets based on destination costs. Track expenses as you go to stay on target.',
                  style: WaydeckTheme.caption.copyWith(
                    color: WaydeckTheme.textSecondary,
                  ),
                ),
              ],
            ),
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
    return amount.toStringAsFixed(0);
  }
}

/// Budget info holder
class BudgetInfo {
  final double budget;
  final double spent;

  BudgetInfo({required this.budget, required this.spent});
}
