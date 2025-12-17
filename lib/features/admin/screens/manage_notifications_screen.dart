import 'package:flutter/material.dart';
import '../../../models/notification_model.dart';
import '../../../services/database_helper.dart';
import '../../../services/notification_service.dart';
import '../../../services/api_service.dart';

class ManageNotificationsScreen extends StatefulWidget {
  const ManageNotificationsScreen({super.key});

  @override
  State<ManageNotificationsScreen> createState() => _ManageNotificationsScreenState();
}

class _ManageNotificationsScreenState extends State<ManageNotificationsScreen> {
  final DatabaseHelper _db = DatabaseHelper.instance;
  final NotificationService _notificationService = NotificationService();
  final ApiService _apiService = ApiService();
  List<NotificationModel> _notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() => _isLoading = true);

    // Get unique notifications (group by title, message, and created_at)
    final results = await _db.rawQuery(
      '''
      SELECT *, COUNT(*) as recipient_count
      FROM notifications
      GROUP BY title, message, created_at
      ORDER BY created_at DESC
      ''',
    );

    setState(() {
      _notifications = results.map((e) => NotificationModel.fromMap(e)).toList();
      _isLoading = false;
    });
  }

  Future<void> _deleteNotification(NotificationModel notification) async {
    // Delete all notifications with the same title, message, and timestamp
    await _db.delete(
      'notifications',
      where: 'title = ? AND message = ? AND created_at = ?',
      whereArgs: [notification.title, notification.message, notification.createdAt],
    );
    
    // Cancel the notification
    if (notification.id != null) {
      await _notificationService.cancelNotification(notification.id!);
    }
    
    await _loadNotifications();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Broadcast notification deleted')),
      );
    }
  }

  Future<void> _sendBroadcastNotification() async {
    final titleController = TextEditingController();
    final messageController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Send Broadcast Notification'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: messageController,
              decoration: const InputDecoration(
                labelText: 'Message',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Send'),
          ),
        ],
      ),
    );

    if (result == true && titleController.text.isNotEmpty) {
      // Show loading indicator
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sending broadcast...'),
            duration: Duration(seconds: 2),
          ),
        );
      }

      // Send via backend API (this will fan out to all users in Firestore)
      final success = await _apiService.sendBroadcastNotification(
        title: titleController.text,
        message: messageController.text,
        type: 'announcement',
      );

      if (success) {
        // Also save locally for admin's record and send local push notifications
        final users = await _db.query('users');
        final now = DateTime.now().toIso8601String();

        for (var user in users) {
          final notification = NotificationModel(
            userId: user['id'] as int,
            title: titleController.text,
            message: messageController.text,
            type: 'announcement',
            createdAt: now,
            updatedAt: now,
          );

          final id = await _db.insert('notifications', notification.toMap());
          
          // Send local push notification to this device if user is logged in
          await _notificationService.showNotification(
            id: id,
            title: titleController.text,
            body: messageController.text,
          );
        }

        await _loadNotifications();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Broadcast sent to ${users.length} users successfully!')),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to send broadcast. Please check your connection.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Notifications'),
        actions: [
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: _sendBroadcastNotification,
            tooltip: 'Send Broadcast',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _notifications.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _loadNotifications,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _notifications.length,
                    itemBuilder: (context, index) {
                      final notification = _notifications[index];
                      return _buildNotificationCard(notification);
                    },
                  ),
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _sendBroadcastNotification,
        icon: const Icon(Icons.campaign),
        label: const Text('Send Broadcast'),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_none,
            size: 100,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            'No Notifications',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Send a broadcast notification to get started',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _sendBroadcastNotification,
            icon: const Icon(Icons.campaign),
            label: const Text('Send Broadcast Notification'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(NotificationModel notification) {
    IconData icon;
    Color color;

    switch (notification.type) {
      case 'reminder':
        icon = Icons.alarm;
        color = Colors.blue;
        break;
      case 'achievement':
        icon = Icons.emoji_events;
        color = Colors.amber;
        break;
      case 'announcement':
        icon = Icons.campaign;
        color = Colors.purple;
        break;
      default:
        icon = Icons.notifications;
        color = Colors.grey;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notification.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notification.message,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  FutureBuilder<int>(
                    future: _getRecipientCount(notification),
                    builder: (context, snapshot) {
                      final count = snapshot.data ?? 1;
                      return Row(
                        children: [
                          Icon(Icons.people, size: 14, color: Colors.grey[500]),
                          const SizedBox(width: 4),
                          Text(
                            '$count recipient${count > 1 ? 's' : ''}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[500],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Icon(Icons.access_time, size: 14, color: Colors.grey[500]),
                          const SizedBox(width: 4),
                          Text(
                            _formatDate(notification.createdAt),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Delete Notification'),
                    content: const Text('Are you sure you want to delete this notification?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('Delete'),
                      ),
                    ],
                  ),
                );

                if (confirm == true) {
                  await _deleteNotification(notification);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<int> _getRecipientCount(NotificationModel notification) async {
    final results = await _db.query(
      'notifications',
      where: 'title = ? AND message = ? AND created_at = ?',
      whereArgs: [notification.title, notification.message, notification.createdAt],
    );
    return results.length;
  }

  String _formatDate(String dateTimeString) {
    try {
      final dateTime = DateTime.parse(dateTimeString);
      return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return '';
    }
  }
}
