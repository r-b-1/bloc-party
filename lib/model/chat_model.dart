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

    final messageData = data['messages'];
    List<Message> message;
    if (messageData is List) {
      message = messageData.map((e) => Message(timestamp: e.timestamp, sender: e.sender.toString(), message: e.message.toString())).toList();
    } else {
      message = [];
    }

    final memberData = data['members'];
    List<String> membersList;
    if (messageData is List) {
      membersList = messageData.map((e) => e.toString()).toList();
    } else {
      membersList = [];
    }

    return Chat(
      name: data['name'] ?? '',
      members: membersList,
      messages: message
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
  bool isLoading = false;

  ChatModel(Chat curChat) {
    currentChat = curChat;
  }

  // Sends a message
  Future<void> addMessage(String messageText) async {

    isLoading = true;

    // Gets Current User
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
        timestamp: FieldValue.serverTimestamp().toString(),
        sender: _currentUser.username,
        message: messageText
      )
    );

    final activeDoc = FirebaseFirestore.instance.collection('chats').doc(currentChat!.name);

    await activeDoc.set(currentChat!.toFirestore());
    notifyListeners();
  }


}
