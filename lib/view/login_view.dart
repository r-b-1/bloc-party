import 'package:flutter/material.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:go_router/go_router.dart';

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return SignInScreen(
      providers: [
        EmailAuthProvider(),
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
        // action will be AuthAction.signIn or AuthAction.register
        // We can show different footers for each
        if (action == AuthAction.signIn) {
          return Column(
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 16),
                child: Text(
                  'By continuing, you agree to our Terms of Service.',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              TextButton(
                onPressed: () {
                  // Navigate to your new registration route
                  context.go('/register');
                },
                child: const Text('Don\'t have an account? Sign up here'),
              ),
            ],
          );
        } else {
          // You are on the built-in register view, show a "back to login"
          return TextButton(
            onPressed: () {
              // This is how you manually switch the screen back
              // (Though the back button also works)
              FirebaseUIAuth.signOut(context: context);
            },
            child: const Text('Already have an account? Sign in'),
          );
        }
      },

      actions: [
        AuthStateChangeAction<UserCreated>((context, state) {
          //verifying email
          context.go('/verify-email');
        }),
        // AuthStateChangeAction<UserCreated>((context, state) {
        //   //user verify email
        //   context.go('/create-profile');
        // }),
        AuthStateChangeAction<SignedIn>((context, state) {
          // GoRouter will handle navigation automatically
          if (state.user?.emailVerified == true){
          context.go('/home');
          }
          else {
            context.go('/verify-email');
          }
        }),
      ],
    );
  }
}
