import 'package:photography_application/core/navigation/router.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUpScreen> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.only(top: 60, left: 24,right: 24),
        // padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Sign Up",
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            const Text(
              "Create account and choose favorite menu",
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 24),

          Text(
            "Name",
            // style: ,
          ),
            // name Field
            TextField(
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                hintText: "Your name",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 16),
//Email field
 Text(
            "Email",
            // style: ,
          ),
            TextField(
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                hintText: "Your email",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Password Field
            Text(
              "Password"
            ),
            TextField(
              obscureText: _obscureText,
              decoration: InputDecoration(
                labelText: "Your Password",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureText ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureText = !_obscureText;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 10),

            // // Forgot Password
            // Align(
            //   alignment: Alignment.centerLeft,
            //   child: TextButton(
            //     onPressed: () {},
            //     child: Text(
            //       "Forgot Password?",
            //       style: TextStyle(color: Color(0xFF54408C)),
            //     ),
            //   ),
            // ),
            // const SizedBox(height: 20),

            // Login Button
            ElevatedButton(
              onPressed: () {
                // Xử lý đăng nhập
                  AppRouter.router.navigateTo(context, "/verify", transition: TransitionType.fadeIn);

              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF54408C),
                minimumSize: Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child: Text("Register", style: TextStyle(fontSize: 18, color: Colors.white)),
            ),
            const SizedBox(height: 15),

            // Sign Up
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Have you an account?"),
                TextButton(
                  onPressed: () {
                  AppRouter.router.navigateTo(context, "/loginScreen", transition: TransitionType.fadeIn);

                  },
                  child: Text("Sign In", style: TextStyle(color: Color(0xFF54408C))),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Text(
            //   "By clicking Register, you agree to our Terms and Data Policy."
            // ),
          ],
        ),
      ),
    );
  }
}
