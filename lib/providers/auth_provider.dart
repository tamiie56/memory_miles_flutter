// lib/providers/auth_provider.dart

import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/api_service.dart';
import '../services/token_storage.dart'
if (dart.library.html) '../services/token_storage_web.dart';

class AuthProvider extends ChangeNotifier {
  User? _user;
  bool _loading = false;
  String? _error;

  User? get user => _user;
  bool get loading => _loading;
  String? get error => _error;
  bool get isLoggedIn => _user != null;

  Future<void> tryAutoLogin() async {
    final token = await getToken();
    if (token != null) {
      final user = await ApiService.getUser();
      if (user != null) {
        _user = user;
        notifyListeners();
      }
    }
  }

  Future<bool> signup(String username, String email, String password) async {
    _loading = true;
    _error = null;
    notifyListeners();

    final result = await ApiService.signup(
      username: username,
      email: email,
      password: password,
    );

    _loading = false;
    if (result['success']) {
      notifyListeners();
      return true;
    } else {
      _error = result['message'];
      notifyListeners();
      return false;
    }
  }

  Future<bool> signin(String email, String password) async {
    _loading = true;
    _error = null;
    notifyListeners();

    final result = await ApiService.signin(email: email, password: password);

    _loading = false;
    if (result['success']) {
      _user = result['user'];
      notifyListeners();
      return true;
    } else {
      _error = result['message'];
      notifyListeners();
      return false;
    }
  }

  Future<void> signout() async {
    await ApiService.signout();
    _user = null;
    notifyListeners();
  }

  Future<Map<String, dynamic>> updateUsername(String username) async {
    if (username.isEmpty) return {'success': false, 'message': 'Username cannot be empty'};
    final result = await ApiService.updateProfile(username: username);
    if (result['success'] && result['user'] != null) {
      _user = result['user'];
      notifyListeners();
    }
    return result;
  }

  Future<Map<String, dynamic>> updateEmail(String email) async {
    if (email.isEmpty || !email.contains('@')) {
      return {'success': false, 'message': 'Invalid email address'};
    }
    final result = await ApiService.updateProfile(email: email);
    if (result['success'] && result['user'] != null) {
      _user = result['user'];
      notifyListeners();
    }
    return result;
  }

  Future<Map<String, dynamic>> updatePassword(String oldPassword, String newPassword) async {
    if (oldPassword.isEmpty || newPassword.isEmpty) {
      return {'success': false, 'message': 'All fields are required'};
    }
    if (newPassword.length < 6) {
      return {'success': false, 'message': 'Password must be at least 6 characters'};
    }
    final result = await ApiService.updatePassword(
      oldPassword: oldPassword,
      newPassword: newPassword,
    );
    return result;
  }
}