import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../models/notification_model.dart';
import 'database_helper.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  final DatabaseHelper _db = DatabaseHelper.instance;

  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    // Initialize timezone
    tz.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    _initialized = true;
  }

  void _onNotificationTapped(NotificationResponse response) {
    // Handle notification tap
    print('Notification tapped: ${response.payload}');
  }

  // Show immediate notification
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'learning_hub_channel',
      'Learning Hub Notifications',
      channelDescription: 'Notifications for study reminders and updates',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
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

    await _notifications.show(id, title, body, details, payload: payload);
  }

  // Schedule notification
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'learning_hub_channel',
      'Learning Hub Notifications',
      channelDescription: 'Notifications for study reminders and updates',
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

    await _notifications.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledTime, tz.local),
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: payload,
    );
  }

  // Cancel notification
  Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }

  // Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  // Save notification to database
  Future<int> saveNotification(NotificationModel notification) async {
    return await _db.insert('notifications', notification.toMap());
  }

  // Get all notifications for a user
  Future<List<NotificationModel>> getUserNotifications(int userId) async {
    final results = await _db.query(
      'notifications',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'created_at DESC',
    );

    return results.map((map) => NotificationModel.fromMap(map)).toList();
  }

  // Mark notification as read
  Future<void> markAsRead(int notificationId) async {
    await _db.update(
      'notifications',
      {'is_read': 1, 'updated_at': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [notificationId],
    );
  }

  // Delete notification
  Future<void> deleteNotification(int notificationId) async {
    await _db.delete(
      'notifications',
      where: 'id = ?',
      whereArgs: [notificationId],
    );
  }

  // Create study reminder
  Future<void> createStudyReminder({
    required int userId,
    required String courseTitle,
    required DateTime reminderTime,
  }) async {
    final now = DateTime.now().toIso8601String();
    
    final notification = NotificationModel(
      userId: userId,
      title: 'Study Reminder',
      message: 'Time to continue learning "$courseTitle"!',
      type: 'reminder',
      createdAt: now,
      updatedAt: now,
    );

    final id = await saveNotification(notification);

    await scheduleNotification(
      id: id,
      title: notification.title,
      body: notification.message,
      scheduledTime: reminderTime,
    );
  }

  // Create achievement notification
  Future<void> createAchievementNotification({
    required int userId,
    required String achievement,
  }) async {
    final now = DateTime.now().toIso8601String();
    
    final notification = NotificationModel(
      userId: userId,
      title: '🎉 Achievement Unlocked!',
      message: achievement,
      type: 'achievement',
      createdAt: now,
      updatedAt: now,
    );

    final id = await saveNotification(notification);

    await showNotification(
      id: id,
      title: notification.title,
      body: notification.message,
    );
  }

  // Create quiz completion notification
  Future<void> createQuizCompletionNotification({
    required int userId,
    required String quizTitle,
    required int score,
    required bool passed,
  }) async {
    final now = DateTime.now().toIso8601String();
    
    final notification = NotificationModel(
      userId: userId,
      title: passed ? '✅ Quiz Passed!' : '📝 Quiz Completed',
      message: 'You scored $score% on "$quizTitle"',
      type: 'quiz',
      createdAt: now,
      updatedAt: now,
    );

    final id = await saveNotification(notification);

    await showNotification(
      id: id,
      title: notification.title,
      body: notification.message,
    );
  }

  // Create course enrollment notification
  Future<void> createEnrollmentNotification({
    required int userId,
    required String courseTitle,
  }) async {
    final now = DateTime.now().toIso8601String();
    
    final notification = NotificationModel(
      userId: userId,
      title: '🎓 Enrolled Successfully!',
      message: 'You\'re now enrolled in "$courseTitle". Start learning today!',
      type: 'course',
      createdAt: now,
      updatedAt: now,
    );

    final id = await saveNotification(notification);

    await showNotification(
      id: id,
      title: notification.title,
      body: notification.message,
    );
  }

  // Create lesson completion notification
  Future<void> createLessonCompletionNotification({
    required int userId,
    required String lessonTitle,
    required String courseTitle,
  }) async {
    final now = DateTime.now().toIso8601String();
    
    final notification = NotificationModel(
      userId: userId,
      title: '✅ Lesson Completed!',
      message: 'You completed "$lessonTitle" in $courseTitle. Keep up the great work!',
      type: 'course',
      createdAt: now,
      updatedAt: now,
    );

    final id = await saveNotification(notification);

    await showNotification(
      id: id,
      title: notification.title,
      body: notification.message,
    );
  }

  // Create course completion notification
  Future<void> createCourseCompletionNotification({
    required int userId,
    required String courseTitle,
  }) async {
    final now = DateTime.now().toIso8601String();
    
    final notification = NotificationModel(
      userId: userId,
      title: '🎉 Course Completed!',
      message: 'Congratulations! You\'ve completed "$courseTitle"!',
      type: 'achievement',
      createdAt: now,
      updatedAt: now,
    );

    final id = await saveNotification(notification);

    await showNotification(
      id: id,
      title: notification.title,
      body: notification.message,
    );
  }

  // Create new course notification (for all users)
  Future<void> createNewCourseNotification({
    required String courseTitle,
    required String instructor,
  }) async {
    final now = DateTime.now().toIso8601String();
    
    // Get all users
    final users = await _db.query('users');
    
    for (var user in users) {
      final userId = user['id'] as int;
      
      final notification = NotificationModel(
        userId: userId,
        title: '📚 New Course Available!',
        message: 'Check out "$courseTitle" by $instructor',
        type: 'course',
        createdAt: now,
        updatedAt: now,
      );

      final id = await saveNotification(notification);

      await showNotification(
        id: id,
        title: notification.title,
        body: notification.message,
      );
    }
  }

  // Create new lesson notification (for enrolled users)
  Future<void> createNewLessonNotification({
    required int courseId,
    required String lessonTitle,
    required String courseTitle,
  }) async {
    final now = DateTime.now().toIso8601String();
    
    // Get enrolled users
    final enrollments = await _db.query(
      'enrollments',
      where: 'course_id = ?',
      whereArgs: [courseId],
    );
    
    for (var enrollment in enrollments) {
      final userId = enrollment['user_id'] as int;
      
      final notification = NotificationModel(
        userId: userId,
        title: '📖 New Lesson Added!',
        message: '"$lessonTitle" is now available in $courseTitle',
        type: 'course',
        createdAt: now,
        updatedAt: now,
      );

      final id = await saveNotification(notification);

      await showNotification(
        id: id,
        title: notification.title,
        body: notification.message,
      );
    }
  }

  // Create new quiz notification (for enrolled users)
  Future<void> createNewQuizNotification({
    required int courseId,
    required String quizTitle,
    required String courseTitle,
  }) async {
    final now = DateTime.now().toIso8601String();
    
    // Get enrolled users
    final enrollments = await _db.query(
      'enrollments',
      where: 'course_id = ?',
      whereArgs: [courseId],
    );
    
    for (var enrollment in enrollments) {
      final userId = enrollment['user_id'] as int;
      
      final notification = NotificationModel(
        userId: userId,
        title: '📝 New Quiz Available!',
        message: 'Test your knowledge: "$quizTitle" in $courseTitle',
        type: 'quiz',
        createdAt: now,
        updatedAt: now,
      );

      final id = await saveNotification(notification);

      await showNotification(
        id: id,
        title: notification.title,
        body: notification.message,
      );
    }
  }

  // Create admin broadcast notification (for all users)
  Future<void> createAdminBroadcastNotification({
    required String title,
    required String message,
  }) async {
    final now = DateTime.now().toIso8601String();
    
    // Get all users
    final users = await _db.query('users');
    
    for (var user in users) {
      final userId = user['id'] as int;
      
      final notification = NotificationModel(
        userId: userId,
        title: '📢 $title',
        message: message,
        type: 'announcement',
        createdAt: now,
        updatedAt: now,
      );

      final id = await saveNotification(notification);

      await showNotification(
        id: id,
        title: notification.title,
        body: notification.message,
      );
    }
  }

  // Get unread notification count
  Future<int> getUnreadCount(int userId) async {
    final results = await _db.query(
      'notifications',
      where: 'user_id = ? AND is_read = ?',
      whereArgs: [userId, 0],
    );
    return results.length;
  }
}
