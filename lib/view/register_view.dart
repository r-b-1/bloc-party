import 'package:flutter/material.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:go_router/go_router.dart';

class RegisterView extends StatelessWidget {
  const RegisterView({super.key});

  @override
  Widget build(BuildContext context) {
    return RegisterScreen(
      providers: [EmailAuthProvider()],
      headerBuilder: (context, constraints, shrinkOffset) {
        return const Padding(
          padding: EdgeInsets.all(20),
          child: Icon(Icons.person_add, size: 100, color: Colors.green),
        );
      },
      subtitleBuilder: (context, action) {
        return const Padding(
          padding: EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            'Create your account to get started!',
            textAlign: TextAlign.center,
          ),
        );
      },
      actions: [
        AuthStateChangeAction<UserCreated>((context, state) {
          // Go to a profile setup page or directly to home
          context.go('/verify-email');
        }),
      ],
    );
  }
}
