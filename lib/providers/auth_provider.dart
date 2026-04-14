// lib/providers/auth_provider.dart

import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/api_service.dart';

class AuthProvider extends ChangeNotifier {
  User? _user;
  bool _loading = false;
  String? _error;

  User? get user => _user;
  bool get loading => _loading;
  String? get error => _error;
  bool get isLoggedIn => _user != null;

  Future<void> tryAutoLogin() async {
    final token = await ApiService.getToken();
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
}
