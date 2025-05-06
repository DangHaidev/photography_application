import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:photography_application/core/navigation/router.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:photography_application/core/firebase/firebase_options_web.dart';


void main()async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    await Firebase.initializeApp(options: firebaseWebOptions);
  } else{
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
