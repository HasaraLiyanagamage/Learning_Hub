import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:provider/provider.dart';
import '../../../core/themes/app_theme.dart';
import '../../../services/database_helper.dart';
import '../../../models/course_model.dart';
import '../../auth/providers/auth_provider.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  final DatabaseHelper _db = DatabaseHelper.instance;
  bool _isLoading = true;
  
  // Stats
  int _enrolledCourses = 0;
  int _completedLessons = 0;
  int _quizzesTaken = 0;
  int _totalNotes = 0;
  double _overallProgress = 0.0;
  
  // Course progress
  List<Map<String, dynamic>> _courseProgress = [];
  
  // Weekly activity
  final List<double> _weeklyActivity = [0, 0, 0, 0, 0, 0, 0];

  @override
  void initState() {
    super.initState();
    _loadProgressData();
  }

  Future<void> _loadProgressData() async {
    setState(() => _isLoading = true);
    
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userId = authProvider.currentUser?.id;

    if (userId == null) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      // Get enrolled courses count
      final enrollments = await _db.query(
        'enrollments',
        where: 'user_id = ?',
        whereArgs: [userId],
      );
      _enrolledCourses = enrollments.length;

      // Get completed lessons count
      final completedLessons = await _db.query(
        'user_progress',
        where: 'user_id = ? AND is_completed = ?',
        whereArgs: [userId, 1],
      );
      _completedLessons = completedLessons.length;

      // Get quizzes taken count
      final quizResults = await _db.query(
        'quiz_results',
        where: 'user_id = ?',
        whereArgs: [userId],
      );
      _quizzesTaken = quizResults.length;

      // Get notes count
      final notes = await _db.query(
        'notes',
        where: 'user_id = ?',
        whereArgs: [userId],
      );
      _totalNotes = notes.length;

      // Calculate course progress
      _courseProgress = [];
      for (var enrollment in enrollments) {
        final courseId = enrollment['course_id'];
        
        // Get course details
        final courseData = await _db.query(
          'courses',
          where: 'id = ?',
          whereArgs: [courseId],
        );
        
        if (courseData.isEmpty) continue;
        
        final course = CourseModel.fromMap(courseData.first);
        
        // Get total lessons for this course
        final totalLessons = await _db.query(
          'lessons',
          where: 'course_id = ?',
          whereArgs: [courseId],
        );
        
        if (totalLessons.isEmpty) continue;
        
        // Get completed lessons for this course
        final completedCourseLessons = await _db.query(
          'user_progress',
          where: 'user_id = ? AND course_id = ? AND is_completed = ?',
          whereArgs: [userId, courseId, 1],
        );
        
        final progress = totalLessons.isNotEmpty
            ? completedCourseLessons.length / totalLessons.length
            : 0.0;
        
        _courseProgress.add({
          'title': course.title,
          'progress': progress,
        });
      }

      // Calculate overall progress
      if (_courseProgress.isNotEmpty) {
        final totalProgress = _courseProgress.fold<double>(
          0.0,
          (sum, course) => sum + (course['progress'] as double),
        );
        _overallProgress = totalProgress / _courseProgress.length;
      }

      // Get weekly activity (lessons completed per day in the last 7 days)
      final now = DateTime.now();
      for (int i = 0; i < 7; i++) {
        final dayStart = DateTime(now.year, now.month, now.day - (6 - i));
        final dayEnd = dayStart.add(const Duration(days: 1));
        
        final dayProgress = await _db.query(
          'user_progress',
          where: 'user_id = ? AND is_completed = ? AND completed_at >= ? AND completed_at < ?',
          whereArgs: [
            userId,
            1,
            dayStart.toIso8601String(),
            dayEnd.toIso8601String(),
          ],
        );
        
        _weeklyActivity[i] = dayProgress.length.toDouble();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading progress: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Progress'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadProgressData,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Overall Progress
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Text(
                      'Overall Progress',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),
                    CircularPercentIndicator(
                      radius: 80,
                      lineWidth: 12,
                      percent: _overallProgress,
                      center: Text(
                        '${(_overallProgress * 100).toInt()}%',
                        style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                      ),
                      progressColor: AppTheme.primaryColor,
                      backgroundColor: Colors.grey.shade200,
                      circularStrokeCap: CircularStrokeCap.round,
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Keep up the great work!',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Stats Grid
            const Text(
              'Statistics',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildStatCard('Courses', '$_enrolledCourses', Icons.school, Colors.blue)),
                const SizedBox(width: 16),
                Expanded(child: _buildStatCard('Completed', '$_completedLessons', Icons.check_circle, Colors.green)),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildStatCard('Quizzes', '$_quizzesTaken', Icons.quiz, Colors.orange)),
                const SizedBox(width: 16),
                Expanded(child: _buildStatCard('Notes', '$_totalNotes', Icons.note, Colors.purple)),
              ],
            ),
            const SizedBox(height: 24),
            // Course Progress
            const Text(
              'Course Progress',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ..._courseProgress.isEmpty
                ? [
                    Card(
                      elevation: 1,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: const Padding(
                        padding: EdgeInsets.all(24.0),
                        child: Center(
                          child: Text(
                            'No enrolled courses yet',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                      ),
                    ),
                  ]
                : _courseProgress.map((course) {
                    return _buildCourseProgress(
                      course['title'] as String,
                      course['progress'] as double,
                    );
                  }).toList(),
            const SizedBox(height: 24),
            // Weekly Activity Chart
            const Text(
              'Weekly Activity',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: SizedBox(
                  height: 200,
                  child: BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: 10,
                      barTouchData: BarTouchData(enabled: false),
                      titlesData: FlTitlesData(
                        show: true,
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                              return Text(
                                days[value.toInt()],
                                style: const TextStyle(fontSize: 12),
                              );
                            },
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 30,
                            getTitlesWidget: (value, meta) {
                              return Text(
                                value.toInt().toString(),
                                style: const TextStyle(fontSize: 12),
                              );
                            },
                          ),
                        ),
                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      ),
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        horizontalInterval: 2,
                      ),
                      borderData: FlBorderData(show: false),
                      barGroups: List.generate(7, (index) {
                        return BarChartGroupData(
                          x: index,
                          barRods: [
                            BarChartRodData(
                              toY: _weeklyActivity[index],
                              color: AppTheme.primaryColor,
                              width: 16,
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                            ),
                          ],
                        );
                      }),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
              ),
            ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color),
            ),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildCourseProgress(String courseName, double progress) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              courseName,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            LinearPercentIndicator(
              lineHeight: 8,
              percent: progress,
              backgroundColor: Colors.grey.shade200,
              progressColor: AppTheme.primaryColor,
              barRadius: const Radius.circular(4),
              trailing: Text(
                '${(progress * 100).toInt()}%',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
