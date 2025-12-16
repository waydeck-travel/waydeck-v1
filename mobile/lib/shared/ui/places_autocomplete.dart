import 'dart:async';
import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../services/places_service.dart';
import '../utils/debouncer.dart';

/// Place autocomplete type
enum PlaceType {
  city,
  address,
  establishment,
  airport,  // Added for flight origin/destination
  any,
}

/// Places Autocomplete Widget
class PlacesAutocomplete extends StatefulWidget {
  final String? initialValue;
  final String label;
  final String? hintText;
  final PlaceType type;
  final String? establishmentType; // e.g., 'lodging' for hotels
  final void Function(PlacePrediction prediction, PlaceDetails? details)? onSelected;
  final void Function(String text)? onChanged;
  final TextEditingController? controller;

  const PlacesAutocomplete({
    super.key,
    this.initialValue,
    required this.label,
    this.hintText,
    this.type = PlaceType.any,
    this.establishmentType,
    this.onSelected,
    this.onChanged,
    this.controller,
  });

  @override
  State<PlacesAutocomplete> createState() => _PlacesAutocompleteState();
}

class _PlacesAutocompleteState extends State<PlacesAutocomplete> {
  late TextEditingController _controller;
  final _focusNode = FocusNode();
  final _layerLink = LayerLink();
  
  OverlayEntry? _overlayEntry;
  List<PlacePrediction> _predictions = [];
  bool _isLoading = false;
  final _debouncer = Debouncer(milliseconds: 500);

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController(text: widget.initialValue);
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _debouncer.dispose();
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    _removeOverlay();
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  void _onFocusChange() {
    if (!_focusNode.hasFocus) {
      _removeOverlay();
    }
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  Future<void> _onTextChanged(String value) async {
    widget.onChanged?.call(value);

    if (value.length < 2) {
      _removeOverlay();
      setState(() => _predictions = []);
      return;
    }

    _debouncer.run(() async {
      if (!mounted) return;

      setState(() => _isLoading = true);

      List<PlacePrediction> predictions;
      switch (widget.type) {
        case PlaceType.city:
          predictions = await placesService.autocompleteCities(value);
          break;
        case PlaceType.address:
          predictions = await placesService.autocompleteAddresses(value);
          break;
        case PlaceType.establishment:
          predictions = await placesService.autocompleteEstablishments(
            value,
            type: widget.establishmentType,
          );
          break;
        case PlaceType.airport:
          predictions = await placesService.autocompleteEstablishments(
            value,
            type: 'airport',
          );
          break;
        case PlaceType.any:
          predictions = await placesService.autocomplete(value);
          break;
      }

      if (!mounted) return;

      setState(() {
        _predictions = predictions;
        _isLoading = false;
      });

      if (_predictions.isNotEmpty) {
        _showOverlay();
      } else {
        _removeOverlay();
      }
    });
  }

  void _showOverlay() {
    _removeOverlay();

    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final size = renderBox.size;

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        width: size.width,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: Offset(0, size.height + 4),
          child: Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(WaydeckTheme.radiusMd),
            child: Container(
              constraints: const BoxConstraints(maxHeight: 250),
              decoration: BoxDecoration(
                color: WaydeckTheme.surface,
                borderRadius: BorderRadius.circular(WaydeckTheme.radiusMd),
                border: Border.all(color: WaydeckTheme.surfaceVariant),
              ),
              child: ListView.builder(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                itemCount: _predictions.length,
                itemBuilder: (context, index) {
                  final prediction = _predictions[index];
                  return InkWell(
                    onTap: () => _selectPrediction(prediction),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _getIconForType(prediction),
                            size: 20,
                            color: WaydeckTheme.textSecondary,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  prediction.mainText,
                                  style: WaydeckTheme.bodyMedium,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                if (prediction.secondaryText != null)
                                  Text(
                                    prediction.secondaryText!,
                                    style: WaydeckTheme.caption.copyWith(
                                      color: WaydeckTheme.textSecondary,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  IconData _getIconForType(PlacePrediction prediction) {
    if (prediction.isCity) return Icons.location_city;
    if (prediction.isEstablishment) return Icons.business;
    if (prediction.types.contains('airport')) return Icons.flight;
    if (prediction.types.contains('train_station')) return Icons.train;
    return Icons.place;
  }

  Future<void> _selectPrediction(PlacePrediction prediction) async {
    _removeOverlay();
    _controller.text = prediction.mainText;
    _focusNode.unfocus();

    // Get place details if callback provided
    if (widget.onSelected != null) {
      PlaceDetails? details;
      try {
        details = await placesService.getPlaceDetails(prediction.placeId);
      } catch (e) {
        // Ignore errors getting details
      }
      widget.onSelected!(prediction, details);
    }
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.label,
            style: WaydeckTheme.bodySmall.copyWith(
              fontWeight: FontWeight.w500,
              color: WaydeckTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _controller,
            focusNode: _focusNode,
            onChanged: _onTextChanged,
            decoration: InputDecoration(
              hintText: widget.hintText,
              filled: true,
              fillColor: WaydeckTheme.surfaceVariant,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(WaydeckTheme.radiusMd),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
              suffixIcon: _isLoading
                  ? const Padding(
                      padding: EdgeInsets.all(12),
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : const Icon(Icons.search, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}
