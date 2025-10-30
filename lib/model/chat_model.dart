import 'package:blocparty/model/message_model.dart';
import 'package:blocparty/model/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Chat{
  final String name;
  final List<AddUser> members;
  final List<Message> messages;

  Chat({
    required this.name,
    required this.members,
    required this.messages
  });

  factory Chat.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    if (!doc.exists) {
      throw Exception('Document does not exist');
    }
    final data = doc.data();
    if (data == null) {
      throw Exception('Document data is null');
    }

    return Chat(
      name: data['name'] ?? '',
      members: data['members'] ?? '',
      messages: data['messages'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'members': members,
      'messages': messages,
    };
  }
}
