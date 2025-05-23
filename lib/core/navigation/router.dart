// import 'dart:io';

// import 'package:fluro/fluro.dart';
// import 'package:flutter/material.dart';
// import 'package:photography_application/src/views/SignUp/SignUp.dart';
// import 'package:photography_application/src/views/SignUp/verify.dart';
// import 'package:photography_application/src/views/SignUp/verifyNumberphone.dart';
// import 'package:photography_application/src/views/detail.dart';
// import 'package:photography_application/src/views/SignIn/login.dart';
// import 'package:photography_application/src/views/SignIn/loginScreen.dart';
// import 'package:photography_application/src/views/Home/home_screen.dart';
// import 'package:photography_application/src/views/post/edit_post_screen.dart';
// import 'package:photography_application/src/views/post/post_screen.dart';

// class AppRouter {
//   static final FluroRouter router = FluroRouter();

//   static Handler _homeHandler = Handler(
//     // handlerFunc: (context, parameters) => OnboardingScreen(),
//     // handlerFunc: (context, parameters) => HomeScreenProvider(),
//     handlerFunc: (context, parameters) => ImagePickerScreen(),

//   );

//   static Handler _detailHandler = Handler(
//     handlerFunc: (context, parameters) {
//       final id = parameters['id']?.first; // Lấy tham số từ URL
//       return DetailScreen(id: id);
//     },
//   );

//   static Handler _loginScreenHandler = Handler(
//     handlerFunc: (context, parameters) => LoginScreen(),
//   );

//   static Handler _signupScreenHandler = Handler(
//     handlerFunc: (context, parameters) => SignUpScreen(),
//   );

//   static Handler _verifyScreenHandler = Handler(
//     handlerFunc: (context, parameters) => EmailVerificationInput(),
//   );

//   static Handler _verifyPhoneNumberScreenHandler = Handler(
//     handlerFunc: (context, parameters) => PhoneNumberScreen(),
//   );

// // static Handler _editpost = Handler(
// //   handlerFunc: (context, parameters) {
// //     final imagePath = parameters['path']?.first;
// //     if (imagePath != null) {
// //       final decodedPath = Uri.decodeComponent(imagePath);
// //       return MediaEditScreen(selectedImage: File(decodedPath));
// //     }
// //     // fallback nếu thiếu path hoặc lỗi
// //     return Scaffold(
// //       body: Center(
// //         child: Text('No image selected.'),
// //       ),
// //     );
// //   },
// // );

//   static void defineRoutes() {
//     router.define(
//       '/',
//       handler: _homeHandler,
//       transitionType: TransitionType.fadeIn, // Hiệu ứng chuyển trang
//     );

//     router.define(
//       '/detail/:id', // Route có tham số
//       handler: _detailHandler,
//       transitionType: TransitionType.cupertino,
//     );
//     router.define(
//       '/loginScreen',
//       handler: _loginScreenHandler,
//       transitionType: TransitionType.fadeIn,
//     );

//     router.define(
//       '/signupScreen',
//       handler: _signupScreenHandler,
//       transitionType: TransitionType.fadeIn,
//     );

//     router.define(
//       '/verify',
//       handler: _verifyScreenHandler,
//       transitionType: TransitionType.fadeIn,
//     );

//     router.define(
//       '/verifyPhone',
//       handler: _verifyPhoneNumberScreenHandler,
//       transitionType: TransitionType.fadeIn,
//     );

// // router.define("/editpost", handler: _editpost);
//   }
// }


import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:photography_application/src/views/SignUp/SignUp.dart';
import 'package:photography_application/src/views/SignUp/verify.dart';
import 'package:photography_application/src/views/SignUp/verifyNumberphone.dart';
import 'package:photography_application/src/views/detail.dart';
import 'package:photography_application/src/views/SignIn/login.dart';
import 'package:photography_application/src/views/SignIn/loginScreen.dart';
import 'package:photography_application/src/views/ForgotPassword/forgotPassword.dart';
import 'package:photography_application/src/views/ForgotPassword/forgotPasswordWithEmail.dart';
import 'package:photography_application/src/views/home/home_screen.dart';

import '../../src/views/messages/chat_detail_screen.dart';
import '../../src/views/messages/chat_list_screen.dart';
import '../../src/views/post/post_screen.dart';
import '../../src/views/profile/edit/edit_email.dart';
import '../../src/views/profile/edit/edit_facebook.dart';
import '../../src/views/profile/edit/edit_instagram.dart';
import '../../src/views/profile/edit/edit_notifications.dart';
import '../../src/views/profile/edit/edit_pesonal_info.dart';
import '../../src/views/profile/edit/edit_website.dart';
import '../../src/views/profile/post_detail.dart';
import '../../src/views/profile/profile_id.dart';
import '../../src/views/profile/settings.dart';
import '../domain/models/User.dart';

class AppRouter {
  static final FluroRouter router = FluroRouter();

  static Handler _onboardScreenHandler = Handler(
    handlerFunc: (context, parameters) => OnboardingScreen(),
  );

  // static Handler _detailHandler = Handler(
  //   handlerFunc: (context, parameters) {
  //     final id = parameters['id']?.first; // Lấy tham số từ URL
  //     return DetailScreen(id: id);
  //   },
  // );

  static final Handler _profileId = Handler(
    handlerFunc: (BuildContext? context, Map<String, List<String>> parameters) {
      final settings = context?.settings;
      final args = settings?.arguments as Map<String, dynamic>? ?? {};
      final User? postAuthor = args['user'] as User?;

      return ProfilePage(user: postAuthor!);
    }

  );

  static Handler _settings = Handler(
    handlerFunc: (context, parameters) => SettingsPage(),
  );

  static final Handler _postDetail = Handler(
    handlerFunc: (BuildContext? context, Map<String, List<String>> parameters) {
      final settings = context?.settings;
      final args = settings?.arguments as Map<String, dynamic>? ?? {};

      final String postId = args['postId'] ?? '';
      final User? postAuthor = args['user'] as User?;

      return PostDetailPage(postId: postId, postAuthor: postAuthor);
    },
  );


  static Handler _editEmail = Handler(
    handlerFunc: (context, parameters) => EditEmailPage(),
  );
  static Handler _editFacebook = Handler(
    handlerFunc: (context, parameters) => EditFacebookPage(),
  );
  static Handler _editInstagram = Handler(
    handlerFunc: (context, parameters) => EditInstagramPage(),
  );
  static Handler _editNotifications = Handler(
    handlerFunc: (context, parameters) => EditNotificationsPage(),
  );
  static Handler _editPesonalInfo = Handler(
    handlerFunc: (context, parameters) => EditPersonalInfoPage(),
  );
  static Handler _editWebsite = Handler(
    handlerFunc: (context, parameters) => EditWebsitePage(),
  );

  static Handler _loginScreenHandler = Handler(
    handlerFunc: (context, parameters) => LoginScreen(),
  );

  static Handler _signupScreenHandler = Handler(
    handlerFunc: (context, parameters) => SignUpScreen(),
  );

  static Handler _homeScreenHandler = Handler(
    handlerFunc: (context, parameters) => HomeScreen(),
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

  static Handler _imagePickerHandler = Handler(
    // handlerFunc: (context, parameters) => OnboardingScreen(),
    // handlerFunc: (context, parameters) => HomeScreenProvider(),
    handlerFunc: (context, parameters) => ImagePickerScreen(),

  );

  // static Handler _chatHandler = Handler(
  //   handlerFunc: (context, parameters) {
  //     final currentUserId = parameters['currentUserId']?.first ?? '';
  //     return ChatListScreen(currentUserId: currentUserId);
  //   },
  // );


  static void defineRoutes() {
    router.define(
      '/',
      handler: _onboardScreenHandler,
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
      '/loginScreen',
      handler: _profileId,
      transitionType: TransitionType.fadeIn,
    );
    router.define(
      '/settings',
      handler: _settings,
      transitionType: TransitionType.fadeIn,
    );
    router.define(
      '/editEmail',
      handler: _editEmail,
      transitionType: TransitionType.fadeIn,
    );
    router.define(
      '/editInstagram',
      handler: _editInstagram,
      transitionType: TransitionType.fadeIn,
    );
    router.define(
      '/editFacebook',
      handler: _editFacebook,
      transitionType: TransitionType.fadeIn,
    );
    router.define(
      '/editWebsite',
      handler: _editWebsite,
      transitionType: TransitionType.fadeIn,
    );
    router.define(
      '/editNotifications',
      handler: _editNotifications,
      transitionType: TransitionType.fadeIn,
    );
    router.define(
      '/editPersonalInfo',
      handler: _editPesonalInfo,
      transitionType: TransitionType.fadeIn,
    );

    router.define(
      '/postDetail',
      handler: _postDetail,
      transitionType: TransitionType.fadeIn,
    );

    // router.define(
    //   "/verify",
    //   handler: _verifyScreenHandler,
    //   transitionType: TransitionType.fadeIn,
    // );

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

    router.define(
      '/home',
      handler: _homeScreenHandler,
      transitionType: TransitionType.fadeIn,
    );

    router.define(
      '/create',
      handler: _imagePickerHandler,
      transitionType: TransitionType.fadeIn,
    );

    // router.define(
    //   '/chat',
    //   handler: _chatHandler,
    //   transitionType: TransitionType.fadeIn,
    // );
  }
}