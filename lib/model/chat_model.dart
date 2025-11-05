import 'package:blocparty/model/message_model.dart';
import 'package:blocparty/model/login_model/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Chat{
  final String name;
  final List<String> members;
  List<Message> messages = [];

  Chat({
    required this.name,
    required this.members,
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

class ChatModel extends ChangeNotifier{
  ChatModel();

  Future<void> addChat({
    required String name,
    required List<String> chatters,
  }) async {
    try {
      notifyListeners();

      // Creating a new document in firestore
      final docRef = FirebaseFirestore.instance.collection('chats').doc();

      // Creating the chat
      final newItem = Chat(
        name: name,
        members: chatters
      );

      // Saving to Firestore
      await docRef.set(newItem.toFirestore());

      // Update UI
      notifyListeners();
    } catch (e) {
      print('Error adding item: $e');
      notifyListeners();
      rethrow;
    }
  }
}
