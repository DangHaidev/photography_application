import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:fluro/fluro.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:photography_application/src/views/SignInWithGoogle/database.dart';
import '../../../core/navigation/router.dart';
import '../../../core/domain/models/User.dart' as app_user; // Import model User

class AuthMethods {
  final firebase_auth.FirebaseAuth auth = firebase_auth.FirebaseAuth.instance;

  Future<firebase_auth.User?> getCurrentUser() async {
    return auth.currentUser;
  }

  Future<void> signInWithGoogle(BuildContext context) async {
    try {
      final firebase_auth.FirebaseAuth firebaseAuth = firebase_auth.FirebaseAuth.instance;

      GoogleSignIn googleSignIn;
      if (kIsWeb) {
        googleSignIn = GoogleSignIn(
          clientId:
          '686318528774-6e9nc5eb31kbcuu359besm5aqqp7bp5a.apps.googleusercontent.com',
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

      final firebase_auth.AuthCredential credential = firebase_auth.GoogleAuthProvider.credential(
        idToken: googleSignInAuthentication.idToken,
        accessToken: googleSignInAuthentication.accessToken,
      );

      firebase_auth.UserCredential result = await firebaseAuth.signInWithCredential(credential);
      firebase_auth.User? userDetail = result.user;

      if (userDetail == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unable to get user information')),
        );
        return;
      }

      // Tạo instance của model User
      final app_user.User user = app_user.User(
        id: userDetail.uid,
        name: userDetail.displayName ?? 'Unknown User',
        email: userDetail.email ?? '',
        avatarUrl: userDetail.photoURL ?? '',
        bio: '',
        totalFollowers: 0,
        totalPosts: 0,
        totalDownloadPosts: 0,
        createdAt: Timestamp.now(),
      );

      // Chuẩn bị dữ liệu để lưu vào Firestore
      Map<String, dynamic> userInfoMap = {
        ...user.toMap(),
      };

      // Lưu thông tin người dùng vào Firestore
      print('Saving user: ${userDetail.uid}, $userInfoMap');
      await DatabaseMethods().addUser(userDetail.uid, userInfoMap);
      print('Saved user: ${userDetail.uid}');

      // Điều hướng đến Homepage
      AppRouter.router.navigateTo(
        context,
        "/profileMe",
        transition: TransitionType.fadeIn,
      );
    } catch (e) {
      print('Login error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login error: $e')),
      );
    }
  }

  // Hàm kiểm tra và điều hướng nếu đã đăng nhập
  Future<void> checkSessionAndNavigate(BuildContext context) async {
    firebase_auth.User? user = await getCurrentUser();
    if (user != null) {
      AppRouter.router.navigateTo(
        context,
        "/profileMe",
        transition: TransitionType.fadeIn,
        clearStack: true,
      );
    }
  }
}