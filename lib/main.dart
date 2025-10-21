import 'package:blocparty/flutter_backend/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:blocparty/view/navigation/navigation_bar.dart';
import 'package:blocparty/view/chat_view.dart';
import 'package:blocparty/view/item_descriptions_view.dart';
import 'package:blocparty/view/login_view.dart';
import 'package:blocparty/view/schedule_view.dart';
import 'package:blocparty/flutter_backend/go_router.dart';

import 'package:go_router/go_router.dart';

const clientId = '';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp(clientId: clientId));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.clientId});

  final String clientId;

  @override
  Widget build(BuildContext context) {
    final GoRouter router = GoRouter(
      initialLocation: '/auth',
      refreshListenable: GoRouterRefreshStream(FirebaseAuth.instance.authStateChanges()),
      routes: [
        GoRoute(
          path: '/auth',
          builder: (context, state) => LoginView(),
        ),
        GoRoute(
          path: '/home',
          builder: (context, state) => const MainNavigation(),
        ),
        GoRoute(
          path: '/item_description',
          builder: (context, state) => const ItemDescriptionView(),
        ),
        GoRoute(
          path: '/schedule',
          builder: (context, state) => const ScheduleView(),
        ),
        GoRoute(
          path: '/chat',
          builder: (context, state) => const ChatView(),
        ),
      ],
      redirect: (context, state) {
        final user = FirebaseAuth.instance.currentUser;
        final loggingIn = state.name == '/auth';

        if (user == null && !loggingIn) return '/auth';
        if (user != null && loggingIn) return '/home';
        return null; // no redirect
      },
    );

    return MaterialApp.router(
      title: 'BlocParty',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 1,
          iconTheme: IconThemeData(color: Colors.black),
          titleTextStyle: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),
      ),
      routerConfig: router,
    );
  }
}
