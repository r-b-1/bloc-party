import 'package:blocparty/model/message_model.dart';
import 'package:blocparty/model/login_model/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/material.dart';

class Chat{
  final String name;
  final List<String> members;
  List<Message> messages = [];

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
      messages: data['messages']
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

// Handles functions of a single chat
class ChatModel extends ChangeNotifier{
  Chat ?currentChat;

  ChatModel(String doc) {
    _fetchChat(doc);
  }

  // Fetches the chat data from firebase
  Future<void> _fetchChat(String doc) async {
    final chatDoc = FirebaseFirestore.instance.collection('chats').doc(doc).get();
    currentChat = Chat.fromFirestore(await chatDoc);
  }

  // Sends a message
  Future<void> _addMessage(String messageText) async {

    // Gets Current User's Username
    AddUser _currentUser;
    final authUser = auth.FirebaseAuth.instance.currentUser;
    if (authUser == null) {
      throw Exception('No user logged in');
    }
    final userDoc = await FirebaseFirestore.instance.collection('users').doc(authUser.uid).get();
    if (!userDoc.exists) {
      throw Exception('User document not found');
    }
    _currentUser = AddUser.fromFirestore(userDoc);

    // Adds the message to firebase
    currentChat?.messages.add(
      Message(
        timestamp: FieldValue.serverTimestamp(),
        sender: _currentUser.username,
        message: messageText
      )
    );
  }


}
