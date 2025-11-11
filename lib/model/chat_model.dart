import 'package:blocparty/model/message_model.dart';
import 'package:blocparty/model/login_model/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/material.dart';

class Chat{
  final String name;
  final List<String> members;
  List<String> messagesText = [];
  List<String> messagesSender = [];
  List<Message> messages = [];

  Chat({
    required this.name,
    required this.members,
    required this.messagesText,
    required this.messagesSender,
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

    final memberData = data['members'];
    List<String> memberDataList;
    if (memberData is List) {
      memberDataList = memberData.map((e) => e.toString()).toList();
    } else {
      memberDataList = [];
    }

    final messageData = data['messagetext'];
    List<String> messageTextData;
    if (messageData is List) {
      messageTextData = messageData.map((e) => e.toString()).toList();
    } else {
      messageTextData = [];
    }

    final messageSendData = data['messagesender'];
    List<String> messageSenderData;
    if (messageSendData is List) {
      messageSenderData = messageSendData.map((e) => e.toString()).toList();
    } else {
      messageSenderData = [];
    }

    List<Message> messagesToAdd = [];
    for(int i = 0; i < messageTextData.length; i++) {
      messagesToAdd.add(Message(sender: messageSenderData.elementAt(i), message: messageTextData.elementAt(i)));
      print('message added');
    }

    return Chat(
      name: data['name'] ?? '',
      members: memberDataList,
      messagesText: messageTextData,
      messagesSender: messageSenderData,
      messages: messagesToAdd
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'members': members,
      'messagetext': messagesText,
      'messagesender': messagesSender
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
    currentChat?.messagesText.add(messageText);
    currentChat?.messagesSender.add(_currentUser.username);

    final activeDoc = FirebaseFirestore.instance.collection('chats').doc(currentChat!.name);

    await activeDoc.set(currentChat!.toFirestore());
    notifyListeners();

    isLoading = false;
  }


}
