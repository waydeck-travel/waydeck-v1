import 'package:flutter/material.dart';
import '../../app/theme.dart';
import '../data/countries.dart';

/// Country Picker with autocomplete functionality
/// Shows country name and flag, saves country code
class CountryPicker extends StatefulWidget {
  final String? selectedCode;
  final ValueChanged<String?> onChanged;
  final String label;
  final String? hintText;

  const CountryPicker({
    super.key,
    this.selectedCode,
    required this.onChanged,
    this.label = 'Country',
    this.hintText,
  });

  @override
  State<CountryPicker> createState() => _CountryPickerState();
}

class _CountryPickerState extends State<CountryPicker> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _showDropdown = false;
  List<Country> _filteredCountries = [];
  Country? _selectedCountry;

  @override
  void initState() {
    super.initState();
    _selectedCountry = getCountryByCode(widget.selectedCode);
    if (_selectedCountry != null) {
      _controller.text = _selectedCountry!.name;
    }
    _filteredCountries = countries;
    
    _focusNode.addListener(() {
      setState(() {
        _showDropdown = _focusNode.hasFocus;
        if (_focusNode.hasFocus) {
          _filteredCountries = searchCountries(_controller.text);
        }
      });
    });
  }

  @override
  void didUpdateWidget(CountryPicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedCode != oldWidget.selectedCode) {
      _selectedCountry = getCountryByCode(widget.selectedCode);
      if (_selectedCountry != null) {
        _controller.text = _selectedCountry!.name;
      } else {
        _controller.clear();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onTextChanged(String value) {
    setState(() {
      _filteredCountries = searchCountries(value);
      // Clear selection if user modifies text
      if (_selectedCountry != null && _selectedCountry!.name != value) {
        _selectedCountry = null;
        widget.onChanged(null);
      }
    });
  }

  void _selectCountry(Country country) {
    setState(() {
      _selectedCountry = country;
      _controller.text = country.name;
      _showDropdown = false;
    });
    _focusNode.unfocus();
    widget.onChanged(country.code);
  }

  void _clearSelection() {
    setState(() {
      _selectedCountry = null;
      _controller.clear();
      _filteredCountries = countries;
    });
    widget.onChanged(null);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
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
        TextFormField(
          controller: _controller,
          focusNode: _focusNode,
          onChanged: _onTextChanged,
          decoration: InputDecoration(
            hintText: widget.hintText ?? 'Search country...',
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
              vertical: 16,
            ),
            prefixIcon: _selectedCountry != null
                ? Padding(
                    padding: const EdgeInsets.only(left: 12, right: 4),
                    child: Text(
                      _selectedCountry!.emoji ?? '',
                      style: const TextStyle(fontSize: 20),
                    ),
                  )
                : const Icon(Icons.public, size: 20),
            prefixIconConstraints: const BoxConstraints(
              minWidth: 48,
              minHeight: 0,
            ),
            suffixIcon: _selectedCountry != null
                ? IconButton(
                    icon: const Icon(Icons.clear, size: 18),
                    onPressed: _clearSelection,
                  )
                : const Icon(Icons.arrow_drop_down),
          ),
          style: WaydeckTheme.bodyMedium,
        ),
        if (_showDropdown && _filteredCountries.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 4),
            constraints: const BoxConstraints(maxHeight: 200),
            decoration: BoxDecoration(
              color: WaydeckTheme.surface,
              borderRadius: BorderRadius.circular(WaydeckTheme.radiusMd),
              border: Border.all(color: WaydeckTheme.textTertiary.withValues(alpha: 0.3)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ListView.builder(
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(vertical: 4),
              itemCount: _filteredCountries.length,
              itemBuilder: (context, index) {
                final country = _filteredCountries[index];
                final isSelected = _selectedCountry?.code == country.code;
                return InkWell(
                  onTap: () => _selectCountry(country),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    color: isSelected
                        ? WaydeckTheme.primary.withValues(alpha: 0.1)
                        : null,
                    child: Row(
                      children: [
                        Text(
                          country.emoji ?? '',
                          style: const TextStyle(fontSize: 18),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            country.name,
                            style: WaydeckTheme.bodyMedium.copyWith(
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                        Text(
                          country.code,
                          style: WaydeckTheme.bodySmall.copyWith(
                            color: WaydeckTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}
