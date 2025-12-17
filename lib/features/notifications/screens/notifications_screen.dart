import 'package:flutter/material.dart';
import '../../../core/themes/app_theme.dart';
import '../../../models/notification_model.dart';
import '../../../services/notification_service.dart';
import '../../../services/api_service.dart';
import '../../../services/database_helper.dart';
import 'package:provider/provider.dart';
import '../../auth/providers/auth_provider.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final NotificationService _notificationService = NotificationService();
  final ApiService _apiService = ApiService();
  final DatabaseHelper _db = DatabaseHelper.instance;
  List<NotificationModel> _notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() => _isLoading = true);
    
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userId = authProvider.currentUser?.id ?? 0;

    // Try to fetch from backend first
    try {
      final backendNotifications = await _apiService.fetchUserNotifications(userId);
      
      if (backendNotifications.isNotEmpty) {
        // Sync backend notifications to local database
        for (var notifData in backendNotifications) {
          // Check if notification already exists locally
          final existing = await _db.query(
            'notifications',
            where: 'user_id = ? AND title = ? AND message = ? AND created_at = ?',
            whereArgs: [
              notifData['user_id'],
              notifData['title'],
              notifData['message'],
              notifData['created_at'],
            ],
          );
          
          if (existing.isEmpty) {
            // Insert new notification from backend
            final notification = NotificationModel(
              userId: notifData['user_id'] ?? userId,
              title: notifData['title'] ?? '',
              message: notifData['message'] ?? '',
              type: notifData['type'] ?? 'announcement',
              isRead: notifData['is_read'] == true || notifData['is_read'] == 1,
              createdAt: notifData['created_at'] ?? DateTime.now().toIso8601String(),
              updatedAt: notifData['updated_at'] ?? DateTime.now().toIso8601String(),
            );
            
            final id = await _db.insert('notifications', notification.toMap());
            
            // Show local push notification for new notifications
            if (!notification.isRead) {
              await _notificationService.showNotification(
                id: id,
                title: notification.title,
                body: notification.message,
              );
            }
          }
        }
      }
    } catch (e) {
      print('Error fetching notifications from backend: $e');
      // Fall back to local data if backend fails
    }

    // Load all notifications from local database (now includes synced ones)
    final notifications = await _notificationService.getUserNotifications(userId);
    
    setState(() {
      _notifications = notifications;
      _isLoading = false;
    });
  }

  Future<void> _markAsRead(NotificationModel notification) async {
    if (!notification.isRead) {
      await _notificationService.markAsRead(notification.id!);
      await _loadNotifications();
    }
  }

  Future<void> _deleteNotification(NotificationModel notification) async {
    await _notificationService.deleteNotification(notification.id!);
    await _notificationService.cancelNotification(notification.id!);
    await _loadNotifications();
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Notification deleted')),
      );
    }
  }

  IconData _getNotificationIcon(String type) {
    switch (type) {
      case 'reminder':
        return Icons.alarm;
      case 'achievement':
        return Icons.emoji_events;
      case 'course':
        return Icons.school;
      case 'quiz':
        return Icons.quiz;
      default:
        return Icons.notifications;
    }
  }

  Color _getNotificationColor(String type) {
    switch (type) {
      case 'reminder':
        return Colors.blue;
      case 'achievement':
        return Colors.amber;
      case 'course':
        return AppTheme.primaryColor;
      case 'quiz':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          if (_notifications.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Clear All'),
                    content: const Text('Delete all notifications?'),
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
                  for (var notification in _notifications) {
                    await _notificationService.deleteNotification(notification.id!);
                  }
                  await _notificationService.cancelAllNotifications();
                  await _loadNotifications();
                }
              },
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
            'You\'re all caught up!',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(NotificationModel notification) {
    final color = _getNotificationColor(notification.type);
    final icon = _getNotificationIcon(notification.type);

    return Dismissible(
      key: Key(notification.id.toString()),
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => _deleteNotification(notification),
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        elevation: notification.isRead ? 1 : 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: notification.isRead
              ? BorderSide.none
              : BorderSide(color: color.withOpacity(0.3), width: 2),
        ),
        child: InkWell(
          onTap: () => _markAsRead(notification),
          borderRadius: BorderRadius.circular(12),
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
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              notification.title,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: notification.isRead
                                    ? FontWeight.w500
                                    : FontWeight.bold,
                              ),
                            ),
                          ),
                          if (!notification.isRead)
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
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
                      Text(
                        _formatTime(notification.createdAt),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatTime(String dateTimeString) {
    try {
      final dateTime = DateTime.parse(dateTimeString);
      final now = DateTime.now();
      final difference = now.difference(dateTime);

      if (difference.inMinutes < 1) {
        return 'Just now';
      } else if (difference.inHours < 1) {
        return '${difference.inMinutes}m ago';
      } else if (difference.inDays < 1) {
        return '${difference.inHours}h ago';
      } else if (difference.inDays < 7) {
        return '${difference.inDays}d ago';
      } else {
        return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
      }
    } catch (e) {
      return '';
    }
  }
}
