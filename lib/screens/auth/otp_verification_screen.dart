// lib/screens/auth/otp_verification_screen.dart

import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../utils/theme.dart';
import 'reset_password_screen.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String email;

  const OtpVerificationScreen({super.key, required this.email});

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final _otpCtrl = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _otpCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleVerify() async {
    final otp = _otpCtrl.text.trim();

    if (otp.isEmpty || otp.length != 6) {
      setState(() => _error = 'Please enter the 6-digit OTP.');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    final result = await ApiService.verifyOtp(
      email: widget.email,
      otp: otp,
    );

    setState(() {
      _loading = false;
    });

    if (result['success']) {
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ResetPasswordScreen(
              email: widget.email,
              otp: otp,
            ),
          ),
        );
      }
    } else {
      setState(() => _error = result['message']);
    }
  }

  Future<void> _resendOtp() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final result = await ApiService.forgotPassword(widget.email);
    setState(() {
      _loading = false;
    });
    if (result['success']) {
      setState(() => _error = 'OTP resent successfully.');
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
        // ✅ FIX: AppBar color from theme, not hardcoded
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.iconTheme.color),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.mark_email_read_outlined,
                size: 56, color: AppTheme.primary),
            const SizedBox(height: 16),
            Text(
              'Enter OTP',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                // ✅ FIX: Dark-aware text color
                color: textColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'A 6-digit OTP has been sent to ${widget.email}. It expires in 10 minutes.',
              style: TextStyle(
                fontSize: 14,
                // ✅ FIX: Dark-aware subtitle color
                color: subtitleColor,
              ),
            ),
            const SizedBox(height: 32),

            TextField(
              controller: _otpCtrl,
              keyboardType: TextInputType.number,
              maxLength: 6,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                letterSpacing: 8,
              ),
              decoration: const InputDecoration(
                hintText: '000000',
                counterText: '',
                prefixIcon: Icon(Icons.pin_outlined),
              ),
            ),

            if (_error != null) ...[
              const SizedBox(height: 8),
              Text(
                _error!,
                style: TextStyle(
                  color: _error == 'OTP resent successfully.'
                      ? Colors.green
                      : AppTheme.danger,
                  fontSize: 12,
                ),
              ),
            ],

            const SizedBox(height: 24),

            ElevatedButton(
              onPressed: _loading ? null : _handleVerify,
              child: _loading
                  ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2),
              )
                  : const Text('VERIFY OTP'),
            ),

            const SizedBox(height: 12),

            Center(
              child: TextButton(
                onPressed: _loading ? null : _resendOtp,
                child: const Text(
                  'Resend OTP',
                  style: TextStyle(color: AppTheme.primary),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
