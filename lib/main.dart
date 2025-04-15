import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:photography_application/core/navigation/router.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

void main()async {
  WidgetsFlutterBinding.ensureInitialized();
  if(kIsWeb){
    await Firebase.initializeApp(
        options: const FirebaseOptions(
            apiKey: "AIzaSyA6sS5zPUFkiTlAw8qwou8kBgGVsRd5ccA",
            authDomain: "photography-application-17813.firebaseapp.com",
            projectId: "photography-application-17813",
            storageBucket: "photography-application-17813.firebasestorage.app",
            messagingSenderId: "686318528774",
            appId: "1:686318528774:web:afba923deff60f17671687",
            measurementId: "G-PW1QXTTF4B"
        ));
  }else{
    await Firebase.initializeApp();
  }
  AppRouter.defineRoutes(); // Định nghĩa các route
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fluro Example',
      debugShowCheckedModeBanner: false,
      onGenerateRoute: AppRouter.router.generator, // Sử dụng Fluro để xử lý route
      initialRoute: '/', // Route mặc định
    );
  }
}
