import 'package:flutter/material.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:go_router/go_router.dart';

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return SignInScreen(
      providers: [
        EmailAuthProvider(), // or any other providers you want
      ],
      headerBuilder: (context, constraints, shrinkOffset) {
        return const Padding(
          padding: EdgeInsets.all(20),
          child: Icon(Icons.lock, size: 100, color: Colors.blue),
        );
      },
      subtitleBuilder: (context, action) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            action == AuthAction.signIn
                ? 'Welcome back! Please sign in.'
                : 'Create your account below!',
            textAlign: TextAlign.center,
          ),
        );
      },
      footerBuilder: (context, action) {
        return const Padding(
          padding: EdgeInsets.only(top: 16),
          child: Text(
            'By continuing, you agree to our Terms of Service.',
            style: TextStyle(color: Colors.grey),
          ),
        );
      },
      actions: [
        AuthStateChangeAction<SignedIn>((context, state) {
          // GoRouter will handle navigation automatically
          context.go('/home');
        }),
      ],
    );
  }
}