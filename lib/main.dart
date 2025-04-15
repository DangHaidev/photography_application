  import 'package:flutter/material.dart';
  import 'package:hive_flutter/hive_flutter.dart';
  import 'package:firebase_core/firebase_core.dart';
  import 'package:photography_application/core/navigation/router.dart';

  class MyApp extends StatelessWidget {
    MyApp({super.key}) {
      AppRouter.defineRoutes(); // GỌI TRƯỚC KHI generator được dùng
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
  void main() async {
    WidgetsFlutterBinding.ensureInitialized();
    try {
      await Firebase.initializeApp(
        // options: const FirebaseOptions(
        //     apiKey: "AIzaSyA6sS5zPUFkiTlAw8qwou8kBgGVsRd5ccA",
        //     authDomain: "photography-application-17813.firebaseapp.com",
        //     projectId: "photography-application-17813",
        //     storageBucket: "photography-application-17813.firebasestorage.app",
        //     messagingSenderId: "686318528774",
        //     appId: "1:686318528774:web:afba923deff60f17671687",
        //     measurementId: "G-PW1QXTTF4B"
        // )
      );
      print("Firebase initialized successfully");
    } catch (e) {
      print("Firebase initialization error: $e");
    }
    runApp(MyApp());
  }


