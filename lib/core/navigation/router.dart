import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:photography_application/src/views/SignUp/SignUp.dart';
import 'package:photography_application/src/views/SignUp/verify.dart';
import 'package:photography_application/src/views/SignUp/verifyNumberphone.dart';
import 'package:photography_application/src/views/detail.dart';
import 'package:photography_application/src/views/SignIn/login.dart';
import 'package:photography_application/src/views/SignIn/loginScreen.dart';
import 'package:photography_application/src/views/ForgotPassword/forgotPassword.dart';
import 'package:photography_application/src/views/ForgotPassword/forgotPasswordWithEmail.dart';

import '../../src/views/profile/profile_me.dart';

class AppRouter {
  static final FluroRouter router = FluroRouter();

  static Handler _homeHandler = Handler(
    handlerFunc: (context, parameters) => OnboardingScreen(),
  );

  // static Handler _detailHandler = Handler(
  //   handlerFunc: (context, parameters) {
  //     final id = parameters['id']?.first; // Lấy tham số từ URL
  //     return DetailScreen(id: id);
  //   },
  // );
  static Handler _profileMe = Handler(
    handlerFunc: (context, parameters) => ProfileMePage(),
  );

  static Handler _loginScreenHandler = Handler(
    handlerFunc: (context, parameters) => LoginScreen(),
  );

  static Handler _signupScreenHandler = Handler(
    handlerFunc: (context, parameters) => SignUpScreen(),
  );

  //
  static Handler _verifyScreenHandler = Handler(
    handlerFunc: (context, parameters) {
      final email = parameters["email"]?.first ?? "";
      return EmailVerificationInput(email: email);
    },
  );

  static Handler _forgotPasswprdSceenHandler = Handler(
    handlerFunc: (context, parameters) => ForgotPasswordScreen(),
  );
  static Handler _forgotPasswprWithEmailScreenHandler = Handler(
    handlerFunc: (context, parameters) => ResetPasswordScreen(),
  );
  static Handler _verifyPhoneNumberScreenHandler = Handler(
    handlerFunc: (context, parameters) => PhoneNumberScreen(),
  );

  static void defineRoutes() {
    router.define(
      '/',
      handler: _homeHandler,
      transitionType: TransitionType.fadeIn, // Hiệu ứng chuyển trang
    );

    // router.define(
    //   '/detail/:id', // Route có tham số
    //   handler: _detailHandler,
    //   transitionType: TransitionType.cupertino,
    // );

    router.define(
      '/loginScreen',
      handler: _loginScreenHandler,
      transitionType: TransitionType.fadeIn,
    );

    router.define(
      '/profileMe',
      handler: _profileMe,
      transitionType: TransitionType.fadeIn,
    );

    router.define(
      "/verify",
      handler: _verifyScreenHandler,
      transitionType: TransitionType.fadeIn,
    );

    router.define(
      '/signupScreen',
      handler: _signupScreenHandler,
      transitionType: TransitionType.fadeIn,
    );

    router.define(
      '/forgotPassword',
      handler: _forgotPasswprdSceenHandler,
      transitionType: TransitionType.fadeIn,
    );
    router.define(
      '/forgotPasswordWithEmail',
      handler: _forgotPasswprWithEmailScreenHandler,
      transitionType: TransitionType.fadeIn,
    );

    router.define(
      '/verifyPhone',
      handler: _verifyPhoneNumberScreenHandler,
      transitionType: TransitionType.fadeIn,
    );
  }
}
