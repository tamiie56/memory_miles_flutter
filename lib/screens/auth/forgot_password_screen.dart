// lib/screens/auth/forgot_password_screen.dart

import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../utils/theme.dart';
import 'otp_verification_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailCtrl = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    final email = _emailCtrl.text.trim();

    if (email.isEmpty || !email.contains('@')) {
      setState(() => _error = 'Please enter a valid email address.');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    final result = await ApiService.forgotPassword(email);

    setState(() {
      _loading = false;
    });

    if (result['success']) {
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => OtpVerificationScreen(email: email),
          ),
        );
      }
    } else {
      setState(() => _error = result['message']);
    }
  }

  @override
  Widget build(BuildContext context) {
    // ✅ FIX: Use Theme.of(context) for dark mode support
    final theme = Theme.of(context);
    final textColor = theme.textTheme.bodyLarge?.color ?? AppTheme.textDark;
    final subtitleColor = theme.textTheme.bodySmall?.color ?? AppTheme.textMid;

    return Scaffold(
      appBar: AppBar(
        // ✅ FIX: Remove hardcoded AppTheme.background — AppBar color comes from theme
        elevation: 0,
        leading: IconButton(
          // ✅ FIX: Icon color from theme
          icon: Icon(Icons.arrow_back, color: theme.iconTheme.color),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.lock_reset, size: 56, color: AppTheme.primary),
            const SizedBox(height: 16),
            Text(
              'Forgot Password?',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                // ✅ FIX: Dark-aware text color
                color: textColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Enter your email address and we will send you a 6-digit OTP to reset your password.',
              style: TextStyle(
                fontSize: 14,
                // ✅ FIX: Dark-aware subtitle color
                color: subtitleColor,
              ),
            ),
            const SizedBox(height: 32),

            TextField(
              controller: _emailCtrl,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                hintText: 'Email',
                prefixIcon: Icon(Icons.email_outlined),
              ),
            ),

            if (_error != null) ...[
              const SizedBox(height: 8),
              Text(_error!,
                  style:
                  const TextStyle(color: AppTheme.danger, fontSize: 12)),
            ],

            const SizedBox(height: 24),

            ElevatedButton(
              onPressed: _loading ? null : _handleSubmit,
              child: _loading
                  ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2),
              )
                  : const Text('SEND OTP'),
            ),
          ],
        ),
      ),
    );
  }
}
