import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../../app/theme.dart';
import '../../../../../shared/models/models.dart';
import '../../../../../shared/ui/ui.dart';
import '../../../../../shared/data/mode_field_config.dart';
import '../../providers/trip_items_provider.dart';

/// Transport Form Screen with mode-specific fields
class TransportFormScreen extends ConsumerStatefulWidget {
  final String tripId;
  final String? itemId;

  const TransportFormScreen({
    super.key,
    required this.tripId,
    this.itemId,
  });

  bool get isEdit => itemId != null;

  @override
  ConsumerState<TransportFormScreen> createState() => _TransportFormScreenState();
}

class _TransportFormScreenState extends ConsumerState<TransportFormScreen> {
  final _formKey = GlobalKey<FormState>();
  
  TransportMode _mode = TransportMode.flight;
  
  // Carrier section
  final _carrierNameController = TextEditingController();
  final _carrierCodeController = TextEditingController();
  final _transportNumberController = TextEditingController();
  final _bookingRefController = TextEditingController();
  
  // Origin section
  final _originCityController = TextEditingController();
  final _originCodeController = TextEditingController();
  final _originStationController = TextEditingController();
  final _originTerminalController = TextEditingController();
  
  // Destination section
  final _destCityController = TextEditingController();
  final _destCodeController = TextEditingController();
  final _destStationController = TextEditingController();
  final _destTerminalController = TextEditingController();
  
  // Additional fields
  final _coachSeatController = TextEditingController();
  final _vehicleController = TextEditingController();
  final _vehicleNumberController = TextEditingController();
  final _passengerCountController = TextEditingController(text: '1');
  final _commentController = TextEditingController();
  
  // Expense fields
  final _expenseAmountController = TextEditingController();
  final _expenseNotesController = TextEditingController();
  String? _expenseCurrency = 'INR';
  PaymentStatus _paymentStatus = PaymentStatus.notPaid;
  String? _paymentMethod;
  bool _expenseExpanded = false;
  
  // Same location toggle for rentals (car/bike)
  bool _sameAsPickup = false;
  
  // Selected passenger traveller IDs
  List<String> _selectedPassengerIds = [];
  
  DateTime? _departureDate;
  TimeOfDay? _departureTime;
  DateTime? _arrivalDate;
  TimeOfDay? _arrivalTime;

  @override
  void dispose() {
    _carrierNameController.dispose();
    _carrierCodeController.dispose();
    _transportNumberController.dispose();
    _bookingRefController.dispose();
    _originCityController.dispose();
    _originCodeController.dispose();
    _originStationController.dispose();
    _originTerminalController.dispose();
    _destCityController.dispose();
    _destCodeController.dispose();
    _destStationController.dispose();
    _destTerminalController.dispose();
    _coachSeatController.dispose();
    _vehicleController.dispose();
    _vehicleNumberController.dispose();
    _passengerCountController.dispose();
    _commentController.dispose();
    _expenseAmountController.dispose();
    _expenseNotesController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    final departureLocal = _combineDateAndTime(_departureDate, _departureTime);
    final arrivalLocal = _combineDateAndTime(_arrivalDate, _arrivalTime);

    // Validate that arrival is after departure
    if (departureLocal != null && arrivalLocal != null) {
      if (arrivalLocal.isBefore(departureLocal)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Arrival time must be after departure time'),
            backgroundColor: WaydeckTheme.error,
          ),
        );
        return;
      }
    }

    // Generate title based on mode
    String title;
    if (_transportNumberController.text.isNotEmpty) {
      title = '${_mode.displayName} ${_transportNumberController.text}'.trim();
    } else if (_carrierNameController.text.isNotEmpty) {
      title = '${_mode.displayName} - ${_carrierNameController.text}'.trim();
    } else {
      title = _mode.displayName;
    }

    final success = await ref.read(tripItemFormProvider.notifier).createTransportItem(
      tripId: widget.tripId,
      title: title,
      startTimeUtc: departureLocal,
      endTimeUtc: arrivalLocal,
      comment: _commentController.text.isEmpty ? null : _commentController.text,
      mode: _mode,
      carrierName: _carrierNameController.text.isEmpty ? null : _carrierNameController.text,
      carrierCode: _carrierCodeController.text.isEmpty ? null : _carrierCodeController.text,
      transportNumber: _transportNumberController.text.isEmpty ? null : _transportNumberController.text,
      bookingReference: _bookingRefController.text.isEmpty ? null : _bookingRefController.text,
      originCity: _originCityController.text.isEmpty ? null : _originCityController.text,
      originAirportCode: _originCodeController.text.isEmpty ? null : _originCodeController.text.toUpperCase(),
      originTerminal: _originTerminalController.text.isEmpty 
          ? (_originStationController.text.isEmpty ? null : _originStationController.text)
          : _originTerminalController.text,
      destinationCity: _destCityController.text.isEmpty ? null : _destCityController.text,
      destinationAirportCode: _destCodeController.text.isEmpty ? null : _destCodeController.text.toUpperCase(),
      destinationTerminal: _destTerminalController.text.isEmpty 
          ? (_destStationController.text.isEmpty ? null : _destStationController.text)
          : _destTerminalController.text,
      departureLocal: departureLocal,
      arrivalLocal: arrivalLocal,
      passengerCount: int.tryParse(_passengerCountController.text),
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

  /// Extract IATA code from text (e.g., "BOM" from "Mumbai Airport (BOM)")
  String? _extractIataCode(String? text) {
    if (text == null) return null;
    // Try to find pattern like (BOM) or [BOM] or - BOM
    final patterns = [
      RegExp(r'\(([A-Z]{3})\)'),  // (BOM)
      RegExp(r'\[([A-Z]{3})\]'),  // [BOM]
      RegExp(r'\s-\s?([A-Z]{3})$'),  // - BOM at end
      RegExp(r'\b([A-Z]{3})\s+Airport', caseSensitive: true),  // DEL Airport
    ];
    for (final pattern in patterns) {
      final match = pattern.firstMatch(text);
      if (match != null) {
        return match.group(1);
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(tripItemFormProvider);
    final config = ModeFieldConfig.forMode(_mode);

    return Scaffold(
      backgroundColor: WaydeckTheme.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
        title: Text(widget.isEdit ? 'Edit Transport' : 'Add Transport'),
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
                  style: WaydeckTheme.bodySmall.copyWith(color: WaydeckTheme.error),
                ),
              ),

            // Mode selector
            Text('Mode *', style: WaydeckTheme.bodySmall.copyWith(
              fontWeight: FontWeight.w500,
              color: WaydeckTheme.textSecondary,
            )),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: TransportMode.values.map((mode) {
                final isSelected = _mode == mode;
                return ChoiceChip(
                  label: Text('${mode.icon} ${mode.displayName}'),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) setState(() => _mode = mode);
                  },
                  selectedColor: WaydeckTheme.primary.withValues(alpha: 0.2),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // Carrier section (conditional)
            if (config.showCarrier) ...[
              Text(config.carrierLabel, style: WaydeckTheme.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              if (config.showCarrierCode)
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: AirlineAutocomplete(
                        nameController: _carrierNameController,
                        codeController: _carrierCodeController,
                        label: config.carrierLabel,
                        hintText: config.carrierHint,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: WaydeckInput(
                        controller: _carrierCodeController,
                        label: 'Code',
                        hintText: '6E',
                      ),
                    ),
                  ],
                )
              else
                WaydeckInput(
                  controller: _carrierNameController,
                  label: config.carrierLabel,
                  hintText: config.carrierHint,
                ),
              const SizedBox(height: 12),
            ],

            // Number and Booking Reference
            if (config.showNumber || config.bookingLabel.isNotEmpty) ...[
              Row(
                children: [
                  if (config.showNumber)
                    Expanded(
                      child: WaydeckInput(
                        controller: _transportNumberController,
                        label: config.numberLabel,
                        hintText: config.numberHint,
                      ),
                    ),
                  if (config.showNumber && config.bookingLabel.isNotEmpty)
                    const SizedBox(width: 12),
                  if (config.bookingLabel.isNotEmpty)
                    Expanded(
                      child: WaydeckInput(
                        controller: _bookingRefController,
                        label: config.bookingLabel,
                        hintText: config.bookingHint,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
            ],

            // Vehicle info (for car/bike)
            if (config.showVehicle) ...[
              WaydeckInput(
                controller: _vehicleController,
                label: config.vehicleLabel,
                hintText: config.vehicleHint,
              ),
              const SizedBox(height: 12),
            ],

            // Vehicle registration number (for car/bike/bus)
            if (config.showVehicleNumber) ...[
              WaydeckInput(
                controller: _vehicleNumberController,
                label: config.vehicleNumberLabel,
                hintText: config.vehicleNumberHint,
              ),
              const SizedBox(height: 12),
            ],

            // Coach/Seat/Cabin
            if (config.showCoachSeat) ...[
              WaydeckInput(
                controller: _coachSeatController,
                label: config.coachSeatLabel,
                hintText: config.coachSeatHint,
              ),
              const SizedBox(height: 12),
            ],

            // Same location toggle for rentals
            if (config.allowSameLocation) ...[
              CheckboxListTile(
                title: Text(
                  'Return to same location',
                  style: WaydeckTheme.bodyMedium,
                ),
                subtitle: Text(
                  'Dropoff will be same as pickup',
                  style: WaydeckTheme.bodySmall.copyWith(
                    color: WaydeckTheme.textSecondary,
                  ),
                ),
                value: _sameAsPickup,
                onChanged: (value) {
                  setState(() {
                    _sameAsPickup = value ?? false;
                  });
                },
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
                activeColor: WaydeckTheme.primary,
              ),
              const SizedBox(height: 12),
            ],

            const SizedBox(height: 12),

            // Origin section
            Text(config.originSectionLabel, style: WaydeckTheme.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            
            // City/Airport row with optional airport code
            if (config.showLocationCode)
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: PlacesAutocomplete(
                      controller: _originCityController,
                      label: _mode == TransportMode.flight ? 'Airport *' : 'City *',
                      hintText: _mode == TransportMode.flight ? 'Search airport' : 'Search city',
                      type: _mode == TransportMode.flight ? PlaceType.airport : PlaceType.city,
                      onSelected: (prediction, details) {
                        _originCityController.text = prediction.mainText;
                        // Auto-fill airport code if available
                        if (_mode == TransportMode.flight) {
                          String? iataCode = _extractIataCode(prediction.mainText) ??
                              _extractIataCode(prediction.secondaryText) ??
                              _extractIataCode(prediction.description);
                          if (iataCode != null && _originCodeController.text.isEmpty) {
                            _originCodeController.text = iataCode;
                          }
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: WaydeckInput(
                      controller: _originCodeController,
                      label: config.locationCodeLabel,
                      hintText: config.locationCodeHint,
                    ),
                  ),
                ],
              )
            else
              PlacesAutocomplete(
                controller: _originCityController,
                label: 'City *',
                hintText: 'Search city',
                type: PlaceType.city,
              ),
            const SizedBox(height: 12),

            // Station/Stop name (for train, bus, cruise, metro, ferry)
            if (config.showStation) ...[
              WaydeckInput(
                controller: _originStationController,
                label: config.stationLabel,
                hintText: config.stationHint,
              ),
              const SizedBox(height: 12),
            ],

            // Terminal/Platform/Bay
            if (config.showTerminal)
              WaydeckInput(
                controller: _originTerminalController,
                label: config.terminalLabel,
                hintText: config.terminalHint,
              ),
            const SizedBox(height: 24),

            // Destination section (hidden when same-as-pickup is enabled)
            if (!_sameAsPickup) ...[
              Text(config.destSectionLabel, style: WaydeckTheme.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              
              // City/Airport row with optional airport code
              if (config.showLocationCode)
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: PlacesAutocomplete(
                        controller: _destCityController,
                        label: _mode == TransportMode.flight ? 'Airport *' : 'City *',
                        hintText: _mode == TransportMode.flight ? 'Search airport' : 'Search city',
                        type: _mode == TransportMode.flight ? PlaceType.airport : PlaceType.city,
                        onSelected: (prediction, details) {
                          _destCityController.text = prediction.mainText;
                          // Auto-fill airport code if available
                          if (_mode == TransportMode.flight) {
                            String? iataCode = _extractIataCode(prediction.mainText) ??
                                _extractIataCode(prediction.secondaryText) ??
                                _extractIataCode(prediction.description);
                            if (iataCode != null && _destCodeController.text.isEmpty) {
                              _destCodeController.text = iataCode;
                            }
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: WaydeckInput(
                        controller: _destCodeController,
                        label: config.locationCodeLabel,
                        hintText: 'BOM',
                      ),
                    ),
                  ],
                )
              else
                PlacesAutocomplete(
                  controller: _destCityController,
                  label: 'City *',
                  hintText: 'Search city',
                  type: PlaceType.city,
                ),
              const SizedBox(height: 12),

              // Station/Stop name (for train, bus, cruise, metro, ferry)
              if (config.showStation) ...[
                WaydeckInput(
                  controller: _destStationController,
                  label: config.stationLabel,
                  hintText: config.stationHint,
                ),
                const SizedBox(height: 12),
              ],

              // Terminal/Platform/Bay
              if (config.showTerminal)
                WaydeckInput(
                  controller: _destTerminalController,
                  label: config.terminalLabel,
                  hintText: config.terminalHint,
                ),
              const SizedBox(height: 24),
            ],

            // Times section
            Text('Times', style: WaydeckTheme.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _buildDateTimeField('Departure', _departureDate, _departureTime, isDeparture: true)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _buildDateTimeField('Arrival', _arrivalDate, _arrivalTime, isDeparture: false)),
              ],
            ),
            const SizedBox(height: 24),

            // Passengers selection
            if (config.showPassengers) ...[
              Text('Passengers', style: WaydeckTheme.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              PassengerPicker(
                selectedTravellerIds: _selectedPassengerIds,
                onChanged: (ids) => setState(() => _selectedPassengerIds = ids),
              ),
              const SizedBox(height: 24),
            ],

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

            // Comment
            WaydeckInput(
              controller: _commentController,
              label: 'Comment',
              hintText: 'Any notes about this transport...',
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateTimeField(String label, DateTime? date, TimeOfDay? time, {required bool isDeparture}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: WaydeckTheme.bodySmall.copyWith(
          fontWeight: FontWeight.w500,
          color: WaydeckTheme.textSecondary,
        )),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: date ?? DateTime.now(),
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) {
                    setState(() {
                      if (isDeparture) {
                        _departureDate = picked;
                      } else {
                        _arrivalDate = picked;
                      }
                    });
                  }
                },
                borderRadius: BorderRadius.circular(WaydeckTheme.radiusMd),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: WaydeckTheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(WaydeckTheme.radiusMd),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today, size: 18, color: WaydeckTheme.textSecondary),
                      const SizedBox(width: 8),
                      Text(
                        date != null ? '${date.day}/${date.month}/${date.year}' : 'Date',
                        style: WaydeckTheme.bodyMedium.copyWith(
                          color: date != null ? WaydeckTheme.textPrimary : WaydeckTheme.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: InkWell(
                onTap: () async {
                  final picked = await showTimePicker(
                    context: context,
                    initialTime: time ?? TimeOfDay.now(),
                  );
                  if (picked != null) {
                    setState(() {
                      if (isDeparture) {
                        _departureTime = picked;
                      } else {
                        _arrivalTime = picked;
                      }
                    });
                  }
                },
                borderRadius: BorderRadius.circular(WaydeckTheme.radiusMd),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: WaydeckTheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(WaydeckTheme.radiusMd),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.access_time, size: 18, color: WaydeckTheme.textSecondary),
                      const SizedBox(width: 8),
                      Text(
                        time != null ? time.format(context) : 'Time',
                        style: WaydeckTheme.bodyMedium.copyWith(
                          color: time != null ? WaydeckTheme.textPrimary : WaydeckTheme.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
