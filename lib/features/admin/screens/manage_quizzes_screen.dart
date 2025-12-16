import 'package:flutter/material.dart';
import '../../../core/themes/app_theme.dart';
import '../../../services/database_helper.dart';
import '../../../models/quiz_model.dart';
import '../../../models/course_model.dart';
import 'add_edit_quiz_screen.dart';
import 'manage_quiz_questions_screen.dart';

class ManageQuizzesScreen extends StatefulWidget {
  const ManageQuizzesScreen({super.key});

  @override
  State<ManageQuizzesScreen> createState() => _ManageQuizzesScreenState();
}

class _ManageQuizzesScreenState extends State<ManageQuizzesScreen> {
  final DatabaseHelper _db = DatabaseHelper.instance;
  List<QuizModel> _quizzes = [];
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
    
    // Load quizzes
    final quizzesQuery = _selectedCourseId == null
        ? await _db.query('quizzes', orderBy: 'created_at DESC')
        : await _db.query(
            'quizzes',
            where: 'course_id = ?',
            whereArgs: [_selectedCourseId],
            orderBy: 'created_at DESC',
          );
    
    final quizzes = quizzesQuery.map((e) => QuizModel.fromMap(e)).toList();
    
    setState(() {
      _courses = courses;
      _quizzes = quizzes;
      _isLoading = false;
    });
  }

  Future<void> _deleteQuiz(int quizId) async {
    // Delete related questions first
    await _db.delete('quiz_questions', where: 'quiz_id = ?', whereArgs: [quizId]);
    
    // Delete the quiz
    await _db.delete('quizzes', where: 'id = ?', whereArgs: [quizId]);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Quiz deleted successfully'),
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
        category: '',
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
        title: const Text('Manage Quizzes'),
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
                        'Create a course first before adding quizzes',
                        style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                      ),
                    ],
                  ),
                )
              : _quizzes.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.quiz_outlined, size: 64, color: Colors.grey[400]),
                          const SizedBox(height: 16),
                          Text(
                            'No quizzes yet',
                            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Tap + to create your first quiz',
                            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _quizzes.length,
                      itemBuilder: (context, index) {
                        final quiz = _quizzes[index];
                        return _buildQuizCard(quiz);
                      },
                    ),
      floatingActionButton: _courses.isEmpty
          ? null
          : FloatingActionButton(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AddEditQuizScreen(courses: _courses),
                  ),
                );
                _loadData();
              },
              backgroundColor: AppTheme.adminPrimaryColor,
              child: const Icon(Icons.add),
            ),
    );
  }

  Widget _buildQuizCard(QuizModel quiz) {
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
                    color: Colors.orange.shade100,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.quiz, color: Colors.orange.shade700, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        quiz.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _getCourseName(quiz.courseId),
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
            Text(
              quiz.description,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildInfoChip(Icons.question_answer, '${quiz.totalQuestions} questions'),
                const SizedBox(width: 8),
                _buildInfoChip(Icons.timer, '${quiz.duration ~/ 60} min'),
                const SizedBox(width: 8),
                _buildInfoChip(Icons.check_circle, '${quiz.passingScore}% pass'),
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
                        builder: (_) => ManageQuizQuestionsScreen(quiz: quiz),
                      ),
                    );
                    _loadData();
                  },
                  icon: const Icon(Icons.list, size: 18),
                  label: const Text('Questions'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.green,
                  ),
                ),
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AddEditQuizScreen(
                          courses: _courses,
                          quiz: quiz,
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
                        title: const Text('Delete Quiz'),
                        content: Text(
                          'Are you sure you want to delete "${quiz.title}"? This will also delete all related questions.',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                              _deleteQuiz(quiz.id!);
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
