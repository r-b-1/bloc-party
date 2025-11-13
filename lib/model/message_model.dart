import 'package:cloud_firestore/cloud_firestore.dart';

import 'login_model/user_model.dart';

// Just a basic class to store the messages as an object
// (This was originally used for a lot more but now its just storage)
class Message {
  final String sender;
  final String message;

  Message({
    required this.sender,
    required this.message
  });
}