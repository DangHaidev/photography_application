import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:photography_application/firebase_options.dart';
import 'package:photography_application/core/navigation/router.dart';
import 'package:photography_application/src/blocs/comment/comment_bloc.dart';
import 'package:photography_application/src/blocs/follow/follow_bloc.dart';
import 'package:photography_application/src/blocs/post/post_bloc.dart';
import 'package:photography_application/src/blocs/user/user_bloc.dart';

Future<void> saveFcmToken() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) {
    print('User not logged in, skip saving FCM token');
    return;
  }

  String? token = await FirebaseMessaging.instance.getToken();
  if (token != null) {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .update({'fcmToken': token});
    print('FCM Token saved to Firestore: $token');
  }
}

Future<void> setupFirebaseMessaging() async {
  final messaging = FirebaseMessaging.instance;

  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  print('User granted permission: ${settings.authorizationStatus}');

  await saveFcmToken();

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print('Foreground message received: ${message.data}');
    if (message.notification != null) {
      print('Notification: ${message.notification}');
    }
  });
}

Future<void> setupFirestoreEmulator() async {
  // Nếu bạn chạy emulator local Firestore trên localhost:8080
  // uncomment dòng dưới đây để kết nối với emulator
  FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080);
  // FirebaseFirestore.instance.useFirestoreEmulator('192.168.1.31', 8080);

}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print("Firebase initialized successfully");

    await setupFirestoreEmulator(); // Kết nối với Firestore Emulator (nếu có)

    await setupFirebaseMessaging(); // Khởi tạo Firebase Messaging
  } catch (e) {
    print("Firebase initialization error: $e");
  }

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<UserBloc>(create: (_) => UserBloc()),
        BlocProvider<PostBloc>(create: (_) => PostBloc()),
        BlocProvider<CommentBloc>(create: (_) => CommentBloc()),
        BlocProvider<FollowBloc>(create: (_) => FollowBloc()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  MyApp({super.key}) {
    AppRouter.defineRoutes();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Photography App',
      debugShowCheckedModeBanner: false,
      onGenerateRoute: AppRouter.router.generator,
      initialRoute: '/',
    );
  }
}
