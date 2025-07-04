  import 'package:flutter/material.dart';
  import 'package:firebase_core/firebase_core.dart';
  import 'package:flutter_bloc/flutter_bloc.dart';
  import 'package:photography_application/core/blocs/theme_provider.dart';
  import 'package:photography_application/core/design_systems/theme/theme.dart';

  import 'package:photography_application/core/navigation/router.dart';
  import 'package:photography_application/src/blocs/chat/chat_bloc.dart';
  import 'package:photography_application/src/blocs/comment/comment_bloc.dart';
  import 'package:photography_application/src/blocs/follow/follow_bloc.dart';
  import 'package:photography_application/src/blocs/message/message_bloc.dart';
  import 'package:photography_application/src/blocs/post/post_bloc.dart';
  import 'package:photography_application/src/blocs/user/user_bloc.dart';
  import 'package:provider/provider.dart';

  void main() async {
    WidgetsFlutterBinding.ensureInitialized();
    try {
      await Firebase.initializeApp();
      print("Firebase initialized successfully");
    } catch (e) {
      print("Firebase initialization error: $e");
    }

    runApp(
      MultiBlocProvider(
        providers: [
          BlocProvider<UserBloc>(create: (_) => UserBloc()),
          BlocProvider<PostBloc>(
            // create: (_) => PostBloc()..add(FetchPostsEvent()),
            create: (_) => PostBloc(),
          ),
          BlocProvider<CommentBloc>(
            create: (context) => CommentBloc(context.read<PostBloc>()),
          ),
          BlocProvider<FollowBloc>(create: (_) => FollowBloc()),
          BlocProvider<MessageBloc>(create: (_) => MessageBloc()),
          BlocProvider<ChatBloc>(create: (_) => ChatBloc()),
        ],
        child: MyApp(),
      ),
    );
  }

  class MyApp extends StatelessWidget {
    MyApp({super.key}) {
      AppRouter.defineRoutes(); // GỌI TRƯỚC KHI generator được dùng
    }

    @override
    Widget build(BuildContext context) {
      return ChangeNotifierProvider(
        create: (_) => ThemeProvider(),
        child: Consumer<ThemeProvider>(
          builder: (context, themeProvider, child) {
      return MaterialApp(
        theme: BMaterialTheme.light(),
              darkTheme: BMaterialTheme.dark(),
              themeMode: themeProvider.themeMode,
        title: 'Photography App',
        debugShowCheckedModeBanner: false,
        onGenerateRoute: AppRouter.router.generator,
        initialRoute: '/home',
      );
      }
      )
      );
    }
  }
