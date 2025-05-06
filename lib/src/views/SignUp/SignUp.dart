import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluro/fluro.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:photography_application/core/navigation/router.dart';

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUpScreen> {
  String email = "", password = "", name = "";
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;
  bool _obscureText = true;

  Future<void> registration() async {
    setState(() => isLoading = true);

    if (emailController.text.isNotEmpty && nameController.text.isNotEmpty) {
      try {
        UserCredential userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(email: emailController.text, password: passwordController.text);

        await userCredential.user?.updateDisplayName(nameController.text);
        await userCredential.user?.sendEmailVerification();

        // Lưu thông tin người dùng vào Firestore
        await FirebaseFirestore.instance.collection('users').doc(userCredential.user?.uid).set({
          'email': userCredential.user?.email,
          'name': nameController.text,
          'uid': userCredential.user?.uid,
          'createdAt': DateTime.now().toIso8601String(),
        }, SetOptions(merge: true));

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Registration successful. Please check your email for verification.",
              style: TextStyle(fontSize: 16),
            ),
          ),
        );

        AppRouter.router.navigateTo(
          context,
          "/verify?email=${Uri.encodeComponent(emailController.text)}",
          transition: TransitionType.fadeIn,
        );
      } on FirebaseAuthException catch (e) {
        String errorMessage = switch (e.code) {
          'weak-password' => "The password provided is too weak",
          'email-already-in-use' => "Account already exists",
          'invalid-email' => "Invalid email",
          _ => "An error occurred. Please try again.",
        };

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.orangeAccent,
            content: Text(errorMessage, style: TextStyle(fontSize: 16)),
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            content: Text("Unknown error: ${e.toString()}", style: TextStyle(fontSize: 16)),
          ),
        );
      } finally {
        setState(() => isLoading = false);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Please fill all fields", style: TextStyle(fontSize: 16)),
        ),
      );
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        leading: BackButton(color: Colors.black),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              SizedBox(height: 40),
              Align(
                alignment: Alignment.centerLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Register",
                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 5),
                    Text(
                      "Create account",
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24),

              _buildLabel("Name"),
              _buildTextField(
                controller: nameController,
                hint: "Your name",
                validator: (value) => (value == null || value.isEmpty) ? "Please enter name" : null,
              ),
              SizedBox(height: 16),

              _buildLabel("Email"),
              _buildTextField(
                controller: emailController,
                hint: "Your email",
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) return "Please enter email";
                  final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                  if (!emailRegex.hasMatch(value)) return "Invalid email format";
                  return null;
                },
              ),
              SizedBox(height: 16),

              _buildLabel("Password"),
              TextFormField(
                controller: passwordController,
                obscureText: _obscureText,
                validator: (value) => (value == null || value.isEmpty) ? "Please enter password" : null,
                decoration: InputDecoration(
                  hintText: "Your password",
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  suffixIcon: IconButton(
                    icon: Icon(_obscureText ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => setState(() => _obscureText = !_obscureText),
                  ),
                ),
              ),
              SizedBox(height: 24),

              ElevatedButton(
                onPressed: isLoading
                    ? null
                    : () {
                  if (_formKey.currentState?.validate() ?? false) {
                    registration();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  minimumSize: Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                ),
                child: isLoading
                    ? SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
                    : Text("Register", style: TextStyle(fontSize: 18)),
              ),
              SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Do you have an account?"),
                  TextButton(
                    onPressed: () {
                      AppRouter.router.navigateTo(
                        context,
                        "/loginScreen",
                        transition: TransitionType.fadeIn,
                      );
                    },
                    child: Text(
                      "Log in",
                      style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) => Align(
    alignment: Alignment.centerLeft,
    child: Text(
      text,
      style: TextStyle(fontWeight: FontWeight.w500),
    ),
  );

  Widget _buildTextField({
    required TextEditingController controller,
    String? hint,
    TextInputType keyboardType = TextInputType.text,
    FormFieldValidator<String>? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}