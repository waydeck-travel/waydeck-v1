import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../../app/theme.dart';
import '../../../../shared/ui/ui.dart';
import '../../../../shared/services/traveller_avatar_service.dart';
import '../providers/travellers_provider.dart';

/// Traveller Form Screen
class TravellerFormScreen extends ConsumerStatefulWidget {
  final String? travellerId;

  const TravellerFormScreen({super.key, this.travellerId});

  bool get isEdit => travellerId != null;

  @override
  ConsumerState<TravellerFormScreen> createState() => _TravellerFormScreenState();
}

class _TravellerFormScreenState extends ConsumerState<TravellerFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passportController = TextEditingController();
  final _notesController = TextEditingController();

  DateTime? _passportExpiry;
  DateTime? _dateOfBirth;
  String? _nationality;
  String? _avatarUrl;
  bool _isUploadingAvatar = false;

  @override
  void initState() {
    super.initState();
    if (widget.isEdit) {
      _loadTraveller();
    }
  }

  Future<void> _loadTraveller() async {
    final traveller = await ref.read(travellerProvider(widget.travellerId!).future);
    if (traveller != null && mounted) {
      setState(() {
        _nameController.text = traveller.fullName;
        _emailController.text = traveller.email ?? '';
        _phoneController.text = traveller.phone ?? '';
        _passportController.text = traveller.passportNumber ?? '';
        _notesController.text = traveller.notes ?? '';
        _passportExpiry = traveller.passportExpiry;
        _dateOfBirth = traveller.dateOfBirth;
        _nationality = traveller.nationality;
        _avatarUrl = traveller.avatarUrl;
      });
    }
  }

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

    bool success;
    if (widget.isEdit) {
      success = await ref.read(travellerFormProvider.notifier).updateTraveller(
        travellerId: widget.travellerId!,
        fullName: _nameController.text.trim(),
        email: _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
        phone: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
        passportNumber: _passportController.text.trim().isEmpty ? null : _passportController.text.trim(),
        passportExpiry: _passportExpiry,
        nationality: _nationality,
        dateOfBirth: _dateOfBirth,
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
        avatarUrl: _avatarUrl,
      );
    } else {
      success = await ref.read(travellerFormProvider.notifier).createTraveller(
        fullName: _nameController.text.trim(),
        email: _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
        phone: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
        passportNumber: _passportController.text.trim().isEmpty ? null : _passportController.text.trim(),
        passportExpiry: _passportExpiry,
        nationality: _nationality,
        dateOfBirth: _dateOfBirth,
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
        avatarUrl: _avatarUrl,
      );
    }

    if (success && mounted) {
      context.pop();
    }
  }

  Future<void> _pickAvatar() async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from Gallery'),
                onTap: () async {
                  Navigator.pop(ctx);
                  await _uploadFromGallery();
                },
              ),
              if (!kIsWeb)
                ListTile(
                  leading: const Icon(Icons.camera_alt),
                  title: const Text('Take a Photo'),
                  onTap: () async {
                    Navigator.pop(ctx);
                    await _uploadFromCamera();
                  },
                ),
              if (_avatarUrl != null)
                ListTile(
                  leading: const Icon(Icons.delete, color: Colors.red),
                  title: const Text('Remove Photo', style: TextStyle(color: Colors.red)),
                  onTap: () async {
                    Navigator.pop(ctx);
                    setState(() => _avatarUrl = null);
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _uploadFromGallery() async {
    final file = await travellerAvatarService.pickImage();
    if (file != null) {
      await _uploadImage(file);
    }
  }

  Future<void> _uploadFromCamera() async {
    final file = await travellerAvatarService.takePhoto();
    if (file != null) {
      await _uploadImage(file);
    }
  }

  Future<void> _uploadImage(dynamic file) async {
    if (!widget.isEdit) {
      // For new travellers, just show a preview (upload after save)
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Save the traveller first, then add a photo')),
      );
      return;
    }

    setState(() => _isUploadingAvatar = true);
    try {
      final bytes = await file.readAsBytes();
      final extension = file.path.split('.').last.toLowerCase();
      final url = await travellerAvatarService.uploadAvatar(
        travellerId: widget.travellerId!,
        imageBytes: bytes,
        extension: extension.isNotEmpty ? extension : 'jpg',
      );
      if (url != null && mounted) {
        setState(() => _avatarUrl = url);
        await travellerAvatarService.updateTravellerAvatar(widget.travellerId!, url);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error uploading: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploadingAvatar = false);
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
          onPressed: () => context.pop(),
        ),
        title: Text(widget.isEdit ? 'Edit Traveller' : 'Add Traveller'),
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
            // Avatar section
            Center(
              child: GestureDetector(
                onTap: _pickAvatar,
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: WaydeckTheme.primary.withValues(alpha: 0.1),
                      backgroundImage: _avatarUrl != null
                          ? CachedNetworkImageProvider(_avatarUrl!)
                          : null,
                      child: _isUploadingAvatar
                          ? const CircularProgressIndicator()
                          : _avatarUrl == null
                              ? Text(
                                  _nameController.text.isNotEmpty
                                      ? _nameController.text[0].toUpperCase()
                                      : '👤',
                                  style: const TextStyle(fontSize: 36),
                                )
                              : null,
                    ),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: WaydeckTheme.primary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.camera_alt, size: 16, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                widget.isEdit ? 'Tap to change photo' : 'Add photo after saving',
                style: WaydeckTheme.caption,
              ),
            ),
            const SizedBox(height: 24),

            // Basic Info
            Text('Basic Information', style: WaydeckTheme.heading3),
            const SizedBox(height: 12),
            WaydeckInput(
              controller: _nameController,
              label: 'Full Name *',
              hintText: 'John Doe',
              validator: (v) => v?.isEmpty == true ? 'Required' : null,
            ),
            const SizedBox(height: 12),
            WaydeckInput(
              controller: _emailController,
              label: 'Email',
              hintText: 'john@example.com',
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 12),
            WaydeckInput(
              controller: _phoneController,
              label: 'Phone',
              hintText: '+1 555 123 4567',
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildDatePicker(
                    label: 'Date of Birth',
                    date: _dateOfBirth,
                    onPicked: (d) => setState(() => _dateOfBirth = d),
                    firstDate: DateTime(1900),
                    lastDate: DateTime.now(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CountryPicker(
                    selectedCode: _nationality,
                    onChanged: (code) => setState(() => _nationality = code),
                    label: 'Nationality',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Passport Info
            Text('Passport Information', style: WaydeckTheme.heading3),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: WaydeckInput(
                    controller: _passportController,
                    label: 'Passport Number',
                    hintText: 'AB1234567',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildDatePicker(
                    label: 'Expiry Date',
                    date: _passportExpiry,
                    onPicked: (d) => setState(() => _passportExpiry = d),
                    firstDate: DateTime.now().subtract(const Duration(days: 365 * 10)),
                    lastDate: DateTime.now().add(const Duration(days: 365 * 20)),
                  ),
                ),
              ],
            ),
            if (_passportExpiry != null && _passportExpiry!.isBefore(DateTime.now().add(const Duration(days: 180))))
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _passportExpiry!.isBefore(DateTime.now())
                        ? Colors.red.withValues(alpha: 0.1)
                        : Colors.orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.warning_amber_rounded,
                        color: _passportExpiry!.isBefore(DateTime.now()) ? Colors.red : Colors.orange,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _passportExpiry!.isBefore(DateTime.now())
                              ? 'Passport has expired!'
                              : 'Passport expires within 6 months',
                          style: WaydeckTheme.bodySmall.copyWith(
                            color: _passportExpiry!.isBefore(DateTime.now()) ? Colors.red : Colors.orange,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 24),

            // Notes
            WaydeckInput(
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
