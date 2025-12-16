import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../data/airlines_database.dart';

/// Airline Autocomplete Widget
/// Shows airline suggestions as user types airline name
/// Auto-fills both name and code when selection is made
class AirlineAutocomplete extends StatefulWidget {
  final TextEditingController nameController;
  final TextEditingController? codeController;
  final String label;
  final String hintText;

  const AirlineAutocomplete({
    super.key,
    required this.nameController,
    this.codeController,
    this.label = 'Airline Name',
    this.hintText = 'e.g., IndiGo, Air India',
  });

  @override
  State<AirlineAutocomplete> createState() => _AirlineAutocompleteState();
}

class _AirlineAutocompleteState extends State<AirlineAutocomplete> {
  final _focusNode = FocusNode();
  final _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  List<Airline> _suggestions = [];

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_handleFocusChange);
    widget.nameController.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChange);
    widget.nameController.removeListener(_onTextChanged);
    _focusNode.dispose();
    _removeOverlay();
    super.dispose();
  }

  void _handleFocusChange() {
    if (!_focusNode.hasFocus) {
      _removeOverlay();
    }
  }

  void _onTextChanged() {
    final query = widget.nameController.text.trim();
    if (query.length >= 2) {
      _suggestions = searchAirlines(query);
      if (_suggestions.isNotEmpty && _focusNode.hasFocus) {
        _showOverlay();
      } else {
        _removeOverlay();
      }
    } else {
      _removeOverlay();
    }
  }

  void _showOverlay() {
    _removeOverlay();
    
    final overlay = Overlay.of(context);
    final renderBox = context.findRenderObject() as RenderBox;
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
            borderRadius: BorderRadius.circular(8),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 250),
              child: ListView.builder(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                itemCount: _suggestions.length,
                itemBuilder: (context, index) {
                  final airline = _suggestions[index];
                  return ListTile(
                    dense: true,
                    leading: Container(
                      width: 40,
                      height: 28,
                      decoration: BoxDecoration(
                        color: WaydeckTheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Center(
                        child: Text(
                          airline.iataCode,
                          style: WaydeckTheme.bodySmall.copyWith(
                            fontWeight: FontWeight.bold,
                            color: WaydeckTheme.primary,
                          ),
                        ),
                      ),
                    ),
                    title: Text(airline.name, style: WaydeckTheme.bodyMedium),
                    subtitle: Text(
                      airline.country ?? '',
                      style: WaydeckTheme.caption,
                    ),
                    onTap: () => _selectAirline(airline),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );

    overlay.insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _selectAirline(Airline airline) {
    widget.nameController.text = airline.name;
    widget.codeController?.text = airline.iataCode;
    _removeOverlay();
    _focusNode.unfocus();
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
            controller: widget.nameController,
            focusNode: _focusNode,
            decoration: InputDecoration(
              hintText: widget.hintText,
              hintStyle: WaydeckTheme.bodyMedium.copyWith(
                color: WaydeckTheme.textTertiary,
              ),
              filled: true,
              fillColor: WaydeckTheme.surfaceVariant,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(WaydeckTheme.radiusMd),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              prefixIcon: const Icon(Icons.flight, size: 20),
              suffixIcon: widget.nameController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 18),
                      onPressed: () {
                        widget.nameController.clear();
                        widget.codeController?.clear();
                      },
                    )
                  : null,
            ),
            style: WaydeckTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

