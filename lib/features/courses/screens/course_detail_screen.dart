import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/themes/app_theme.dart';
import '../../../models/course_model.dart';
import '../../../models/lesson_model.dart';
import '../../../services/database_helper.dart';
import '../../../services/enrollment_service.dart';
import '../../auth/providers/auth_provider.dart';
import '../../lessons/screens/lesson_detail_screen.dart';

class CourseDetailScreen extends StatefulWidget {
  final CourseModel course;

  const CourseDetailScreen({super.key, required this.course});

  @override
  State<CourseDetailScreen> createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends State<CourseDetailScreen> {
  final DatabaseHelper _db = DatabaseHelper.instance;
  final EnrollmentService _enrollmentService = EnrollmentService();
  
  List<LessonModel> _lessons = [];
  bool _isLoading = true;
  bool _isEnrolled = false;
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userId = authProvider.currentUser?.id;
    
    // Load lessons
    final lessonsData = await _db.query(
      'lessons',
      where: 'course_id = ?',
      whereArgs: [widget.course.id],
      orderBy: 'order_index ASC',
    );
    
    final lessons = lessonsData.map((e) => LessonModel.fromMap(e)).toList();
    
    // Check enrollment and favorite status only if user is logged in
    bool enrolled = false;
    bool favorite = false;
    
    if (userId != null) {
      enrolled = await _enrollmentService.isEnrolled(userId, widget.course.id!);
      favorite = await _enrollmentService.isFavorite(userId, widget.course.id!);
    }
    
    setState(() {
      _lessons = lessons;
      _isEnrolled = enrolled;
      _isFavorite = favorite;
      _isLoading = false;
    });
  }

  Future<void> _toggleEnrollment() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userId = authProvider.currentUser?.id;

    if (userId == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please login to enroll in courses'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    try {
      if (_isEnrolled) {
        await _enrollmentService.unenrollFromCourse(userId, widget.course.id!);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Unenrolled from course'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      } else {
        // enrollInCourse now handles notification sending internally
        await _enrollmentService.enrollInCourse(
          userId, 
          widget.course.id!,
          courseTitle: widget.course.title,
        );
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Successfully enrolled!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }

      await _loadData();
    } catch (e) {
      if (mounted) {
        String errorMessage = e.toString();
        
        // Handle specific errors
        if (errorMessage.contains('Already enrolled')) {
          errorMessage = 'You are already enrolled in this course';
        } else if (errorMessage.contains('UNIQUE constraint')) {
          errorMessage = 'You are already enrolled in this course';
        } else {
          errorMessage = 'Error: $errorMessage';
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _toggleFavorite() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userId = authProvider.currentUser?.id;

    if (userId == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please login to add favorites'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    try {
      if (_isFavorite) {
        await _enrollmentService.removeFromFavorites(userId, widget.course.id!);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Removed from favorites'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      } else {
        await _enrollmentService.addToFavorites(userId, widget.course.id!);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Added to favorites'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }

      await _loadData();
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
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            actions: [
              IconButton(
                onPressed: _toggleFavorite,
                icon: Icon(
                  _isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: _isFavorite ? Colors.red : Colors.white,
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                widget.course.title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                ),
                child: Center(
                  child: Icon(
                    Icons.school,
                    size: 80,
                    color: Colors.white.withOpacity(0.3),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Course Info
                  Row(
                    children: [
                      _buildInfoChip(
                        Icons.signal_cellular_alt,
                        widget.course.difficulty,
                        _getDifficultyColor(widget.course.difficulty),
                      ),
                      const SizedBox(width: 8),
                      _buildInfoChip(
                        Icons.access_time,
                        '${widget.course.duration} min',
                        Colors.orange,
                      ),
                      const SizedBox(width: 8),
                      _buildInfoChip(
                        Icons.star,
                        widget.course.rating.toStringAsFixed(1),
                        Colors.amber,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Description
                  const Text(
                    'About this course',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.course.description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Stats
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          'Lessons',
                          '${widget.course.lessonsCount}',
                          Icons.play_circle_outline,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildStatCard(
                          'Students',
                          '${widget.course.enrolledCount}',
                          Icons.people,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Enroll Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: _toggleEnrollment,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isEnrolled
                            ? AppTheme.successColor
                            : AppTheme.primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: Icon(
                        _isEnrolled ? Icons.check_circle : Icons.school,
                        color: Colors.white,
                      ),
                      label: Text(
                        _isEnrolled ? 'Enrolled' : 'Enroll Now',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Lessons Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Course Content',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${_lessons.length} lessons',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
          _isLoading
              ? const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                )
              : _lessons.isEmpty
                  ? SliverFillRemaining(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.video_library_outlined,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No lessons available yet',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final lesson = _lessons[index];
                          return _buildLessonCard(context, lesson, index + 1);
                        },
                        childCount: _lessons.length,
                      ),
                    ),
        ],
      ),
    );
  }

  Widget _buildLessonCard(BuildContext context, LessonModel lesson, int number) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: InkWell(
          onTap: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => LessonDetailScreen(lesson: lesson),
              ),
            );
            // Refresh data after returning from lesson
            _loadData();
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: lesson.isCompleted == 1
                        ? AppTheme.successColor.withOpacity(0.1)
                        : AppTheme.primaryColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: lesson.isCompleted == 1
                        ? Icon(Icons.check, color: AppTheme.successColor)
                        : Text(
                            '$number',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        lesson.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 14,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${lesson.duration} min',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.play_circle_outline,
                  color: AppTheme.primaryColor,
                  size: 28,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppTheme.primaryColor, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'beginner':
        return Colors.green;
      case 'intermediate':
        return Colors.orange;
      case 'advanced':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
