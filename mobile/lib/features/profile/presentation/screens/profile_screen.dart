import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme.dart';
import '../../../../app/theme_provider.dart';
import '../../../../shared/ui/ui.dart';
import '../../../../shared/services/notification_service.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

/// Profile Screen
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final currentTheme = ref.watch(themeProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // User info card with edit button
          WaydeckCard(
            child: Column(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: WaydeckTheme.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      _getInitials(user?.email),
                      style: WaydeckTheme.heading2.copyWith(
                        color: WaydeckTheme.primary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  user?.email ?? 'Unknown',
                  style: WaydeckTheme.heading3,
                ),
                const SizedBox(height: 4),
                Text(
                  'Member since ${_formatDate(user?.createdAt)}',
                  style: WaydeckTheme.bodySmall.copyWith(
                    color: WaydeckTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: () => context.push('/profile/edit'),
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  label: const Text('Edit Profile'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: WaydeckTheme.primary,
                    side: BorderSide(color: WaydeckTheme.primary.withValues(alpha: 0.3)),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Appearance section
          Text('Appearance', style: WaydeckTheme.heading3),
          const SizedBox(height: 12),
          WaydeckCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                _buildSettingsTile(
                  icon: currentTheme.icon,
                  title: 'Theme',
                  subtitle: currentTheme.displayName,
                  onTap: () => _showThemeSelector(context, ref, currentTheme),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Settings section
          Text('Settings', style: WaydeckTheme.heading3),
          const SizedBox(height: 12),
          WaydeckCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                _buildSettingsTile(
                  icon: Icons.language_outlined,
                  title: 'Language',
                  subtitle: 'English',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Coming soon!')),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Travellers section
          Text('Travellers', style: WaydeckTheme.heading3),
          const SizedBox(height: 12),
          WaydeckCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                _buildSettingsTile(
                  icon: Icons.people_outline,
                  title: 'My Travellers',
                  subtitle: 'Manage passengers for your trips',
                  onTap: () => context.push('/travellers'),
                ),
                const Divider(height: 1),
                _buildSettingsTile(
                  icon: Icons.folder_outlined,
                  title: 'Global Documents',
                  subtitle: 'Passport, visa, insurance',
                  onTap: () => context.push('/global-documents'),
                ),
                const Divider(height: 1),
                _buildSettingsTile(
                  icon: Icons.checklist_outlined,
                  title: 'Checklist Templates',
                  subtitle: 'Reusable packing lists',
                  onTap: () => context.push('/checklist-templates'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Data section
          Text('Data', style: WaydeckTheme.heading3),
          const SizedBox(height: 12),
          WaydeckCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                _buildSettingsTile(
                  icon: Icons.archive_outlined,
                  title: 'Archived Trips',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Coming soon!')),
                    );
                  },
                ),
                const Divider(height: 1),
                _buildSettingsTile(
                  icon: Icons.cloud_download_outlined,
                  title: 'Export Data',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Coming soon!')),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Notifications section
          Text('Notifications', style: WaydeckTheme.heading3),
          const SizedBox(height: 12),
          WaydeckCard(
            padding: EdgeInsets.zero,
            child: _NotificationSettings(),
          ),
          const SizedBox(height: 24),

          // About section
          Text('About', style: WaydeckTheme.heading3),
          const SizedBox(height: 12),
          WaydeckCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                _buildSettingsTile(
                  icon: Icons.info_outline,
                  title: 'About Waydeck',
                  onTap: () {
                    showAboutDialog(
                      context: context,
                      applicationName: 'Waydeck',
                      applicationVersion: '1.0.0',
                      applicationLegalese: '© 2025 Waydeck',
                    );
                  },
                ),
                const Divider(height: 1),
                _buildSettingsTile(
                  icon: Icons.help_outline,
                  title: 'Help & Support',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Coming soon!')),
                    );
                  },
                ),
                const Divider(height: 1),
                _buildSettingsTile(
                  icon: Icons.privacy_tip_outlined,
                  title: 'Privacy Policy',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Coming soon!')),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Sign out button
          WaydeckButton(
            isOutlined: true,
            isDestructive: true,
            onPressed: () => _showSignOutDialog(context, ref),
            child: const Text('Sign Out'),
          ),
          const SizedBox(height: 32),

          // App version
          Center(
            child: Text(
              'Waydeck v1.0.0',
              style: WaydeckTheme.caption,
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: WaydeckTheme.textSecondary),
      title: Text(title, style: WaydeckTheme.bodyMedium),
      subtitle: subtitle != null
          ? Text(subtitle, style: WaydeckTheme.bodySmall)
          : null,
      trailing: Icon(
        Icons.chevron_right,
        color: WaydeckTheme.textSecondary,
      ),
      onTap: onTap,
    );
  }

  String _getInitials(String? email) {
    if (email == null || email.isEmpty) return '?';
    final parts = email.split('@').first;
    if (parts.isEmpty) return '?';
    return parts.substring(0, 1).toUpperCase();
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return 'Unknown';
    try {
      final date = DateTime.parse(dateStr);
      const months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      return '${months[date.month - 1]} ${date.year}';
    } catch (_) {
      return 'Unknown';
    }
  }

  void _showSignOutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await ref.read(signOutProvider)();
              if (context.mounted) {
                context.go('/');
              }
            },
            style: TextButton.styleFrom(foregroundColor: WaydeckTheme.error),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }

  void _showThemeSelector(BuildContext context, WidgetRef ref, AppThemeMode currentTheme) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Choose Theme', style: WaydeckTheme.heading2),
            const SizedBox(height: 8),
            Text(
              'Select how Waydeck should look',
              style: WaydeckTheme.bodySmall.copyWith(color: WaydeckTheme.textSecondary),
            ),
            const SizedBox(height: 24),
            ...AppThemeMode.values.map((mode) => ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: mode == currentTheme 
                      ? WaydeckTheme.primary.withValues(alpha: 0.1)
                      : Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  mode.icon,
                  color: mode == currentTheme ? WaydeckTheme.primary : null,
                ),
              ),
              title: Text(mode.displayName),
              subtitle: Text(_getThemeDescription(mode)),
              trailing: mode == currentTheme
                  ? Icon(Icons.check_circle, color: WaydeckTheme.primary)
                  : null,
              onTap: () {
                ref.read(themeProvider.notifier).setTheme(mode);
                Navigator.pop(ctx);
              },
            )),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  String _getThemeDescription(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.system:
        return 'Match your device settings';
      case AppThemeMode.light:
        return 'Always use light colors';
      case AppThemeMode.dark:
        return 'Always use dark colors';
    }
  }
}

/// Notification settings widget with toggle
class _NotificationSettings extends StatefulWidget {
  @override
  State<_NotificationSettings> createState() => _NotificationSettingsState();
}

class _NotificationSettingsState extends State<_NotificationSettings> {
  bool _notificationsEnabled = true;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final enabled = await notificationService.getNotificationsEnabled();
    if (mounted) {
      setState(() {
        _notificationsEnabled = enabled;
        _loading = false;
      });
    }
  }

  Future<void> _toggleNotifications(bool value) async {
    if (value) {
      // Request permission when enabling
      final granted = await notificationService.requestPermission();
      if (!granted) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please enable notifications in Settings'),
            ),
          );
        }
        return;
      }
    }

    await notificationService.setNotificationsEnabled(value);
    if (mounted) {
      setState(() => _notificationsEnabled = value);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: WaydeckTheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.notifications_outlined, color: WaydeckTheme.primary),
          ),
          title: const Text('Event Reminders'),
          subtitle: const Text('Get notified 30 min before events'),
          trailing: _loading
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Switch.adaptive(
                  value: _notificationsEnabled,
                  onChanged: _toggleNotifications,
                  activeTrackColor: WaydeckTheme.primary,
                ),
        ),
        if (!_loading && _notificationsEnabled) ...[
          const Divider(height: 1),
          ListTile(
            leading: const SizedBox(width: 40),
            title: const Text('Test Notification'),
            subtitle: const Text('Send a test notification'),
            trailing: Icon(Icons.chevron_right, color: WaydeckTheme.textSecondary),
            onTap: () async {
              try {
                // First ensure we have permission
                final granted = await notificationService.requestPermission();
                if (!granted) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please enable notifications in your device settings'),
                        backgroundColor: Colors.orange,
                      ),
                    );
                  }
                  return;
                }
                
                // Show the test notification
                await notificationService.showTestNotification();
                
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('✓ Test notification sent!'),
                      backgroundColor: WaydeckTheme.success,
                    ),
                  );
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
              }
            },
          ),
        ],
      ],
    );
  }
}
