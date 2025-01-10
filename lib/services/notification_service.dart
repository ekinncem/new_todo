import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._();
  static NotificationService get instance => _instance;
  
  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();

  NotificationService._();

  Future<void> init() async {
    tz.initializeTimeZones();
    
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    
    await _notifications.initialize(
      const InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      ),
    );
  }

  Future<void> scheduleEventNotification({
    required int id,
    required String title,
    required DateTime eventDate,
    required String type,
  }) async {
    // Bir hafta öncesi için bildirim
    final weekBefore = eventDate.subtract(const Duration(days: 7));
    if (weekBefore.isAfter(DateTime.now())) {
      await _notifications.zonedSchedule(
        id * 2,
        'Yaklaşan $type',
        '$title etkinliğine bir hafta kaldı',
        tz.TZDateTime.from(weekBefore, tz.local),
        NotificationDetails(
          android: AndroidNotificationDetails(
            'event_reminders',
            'Event Reminders',
            importance: Importance.high,
            priority: Priority.high,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      );
    }

    // Bir gün öncesi için bildirim
    final dayBefore = eventDate.subtract(const Duration(days: 1));
    if (dayBefore.isAfter(DateTime.now())) {
      await _notifications.zonedSchedule(
        id * 2 + 1,
        'Yaklaşan $type',
        '$title etkinliği yarın!',
        tz.TZDateTime.from(dayBefore, tz.local),
        NotificationDetails(
          android: AndroidNotificationDetails(
            'event_reminders',
            'Event Reminders',
            importance: Importance.high,
            priority: Priority.high,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      );
    }
  }

  Future<void> cancelEventNotifications(int eventId) async {
    await _notifications.cancel(eventId * 2); // Bir hafta öncesi bildirimi
    await _notifications.cancel(eventId * 2 + 1); // Bir gün öncesi bildirimi
  }
} 