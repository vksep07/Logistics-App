import 'package:flutter/foundation.dart';
import 'package:logistics_demo/services/database_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  static final AuthService _instance = AuthService._internal();

  static const String _isLoggedInKey = 'isLoggedIn';
  static const String _emailKey = 'email';

  static const String validEmail = 'vksep07@gmail.com';
  static const String validPassword = 'vksep07';

  factory AuthService() => _instance;

  AuthService._internal();

  Future<bool> login(String email, String password) async {
    if (email == validEmail && password == validPassword) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_isLoggedInKey, true);
      await prefs.setString(_emailKey, email);
      return true;
    }
    return false;
  }

  Future<bool> createAccount(String email, String password, String name) async {
    return await _dbHelper.createAdmin(email, password, name);
  }

  // Add a default admin account if none exists
  Future<void> initializeDefaultAdmin() async {
    try {
      const defaultEmail = 'admin@logistics.com';
      const defaultPassword = 'admin123';
      const defaultName = 'Admin';

      await createAccount(defaultEmail, defaultPassword, defaultName);
    } catch (e) {
      if (kDebugMode) {
        print('Error creating default admin: $e');
      }
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isLoggedInKey) ?? false;
  }

  Future<String?> getLoggedInEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_emailKey);
  }
}
