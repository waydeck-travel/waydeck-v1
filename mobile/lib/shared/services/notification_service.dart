import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/models.dart';

/// Notification Service for timeline reminders
/// 
/// Schedules notifications 30 minutes before trip events (flights, activities, etc.)
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  /// Notification lead time in minutes
  static const int reminderMinutesBefore = 30;

  /// Initialize the notification service
  Future<void> initialize() async {
    if (_initialized) return;
    
    // Initialize timezone
    tz.initializeTimeZones();

    // Android settings
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    
    // iOS settings
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    
    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    _initialized = true;
    debugPrint('NotificationService initialized');
  }

  /// Handle notification tap
  void _onNotificationTap(NotificationResponse response) {
    // Payload contains the route to navigate to
    final payload = response.payload;
    if (payload != null) {
      // The app will handle navigation via deep linking
      debugPrint('Notification tapped: $payload');
    }
  }

  /// Request notification permission (iOS/Android 13+)
  Future<bool> requestPermission() async {
    final android = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    
    if (android != null) {
      final granted = await android.requestNotificationsPermission();
      return granted ?? false;
    }

    final ios = _notifications.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    
    if (ios != null) {
      final granted = await ios.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return granted ?? false;
    }

    return true; // Other platforms
  }

  /// Schedule notification for a trip item
  Future<void> scheduleItemReminder(TripItem item, String tripId) async {
    if (!_initialized) await initialize();
    if (!await _notificationsEnabled()) return;

    final startTime = item.getStartTime();
    if (startTime == null) return;

    // Calculate notification time (30 min before)
    final notificationTime = startTime.subtract(
      const Duration(minutes: reminderMinutesBefore),
    );

    // Don't schedule if time has passed
    if (notificationTime.isBefore(DateTime.now())) return;

    final notificationId = item.id.hashCode;
    final title = _getNotificationTitle(item);
    final body = _getNotificationBody(item);
    final payload = '/trips/$tripId/items/${item.id}/${item.type.name}';

    await _scheduleNotification(
      id: notificationId,
      title: title,
      body: body,
      scheduledTime: notificationTime,
      payload: payload,
    );

    debugPrint('Scheduled notification for ${item.title} at $notificationTime');
  }

  /// Cancel notification for a trip item
  Future<void> cancelItemReminder(String itemId) async {
    if (!_initialized) await initialize();
    await _notifications.cancel(itemId.hashCode);
    debugPrint('Cancelled notification for item $itemId');
  }

  /// Schedule all reminders for a trip's items
  Future<void> scheduleAllReminders(List<TripItem> items, String tripId) async {
    for (final item in items) {
      await scheduleItemReminder(item, tripId);
    }
  }

  /// Cancel all reminders for a trip
  Future<void> cancelTripReminders(List<TripItem> items) async {
    for (final item in items) {
      await cancelItemReminder(item.id);
    }
  }

  /// Cancel all notifications
  Future<void> cancelAllReminders() async {
    if (!_initialized) await initialize();
    await _notifications.cancelAll();
  }

  /// Check if notifications are enabled in settings
  Future<bool> _notificationsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('notifications_enabled') ?? true;
  }

  /// Enable/disable notifications in settings
  Future<void> setNotificationsEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', enabled);
    
    if (!enabled) {
      await cancelAllReminders();
    }
  }

  /// Get notification enabled status
  Future<bool> getNotificationsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('notifications_enabled') ?? true;
  }

  String _getNotificationTitle(TripItem item) {
    switch (item.type) {
      case TripItemType.transport:
        final mode = item.transportDetails?.mode.displayName ?? 'Transport';
        return '🚀 $mode in 30 min';
      case TripItemType.stay:
        return '🏨 Check-in in 30 min';
      case TripItemType.activity:
        return '🎟️ Activity in 30 min';
      case TripItemType.note:
        return '📝 Reminder';
    }
  }

  String _getNotificationBody(TripItem item) {
    switch (item.type) {
      case TripItemType.transport:
        final from = item.transportDetails?.originCity ?? '';
        final to = item.transportDetails?.destinationCity ?? '';
        return '${item.title}${from.isNotEmpty && to.isNotEmpty ? '\n$from → $to' : ''}';
      case TripItemType.stay:
        final name = item.stayDetails?.accommodationName ?? item.title;
        return 'Time to check in at $name';
      case TripItemType.activity:
        return item.title;
      case TripItemType.note:
        return item.title;
    }
  }

  Future<void> _scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'waydeck_reminders',
      'Trip Reminders',
      channelDescription: 'Reminders for upcoming trip events',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledTime, tz.local),
      details,
      payload: payload,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  /// Show an immediate notification (for testing)
  Future<void> showTestNotification() async {
    if (!_initialized) await initialize();

    const androidDetails = AndroidNotificationDetails(
      'waydeck_reminders',
      'Trip Reminders',
      channelDescription: 'Reminders for upcoming trip events',
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      0,
      '🔔 Test Notification',
      'Notifications are working!',
      details,
    );
  }
}

/// Global notification service instance
final notificationService = NotificationService();
