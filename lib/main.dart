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
    await Firebase.initializeApp();

    print("Firebase initialized successfully");
  } catch (e) {
    print("Firebase initialization error: $e");
  }
  runApp(MyApp());
}
