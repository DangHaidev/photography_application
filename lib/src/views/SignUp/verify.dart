import 'dart:async';
import 'package:flutter/material.dart';
import 'package:photography_application/core/navigation/router.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EmailVerificationInput extends StatefulWidget {
  final String email;

  const EmailVerificationInput({
    super.key,
    required this.email
  });

  @override
  State<EmailVerificationInput> createState() => _EmailVerificationInputState();
}

class _EmailVerificationInputState extends State<EmailVerificationInput> {
  Timer? _timer;
  Timer? _checkEmailVerificationTimer;
  int _remainingTime = 60; // Thời gian chờ gửi lại email (60 giây)
  bool _canResend = false;
  bool _isVerifying = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
    _startCheckingEmailVerification();
  }

  void _startTimer() {
    setState(() {
      _remainingTime = 60;
      _canResend = false;
    });

    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingTime > 0) {
          _remainingTime--;
        } else {
          _canResend = true;
          _timer?.cancel();
        }
      });
    });
  }

  void _startCheckingEmailVerification() {
    // Kiểm tra trạng thái xác thực email mỗi 5 giây
    _checkEmailVerificationTimer = Timer.periodic(Duration(seconds: 5), (timer) async {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await user.reload();
        user = FirebaseAuth.instance.currentUser;
        if (user != null && user.emailVerified) {
          _checkEmailVerificationTimer?.cancel();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Email has been successfully verified!'))
            );
            // Chuyển đến màn hình tiếp theo sau khi xác thực thành công
            AppRouter.router.navigateTo(context, "/loginScreen");
          }
        }
      }
    });
  }

  Future<void> _resendVerificationEmail() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await user.sendEmailVerification();
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Verification email resent.'))
        );
        _startTimer();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('User not found. Please login again.'))
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error resending email: ${e.toString()}'))
      );
    }
  }

  Future<void> _checkVerificationStatus() async {
    setState(() {
      _isVerifying = true;
    });

    try {
      // Reload người dùng hiện tại để kiểm tra trạng thái xác thực
      User? user = FirebaseAuth.instance.currentUser;
      await user?.reload();
      user = FirebaseAuth.instance.currentUser; // Lấy lại thông tin mới nhất

      if (user != null && user.emailVerified) {
        // Email đã được xác thực
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Email has been successfully verified!'))
        );

        // Chuyển đến màn hình tiếp theo
        AppRouter.router.navigateTo(context, "/loginScreen");
      } else {
        // Email chưa được xác thực
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Email is not verified. Please check your email and click the verification link.'),
              backgroundColor: Colors.orange,
            )
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          )
      );
    } finally {
      setState(() {
        _isVerifying = false;
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _checkEmailVerificationTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Color(0xFF5E3A87);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        leading: const BackButton(color: Colors.black),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: 20),
                const Text('Email Authentication',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                Icon(
                  Icons.email_outlined,
                  size: 80,
                  color: primaryColor,
                ),
                const SizedBox(height: 20),
                Text(
                  'We have sent a verification email to',
                  style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  widget.email,
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[300]!)
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Authentication Instructions',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: primaryColor
                        ),
                      ),
                      SizedBox(height: 12),
                      _buildInstructionStep(
                          '1',
                          'Open your email app'
                      ),
                      SizedBox(height: 8),
                      _buildInstructionStep(
                          '2',
                          'Check email from "Firebase" or check spam folder'
                      ),
                      SizedBox(height: 8),
                      _buildInstructionStep(
                          '3',
                          'Click the verification link in the email'
                      ),
                      SizedBox(height: 8),
                      _buildInstructionStep(
                          '4',
                          'Return to this app and tap "Verified"'
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 25),
                GestureDetector(
                  onTap: _canResend ? _resendVerificationEmail : null,
                  child: Text.rich(
                    TextSpan(
                      text: "Didn't receive email?",
                      children: [
                        TextSpan(
                          text: _canResend
                              ? 'Resend'
                              : 'Resend after $_remainingTime seconds',
                          style: TextStyle(
                            color: _canResend ? primaryColor : Colors.grey,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: _isVerifying ? null : _checkVerificationStatus,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(32),
                    ),
                  ),
                  child: _isVerifying
                      ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                      : const Text(
                    'Verified',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInstructionStep(String number, String instruction) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0xFF5E3A87),
          ),
          child: Center(
            child: Text(
              number,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: Text(
            instruction,
            style: TextStyle(fontSize: 16),
          ),
        ),
      ],
    );
  }
}