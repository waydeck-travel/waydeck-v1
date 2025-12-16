import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme.dart';
import '../../../../shared/ui/ui.dart';
import '../providers/trips_provider.dart';

/// Trip Form Screen for create/edit
class TripFormScreen extends ConsumerStatefulWidget {
  final bool isEdit;
  final String? tripId;

  const TripFormScreen({
    super.key,
    required this.isEdit,
    this.tripId,
  });

  @override
  ConsumerState<TripFormScreen> createState() => _TripFormScreenState();
}

class _TripFormScreenState extends ConsumerState<TripFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _originCityController = TextEditingController();
  final _notesController = TextEditingController();
  String? _originCountryCode;
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    if (widget.isEdit && widget.tripId != null) {
      _loadTrip();
    }
  }

  Future<void> _loadTrip() async {
    final trip = await ref.read(tripProvider(widget.tripId!).future);
    if (trip != null && mounted) {
      setState(() {
        _nameController.text = trip.name;
        _originCityController.text = trip.originCity ?? '';
        _originCountryCode = trip.originCountryCode;
        _notesController.text = trip.notes ?? '';
        _startDate = trip.startDate;
        _endDate = trip.endDate;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _originCityController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    print('_handleSave: called');
    if (!_formKey.currentState!.validate()) {
      print('_handleSave: Form validation failed');
      return;
    }
    
    // Check for date validation errors
    if (_dateError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_dateError!),
          backgroundColor: WaydeckTheme.error,
        ),
      );
      return;
    }
    print('_handleSave: Form validated, name="${_nameController.text.trim()}"');

    final notifier = ref.read(tripFormProvider.notifier);
    bool success;

    if (widget.isEdit && widget.tripId != null) {
      print('_handleSave: Updating existing trip');
      success = await notifier.updateTrip(
        tripId: widget.tripId!,
        name: _nameController.text.trim(),
        originCity: _originCityController.text.trim().isEmpty
            ? null
            : _originCityController.text.trim(),
        originCountryCode: _originCountryCode,
        startDate: _startDate,
        endDate: _endDate,
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
      );
    } else {
      print('_handleSave: Creating new trip');
      success = await notifier.createTrip(
        name: _nameController.text.trim(),
        originCity: _originCityController.text.trim().isEmpty
            ? null
            : _originCityController.text.trim(),
        originCountryCode: _originCountryCode,
        startDate: _startDate,
        endDate: _endDate,
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
      );
    }

    print('_handleSave: Result success=$success');
    if (success && mounted) {
      context.pop();
    }
  }

  String? _dateError;

  Future<void> _selectDate({required bool isStart}) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: (isStart ? _startDate : _endDate) ?? now,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
          // Clear error if now valid
          if (_endDate != null && !_endDate!.isBefore(_startDate!)) {
            _dateError = null;
          } else if (_endDate != null && _endDate!.isBefore(_startDate!)) {
            _dateError = 'End date must be on or after start date';
          }
        } else {
          _endDate = picked;
          // Validate: end date should not be before start date
          if (_startDate != null && _endDate!.isBefore(_startDate!)) {
            _dateError = 'End date must be on or after start date';
          } else {
            _dateError = null;
          }
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(tripFormProvider);

    return Scaffold(
      backgroundColor: WaydeckTheme.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
        title: Text(widget.isEdit ? 'Edit Trip' : 'Create Trip'),
        actions: [
          TextButton(
            onPressed: formState.isLoading ? null : _handleSave,
            child: formState.isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Save'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Error display
            if (formState.error != null)
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: WaydeckTheme.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(WaydeckTheme.radiusMd),
                ),
                child: Text(
                  formState.error!,
                  style: WaydeckTheme.bodySmall.copyWith(
                    color: WaydeckTheme.error,
                  ),
                ),
              ),

            // Trip name
            WaydeckInput(
              controller: _nameController,
              label: 'Trip Name *',
              hintText: 'e.g., Vietnam & Thailand 2025',
              textInputAction: TextInputAction.next,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a trip name';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            // Origin section
            Text(
              'Origin',
              style: WaydeckTheme.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            PlacesAutocomplete(
              controller: _originCityController,
              label: 'City',
              hintText: 'Search city',
              type: PlaceType.city,
              onSelected: (prediction, details) {
                _originCityController.text = prediction.mainText;
                if (details?.countryCode != null && _originCountryCode == null) {
                  setState(() => _originCountryCode = details!.countryCode);
                }
              },
            ),
            const SizedBox(height: 12),
            CountryPicker(
              label: 'Country',
              selectedCode: _originCountryCode,
              hintText: 'Select country...',
              onChanged: (code) {
                setState(() {
                  _originCountryCode = code;
                });
              },
            ),
            const SizedBox(height: 24),

            // Dates section
            Text(
              'Dates',
              style: WaydeckTheme.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildDateField(
                    label: 'Start Date',
                    date: _startDate,
                    onTap: () => _selectDate(isStart: true),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildDateField(
                    label: 'End Date',
                    date: _endDate,
                    onTap: () => _selectDate(isStart: false),
                    hasError: _dateError != null,
                  ),
                ),
              ],
            ),
            if (_dateError != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.error_outline, size: 16, color: WaydeckTheme.error),
                  const SizedBox(width: 4),
                  Text(
                    _dateError!,
                    style: WaydeckTheme.bodySmall.copyWith(
                      color: WaydeckTheme.error,
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 24),

            // Notes
            WaydeckInput(
              controller: _notesController,
              label: 'Notes',
              hintText: 'Any notes about this trip...',
              maxLines: 4,
              textInputAction: TextInputAction.newline,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateField({
    required String label,
    required DateTime? date,
    required VoidCallback onTap,
    bool hasError = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: WaydeckTheme.bodySmall.copyWith(
            fontWeight: FontWeight.w500,
            color: hasError ? WaydeckTheme.error : WaydeckTheme.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(WaydeckTheme.radiusMd),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: WaydeckTheme.surfaceVariant,
              borderRadius: BorderRadius.circular(WaydeckTheme.radiusMd),
              border: hasError ? Border.all(color: WaydeckTheme.error) : null,
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  size: 18,
                  color: WaydeckTheme.textSecondary,
                ),
                const SizedBox(width: 8),
                Text(
                  date != null
                      ? '${date.day}/${date.month}/${date.year}'
                      : 'Select',
                  style: WaydeckTheme.bodyMedium.copyWith(
                    color: date != null
                        ? WaydeckTheme.textPrimary
                        : WaydeckTheme.textTertiary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
