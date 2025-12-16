import '../models/enrollment_model.dart';
import '../models/favorite_model.dart';
import 'database_helper.dart';

class EnrollmentService {
  final DatabaseHelper _db = DatabaseHelper.instance;

  // Enrollment Methods
  Future<int> enrollInCourse(int userId, int courseId) async {
    // Check if already enrolled
    final existing = await isEnrolled(userId, courseId);
    if (existing) {
      throw Exception('Already enrolled in this course');
    }
    
    final now = DateTime.now().toIso8601String();
    
    final enrollment = EnrollmentModel(
      userId: userId,
      courseId: courseId,
      enrolledAt: now,
      status: 'active',
    );

    return await _db.insert('enrollments', enrollment.toMap());
  }

  Future<bool> isEnrolled(int userId, int courseId) async {
    final results = await _db.query(
      'enrollments',
      where: 'user_id = ? AND course_id = ?',
      whereArgs: [userId, courseId],
    );

    return results.isNotEmpty;
  }

  Future<List<EnrollmentModel>> getUserEnrollments(int userId) async {
    final results = await _db.query(
      'enrollments',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'enrolled_at DESC',
    );

    return results.map((map) => EnrollmentModel.fromMap(map)).toList();
  }

  Future<EnrollmentModel?> getEnrollment(int userId, int courseId) async {
    final results = await _db.query(
      'enrollments',
      where: 'user_id = ? AND course_id = ?',
      whereArgs: [userId, courseId],
    );

    if (results.isEmpty) return null;
    return EnrollmentModel.fromMap(results.first);
  }

  Future<void> updateEnrollmentProgress(int enrollmentId, int progress) async {
    await _db.update(
      'enrollments',
      {'progress': progress},
      where: 'id = ?',
      whereArgs: [enrollmentId],
    );
  }

  Future<void> completeEnrollment(int enrollmentId) async {
    final now = DateTime.now().toIso8601String();
    
    await _db.update(
      'enrollments',
      {
        'status': 'completed',
        'completed_at': now,
        'progress': 100,
      },
      where: 'id = ?',
      whereArgs: [enrollmentId],
    );
  }

  Future<void> unenrollFromCourse(int userId, int courseId) async {
    await _db.delete(
      'enrollments',
      where: 'user_id = ? AND course_id = ?',
      whereArgs: [userId, courseId],
    );
  }

  // Favorites Methods
  Future<int> addToFavorites(int userId, int courseId) async {
    final now = DateTime.now().toIso8601String();
    
    final favorite = FavoriteModel(
      userId: userId,
      courseId: courseId,
      createdAt: now,
    );

    return await _db.insert('favorites', favorite.toMap());
  }

  Future<bool> isFavorite(int userId, int courseId) async {
    final results = await _db.query(
      'favorites',
      where: 'user_id = ? AND course_id = ?',
      whereArgs: [userId, courseId],
    );

    return results.isNotEmpty;
  }

  Future<List<FavoriteModel>> getUserFavorites(int userId) async {
    final results = await _db.query(
      'favorites',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'created_at DESC',
    );

    return results.map((map) => FavoriteModel.fromMap(map)).toList();
  }

  Future<void> removeFromFavorites(int userId, int courseId) async {
    await _db.delete(
      'favorites',
      where: 'user_id = ? AND course_id = ?',
      whereArgs: [userId, courseId],
    );
  }

  // Get enrolled course IDs
  Future<List<int>> getEnrolledCourseIds(int userId) async {
    final enrollments = await getUserEnrollments(userId);
    return enrollments.map((e) => e.courseId).toList();
  }

  // Get favorite course IDs
  Future<List<int>> getFavoriteCourseIds(int userId) async {
    final favorites = await getUserFavorites(userId);
    return favorites.map((f) => f.courseId).toList();
  }
}
