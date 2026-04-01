import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

/// 通知服务
///
/// 提供本地通知功能，用于提醒喂养、睡眠、尿布更换等事件。
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;

  // 通知ID前缀
  static const int _feedingPrefix = 1000;
  static const int _sleepPrefix = 2000;
  static const int _diaperPrefix = 3000;
  static const int _vaccinePrefix = 4000;

  /// 初始化通知服务
  Future<void> initialize() async {
    if (_isInitialized) return;

    tz.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(settings);
    _isInitialized = true;
  }

  /// 请求通知权限
  Future<bool> requestPermissions() async {
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

    return true;
  }

  /// 调度喂养提醒
  Future<void> scheduleFeedingReminder({
    required String babyId,
    required int hoursInterval,
    String? babyName,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('feeding_reminder_enabled', true);
    await prefs.setInt('feeding_reminder_interval', hoursInterval);

    final id = _feedingPrefix + babyId.hashCode;

    await _notifications.zonedSchedule(
      id,
      '喂养提醒',
      babyName != null ? '该给$babyName喂奶了' : '该给宝宝喂奶了',
      tz.TZDateTime.now(tz.local).add(Duration(hours: hoursInterval)),
      NotificationDetails(
        android: AndroidNotificationDetails(
          'feeding_channel',
          '喂养提醒',
          channelDescription: '婴儿喂养提醒通知',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  /// 取消喂养提醒
  Future<void> cancelFeedingReminder(String babyId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('feeding_reminder_enabled', false);

    final id = _feedingPrefix + babyId.hashCode;
    await _notifications.cancel(id);
  }

  /// 调度睡眠提醒
  Future<void> scheduleSleepReminder({
    required String babyId,
    required int hoursAfterWake,
    String? babyName,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('sleep_reminder_enabled', true);
    await prefs.setInt('sleep_reminder_interval', hoursAfterWake);

    final id = _sleepPrefix + babyId.hashCode;

    await _notifications.zonedSchedule(
      id,
      '睡眠提醒',
      babyName != null ? '$babyName 该睡觉了' : '宝宝该睡觉了',
      tz.TZDateTime.now(tz.local).add(Duration(hours: hoursAfterWake)),
      NotificationDetails(
        android: AndroidNotificationDetails(
          'sleep_channel',
          '睡眠提醒',
          channelDescription: '婴儿睡眠提醒通知',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  /// 取消睡眠提醒
  Future<void> cancelSleepReminder(String babyId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('sleep_reminder_enabled', false);

    final id = _sleepPrefix + babyId.hashCode;
    await _notifications.cancel(id);
  }

  /// 调度尿布提醒
  Future<void> scheduleDiaperReminder({
    required String babyId,
    required int hoursInterval,
    String? babyName,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('diaper_reminder_enabled', true);
    await prefs.setInt('diaper_reminder_interval', hoursInterval);

    final id = _diaperPrefix + babyId.hashCode;

    await _notifications.zonedSchedule(
      id,
      '尿布提醒',
      babyName != null ? '该给$babyName换尿布了' : '该给宝宝换尿布了',
      tz.TZDateTime.now(tz.local).add(Duration(hours: hoursInterval)),
      NotificationDetails(
        android: AndroidNotificationDetails(
          'diaper_channel',
          '尿布提醒',
          channelDescription: '婴儿尿布更换提醒通知',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  /// 取消尿布提醒
  Future<void> cancelDiaperReminder(String babyId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('diaper_reminder_enabled', false);

    final id = _diaperPrefix + babyId.hashCode;
    await _notifications.cancel(id);
  }

  /// 调度疫苗提醒
  ///
  /// [babyId] - 宝宝ID
  /// [vaccineName] - 疫苗名称
  /// [scheduledDate] - 计划接种日期
  /// [babyName] - 宝宝姓名（可选）
  /// [reminderDaysBefore] - 提前几天提醒，默认1天
  Future<void> scheduleVaccineReminder({
    required String babyId,
    required String vaccineName,
    required DateTime scheduledDate,
    String? babyName,
    int reminderDaysBefore = 1,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('vaccine_reminder_enabled', true);

    // 计算提醒时间（提前X天上午9点）
    final reminderDate = scheduledDate.subtract(Duration(days: reminderDaysBefore));
    final reminderTime = DateTime(
      reminderDate.year,
      reminderDate.month,
      reminderDate.day,
      9, // 上午9点
      0,
    );

    // 如果提醒时间已过，不设置提醒
    if (reminderTime.isBefore(DateTime.now())) return;

    // 生成唯一ID
    final id = _vaccinePrefix + vaccineName.hashCode + scheduledDate.day;

    await _notifications.zonedSchedule(
      id,
      '疫苗接种提醒',
      babyName != null
          ? '$babyName 明天该接种$vaccineName了'
          : '宝宝明天该接种$vaccineName了',
      tz.TZDateTime.from(reminderTime, tz.local),
      NotificationDetails(
        android: AndroidNotificationDetails(
          'vaccine_channel',
          '疫苗接种提醒',
          channelDescription: '婴儿疫苗接种提醒通知',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  /// 取消单个疫苗提醒
  Future<void> cancelVaccineReminder(String vaccineName, DateTime scheduledDate) async {
    final id = _vaccinePrefix + vaccineName.hashCode + scheduledDate.day;
    await _notifications.cancel(id);
  }

  /// 取消宝宝的所有疫苗提醒
  Future<void> cancelAllVaccineReminders(String babyId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('vaccine_reminder_enabled', false);

    // 取消所有疫苗相关通知（通过遍历可能的时间戳）
    // 由于ID是基于疫苗名称和日期生成的，我们需要取消所有疫苗相关的通知
    for (int i = 0; i < 1000; i++) {
      await _notifications.cancel(_vaccinePrefix + i);
    }
  }

  /// 取消所有通知
  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  /// 获取提醒设置状态
  Future<Map<String, bool>> getReminderStatus() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'feeding': prefs.getBool('feeding_reminder_enabled') ?? false,
      'sleep': prefs.getBool('sleep_reminder_enabled') ?? false,
      'diaper': prefs.getBool('diaper_reminder_enabled') ?? false,
      'vaccine': prefs.getBool('vaccine_reminder_enabled') ?? false,
    };
  }
}
