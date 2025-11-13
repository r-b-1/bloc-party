import 'package:blocparty/model/message_model.dart';
import 'package:blocparty/model/login_model/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/material.dart';

class Chat{
  final String name; // Stores the chat name
  final List<String> members; // Stores the list of members by username
  List<String> messagesText = []; // Stores the message's text
  List<String> messagesSender = []; // Stores the message's sender in a list
  List<Message> messages = []; // Stores the messages as a message object for displaying them easier

  Chat({
    required this.name,
    required this.members,
    required this.messagesText,
    required this.messagesSender,
    required this.messages
  });

  // Builds the chat from firebase
  factory Chat.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    if (!doc.exists) {
      throw Exception('Document does not exist');
    }
    final data = doc.data();
    if (data == null) {
      throw Exception('Document data is null');
    }

    // The following sections make sure the data from firebase is converted to a form that the Chat class will accept
    // Members
    final memberData = data['members'];
    List<String> memberDataList;
    if (memberData is List) {
      memberDataList = memberData.map((e) => e.toString()).toList();
    } else {
      memberDataList = [];
    }

    // Message Text
    final messageData = data['messagetext'];
    List<String> messageTextData;
    if (messageData is List) {
      messageTextData = messageData.map((e) => e.toString()).toList();
    } else {
      messageTextData = [];
    }

    // Message Senders
    final messageSendData = data['messagesender'];
    List<String> messageSenderData;
    if (messageSendData is List) {
      messageSenderData = messageSendData.map((e) => e.toString()).toList();
    } else {
      messageSenderData = [];
    }

    // Builds the Message class list  
    List<Message> messagesToAdd = [];
    for(int i = 0; i < messageTextData.length; i++) {
      messagesToAdd.add(Message(sender: messageSenderData.elementAt(i), message: messageTextData.elementAt(i)));
      print('message added');
    }

    // Builds the Chat from the firebase data
    return Chat(
      name: data['name'] ?? '',
      members: memberDataList,
      messagesText: messageTextData,
      messagesSender: messageSenderData,
      messages: messagesToAdd
    );
  }

  // Uploads the data to firebase
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
  late DocumentReference<Map<String, dynamic>> docRef;
  AddUser ?currentUser;

  // Initializes with a specific chat
  ChatModel(Chat curChat) {
    getCurrentChatUser();
    currentChat = curChat;
    docRef = FirebaseFirestore.instance.collection('chats').doc(currentChat?.name);
  }

  // Updates the chat with new data from firebase
  Future<void> updateChat() async {
    
    isLoading = true;

    // Gets the chat from firebase and sets the currentChat to that
    currentChat = Chat.fromFirestore(await docRef.get());

    notifyListeners();
    isLoading = false;
  }

  Future<void> getCurrentChatUser() async {
    final authUser = auth.FirebaseAuth.instance.currentUser;
    if (authUser == null) {
      throw Exception('No user logged in');
    }
    final userDoc = await FirebaseFirestore.instance.collection('users').doc(authUser.uid).get();
    if (!userDoc.exists) {
      throw Exception('User document not found');
    }
    currentUser = AddUser.fromFirestore(userDoc);
    notifyListeners();
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
    
    // Updates the currentChat with the latest data from firebase
    await updateChat();

    // Adds the message to the current chat
    currentChat?.messagesText.add(messageText);
    currentChat?.messagesSender.add(_currentUser.username);

    // Sets the currentChat's firebase doc to the new data
    await docRef.set(currentChat!.toFirestore());

    // Updates the currentChat again
    notifyListeners();
    await updateChat();
    isLoading = false;
  }


}
