import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/themes/app_theme.dart';
import '../../../services/database_helper.dart';

class AdminReportsScreen extends StatefulWidget {
  const AdminReportsScreen({super.key});

  @override
  State<AdminReportsScreen> createState() => _AdminReportsScreenState();
}

class _AdminReportsScreenState extends State<AdminReportsScreen> {
  final DatabaseHelper _db = DatabaseHelper.instance;
  bool _isLoading = true;

  // Stats
  int _totalUsers = 0;
  int _totalCourses = 0;
  int _totalEnrollments = 0;
  int _totalLessonsCompleted = 0;
  int _totalQuizzesTaken = 0;
  double _averageQuizScore = 0.0;
  
  // Charts data
  Map<String, int> _courseEnrollments = {};
  Map<String, int> _userActivity = {};
  List<Map<String, dynamic>> _topCourses = [];
  List<Map<String, dynamic>> _activeUsers = [];

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  Future<void> _loadReports() async {
    setState(() => _isLoading = true);

    try {
      // Get total users
      final users = await _db.query('users', where: 'role = ?', whereArgs: ['user']);
      _totalUsers = users.length;

      // Get total courses
      final courses = await _db.query('courses');
      _totalCourses = courses.length;

      // Get total enrollments
      final enrollments = await _db.query('enrollments');
      _totalEnrollments = enrollments.length;

      // Get completed lessons
      final completedLessons = await _db.query(
        'user_progress',
        where: 'is_completed = ?',
        whereArgs: [1],
      );
      _totalLessonsCompleted = completedLessons.length;

      // Get quiz results
      final quizResults = await _db.query('quiz_results');
      _totalQuizzesTaken = quizResults.length;

      // Calculate average quiz score
      if (quizResults.isNotEmpty) {
        final totalScore = quizResults.fold<int>(
          0,
          (sum, result) => sum + (result['score'] as int),
        );
        _averageQuizScore = totalScore / quizResults.length;
      }

      // Get course enrollments data
      _courseEnrollments = {};
      for (var course in courses) {
        final courseId = course['id'] as int;
        final enrollmentCount = await _db.query(
          'enrollments',
          where: 'course_id = ?',
          whereArgs: [courseId],
        );
        _courseEnrollments[course['title'] as String] = enrollmentCount.length;
      }

      // Get top 5 courses by enrollment
      _topCourses = [];
      for (var course in courses) {
        final courseId = course['id'] as int;
        final enrollmentCount = await _db.query(
          'enrollments',
          where: 'course_id = ?',
          whereArgs: [courseId],
        );
        _topCourses.add({
          'title': course['title'],
          'enrollments': enrollmentCount.length,
          'rating': course['rating'],
        });
      }
      _topCourses.sort((a, b) => (b['enrollments'] as int).compareTo(a['enrollments'] as int));
      _topCourses = _topCourses.take(5).toList();

      // Get active users (users with recent progress)
      _activeUsers = [];
      for (var user in users) {
        final userId = user['id'] as int;
        final userProgress = await _db.query(
          'user_progress',
          where: 'user_id = ? AND is_completed = ?',
          whereArgs: [userId, 1],
        );
        final userEnrollments = await _db.query(
          'enrollments',
          where: 'user_id = ?',
          whereArgs: [userId],
        );
        
        if (userProgress.isNotEmpty || userEnrollments.isNotEmpty) {
          _activeUsers.add({
            'name': user['name'],
            'email': user['email'],
            'completed': userProgress.length,
            'enrolled': userEnrollments.length,
          });
        }
      }
      _activeUsers.sort((a, b) => (b['completed'] as int).compareTo(a['completed'] as int));
      _activeUsers = _activeUsers.take(10).toList();

      // Get user activity by day (last 7 days)
      _userActivity = {};
      final now = DateTime.now();
      for (int i = 6; i >= 0; i--) {
        final date = now.subtract(Duration(days: i));
        final dateStr = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
        
        final dayProgress = await _db.rawQuery(
          'SELECT COUNT(*) as count FROM user_progress WHERE DATE(completed_at) = ?',
          [dateStr],
        );
        
        final dayName = _getDayName(date.weekday);
        _userActivity[dayName] = (dayProgress.first['count'] as int?) ?? 0;
      }

      setState(() => _isLoading = false);
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading reports: ${e.toString()}')),
        );
      }
    }
  }

  String _getDayName(int weekday) {
    switch (weekday) {
      case 1: return 'Mon';
      case 2: return 'Tue';
      case 3: return 'Wed';
      case 4: return 'Thu';
      case 5: return 'Fri';
      case 6: return 'Sat';
      case 7: return 'Sun';
      default: return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics & Reports'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadReports,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadReports,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Overview Stats
                    const Text(
                      'Overview',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    _buildOverviewStats(),
                    const SizedBox(height: 32),

                    // User Activity Chart
                    const Text(
                      'User Activity (Last 7 Days)',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    _buildActivityChart(),
                    const SizedBox(height: 32),

                    // Course Enrollments Chart
                    const Text(
                      'Course Enrollments',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    _buildEnrollmentsChart(),
                    const SizedBox(height: 32),

                    // Top Courses
                    const Text(
                      'Top Courses',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    _buildTopCourses(),
                    const SizedBox(height: 32),

                    // Active Users
                    const Text(
                      'Most Active Users',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    _buildActiveUsers(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildOverviewStats() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Total Users',
                _totalUsers.toString(),
                Icons.people,
                Colors.blue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'Total Courses',
                _totalCourses.toString(),
                Icons.school,
                Colors.purple,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Enrollments',
                _totalEnrollments.toString(),
                Icons.assignment,
                Colors.green,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'Completed',
                _totalLessonsCompleted.toString(),
                Icons.check_circle,
                Colors.orange,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Quizzes Taken',
                _totalQuizzesTaken.toString(),
                Icons.quiz,
                Colors.teal,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'Avg Score',
                '${_averageQuizScore.toStringAsFixed(1)}%',
                Icons.star,
                Colors.amber,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildActivityChart() {
    if (_userActivity.isEmpty) {
      return Container(
        height: 200,
        alignment: Alignment.center,
        child: const Text('No activity data available'),
      );
    }

    return Container(
      height: 250,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: (_userActivity.values.reduce((a, b) => a > b ? a : b) + 5).toDouble(),
          barTouchData: BarTouchData(enabled: true),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final days = _userActivity.keys.toList();
                  if (value.toInt() >= 0 && value.toInt() < days.length) {
                    return Text(
                      days[value.toInt()],
                      style: const TextStyle(fontSize: 10),
                    );
                  }
                  return const Text('');
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
                    style: const TextStyle(fontSize: 10),
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
            horizontalInterval: 5,
          ),
          borderData: FlBorderData(show: false),
          barGroups: _userActivity.entries.toList().asMap().entries.map((entry) {
            return BarChartGroupData(
              x: entry.key,
              barRods: [
                BarChartRodData(
                  toY: entry.value.value.toDouble(),
                  color: AppTheme.primaryColor,
                  width: 20,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildEnrollmentsChart() {
    if (_courseEnrollments.isEmpty) {
      return Container(
        height: 200,
        alignment: Alignment.center,
        child: const Text('No enrollment data available'),
      );
    }

    return Container(
      height: 300,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: PieChart(
        PieChartData(
          sectionsSpace: 2,
          centerSpaceRadius: 60,
          sections: _courseEnrollments.entries.map((entry) {
            final total = _courseEnrollments.values.reduce((a, b) => a + b);
            final percentage = (entry.value / total * 100).toStringAsFixed(1);
            final color = _getColorForIndex(_courseEnrollments.keys.toList().indexOf(entry.key));
            
            return PieChartSectionData(
              color: color,
              value: entry.value.toDouble(),
              title: '$percentage%',
              radius: 80,
              titleStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Color _getColorForIndex(int index) {
    final colors = [
      Colors.blue,
      Colors.purple,
      Colors.green,
      Colors.orange,
      Colors.teal,
      Colors.pink,
      Colors.indigo,
      Colors.amber,
    ];
    return colors[index % colors.length];
  }

  Widget _buildTopCourses() {
    if (_topCourses.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        alignment: Alignment.center,
        child: const Text('No course data available'),
      );
    }

    return Column(
      children: _topCourses.map((course) {
        final index = _topCourses.indexOf(course);
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _getColorForIndex(index).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: Text(
                  '#${index + 1}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: _getColorForIndex(index),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      course['title'],
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.people, size: 14, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          '${course['enrollments']} enrollments',
                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        ),
                        const SizedBox(width: 12),
                        Icon(Icons.star, size: 14, color: Colors.amber),
                        const SizedBox(width: 4),
                        Text(
                          '${course['rating']}',
                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildActiveUsers() {
    if (_activeUsers.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        alignment: Alignment.center,
        child: const Text('No user activity data available'),
      );
    }

    return Column(
      children: _activeUsers.map((user) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                child: Icon(Icons.person, color: AppTheme.primaryColor),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user['name'],
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user['email'],
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${user['completed']} completed',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${user['enrolled']} enrolled',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
