import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/app_constants.dart';
import '../models/user_model.dart';
import 'database_helper.dart';

class AuthService {
  final DatabaseHelper _db = DatabaseHelper.instance;

  // Login
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final users = await _db.query(
        'users',
        where: 'email = ? AND password = ?',
        whereArgs: [email, password],
      );

      if (users.isEmpty) {
        return {
          'success': false,
          'message': 'Invalid email or password',
        };
      }

      final user = UserModel.fromMap(users.first);
      await _saveUserSession(user);

      return {
        'success': true,
        'message': 'Login successful',
        'user': user,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Login failed: $e',
      };
    }
  }

  // Register
  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    String? phone,
    String role = 'user',
  }) async {
    try {
      // Check if email already exists
      final existingUsers = await _db.query(
        'users',
        where: 'email = ?',
        whereArgs: [email],
      );

      if (existingUsers.isNotEmpty) {
        return {
          'success': false,
          'message': 'Email already exists',
        };
      }

      final now = DateTime.now().toIso8601String();
      final user = UserModel(
        name: name,
        email: email,
        password: password, // In production, hash the password
        role: role,
        phone: phone,
        createdAt: now,
        updatedAt: now,
      );

      final userId = await _db.insert('users', user.toMap());
      final newUser = user.copyWith(id: userId);
      await _saveUserSession(newUser);

      return {
        'success': true,
        'message': 'Registration successful',
        'user': newUser,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Registration failed: $e',
      };
    }
  }

  // Save user session
  Future<void> _saveUserSession(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.keyIsLoggedIn, true);
    await prefs.setInt(AppConstants.keyUserId, user.id!);
    await prefs.setString(AppConstants.keyUserRole, user.role);
    await prefs.setString(AppConstants.keyUserName, user.name);
    await prefs.setString(AppConstants.keyUserEmail, user.email);
  }

  // Get current user
  Future<UserModel?> getCurrentUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isLoggedIn = prefs.getBool(AppConstants.keyIsLoggedIn) ?? false;

      if (!isLoggedIn) return null;

      final userId = prefs.getInt(AppConstants.keyUserId);
      if (userId == null) return null;

      final users = await _db.query(
        'users',
        where: 'id = ?',
        whereArgs: [userId],
      );

      if (users.isEmpty) return null;

      return UserModel.fromMap(users.first);
    } catch (e) {
      return null;
    }
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(AppConstants.keyIsLoggedIn) ?? false;
  }

  // Get user role
  Future<String?> getUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConstants.keyUserRole);
  }

  // Logout
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  // Update user profile
  Future<Map<String, dynamic>> updateProfile({
    required int userId,
    String? name,
    String? phone,
    String? avatar,
  }) async {
    try {
      final now = DateTime.now().toIso8601String();
      final updateData = <String, dynamic>{
        'updated_at': now,
      };

      if (name != null) updateData['name'] = name;
      if (phone != null) updateData['phone'] = phone;
      if (avatar != null) updateData['avatar'] = avatar;

      await _db.update(
        'users',
        updateData,
        where: 'id = ?',
        whereArgs: [userId],
      );

      // Update shared preferences
      final prefs = await SharedPreferences.getInstance();
      if (name != null) {
        await prefs.setString(AppConstants.keyUserName, name);
      }

      return {
        'success': true,
        'message': 'Profile updated successfully',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Update failed: $e',
      };
    }
  }

  // Change password
  Future<Map<String, dynamic>> changePassword({
    required int userId,
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      // Verify old password
      final users = await _db.query(
        'users',
        where: 'id = ? AND password = ?',
        whereArgs: [userId, oldPassword],
      );

      if (users.isEmpty) {
        return {
          'success': false,
          'message': 'Current password is incorrect',
        };
      }

      // Update password
      final now = DateTime.now().toIso8601String();
      await _db.update(
        'users',
        {
          'password': newPassword,
          'updated_at': now,
        },
        where: 'id = ?',
        whereArgs: [userId],
      );

      return {
        'success': true,
        'message': 'Password changed successfully',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Password change failed: $e',
      };
    }
  }
}
