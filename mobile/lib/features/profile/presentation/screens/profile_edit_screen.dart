import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme.dart';
import '../../../../shared/ui/ui.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

/// Profile Edit Screen with extended fields
class ProfileEditScreen extends ConsumerStatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  ConsumerState<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends ConsumerState<ProfileEditScreen> {
  final _formKey = GlobalKey<FormState>();
  
  final _displayNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _nationalityController = TextEditingController();
  final _passportNumberController = TextEditingController();
  
  DateTime? _dateOfBirth;
  DateTime? _passportExpiry;
  String? _countryCode;
  
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    // Load existing profile data if available
    // This would typically fetch from a profile provider
    final user = ref.read(currentUserProvider);
    if (user != null) {
      setState(() {
        _displayNameController.text = user.email?.split('@').first ?? '';
      });
    }
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _phoneController.dispose();
    _nationalityController.dispose();
    _passportNumberController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // TODO: Implement Supabase profile update
      // await ref.read(profileProvider.notifier).updateProfile(...);

      await Future.delayed(const Duration(milliseconds: 500)); // Simulate save

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('✓ Profile updated'),
            backgroundColor: WaydeckTheme.success,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: WaydeckTheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _selectDate({required bool isPassportExpiry}) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: isPassportExpiry 
          ? (_passportExpiry ?? now.add(const Duration(days: 365 * 5)))
          : (_dateOfBirth ?? DateTime(now.year - 25)),
      firstDate: isPassportExpiry ? now : DateTime(1920),
      lastDate: isPassportExpiry ? DateTime(2100) : now,
    );

    if (picked != null) {
      setState(() {
        if (isPassportExpiry) {
          _passportExpiry = picked;
        } else {
          _dateOfBirth = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
        title: const Text('Edit Profile'),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _handleSave,
            child: _isLoading
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
            // Profile avatar section
            Center(
              child: Stack(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: WaydeckTheme.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        _displayNameController.text.isNotEmpty
                            ? _displayNameController.text[0].toUpperCase()
                            : '?',
                        style: WaydeckTheme.heading1.copyWith(
                          color: WaydeckTheme.primary,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: WaydeckTheme.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Basic Info Section
            Text('Basic Information', style: WaydeckTheme.heading3),
            const SizedBox(height: 12),

            WaydeckInput(
              controller: _displayNameController,
              label: 'Display Name',
              hintText: 'Your name',
              textInputAction: TextInputAction.next,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter your name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            WaydeckInput(
              controller: _phoneController,
              label: 'Phone Number',
              hintText: '+1 234 567 8900',
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 16),

            // Date of Birth
            _buildDatePickerField(
              label: 'Date of Birth',
              date: _dateOfBirth,
              hintText: 'Select your birth date',
              onTap: () => _selectDate(isPassportExpiry: false),
            ),
            const SizedBox(height: 32),

            // Passport Section
            Text('Passport Details', style: WaydeckTheme.heading3),
            const SizedBox(height: 4),
            Text(
              'Optional - used for auto-filling traveller info',
              style: WaydeckTheme.bodySmall.copyWith(color: WaydeckTheme.textSecondary),
            ),
            const SizedBox(height: 12),

            CountryPicker(
              label: 'Nationality',
              selectedCode: _countryCode,
              hintText: 'Select country',
              onChanged: (code) {
                setState(() => _countryCode = code);
              },
            ),
            const SizedBox(height: 16),

            WaydeckInput(
              controller: _passportNumberController,
              label: 'Passport Number',
              hintText: 'AB1234567',
              textInputAction: TextInputAction.done,
            ),
            const SizedBox(height: 16),

            // Passport Expiry
            _buildDatePickerField(
              label: 'Passport Expiry',
              date: _passportExpiry,
              hintText: 'Select expiry date',
              onTap: () => _selectDate(isPassportExpiry: true),
            ),
            const SizedBox(height: 32),

            // Info card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: WaydeckTheme.info.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: WaydeckTheme.info, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Your profile information helps auto-fill forms and allows you to quickly add yourself as a traveller.',
                      style: WaydeckTheme.bodySmall.copyWith(
                        color: WaydeckTheme.info,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildDatePickerField({
    required String label,
    required DateTime? date,
    required String hintText,
    required VoidCallback onTap,
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
          onTap: onTap,
          borderRadius: BorderRadius.circular(WaydeckTheme.radiusMd),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: Theme.of(context).inputDecorationTheme.fillColor,
              borderRadius: BorderRadius.circular(WaydeckTheme.radiusMd),
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
                      : hintText,
                  style: WaydeckTheme.bodyMedium.copyWith(
                    color: date != null
                        ? Theme.of(context).textTheme.bodyLarge?.color
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
