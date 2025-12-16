import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../../app/theme.dart';
import '../../../../../shared/ui/ui.dart';
import '../../../../../shared/models/enums.dart';
import '../../providers/trip_items_provider.dart';

/// Activity Form Screen
class ActivityFormScreen extends ConsumerStatefulWidget {
  final String tripId;
  final String? itemId;

  const ActivityFormScreen({super.key, required this.tripId, this.itemId});

  bool get isEdit => itemId != null;

  @override
  ConsumerState<ActivityFormScreen> createState() => _ActivityFormScreenState();
}

class _ActivityFormScreenState extends ConsumerState<ActivityFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _locationController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  String? _countryCode;  // Changed from TextEditingController to String
  final _bookingCodeController = TextEditingController();
  final _urlController = TextEditingController();
  final _commentController = TextEditingController();

  String? _category;
  DateTime? _startDate;
  TimeOfDay? _startTime;
  DateTime? _endDate;
  TimeOfDay? _endTime;
  bool _isLoading = false;
  
  // Expense fields
  final _expenseAmountController = TextEditingController();
  final _expenseNotesController = TextEditingController();
  String? _expenseCurrency = 'INR';
  PaymentStatus _paymentStatus = PaymentStatus.notPaid;
  String? _paymentMethod;
  bool _expenseExpanded = false;

  final List<String> _categories = [
    'tour', 'museum', 'food', 'nightlife', 'adventure', 'shopping', 'relaxation', 'other'
  ];

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
        final details = item.activityDetails;
        setState(() {
          _nameController.text = item.title;
          _locationController.text = details?.locationName ?? '';
          _addressController.text = details?.address ?? '';
          _cityController.text = details?.city ?? '';
          _countryCode = details?.countryCode;
          _bookingCodeController.text = details?.bookingCode ?? '';
          _urlController.text = details?.bookingUrl ?? '';
          _commentController.text = item.comment ?? '';
          _category = details?.category;
          
          if (details?.startLocal != null) {
            _startDate = details!.startLocal;
            _startTime = TimeOfDay.fromDateTime(details.startLocal!);
          }
          if (details?.endLocal != null) {
            _endDate = details!.endLocal;
            _endTime = TimeOfDay.fromDateTime(details.endLocal!);
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
    _locationController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _bookingCodeController.dispose();
    _urlController.dispose();
    _commentController.dispose();
    _expenseAmountController.dispose();
    _expenseNotesController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    final startLocal = _combineDateAndTime(_startDate, _startTime);
    final endLocal = _combineDateAndTime(_endDate, _endTime);

    // Validate that end time is after start time
    if (startLocal != null && endLocal != null) {
      if (endLocal.isBefore(startLocal)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('End time must be after start time'),
            backgroundColor: WaydeckTheme.error,
          ),
        );
        return;
      }
    }

    final success = await ref.read(tripItemFormProvider.notifier).createActivityItem(
      tripId: widget.tripId,
      title: _nameController.text,
      startTimeUtc: startLocal,
      endTimeUtc: endLocal,
      comment: _commentController.text.isEmpty ? null : _commentController.text,
      category: _category,
      locationName: _locationController.text.isEmpty ? null : _locationController.text,
      address: _addressController.text.isEmpty ? null : _addressController.text,
      city: _cityController.text.isEmpty ? null : _cityController.text,
      countryCode: _countryCode,
      startLocal: startLocal,
      endLocal: endLocal,
      bookingCode: _bookingCodeController.text.isEmpty ? null : _bookingCodeController.text,
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
        title: Text(widget.isEdit ? 'Edit Activity' : 'Add Activity'),
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
            WaydeckInput(
              controller: _nameController,
              label: 'Activity Name *',
              hintText: 'e.g., Ba Na Hills Day Tour',
              validator: (v) => v?.isEmpty == true ? 'Required' : null,
            ),
            const SizedBox(height: 16),

            // Category
            Text('Category', style: WaydeckTheme.bodySmall.copyWith(
              fontWeight: FontWeight.w500,
              color: WaydeckTheme.textSecondary,
            )),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _categories.map((cat) {
                final isSelected = _category == cat;
                return ChoiceChip(
                  label: Text(cat),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() => _category = selected ? cat : null);
                  },
                  selectedColor: WaydeckTheme.activityColor.withValues(alpha: 0.2),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // Location
            PlacesAutocomplete(
              controller: _locationController,
              label: 'Location Name',
              hintText: 'Search venue or attraction',
              type: PlaceType.establishment,
              onSelected: (prediction, details) {
                _locationController.text = prediction.mainText;
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
            const SizedBox(height: 12),
            WaydeckInput(
              controller: _addressController,
              label: 'Address',
              hintText: 'Address line',
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

            // Times
            Text('Schedule', style: WaydeckTheme.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            _buildDateTimeRow('Start', _startDate, _startTime, isStart: true),
            const SizedBox(height: 12),
            _buildDateTimeRow('End', _endDate, _endTime, isStart: false),
            const SizedBox(height: 24),

            // Booking
            WaydeckInput(
              controller: _bookingCodeController,
              label: 'Booking Code',
              hintText: 'BANA-2025-1234',
            ),
            const SizedBox(height: 12),
            WaydeckInput(
              controller: _urlController,
              label: 'Booking URL',
              hintText: 'https://klook.com/...',
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

  Widget _buildDateTimeRow(String label, DateTime? date, TimeOfDay? time, {required bool isStart}) {
    return Row(
      children: [
        Expanded(child: _buildPicker(
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
                if (isStart) {
                  _startDate = picked;
                } else {
                  _endDate = picked;
                }
              });
            }
          },
        )),
        const SizedBox(width: 8),
        Expanded(child: _buildPicker(
          icon: Icons.access_time,
          text: time != null ? time.format(context) : '$label Time',
          hasValue: time != null,
          onTap: () async {
            final picked = await showTimePicker(
              context: context,
              initialTime: time ?? TimeOfDay.now(),
            );
            if (picked != null) {
              setState(() {
                if (isStart) {
                  _startTime = picked;
                } else {
                  _endTime = picked;
                }
              });
            }
          },
        )),
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
              child: Text(text, style: WaydeckTheme.bodyMedium.copyWith(
                color: hasValue ? WaydeckTheme.textPrimary : WaydeckTheme.textTertiary,
              ), overflow: TextOverflow.ellipsis),
            ),
          ],
        ),
      ),
    );
  }
}
