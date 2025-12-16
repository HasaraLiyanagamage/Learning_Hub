import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/themes/app_theme.dart';
import '../../../models/lesson_model.dart';
import '../../../services/database_helper.dart';
import '../../../services/notification_service.dart';
import '../../auth/providers/auth_provider.dart';

class LessonDetailScreen extends StatefulWidget {
  final LessonModel lesson;

  const LessonDetailScreen({super.key, required this.lesson});

  @override
  State<LessonDetailScreen> createState() => _LessonDetailScreenState();
}

class _LessonDetailScreenState extends State<LessonDetailScreen> {
  final DatabaseHelper _db = DatabaseHelper.instance;
  final NotificationService _notificationService = NotificationService();
  late bool _isCompleted;

  @override
  void initState() {
    super.initState();
    _loadCompletionStatus();
  }

  Future<void> _loadCompletionStatus() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userId = authProvider.currentUser?.id;

    if (userId == null) {
      setState(() => _isCompleted = false);
      return;
    }

    // Check user_progress table for completion status
    final progressRecords = await _db.query(
      'user_progress',
      where: 'user_id = ? AND lesson_id = ?',
      whereArgs: [userId, widget.lesson.id],
    );

    setState(() {
      _isCompleted = progressRecords.isNotEmpty && 
                     (progressRecords.first['is_completed'] == 1);
    });
  }

  Future<void> _toggleCompletion() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userId = authProvider.currentUser?.id;

    if (userId == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please login to track progress'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    final newStatus = !_isCompleted;
    final now = DateTime.now().toIso8601String();

    try {
      // Check if progress record exists
      final existingProgress = await _db.query(
        'user_progress',
        where: 'user_id = ? AND lesson_id = ?',
        whereArgs: [userId, widget.lesson.id],
      );

      if (existingProgress.isEmpty) {
        // Create new progress record
        await _db.insert('user_progress', {
          'user_id': userId,
          'course_id': widget.lesson.courseId,
          'lesson_id': widget.lesson.id,
          'progress_percentage': newStatus ? 100.0 : 0.0,
          'is_completed': newStatus ? 1 : 0,
          'completed_at': newStatus ? now : null,
          'last_accessed': now,
        });
      } else {
        // Update existing progress record
        await _db.update(
          'user_progress',
          {
            'is_completed': newStatus ? 1 : 0,
            'completed_at': newStatus ? now : null,
            'progress_percentage': newStatus ? 100.0 : 0.0,
            'last_accessed': now,
          },
          where: 'user_id = ? AND lesson_id = ?',
          whereArgs: [userId, widget.lesson.id],
        );
      }

      setState(() {
        _isCompleted = newStatus;
      });

      // Send notification when lesson is completed
      if (newStatus) {
        // Get course name
        final courseResults = await _db.query(
          'courses',
          where: 'id = ?',
          whereArgs: [widget.lesson.courseId],
        );
        
        if (courseResults.isNotEmpty) {
          final courseName = courseResults.first['title'] as String;
          
          await _notificationService.createLessonCompletionNotification(
            userId: userId,
            lessonTitle: widget.lesson.title,
            courseTitle: courseName,
          );
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              newStatus ? 'Lesson marked as completed!' : 'Lesson marked as incomplete',
            ),
            backgroundColor: newStatus ? AppTheme.successColor : Colors.grey,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lesson Details'),
        actions: [
          IconButton(
            icon: Icon(_isCompleted ? Icons.check_circle : Icons.check_circle_outline),
            onPressed: _toggleCompletion,
            color: _isCompleted ? AppTheme.successColor : Colors.white,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Video Placeholder
            Container(
              width: double.infinity,
              height: 220,
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.play_circle_filled,
                      size: 80,
                      color: Colors.white.withOpacity(0.9),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      widget.lesson.videoUrl.isNotEmpty ? widget.lesson.videoUrl : 'Video Content',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    widget.lesson.title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Duration
                  Row(
                    children: [
                      Icon(Icons.access_time, size: 18, color: Colors.grey[600]),
                      const SizedBox(width: 8),
                      Text(
                        '${widget.lesson.duration} minutes',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Description
                  const Text(
                    'Description',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.lesson.description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Content
                  const Text(
                    'Lesson Content',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      widget.lesson.content,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[800],
                        height: 1.6,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Mark Complete Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: _toggleCompletion,
                      icon: Icon(_isCompleted ? Icons.replay : Icons.check),
                      label: Text(
                        _isCompleted ? 'Mark as Incomplete' : 'Mark as Complete',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isCompleted
                            ? Colors.grey[600]
                            : AppTheme.successColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
