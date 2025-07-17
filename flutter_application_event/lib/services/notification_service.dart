import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import '../models/event.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    // Initialize timezone
    tz.initializeTimeZones();
    
    // Request notification permissions
    await Permission.notification.request();

    // Initialize settings for Android
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // Initialize settings for iOS
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    // Initialize settings
    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    // Initialize the plugin
    await _notifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );
  }

  // Handle notification tap
  static void _onNotificationTapped(NotificationResponse response) {
    // Handle notification tap here
    print('Notification tapped: ${response.payload}');
  }

  // Schedule event reminder
  static Future<void> scheduleEventReminder(Event event) async {
    if (!event.isReminderSet) return;

    final eventId = event.id ?? 'event_${DateTime.now().millisecondsSinceEpoch}';
    
    // Schedule reminder 30 minutes before event
    final reminderTime = event.dateTime.subtract(Duration(minutes: 30));
    
    if (reminderTime.isBefore(DateTime.now())) {
      // Event is less than 30 minutes away, schedule for 5 minutes before
      final fiveMinBefore = event.dateTime.subtract(Duration(minutes: 5));
      if (fiveMinBefore.isAfter(DateTime.now())) {
        await _scheduleNotification(
          id: int.parse(eventId.hashCode.toString().replaceAll('-', '')),
          title: 'Event Reminder',
          body: '${event.title} starts in 5 minutes at ${event.location}',
          scheduledDate: fiveMinBefore,
          payload: eventId,
        );
      }
    } else {
      await _scheduleNotification(
        id: int.parse(eventId.hashCode.toString().replaceAll('-', '')),
        title: 'Event Reminder',
        body: '${event.title} starts in 30 minutes at ${event.location}',
        scheduledDate: reminderTime,
        payload: eventId,
      );
    }

    // Schedule notification for event start time
    await _scheduleNotification(
      id: int.parse('${eventId}_start'.hashCode.toString().replaceAll('-', '')),
      title: 'Event Starting',
      body: '${event.title} is starting now at ${event.location}',
      scheduledDate: event.dateTime,
      payload: '${eventId}_start',
    );
  }

  // Schedule a notification
  static Future<void> _scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
  }) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'event_reminders',
      'Event Reminders',
      channelDescription: 'Notifications for event reminders',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      enableVibration: true,
      playSound: true,
    );

    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    // Convert DateTime to TZDateTime
    final tzDateTime = tz.TZDateTime.from(scheduledDate, tz.local);

    await _notifications.zonedSchedule(
      id,
      title,
      body,
      tzDateTime,
      platformChannelSpecifics,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: payload,
    );
  }

  // Cancel event reminder
  static Future<void> cancelEventReminder(Event event) async {
    final eventId = event.id ?? 'event_${DateTime.now().millisecondsSinceEpoch}';
    
    // Cancel both reminder and start notifications
    await _notifications.cancel(int.parse(eventId.hashCode.toString().replaceAll('-', '')));
    await _notifications.cancel(int.parse('${eventId}_start'.hashCode.toString().replaceAll('-', '')));
  }

  // Show immediate notification
  static Future<void> showNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'event_reminders',
      'Event Reminders',
      channelDescription: 'Notifications for event reminders',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );

    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    await _notifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      platformChannelSpecifics,
      payload: payload,
    );
  }

  // Cancel all notifications
  static Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  // Get pending notifications
  static Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notifications.pendingNotificationRequests();
  }

  // Check if notification permission is granted
  static Future<bool> isNotificationPermissionGranted() async {
    return await Permission.notification.isGranted;
  }

  // Request notification permission
  static Future<bool> requestNotificationPermission() async {
    final status = await Permission.notification.request();
    return status.isGranted;
  }
} 