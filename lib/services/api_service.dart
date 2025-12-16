import 'package:dio/dio.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/course_model.dart';
import '../models/lesson_model.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'http://localhost:3000', 
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final bool _useFirebase = true; // Toggle between Firebase and REST API

  // ==================== COURSES ====================

  Future<List<CourseModel>> fetchCourses() async {
    try {
      if (_useFirebase) {
        final snapshot = await _firestore.collection('courses').get();
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
      if (_useFirebase) {
        final doc = await _firestore.collection('courses').doc(courseId.toString()).get();
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
      if (_useFirebase) {
        await _firestore.collection('courses').add(course.toMap());
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
      if (_useFirebase) {
        await _firestore
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
      if (_useFirebase) {
        await _firestore.collection('courses').doc(courseId.toString()).delete();
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
      if (_useFirebase) {
        final snapshot = await _firestore
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
      if (_useFirebase) {
        await _firestore.collection('quiz_results').add(result);
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
      if (_useFirebase) {
        await _firestore.collection('user_progress').add(progress);
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
