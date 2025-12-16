import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/themes/app_theme.dart';
import '../../../services/database_helper.dart';
import '../../auth/providers/auth_provider.dart';
import '../../auth/screens/login_screen.dart';
import 'manage_courses_screen.dart';
import 'manage_lessons_screen.dart';
import 'manage_quizzes_screen.dart';
import 'manage_users_screen.dart';
import 'manage_notifications_screen.dart';
import 'admin_reports_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final DatabaseHelper _db = DatabaseHelper.instance;
  Map<String, int> _stats = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() => _isLoading = true);

    final courses = await _db.query('courses');
    final lessons = await _db.query('lessons');
    final quizzes = await _db.query('quizzes');
    final users = await _db.query('users', where: 'role = ?', whereArgs: ['user']);
    final notes = await _db.query('notes');

    setState(() {
      _stats = {
        'courses': courses.length,
        'lessons': lessons.length,
        'quizzes': quizzes.length,
        'users': users.length,
        'notes': notes.length,
      };
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final adminName = authProvider.currentUser?.name ?? 'Admin';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: AppTheme.adminPrimaryColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Logout'),
                  content: const Text('Are you sure you want to logout?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () async {
                        await authProvider.logout();
                        if (context.mounted) {
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(builder: (_) => const LoginScreen()),
                            (route) => false,
                          );
                        }
                      },
                      child: const Text('Logout', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: AppTheme.adminGradient,
                    ),
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome back, $adminName! 👨‍💼',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Manage your learning platform',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Statistics
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Overview',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _buildStatCard(
                                'Courses',
                                '${_stats['courses']}',
                                Icons.school,
                                Colors.blue,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildStatCard(
                                'Lessons',
                                '${_stats['lessons']}',
                                Icons.play_circle_outline,
                                Colors.green,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _buildStatCard(
                                'Quizzes',
                                '${_stats['quizzes']}',
                                Icons.quiz,
                                Colors.orange,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildStatCard(
                                'Users',
                                '${_stats['users']}',
                                Icons.people,
                                Colors.purple,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Management Options
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Management',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildManagementCard(
                          context,
                          'Manage Courses',
                          'Add, edit, or delete courses',
                          Icons.school,
                          Colors.blue,
                          () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const ManageCoursesScreen()),
                            );
                            _loadStats(); // Refresh stats after returning
                          },
                        ),
                        _buildManagementCard(
                          context,
                          'Manage Lessons',
                          'Add, edit, or delete lessons',
                          Icons.video_library,
                          Colors.green,
                          () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const ManageLessonsScreen()),
                            );
                            _loadStats(); // Refresh stats after returning
                          },
                        ),
                        _buildManagementCard(
                          context,
                          'Manage Quizzes',
                          'Create and manage quizzes',
                          Icons.quiz,
                          Colors.orange,
                          () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const ManageQuizzesScreen()),
                            );
                            _loadStats(); // Refresh stats after returning
                          },
                        ),
                        _buildManagementCard(
                          context,
                          'Manage Users',
                          'View and manage user accounts',
                          Icons.people,
                          Colors.purple,
                          () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const ManageUsersScreen()),
                            );
                            _loadStats(); // Refresh stats after returning
                          },
                        ),
                        _buildManagementCard(
                          context,
                          'Manage Notifications',
                          'Send updates to all users',
                          Icons.notifications,
                          Colors.red,
                          () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const ManageNotificationsScreen()),
                            );
                            _loadStats(); // Refresh stats after returning
                          },
                        ),
                        _buildManagementCard(
                          context,
                          'View Reports',
                          'Analytics and user progress',
                          Icons.bar_chart,
                          Colors.teal,
                          () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const AdminReportsScreen()),
                            );
                            _loadStats(); // Refresh stats after returning
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildManagementCard(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }
}
