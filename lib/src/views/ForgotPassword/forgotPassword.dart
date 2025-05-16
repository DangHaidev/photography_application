import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';

import '../../../core/navigation/router.dart';

class ForgotPasswordScreen extends StatefulWidget {
  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  String selectedOption = 'email';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        leading: BackButton(color: Colors.black),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Forgot Password',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Select the contact information we will use to reset your password',
              style: TextStyle(color: Colors.grey[600], fontSize: 15),
            ),
            SizedBox(height: 24),
            Row(
              children: [
                _buildOptionCard(
                  icon: Icons.email,
                  title: 'Email',
                  subtitle: 'Send to your email',
                  value: 'email',
                ),
                SizedBox(width: 16),
                _buildOptionCard(
                  icon: Icons.phone,
                  title: 'Phone number',
                  subtitle: 'Send to your phone',
                  value: 'phone',
                ),
              ],
            ),
            Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (selectedOption == "email") {
                    AppRouter.router.navigateTo(
                      context,
                      "/forgotPasswordWithEmail",
                      transition: TransitionType.fadeIn,
                    );
                  } else if (selectedOption == "phone") {
                    AppRouter.router.navigateTo(
                      context,
                      "/forgotPasswordWithPhone",
                      transition: TransitionType.fadeIn,
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Please select recovery method')),
                    );
                  }
                },
                child: Text(
                  'Reset Password',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
            ),
            SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required String value,
  }) {
    bool isSelected = selectedOption == value;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedOption = value;
          });
        },
        child: Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Color(0xFFF0F0F0),
            border: Border.all(
              color: isSelected ? Colors.black : Colors.transparent,
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: isSelected
                ? [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ]
                : [],
          ),
          child: Column(
            children: [
              Icon(
                icon,
                size: 36,
                color: isSelected ? Colors.black : Colors.grey[600],
              ),
              SizedBox(height: 12),
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
