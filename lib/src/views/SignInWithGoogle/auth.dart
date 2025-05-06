import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:photography_application/src/views/SignInWithGoogle/database.dart';
import '../../../core/navigation/router.dart';


class AuthMethods {
  final FirebaseAuth auth = FirebaseAuth.instance;

  Future<User?> getCurrentUser() async {
    return auth.currentUser;
  }

  Future<void> signInWithGoogle(BuildContext context) async {
    try {
      final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

      GoogleSignIn googleSignIn;
      if (kIsWeb) {
        googleSignIn = GoogleSignIn(
          clientId: '686318528774-n0bjl0lnsk3u9e2kuh9k8cbsbg6n5605.apps.googleusercontent.com',
          scopes: ['email', 'profile'],
        );
      } else {
        googleSignIn = GoogleSignIn(scopes: ['email', 'profile']);
      }

      // Đăng xuất trước để hiển thị màn hình chọn tài khoản
      await googleSignIn.signOut();

      final GoogleSignInAccount? googleSignInAccount = await googleSignIn.signIn();
      if (googleSignInAccount == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Login Cancelled')),
        );
        return;
      }

      final GoogleSignInAuthentication googleSignInAuthentication =
      await googleSignInAccount.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleSignInAuthentication.idToken,
        accessToken: googleSignInAuthentication.accessToken,
      );

      UserCredential result = await firebaseAuth.signInWithCredential(credential);
      User? userDetail = result.user;

      if (userDetail == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unable to get user information')),
        );
        return;
      }

      // Lưu thông tin người dùng vào Firestore
      Map<String, dynamic> userInfoMap = {
        "email": userDetail.email ?? '',
        "name": userDetail.displayName ?? '',
        "imgUrl": userDetail.photoURL ?? '',
        "id": userDetail.uid,
        "createdAt": DateTime.now().toIso8601String(),
      };

      //print("Đang lưu user: ${userDetail.uid}, ${userInfoMap}");
      await DatabaseMethods().addUser(userDetail.uid, userInfoMap);
      // print("Lưu thành công cho user: ${userDetail.uid}");

      // Điều hướng đến Homepage sau khi lưu thành công
      AppRouter.router.navigateTo(context, "/profileMe",
          transition: TransitionType.fadeIn);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login error: $e')),
      );
    }
  }
  // Hàm kiểm tra và điều hướng nếu đã đăng nhập
  Future<void> checkSessionAndNavigate(BuildContext context) async {
    User? user = await getCurrentUser();
    if (user != null) {
      AppRouter.router.navigateTo(context, "/profileMe",
          transition: TransitionType.fadeIn, clearStack: true);
    }
  }
}

