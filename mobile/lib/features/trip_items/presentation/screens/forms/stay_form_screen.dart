import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../../app/theme.dart';
import '../../../../../shared/ui/ui.dart';
import '../../../../../shared/models/enums.dart';
import '../../providers/trip_items_provider.dart';

/// Stay Form Screen
class StayFormScreen extends ConsumerStatefulWidget {
  final String tripId;
  final String? itemId;

  const StayFormScreen({super.key, required this.tripId, this.itemId});

  bool get isEdit => itemId != null;

  @override
  ConsumerState<StayFormScreen> createState() => _StayFormScreenState();
}

class _StayFormScreenState extends ConsumerState<StayFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  String? _countryCode;  // Changed from TextEditingController to String
  final _confirmationController = TextEditingController();
  final _urlController = TextEditingController();
  final _commentController = TextEditingController();

  DateTime? _checkinDate;
  TimeOfDay? _checkinTime;
  DateTime? _checkoutDate;
  TimeOfDay? _checkoutTime;
  bool _hasBreakfast = false;
  bool _isLoading = false;
  
  // Expense fields
  final _expenseAmountController = TextEditingController();
  final _expenseNotesController = TextEditingController();
  String? _expenseCurrency = 'INR';
  PaymentStatus _paymentStatus = PaymentStatus.notPaid;
  String? _paymentMethod;
  bool _expenseExpanded = false;

  @override
  void initState() {
    super.initState();
    if (widget.isEdit) {
      _loadExistingData();
    }
  }

  Future<void> _loadExistingData() async {
    setState(() => _isLoading = true);
    try {
      final item = await ref.read(tripItemProvider(widget.itemId!).future);
      if (item != null && mounted) {
        final details = item.stayDetails;
        setState(() {
          _nameController.text = details?.accommodationName ?? item.title;
          _addressController.text = details?.address ?? '';
          _cityController.text = details?.city ?? '';
          _countryCode = details?.countryCode;
          _confirmationController.text = details?.confirmationNumber ?? '';
          _urlController.text = details?.bookingUrl ?? '';
          _commentController.text = item.comment ?? '';
          _hasBreakfast = details?.hasBreakfast ?? false;
          
          if (details?.checkinLocal != null) {
            _checkinDate = details!.checkinLocal;
            _checkinTime = TimeOfDay.fromDateTime(details.checkinLocal!);
          }
          if (details?.checkoutLocal != null) {
            _checkoutDate = details!.checkoutLocal;
            _checkoutTime = TimeOfDay.fromDateTime(details.checkoutLocal!);
          }
        });
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _confirmationController.dispose();
    _urlController.dispose();
    _commentController.dispose();
    _expenseAmountController.dispose();
    _expenseNotesController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    final checkinLocal = _combineDateAndTime(_checkinDate, _checkinTime);
    final checkoutLocal = _combineDateAndTime(_checkoutDate, _checkoutTime);

    // Validate that checkout is after checkin
    if (checkinLocal != null && checkoutLocal != null) {
      if (checkoutLocal.isBefore(checkinLocal)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Check-out time must be after check-in time'),
            backgroundColor: WaydeckTheme.error,
          ),
        );
        return;
      }
    }

    final success = await ref.read(tripItemFormProvider.notifier).createStayItem(
      tripId: widget.tripId,
      title: _nameController.text,
      startTimeUtc: checkinLocal,
      endTimeUtc: checkoutLocal,
      comment: _commentController.text.isEmpty ? null : _commentController.text,
      accommodationName: _nameController.text,
      address: _addressController.text.isEmpty ? null : _addressController.text,
      city: _cityController.text.isEmpty ? null : _cityController.text,
      countryCode: _countryCode,
      checkinLocal: checkinLocal,
      checkoutLocal: checkoutLocal,
      hasBreakfast: _hasBreakfast,
      confirmationNumber: _confirmationController.text.isEmpty ? null : _confirmationController.text,
      bookingUrl: _urlController.text.isEmpty ? null : _urlController.text,
    );

    if (success && mounted) {
      context.pop();
    }
  }

  DateTime? _combineDateAndTime(DateTime? date, TimeOfDay? time) {
    if (date == null) return null;
    if (time == null) return date;
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
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
        title: Text(widget.isEdit ? 'Edit Stay' : 'Add Stay'),
        actions: [
          TextButton(
            onPressed: formState.isLoading ? null : _handleSave,
            child: formState.isLoading
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('Save'),
          ),
        ],
      ),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            PlacesAutocomplete(
              controller: _nameController,
              label: 'Hotel / Accommodation Name *',
              hintText: 'Search hotel or accommodation',
              type: PlaceType.establishment,
              establishmentType: 'lodging',
              onSelected: (prediction, details) {
                _nameController.text = prediction.mainText;
                if (details != null) {
                  if (details.formattedAddress != null && _addressController.text.isEmpty) {
                    _addressController.text = details.formattedAddress!;
                  }
                  if (details.city != null && _cityController.text.isEmpty) {
                    _cityController.text = details.city!;
                  }
                  if (details.countryCode != null && _countryCode == null) {
                    setState(() => _countryCode = details.countryCode);
                  }
                }
              },
            ),
            const SizedBox(height: 16),
            WaydeckInput(
              controller: _addressController,
              label: 'Address',
              hintText: '123 Beach Road',
            ),
            const SizedBox(height: 12),
            PlacesAutocomplete(
              controller: _cityController,
              label: 'City',
              hintText: 'Search city',
              type: PlaceType.city,
              onSelected: (prediction, details) {
                _cityController.text = prediction.mainText;
                if (details?.countryCode != null && _countryCode == null) {
                  setState(() => _countryCode = details!.countryCode);
                }
              },
            ),
            const SizedBox(height: 12),
            CountryPicker(
              selectedCode: _countryCode,
              onChanged: (code) => setState(() => _countryCode = code),
              label: 'Country',
            ),
            const SizedBox(height: 24),

            // Check-in/out
            Text('Check-in / Check-out', style: WaydeckTheme.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            _buildDateTimeRow('Check-in', _checkinDate, _checkinTime, isCheckin: true),
            const SizedBox(height: 12),
            _buildDateTimeRow('Check-out', _checkoutDate, _checkoutTime, isCheckin: false),
            const SizedBox(height: 24),

            // Breakfast
            SwitchListTile(
              title: const Text('Breakfast Included'),
              secondary: const Text('🍳', style: TextStyle(fontSize: 24)),
              value: _hasBreakfast,
              onChanged: (v) => setState(() => _hasBreakfast = v),
            ),
            const SizedBox(height: 16),

            // Booking
            WaydeckInput(
              controller: _confirmationController,
              label: 'Confirmation Number',
              hintText: 'HTL-98765',
            ),
            const SizedBox(height: 12),
            WaydeckInput(
              controller: _urlController,
              label: 'Booking URL',
              hintText: 'https://booking.com/...',
              keyboardType: TextInputType.url,
            ),
            const SizedBox(height: 24),

            // Expense Section
            ExpenseSection(
              amountController: _expenseAmountController,
              notesController: _expenseNotesController,
              selectedCurrency: _expenseCurrency,
              paymentStatus: _paymentStatus,
              paymentMethod: _paymentMethod,
              onCurrencyChanged: (c) => setState(() => _expenseCurrency = c),
              onStatusChanged: (s) => setState(() => _paymentStatus = s),
              onMethodChanged: (m) => setState(() => _paymentMethod = m),
              isExpanded: _expenseExpanded,
              onToggle: () => setState(() => _expenseExpanded = !_expenseExpanded),
            ),
            const SizedBox(height: 24),

            WaydeckInput(
              controller: _commentController,
              label: 'Comment',
              hintText: 'Any notes...',
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateTimeRow(String label, DateTime? date, TimeOfDay? time, {required bool isCheckin}) {
    return Row(
      children: [
        Expanded(
          child: _buildPicker(
            icon: Icons.calendar_today,
            text: date != null ? '${date.day}/${date.month}/${date.year}' : '$label Date',
            hasValue: date != null,
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: date ?? DateTime.now(),
                firstDate: DateTime(2020),
                lastDate: DateTime(2100),
              );
              if (picked != null) {
                setState(() {
                  if (isCheckin) {
                    _checkinDate = picked;
                  } else {
                    _checkoutDate = picked;
                  }
                });
              }
            },
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildPicker(
            icon: Icons.access_time,
            text: time != null ? time.format(context) : '$label Time',
            hasValue: time != null,
            onTap: () async {
              final picked = await showTimePicker(
                context: context,
                initialTime: time ?? (isCheckin ? const TimeOfDay(hour: 14, minute: 0) : const TimeOfDay(hour: 11, minute: 0)),
              );
              if (picked != null) {
                setState(() {
                  if (isCheckin) {
                    _checkinTime = picked;
                  } else {
                    _checkoutTime = picked;
                  }
                });
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPicker({
    required IconData icon,
    required String text,
    required bool hasValue,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(WaydeckTheme.radiusMd),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: WaydeckTheme.surfaceVariant,
          borderRadius: BorderRadius.circular(WaydeckTheme.radiusMd),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: WaydeckTheme.textSecondary),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                text,
                style: WaydeckTheme.bodyMedium.copyWith(
                  color: hasValue ? WaydeckTheme.textPrimary : WaydeckTheme.textTertiary,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
