import 'package:flutter/material.dart';
import '../../../core/themes/app_theme.dart';
import '../../../services/database_helper.dart';
import '../../../models/lesson_model.dart';
import '../../../models/course_model.dart';
import 'add_edit_lesson_screen.dart';

class ManageLessonsScreen extends StatefulWidget {
  const ManageLessonsScreen({super.key});

  @override
  State<ManageLessonsScreen> createState() => _ManageLessonsScreenState();
}

class _ManageLessonsScreenState extends State<ManageLessonsScreen> {
  final DatabaseHelper _db = DatabaseHelper.instance;
  List<LessonModel> _lessons = [];
  List<CourseModel> _courses = [];
  bool _isLoading = true;
  int? _selectedCourseId;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    // Load courses
    final coursesData = await _db.query('courses', orderBy: 'title ASC');
    final courses = coursesData.map((e) => CourseModel.fromMap(e)).toList();
    
    // Load lessons
    final lessonsQuery = _selectedCourseId == null
        ? await _db.query('lessons', orderBy: 'order_index ASC')
        : await _db.query(
            'lessons',
            where: 'course_id = ?',
            whereArgs: [_selectedCourseId],
            orderBy: 'order_index ASC',
          );
    
    final lessons = lessonsQuery.map((e) => LessonModel.fromMap(e)).toList();
    
    setState(() {
      _courses = courses;
      _lessons = lessons;
      _isLoading = false;
    });
  }

  Future<void> _deleteLesson(int lessonId) async {
    await _db.delete('lessons', where: 'id = ?', whereArgs: [lessonId]);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lesson deleted successfully'),
          backgroundColor: Colors.red,
        ),
      );
    }
    
    _loadData();
  }

  String _getCourseName(int courseId) {
    final course = _courses.firstWhere(
      (c) => c.id == courseId,
      orElse: () => CourseModel(
        id: 0,
        title: 'Unknown',
        description: '',
        instructor: '',
        duration: '',
        category: '',
        level: '',
        thumbnailUrl: '',
        rating: 0,
        enrolledCount: 0,
        lessonsCount: 0,
        isFeatured: false,
        createdAt: '',
        updatedAt: '',
      ),
    );
    return course.title;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Lessons'),
        backgroundColor: AppTheme.adminPrimaryColor,
        actions: [
          if (_courses.isNotEmpty)
            PopupMenuButton<int?>(
              icon: const Icon(Icons.filter_list),
              onSelected: (courseId) {
                setState(() => _selectedCourseId = courseId);
                _loadData();
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: null,
                  child: Text('All Courses'),
                ),
                ..._courses.map((course) => PopupMenuItem(
                      value: course.id,
                      child: Text(course.title),
                    )),
              ],
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _courses.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.school_outlined, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        'No courses available',
                        style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Create a course first before adding lessons',
                        style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                      ),
                    ],
                  ),
                )
              : _lessons.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.video_library_outlined, size: 64, color: Colors.grey[400]),
                          const SizedBox(height: 16),
                          Text(
                            'No lessons yet',
                            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Tap + to create your first lesson',
                            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _lessons.length,
                      itemBuilder: (context, index) {
                        final lesson = _lessons[index];
                        return _buildLessonCard(lesson);
                      },
                    ),
      floatingActionButton: _courses.isEmpty
          ? null
          : FloatingActionButton(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AddEditLessonScreen(courses: _courses),
                  ),
                );
                _loadData();
              },
              backgroundColor: AppTheme.adminPrimaryColor,
              child: const Icon(Icons.add),
            ),
    );
  }

  Widget _buildLessonCard(LessonModel lesson) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: AppTheme.adminPrimaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      '${lesson.orderIndex}',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.adminPrimaryColor,
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
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _getCourseName(lesson.courseId),
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.adminPrimaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildInfoChip(Icons.access_time, lesson.duration),
                const SizedBox(width: 8),
                if (lesson.videoUrl.isNotEmpty)
                  _buildInfoChip(Icons.play_circle, 'Video'),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AddEditLessonScreen(
                          courses: _courses,
                          lesson: lesson,
                        ),
                      ),
                    );
                    _loadData();
                  },
                  icon: const Icon(Icons.edit, size: 18),
                  label: const Text('Edit'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppTheme.adminPrimaryColor,
                  ),
                ),
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Delete Lesson'),
                        content: Text(
                          'Are you sure you want to delete "${lesson.title}"?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                              _deleteLesson(lesson.id!);
                            },
                            child: const Text('Delete', style: TextStyle(color: Colors.red)),
                          ),
                        ],
                      ),
                    );
                  },
                  icon: const Icon(Icons.delete, size: 18),
                  label: const Text('Delete'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.grey[700]),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(fontSize: 11, color: Colors.grey[700]),
          ),
        ],
      ),
    );
  }
}
