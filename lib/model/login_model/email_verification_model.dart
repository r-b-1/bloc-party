import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class EmailVerificationModel extends ChangeNotifier {
  final _auth = FirebaseAuth.instance;
  bool _hasSentEmail = false;

  Future<void> sendVerificationEmailOnce() async {
    if (_hasSentEmail) return;

    await _auth.currentUser?.sendEmailVerification();
    _hasSentEmail = true;
  }
}
