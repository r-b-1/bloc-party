import 'package:flutter/material.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:blocparty/model/email_verification_model.dart';

class VerifyEmailView extends StatelessWidget {
  const VerifyEmailView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => EmailVerificationModel(),
      builder: (context, child) {
        final model = context.read<EmailVerificationModel>();
        model.sendVerificationEmailOnce();

        return EmailVerificationScreen(
          headerBuilder: (context, constraints, shrinkOffset) {
            return const Padding(
              padding: EdgeInsets.all(20),
              child: Icon(Icons.email, size: 100),
            );
          },
          actions: [
            EmailVerifiedAction(() {
              context.go('/create-profile');
            }),
            AuthCancelledAction((context) {
              FirebaseUIAuth.signOut(context: context);
              context.go('/login');
            }),
          ],
        );
      },
    );
  }
}