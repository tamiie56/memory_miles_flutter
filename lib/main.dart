// lib/main.dart

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/story_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/reset_password_screen.dart';
import 'screens/home/home_screen.dart';
import 'utils/theme.dart';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html show window;

void main() {
  runApp(const MemoryMilesApp());
}

class MemoryMilesApp extends StatelessWidget {
  const MemoryMilesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => StoryProvider()),
      ],
      child: MaterialApp(
        title: 'Memory Miles',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.theme,
        home: const AuthWrapper(),
      ),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _checked = false;

  // ✅ নতুন — URL থেকে reset token পড়া
  String? _resetToken;
  String? _resetEmail;

  @override
  void initState() {
    super.initState();
    _readResetTokenFromUrl();
    _checkAuth();
  }

  // ✅ নতুন — email এর link এ token আর email আছে কিনা check করো
  void _readResetTokenFromUrl() {
    if (kIsWeb) {
      final uri = Uri.parse(html.window.location.href);
      final token = uri.queryParameters['token'];
      final email = uri.queryParameters['email'];
      if (token != null && email != null) {
        _resetToken = token;
        _resetEmail = email;
      }
    }
  }

  Future<void> _checkAuth() async {
    await context.read<AuthProvider>().tryAutoLogin();
    if (mounted) setState(() => _checked = true);
  }

  @override
  Widget build(BuildContext context) {
    // ✅ নতুন — reset link এ এলে সরাসরি ResetPasswordScreen দেখাও
    if (_resetToken != null && _resetEmail != null) {
      return ResetPasswordScreen(
        email: _resetEmail!,
        token: _resetToken!,
      );
    }

    if (!_checked) {
      return const Scaffold(
        backgroundColor: Color(0xFFECFEFF),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.flight_takeoff, size: 60, color: Color(0xFF05B6D3)),
              SizedBox(height: 16),
              Text(
                'Memory Miles',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF05B6D3),
                ),
              ),
              SizedBox(height: 24),
              CircularProgressIndicator(color: Color(0xFF05B6D3)),
            ],
          ),
        ),
      );
    }

    final isLoggedIn = context.watch<AuthProvider>().isLoggedIn;
    return isLoggedIn ? const HomeScreen() : const LoginScreen();
  }
}