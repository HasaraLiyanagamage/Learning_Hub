import 'package:dio/dio.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import '../models/course_model.dart';
import '../models/lesson_model.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  static const String _baseUrl = 'http://172.20.10.3:3000';

  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );

  FirebaseFirestore? _firestore;
  bool _useFirebase = false; // Will be set to true if Firebase is available
  // Initialize Firebase Firestore if available
  void _initFirestore() {
    try {
      if (Firebase.apps.isNotEmpty) {
        _firestore = FirebaseFirestore.instance;
        _useFirebase = true;
      }
    } catch (e) {
      print('Firebase not available, using REST API only: $e');
      _useFirebase = false;
    }
  }
  
  FirebaseFirestore? get firestore {
    if (_firestore == null) {
      _initFirestore();
    }
    return _firestore;
  }

  // ==================== COURSES ====================

  Future<List<CourseModel>> fetchCourses() async {
    try {
      if (_useFirebase && firestore != null) {
        final snapshot = await firestore!.collection('courses').get();
        return snapshot.docs
            .map((doc) => CourseModel.fromMap({...doc.data(), 'id': doc.id}))
            .toList();
      } else {
        final response = await _dio.get('/courses');
        return (response.data as List)
            .map((json) => CourseModel.fromMap(json))
            .toList();
      }
    } catch (e) {
      print('Error fetching courses: $e');
      return [];
    }
  }

  Future<CourseModel?> fetchCourse(int courseId) async {
    try {
      if (_useFirebase && firestore != null) {
        final doc = await firestore!.collection('courses').doc(courseId.toString()).get();
        if (doc.exists) {
          return CourseModel.fromMap({...doc.data()!, 'id': doc.id});
        }
      } else {
        final response = await _dio.get('/courses/$courseId');
        return CourseModel.fromMap(response.data);
      }
    } catch (e) {
      print('Error fetching course: $e');
    }
    return null;
  }

  Future<bool> createCourse(CourseModel course) async {
    try {
      if (_useFirebase && firestore != null) {
        await firestore!.collection('courses').add(course.toMap());
        return true;
      } else {
        await _dio.post('/courses', data: course.toMap());
        return true;
      }
    } catch (e) {
      print('Error creating course: $e');
      return false;
    }
  }

  Future<bool> updateCourse(CourseModel course) async {
    try {
      if (_useFirebase && firestore != null) {
        await firestore!
            .collection('courses')
            .doc(course.id.toString())
            .update(course.toMap());
        return true;
      } else {
        await _dio.put('/courses/${course.id}', data: course.toMap());
        return true;
      }
    } catch (e) {
      print('Error updating course: $e');
      return false;
    }
  }

  Future<bool> deleteCourse(int courseId) async {
    try {
      if (_useFirebase && firestore != null) {
        await firestore!.collection('courses').doc(courseId.toString()).delete();
        return true;
      } else {
        await _dio.delete('/courses/$courseId');
        return true;
      }
    } catch (e) {
      print('Error deleting course: $e');
      return false;
    }
  }

  // ==================== LESSONS ====================

  Future<List<LessonModel>> fetchLessons(int courseId) async {
    try {
      if (_useFirebase && firestore != null) {
        final snapshot = await firestore!
            .collection('lessons')
            .where('course_id', isEqualTo: courseId)
            .get();
        return snapshot.docs
            .map((doc) => LessonModel.fromMap({...doc.data(), 'id': doc.id}))
            .toList();
      } else {
        final response = await _dio.get('/lessons', queryParameters: {'courseId': courseId});
        return (response.data as List)
            .map((json) => LessonModel.fromMap(json))
            .toList();
      }
    } catch (e) {
      print('Error fetching lessons: $e');
      return [];
    }
  }

  // ==================== QUIZ RESULTS ====================

  Future<bool> submitQuizResult(Map<String, dynamic> result) async {
    try {
      if (_useFirebase && firestore != null) {
        await firestore!.collection('quiz_results').add(result);
        return true;
      } else {
        await _dio.post('/quiz-results', data: result);
        return true;
      }
    } catch (e) {
      print('Error submitting quiz result: $e');
      return false;
    }
  }

  // ==================== USER PROGRESS ====================

  Future<bool> syncUserProgress(Map<String, dynamic> progress) async {
    try {
      if (_useFirebase && firestore != null) {
        await firestore!.collection('user_progress').add(progress);
        return true;
      } else {
        await _dio.post('/user-progress', data: progress);
        return true;
      }
    } catch (e) {
      print('Error syncing progress: $e');
      return false;
    }
  }

  // ==================== NOTIFICATIONS ====================

  Future<bool> sendBroadcastNotification({
    required String title,
    required String message,
    String type = 'announcement',
  }) async {
    try {
      final response = await _dio.post('/api/notifications/broadcast', data: {
        'title': title,
        'message': message,
        'type': type,
      });
      return response.statusCode == 201;
    } catch (e) {
      print('Error sending broadcast notification: $e');
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> fetchUserNotifications(int userId) async {
    try {
      final response = await _dio.get('/api/notifications/user/$userId');
      if (response.data['success'] == true) {
        return List<Map<String, dynamic>>.from(response.data['data']);
      }
      return [];
    } catch (e) {
      print('Error fetching user notifications: $e');
      return [];
    }
  }

  Future<bool> createNotification({
    required int userId,
    required String title,
    required String message,
    required String type,
  }) async {
    try {
      final response = await _dio.post('/api/notifications', data: {
        'user_id': userId,
        'title': title,
        'message': message,
        'type': type,
        'is_read': false,
      });
      return response.statusCode == 201;
    } catch (e) {
      print('Error creating notification: $e');
      return false;
    }
  }

  Future<bool> markNotificationAsRead(String notificationId) async {
    try {
      final response = await _dio.put('/api/notifications/$notificationId/read');
      return response.statusCode == 200;
    } catch (e) {
      print('Error marking notification as read: $e');
      return false;
    }
  }

  // ==================== CONNECTIVITY ====================

  Future<bool> checkConnectivity() async {
    try {
      final response = await _dio.get('/health');
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
