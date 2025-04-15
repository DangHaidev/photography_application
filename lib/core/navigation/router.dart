import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:photography_application/src/views/SignUp/SignUp.dart';
import 'package:photography_application/src/views/SignUp/verify.dart';
import 'package:photography_application/src/views/SignUp/verifyNumberphone.dart';
import 'package:photography_application/src/views/detail.dart';
import 'package:photography_application/src/views/SignIn/login.dart';
import 'package:photography_application/src/views/SignIn/loginScreen.dart';
import 'package:photography_application/src/views/Home/home_screen.dart';
import 'package:photography_application/src/views/post/edit_post_screen.dart';
import 'package:photography_application/src/views/post/post_screen.dart';

class AppRouter {
  static final FluroRouter router = FluroRouter();

  static Handler _homeHandler = Handler(
    // handlerFunc: (context, parameters) => OnboardingScreen(),
    // handlerFunc: (context, parameters) => HomeScreenProvider(),
    handlerFunc: (context, parameters) => ImagePickerScreen(),

  );

  static Handler _detailHandler = Handler(
    handlerFunc: (context, parameters) {
      final id = parameters['id']?.first; // Lấy tham số từ URL
      return DetailScreen(id: id);
    },
  );

  static Handler _loginScreenHandler = Handler(
    handlerFunc: (context, parameters) => LoginScreen(),
  );

  static Handler _signupScreenHandler = Handler(
    handlerFunc: (context, parameters) => SignUpScreen(),
  );

  static Handler _verifyScreenHandler = Handler(
    handlerFunc: (context, parameters) => EmailVerificationInput(),
  );

  static Handler _verifyPhoneNumberScreenHandler = Handler(
    handlerFunc: (context, parameters) => PhoneNumberScreen(),
  );
static Handler _editpost = Handler(
    handlerFunc: (context, parameters) => MediaEditScreen(),
  );

  static void defineRoutes() {
    router.define(
      '/',
      handler: _homeHandler,
      transitionType: TransitionType.fadeIn, // Hiệu ứng chuyển trang
    );

    router.define(
      '/detail/:id', // Route có tham số
      handler: _detailHandler,
      transitionType: TransitionType.cupertino,
    );
    router.define(
      '/loginScreen',
      handler: _loginScreenHandler,
      transitionType: TransitionType.fadeIn,
    );

    router.define(
      '/signupScreen',
      handler: _signupScreenHandler,
      transitionType: TransitionType.fadeIn,
    );

    router.define(
      '/verify',
      handler: _verifyScreenHandler,
      transitionType: TransitionType.fadeIn,
    );

    router.define(
      '/verifyPhone',
      handler: _verifyPhoneNumberScreenHandler,
      transitionType: TransitionType.fadeIn,
    );

    router.define(
      '/editpost',
      handler: _editpost,
      transitionType: TransitionType.fadeIn,
    );
  }
}
