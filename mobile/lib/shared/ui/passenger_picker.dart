import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme.dart';
import '../../features/travellers/presentation/providers/travellers_provider.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';

/// Special ID for "Me" as a passenger
const String kMePassengerId = '__ME__';

/// Passenger Picker Widget
/// Shows selected passengers and allows adding/removing from travellers list
class PassengerPicker extends ConsumerStatefulWidget {
  final List<String> selectedTravellerIds;
  final void Function(List<String> ids) onChanged;
  final String? label;

  const PassengerPicker({
    super.key,
    required this.selectedTravellerIds,
    required this.onChanged,
    this.label,
  });

  @override
  ConsumerState<PassengerPicker> createState() => _PassengerPickerState();
}

class _PassengerPickerState extends ConsumerState<PassengerPicker> {
  @override
  Widget build(BuildContext context) {
    final travellersAsync = ref.watch(travellersProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: WaydeckTheme.bodySmall.copyWith(
              fontWeight: FontWeight.w500,
              color: WaydeckTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
        ],

        // Selected passengers
        if (widget.selectedTravellerIds.isNotEmpty) ...[
          travellersAsync.when(
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
            data: (travellers) {
              final selected = travellers
                  .where((t) => widget.selectedTravellerIds.contains(t.id))
                  .toList();
              return Wrap(
                spacing: 8,
                runSpacing: 8,
                children: selected.map((traveller) {
                  return Chip(
                    avatar: CircleAvatar(
                      backgroundColor: WaydeckTheme.primary.withValues(alpha: 0.1),
                      child: Text(
                        traveller.initials,
                        style: const TextStyle(fontSize: 10),
                      ),
                    ),
                    label: Text(traveller.fullName),
                    deleteIcon: const Icon(Icons.close, size: 16),
                    onDeleted: () {
                      final newIds = [...widget.selectedTravellerIds];
                      newIds.remove(traveller.id);
                      widget.onChanged(newIds);
                    },
                  );
                }).toList(),
              );
            },
          ),
          const SizedBox(height: 12),
        ],

        // Add passenger button
        OutlinedButton.icon(
          onPressed: () => _showPassengerDialog(context),
          icon: const Icon(Icons.person_add_outlined, size: 18),
          label: Text(widget.selectedTravellerIds.isEmpty
              ? 'Add Passengers'
              : 'Add More Passengers'),
          style: OutlinedButton.styleFrom(
            foregroundColor: WaydeckTheme.primary,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ],
    );
  }

  void _showPassengerDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => _PassengerSelectionSheet(
        selectedIds: widget.selectedTravellerIds,
        onSelectionChanged: widget.onChanged,
      ),
    );
  }
}

class _PassengerSelectionSheet extends ConsumerStatefulWidget {
  final List<String> selectedIds;
  final void Function(List<String>) onSelectionChanged;

  const _PassengerSelectionSheet({
    required this.selectedIds,
    required this.onSelectionChanged,
  });

  @override
  ConsumerState<_PassengerSelectionSheet> createState() => _PassengerSelectionSheetState();
}

class _PassengerSelectionSheetState extends ConsumerState<_PassengerSelectionSheet> {
  late List<String> _selectedIds;

  @override
  void initState() {
    super.initState();
    _selectedIds = List<String>.from(widget.selectedIds);
  }

  void _toggleSelection(String id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
      } else {
        _selectedIds.add(id);
      }
    });
    widget.onSelectionChanged(_selectedIds);
  }

  Future<void> _navigateToAddTraveller() async {
    // Close the bottom sheet first
    Navigator.pop(context);
    
    // Navigate to add traveller screen and wait for result
    // The result will be the newly created traveller's ID
    final newTravellerId = await Navigator.of(context, rootNavigator: true).push<String?>(
      MaterialPageRoute(
        builder: (context) => const _TravellerFormWrapper(),
      ),
    );
    
    // If a new traveller was created, add it to selection and refresh
    if (newTravellerId != null && mounted) {
      final newIds = [..._selectedIds, newTravellerId];
      widget.onSelectionChanged(newIds);
      ref.invalidate(travellersProvider);
    }
  }

  @override
  Widget build(BuildContext context) {
    final travellersAsync = ref.watch(travellersProvider);

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.3,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Text('Select Passengers', style: WaydeckTheme.heading3),
                  const Spacer(),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Done'),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),

            // Add Traveller button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: OutlinedButton.icon(
                onPressed: _navigateToAddTraveller,
                icon: const Icon(Icons.person_add_outlined, size: 18),
                label: const Text('Add New Traveller'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: WaydeckTheme.primary,
                  minimumSize: const Size(double.infinity, 44),
                ),
              ),
            ),
            const Divider(height: 1),

            // Travellers list
            Expanded(
              child: travellersAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Error: $e')),
                data: (travellers) {
                  final user = ref.watch(currentUserProvider);
                  final userEmail = user?.email ?? 'Me';
                  final userName = userEmail.split('@').first;
                  
                  // Total items = 1 (Me) + travellers
                  final totalItems = 1 + travellers.length;
                  
                  if (travellers.isEmpty && !_selectedIds.contains(kMePassengerId)) {
                    return Column(
                      children: [
                        // Me tile even when no other travellers
                        _buildMeTile(userName, userEmail),
                        Expanded(child: _buildEmptyState(context)),
                      ],
                    );
                  }

                  return ListView.builder(
                    controller: scrollController,
                    itemCount: totalItems,
                    itemBuilder: (context, index) {
                      // First item is always "Me"
                      if (index == 0) {
                        return _buildMeTile(userName, userEmail);
                      }
                      
                      // Regular travellers (offset by 1 for Me)
                      final traveller = travellers[index - 1];
                      final isSelected = _selectedIds.contains(traveller.id);

                      return CheckboxListTile(
                        value: isSelected,
                        onChanged: (_) => _toggleSelection(traveller.id),
                        secondary: CircleAvatar(
                          backgroundColor: WaydeckTheme.primary.withValues(alpha: 0.1),
                          child: Text(
                            traveller.initials,
                            style: WaydeckTheme.bodySmall.copyWith(
                              color: WaydeckTheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        title: Text(traveller.fullName),
                        subtitle: traveller.passportNumber != null
                            ? Text('🛂 ${traveller.passportNumber}')
                            : null,
                        activeColor: WaydeckTheme.primary,
                        checkColor: Colors.white,
                      );
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMeTile(String userName, String userEmail) {
    final isMeSelected = _selectedIds.contains(kMePassengerId);
    
    return CheckboxListTile(
      value: isMeSelected,
      onChanged: (_) => _toggleSelection(kMePassengerId),
      secondary: Stack(
        clipBehavior: Clip.none,
        children: [
          CircleAvatar(
            backgroundColor: WaydeckTheme.secondary.withValues(alpha: 0.15),
            child: Text(
              userName.isNotEmpty ? userName[0].toUpperCase() : '?',
              style: WaydeckTheme.bodySmall.copyWith(
                color: WaydeckTheme.secondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Positioned(
            right: -2,
            bottom: -2,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: WaydeckTheme.secondary,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.star, size: 10, color: Colors.white),
            ),
          ),
        ],
      ),
      title: Row(
        children: [
          Text(userName),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: WaydeckTheme.secondary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'Me',
              style: WaydeckTheme.caption.copyWith(
                color: WaydeckTheme.secondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      subtitle: Text(userEmail),
      activeColor: WaydeckTheme.secondary,
      checkColor: Colors.white,
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('👤', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 16),
            Text(
              'No Travellers Yet',
              style: WaydeckTheme.heading3,
            ),
            const SizedBox(height: 8),
            Text(
              'Add travellers to select them as passengers for this trip',
              style: WaydeckTheme.bodySmall.copyWith(
                color: WaydeckTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _navigateToAddTraveller,
              icon: const Icon(Icons.person_add),
              label: const Text('Add Traveller'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Wrapper widget that contains a simplified traveller form and handles result
class _TravellerFormWrapper extends ConsumerStatefulWidget {
  const _TravellerFormWrapper();

  @override
  ConsumerState<_TravellerFormWrapper> createState() => _TravellerFormWrapperState();
}

class _TravellerFormWrapperState extends ConsumerState<_TravellerFormWrapper> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passportController = TextEditingController();
  final _notesController = TextEditingController();

  DateTime? _passportExpiry;
  DateTime? _dateOfBirth;
  String? _nationality;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passportController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await ref.read(travellerFormProvider.notifier).createTraveller(
      fullName: _nameController.text.trim(),
      email: _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
      phone: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
      passportNumber: _passportController.text.trim().isEmpty ? null : _passportController.text.trim(),
      passportExpiry: _passportExpiry,
      nationality: _nationality,
      dateOfBirth: _dateOfBirth,
      notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
    );

    if (success && mounted) {
      // Get the saved traveller ID and return it
      final savedTraveller = ref.read(travellerFormProvider).savedTraveller;
      Navigator.pop(context, savedTraveller?.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(travellerFormProvider);

    return Scaffold(
      backgroundColor: WaydeckTheme.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Add Traveller'),
        actions: [
          TextButton(
            onPressed: formState.isLoading ? null : _handleSave,
            child: formState.isLoading
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('Save'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Basic Info
            Text('Basic Information', style: WaydeckTheme.heading3),
            const SizedBox(height: 12),
            _buildTextField(
              controller: _nameController,
              label: 'Full Name *',
              hintText: 'John Doe',
              validator: (v) => v?.isEmpty == true ? 'Required' : null,
            ),
            const SizedBox(height: 12),
            _buildTextField(
              controller: _emailController,
              label: 'Email',
              hintText: 'john@example.com',
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 12),
            _buildTextField(
              controller: _phoneController,
              label: 'Phone',
              hintText: '+1 555 123 4567',
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 12),
            _buildDatePicker(
              label: 'Date of Birth',
              date: _dateOfBirth,
              onPicked: (d) => setState(() => _dateOfBirth = d),
              firstDate: DateTime(1900),
              lastDate: DateTime.now(),
            ),
            const SizedBox(height: 24),

            // Passport Info
            Text('Passport Information', style: WaydeckTheme.heading3),
            const SizedBox(height: 12),
            _buildTextField(
              controller: _passportController,
              label: 'Passport Number',
              hintText: 'AB1234567',
            ),
            const SizedBox(height: 12),
            _buildDatePicker(
              label: 'Expiry Date',
              date: _passportExpiry,
              onPicked: (d) => setState(() => _passportExpiry = d),
              firstDate: DateTime.now().subtract(const Duration(days: 365 * 10)),
              lastDate: DateTime.now().add(const Duration(days: 365 * 20)),
            ),
            const SizedBox(height: 24),

            // Notes
            _buildTextField(
              controller: _notesController,
              label: 'Notes',
              hintText: 'Dietary requirements, preferences...',
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hintText,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: WaydeckTheme.bodySmall.copyWith(
            fontWeight: FontWeight.w500,
            color: WaydeckTheme.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          validator: validator,
          keyboardType: keyboardType,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hintText,
            filled: true,
            fillColor: WaydeckTheme.surfaceVariant,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(WaydeckTheme.radiusMd),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDatePicker({
    required String label,
    required DateTime? date,
    required void Function(DateTime) onPicked,
    required DateTime firstDate,
    required DateTime lastDate,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: WaydeckTheme.bodySmall.copyWith(
            fontWeight: FontWeight.w500,
            color: WaydeckTheme.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: date ?? DateTime.now(),
              firstDate: firstDate,
              lastDate: lastDate,
            );
            if (picked != null) {
              onPicked(picked);
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
                Expanded(
                  child: Text(
                    date != null
                        ? '${date.day}/${date.month}/${date.year}'
                        : 'Select date',
                    style: WaydeckTheme.bodyMedium.copyWith(
                      color: date != null ? WaydeckTheme.textPrimary : WaydeckTheme.textTertiary,
                    ),
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
