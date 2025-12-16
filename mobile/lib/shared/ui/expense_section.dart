import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../models/enums.dart';
import 'waydeck_input.dart';

/// Common currencies for quick selection
const List<String> commonCurrencies = [
  'USD', 'EUR', 'GBP', 'INR', 'JPY', 'AUD', 'CAD', 'SGD', 'AED', 'THB'
];

/// Payment methods for selection
const List<String> paymentMethods = [
  'Cash', 'Credit Card', 'Debit Card', 'UPI', 'Bank Transfer', 'Wallet', 'Other'
];

/// Reusable Expense Section Widget for forms
/// 
/// Includes fields for: amount, currency, payment status, payment method, notes
class ExpenseSection extends StatelessWidget {
  final TextEditingController amountController;
  final TextEditingController notesController;
  final String? selectedCurrency;
  final PaymentStatus paymentStatus;
  final String? paymentMethod;
  final ValueChanged<String?> onCurrencyChanged;
  final ValueChanged<PaymentStatus> onStatusChanged;
  final ValueChanged<String?> onMethodChanged;
  final bool isExpanded;
  final VoidCallback? onToggle;

  const ExpenseSection({
    super.key,
    required this.amountController,
    required this.notesController,
    this.selectedCurrency,
    required this.paymentStatus,
    this.paymentMethod,
    required this.onCurrencyChanged,
    required this.onStatusChanged,
    required this.onMethodChanged,
    this.isExpanded = false,
    this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header with toggle
        InkWell(
          onTap: onToggle,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Icon(
                  Icons.payments_outlined,
                  size: 20,
                  color: WaydeckTheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Expense Details',
                  style: WaydeckTheme.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                if (amountController.text.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: WaydeckTheme.success.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${selectedCurrency ?? 'INR'} ${amountController.text}',
                      style: WaydeckTheme.caption.copyWith(
                        color: WaydeckTheme.success,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                const SizedBox(width: 8),
                Icon(
                  isExpanded ? Icons.expand_less : Icons.expand_more,
                  color: WaydeckTheme.textSecondary,
                ),
              ],
            ),
          ),
        ),

        // Collapsible content
        if (isExpanded) ...[
          const SizedBox(height: 12),

          // Amount and Currency row
          Row(
            children: [
              // Amount field
              Expanded(
                flex: 2,
                child: WaydeckInput(
                  controller: amountController,
                  label: 'Amount',
                  hintText: '0.00',
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  prefixIcon: Icons.currency_rupee,
                ),
              ),
              const SizedBox(width: 12),
              // Currency selector
              Expanded(
                child: _buildCurrencyDropdown(context),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Payment Status chips
          Text(
            'Payment Status',
            style: WaydeckTheme.bodySmall.copyWith(
              fontWeight: FontWeight.w500,
              color: WaydeckTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: PaymentStatus.values.map((status) {
              final isSelected = paymentStatus == status;
              return ChoiceChip(
                label: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(status.icon),
                    const SizedBox(width: 4),
                    Text(status.displayName),
                  ],
                ),
                selected: isSelected,
                onSelected: (selected) {
                  if (selected) onStatusChanged(status);
                },
                selectedColor: _getStatusColor(status).withValues(alpha: 0.2),
                labelStyle: TextStyle(
                  color: isSelected ? _getStatusColor(status) : null,
                  fontWeight: isSelected ? FontWeight.w600 : null,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),

          // Payment Method dropdown
          _buildPaymentMethodDropdown(context),
          const SizedBox(height: 16),

          // Expense Notes
          WaydeckInput(
            controller: notesController,
            label: 'Expense Notes',
            hintText: 'e.g., Paid via company card, reimbursable',
            maxLines: 2,
          ),
        ],
      ],
    );
  }

  Widget _buildCurrencyDropdown(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Currency',
          style: WaydeckTheme.bodySmall.copyWith(
            fontWeight: FontWeight.w500,
            color: WaydeckTheme.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Theme.of(context).inputDecorationTheme.fillColor,
            borderRadius: BorderRadius.circular(WaydeckTheme.radiusMd),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: selectedCurrency ?? 'INR',
              isExpanded: true,
              icon: const Icon(Icons.arrow_drop_down),
              items: commonCurrencies.map((currency) {
                return DropdownMenuItem(
                  value: currency,
                  child: Text(currency),
                );
              }).toList(),
              onChanged: onCurrencyChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentMethodDropdown(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Payment Method',
          style: WaydeckTheme.bodySmall.copyWith(
            fontWeight: FontWeight.w500,
            color: WaydeckTheme.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Theme.of(context).inputDecorationTheme.fillColor,
            borderRadius: BorderRadius.circular(WaydeckTheme.radiusMd),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String?>(
              value: paymentMethod,
              isExpanded: true,
              hint: const Text('Select method'),
              icon: const Icon(Icons.arrow_drop_down),
              items: [
                const DropdownMenuItem(value: null, child: Text('Not specified')),
                ...paymentMethods.map((method) {
                  return DropdownMenuItem(
                    value: method,
                    child: Text(method),
                  );
                }),
              ],
              onChanged: onMethodChanged,
            ),
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.paid:
        return WaydeckTheme.success;
      case PaymentStatus.partial:
        return WaydeckTheme.warning;
      case PaymentStatus.notPaid:
        return WaydeckTheme.textSecondary;
    }
  }
}
