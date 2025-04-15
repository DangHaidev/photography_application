import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:photography_application/src/views/SignInWithGoogle/database.dart';
import '../HomePage/Homepage.dart';
class AuthMethods {
  final FirebaseAuth auth = FirebaseAuth.instance;

  getCurrentUser() async {
    return await auth.currentUser;
  }

  signInWithGoogle(BuildContext context) async {
    try {
      final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

      GoogleSignIn googleSignIn;
      if (kIsWeb) {
        googleSignIn = GoogleSignIn(
          clientId: '508987404630-8isffop9hlntdbl5kn3jvh04k0cfdbme.apps.googleusercontent.com',
          scopes: ['email', 'profile'],
        );
      } else {
        googleSignIn = GoogleSignIn(scopes: ['email', 'profile']);
      }

      // Đảm bảo đăng xuất trước để hiển thị màn hình chọn tài khoản
      await googleSignIn.signOut();

      final GoogleSignInAccount? googleSignInAccount = await googleSignIn
          .signIn();

      if (googleSignInAccount == null) {
        // Người dùng hủy đăng nhập
        return;
      }

      final GoogleSignInAuthentication googleSignInAuthentication =
      await googleSignInAccount.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
          idToken: googleSignInAuthentication.idToken,
          accessToken: googleSignInAuthentication.accessToken
      );

      UserCredential result = await firebaseAuth.signInWithCredential(
          credential);
      User? userDetail = result.user;

      if (userDetail != null) {
        Map<String, dynamic> userInfoMap = {
          "email": userDetail.email,
          "name": userDetail.displayName,
          "imgUrl": userDetail.photoURL,
          "id": userDetail.uid
        };

        await DatabaseMethods().addUser(userDetail.uid, userInfoMap);
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => Homepage()));
      }
    } catch (e) {
      print("Google login error: $e");
      // Hiển thị thông báo lỗi cho người dùng
    }
  }
}