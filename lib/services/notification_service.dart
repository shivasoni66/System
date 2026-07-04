import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;

    // Only run if not on web (flutter_local_notifications has limited web support)
    if (kIsWeb) {
      debugPrint("Notifications: Web platform. Running in simulated mode.");
      _initialized = true;
      return;
    }

    try {
      tz.initializeTimeZones();

      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      const DarwinInitializationSettings initializationSettingsDarwin =
          DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const InitializationSettings initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsDarwin,
      );

      await _notificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          debugPrint("Notification clicked: ${response.payload}");
        },
      );

      _initialized = true;
      debugPrint("Notifications: Native plugin initialized successfully.");
    } catch (e) {
      debugPrint("Notifications: Failed to initialize native notifications ($e). Falling back to in-app simulated logs.");
      _initialized = false;
    }
  }

  // Schedules a daily reminder to check tasks at a specific hour/minute (e.g. 9:00 PM)
  Future<void> scheduleDailyReminder({int hour = 21, int minute = 0}) async {
    if (!_initialized || kIsWeb) return;

    try {
      // Check permission for Android 13+
      final platform = _notificationsPlugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      if (platform != null) {
        await platform.requestNotificationsPermission();
      }

      await _notificationsPlugin.zonedSchedule(
        0,
        'Quest Warning!',
        'You have unfinished daily quests! Complete them before midnight or face the punishment debuff!',
        _nextInstanceOfTime(hour, minute),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'daily_reminders',
            'Daily Reminders',
            channelDescription: 'Reminds user to complete their daily quests before midnight.',
            importance: Importance.max,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
      debugPrint("Notifications: Scheduled daily reminder at $hour:$minute.");
    } catch (e) {
      debugPrint("Notifications: Failed to schedule native notification ($e).");
    }
  }

  // Shows an instant notification alert immediately (for demonstration/fails)
  Future<void> showInstantNotification({required String title, required String body}) async {
    if (!_initialized || kIsWeb) {
      debugPrint("Notifications (Simulated): [$title] $body");
      return;
    }

    try {
      const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        'instant_alerts',
        'Instant Alerts',
        channelDescription: 'Immediate notifications for game occurrences like failures.',
        importance: Importance.max,
        priority: Priority.high,
      );

      const NotificationDetails details = NotificationDetails(
        android: androidDetails,
        iOS: DarwinNotificationDetails(),
      );

      await _notificationsPlugin.show(
        DateTime.now().millisecondsSinceEpoch ~/ 1000,
        title,
        body,
        details,
      );
      debugPrint("Notifications: Dispatched instant alert: $title");
    } catch (e) {
      debugPrint("Notifications: Failed to show native notification ($e).");
    }
  }

  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }
}
