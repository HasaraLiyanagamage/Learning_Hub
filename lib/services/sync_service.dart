import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'database_helper.dart';
import 'api_service.dart';

class SyncService {
  static final SyncService _instance = SyncService._internal();
  factory SyncService() => _instance;
  SyncService._internal();

  final DatabaseHelper _db = DatabaseHelper.instance;
  final ApiService _api = ApiService();
  final Connectivity _connectivity = Connectivity();

  bool _isSyncing = false;
  bool _isOnline = false;
  StreamSubscription? _connectivitySubscription;

  // Initialize connectivity monitoring
  void initialize() {
    _checkConnectivity();
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen((ConnectivityResult result) {
      _handleConnectivityChange(result);
    });
  }

  void dispose() {
    _connectivitySubscription?.cancel();
  }

  Future<void> _checkConnectivity() async {
    final result = await _connectivity.checkConnectivity();
    _handleConnectivityChange(result);
  }

  void _handleConnectivityChange(ConnectivityResult result) {
    final wasOffline = !_isOnline;
    _isOnline = result == ConnectivityResult.mobile || 
                result == ConnectivityResult.wifi ||
                result == ConnectivityResult.ethernet;

    if (_isOnline && wasOffline) {
      // Just came online, sync pending data
      syncPendingData();
    }
  }

  bool get isOnline => _isOnline;

  // ==================== SYNC OPERATIONS ====================

  Future<void> syncPendingData() async {
    if (_isSyncing || !_isOnline) return;

    _isSyncing = true;
    if (kDebugMode) {
      debugPrint('Starting data synchronization...');
    }

    try {
      await _syncQuizResults();
      await _syncUserProgress();
      await _syncNotes();
      await _downloadCourses();
      
      if (kDebugMode) {
        debugPrint('Data synchronization completed successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error during synchronization: $e');
      }
    } finally {
      _isSyncing = false;
    }
  }

  // Sync quiz results that haven't been uploaded
  Future<void> _syncQuizResults() async {
    try {
      final pendingResults = await _db.query(
        'quiz_results',
        where: 'sync_status = ?',
        whereArgs: [0],
      );

      for (var result in pendingResults) {
        final success = await _api.submitQuizResult(result);
        if (success) {
          await _db.update(
            'quiz_results',
            {'sync_status': 1, 'last_updated': DateTime.now().toIso8601String()},
            where: 'id = ?',
            whereArgs: [result['id']],
          );
        }
      }

      if (kDebugMode) {
        debugPrint('Synced ${pendingResults.length} quiz results');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error syncing quiz results: $e');
      }
    }
  }

  // Sync user progress
  Future<void> _syncUserProgress() async {
    try {
      final pendingProgress = await _db.query(
        'user_progress',
        where: 'sync_status = ?',
        whereArgs: [0],
      );

      for (var progress in pendingProgress) {
        final success = await _api.syncUserProgress(progress);
        if (success) {
          await _db.update(
            'user_progress',
            {'sync_status': 1, 'last_updated': DateTime.now().toIso8601String()},
            where: 'id = ?',
            whereArgs: [progress['id']],
          );
        }
      }

      if (kDebugMode) {
        debugPrint('Synced ${pendingProgress.length} progress records');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error syncing user progress: $e');
      }
    }
  }

  // Sync notes
  Future<void> _syncNotes() async {
    try {
      final pendingNotes = await _db.query(
        'notes',
        where: 'sync_status = ?',
        whereArgs: [0],
      );

      if (kDebugMode) {
        debugPrint('Found ${pendingNotes.length} notes to sync');
      }
      // Note: Implement API endpoint for notes if needed
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error syncing notes: $e');
      }
    }
  }

  // Download latest courses from server
  Future<void> _downloadCourses() async {
    try {
      final courses = await _api.fetchCourses();
      
      for (var course in courses) {
        // Check if course exists locally
        final existing = await _db.query(
          'courses',
          where: 'id = ?',
          whereArgs: [course.id],
        );

        if (existing.isEmpty) {
          // Insert new course
          await _db.insert('courses', course.toMap());
        } else {
          // Update existing course if server version is newer
          final localUpdated = DateTime.parse(existing.first['updated_at'] as String);
          final serverUpdated = DateTime.parse(course.updatedAt);
          
          if (serverUpdated.isAfter(localUpdated)) {
            await _db.update(
              'courses',
              course.toMap(),
              where: 'id = ?',
              whereArgs: [course.id],
            );
          }
        }
      }

      if (kDebugMode) {
        debugPrint('Downloaded and cached ${courses.length} courses');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error downloading courses: $e');
      }
    }
  }

  // Mark record as pending sync
  Future<void> markForSync(String table, int id) async {
    await _db.update(
      table,
      {
        'sync_status': 0,
        'last_updated': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Force sync now
  Future<void> forceSyncNow() async {
    if (!_isOnline) {
      throw Exception('No internet connection');
    }
    await syncPendingData();
  }

  // Get sync status
  Future<Map<String, int>> getSyncStatus() async {
    final quizResults = await _db.query(
      'quiz_results',
      where: 'sync_status = ?',
      whereArgs: [0],
    );

    final progress = await _db.query(
      'user_progress',
      where: 'sync_status = ?',
      whereArgs: [0],
    );

    final notes = await _db.query(
      'notes',
      where: 'sync_status = ?',
      whereArgs: [0],
    );

    return {
      'quiz_results': quizResults.length,
      'user_progress': progress.length,
      'notes': notes.length,
      'total': quizResults.length + progress.length + notes.length,
    };
  }
}
