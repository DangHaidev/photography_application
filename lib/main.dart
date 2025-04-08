import 'package:flutter/material.dart';
import 'package:photography_application/core/navigation/router.dart';

void main() {
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
