import 'package:cloud_firestore/cloud_firestore.dart';

import 'login_model/user_model.dart';

class Message {
  final String sender;
  final String message;

  Message({
    required this.sender,
    required this.message,
  });

  /*factory Message.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    if (!doc.exists) {
      throw Exception('Document does not exist');
    }
    final data = doc.data();
    if (data == null) {
      throw Exception('Document data is null');
    }

    return Message(
      timestamp: data['timestamp'] ?? '',
      sender: data['sender'] ?? '',
      message: data['message'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'timestamp': FieldValue.serverTimestamp().toString(),
      'sender': sender,
      'message': message,
    };
  }*/
}