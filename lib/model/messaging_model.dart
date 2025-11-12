import 'package:blocparty/model/chat_model.dart';
import 'package:blocparty/model/login_model/user_model.dart';
import 'package:blocparty/model/message_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/material.dart';
import 'package:blocparty/model/login_model/auth_model.dart';

class MessagingModel extends ChangeNotifier {
  List<Chat> currentChats = [];
  final AuthViewModel _authViewModel;

  MessagingModel(this._authViewModel) {
    _authViewModel.addListener(_onAuthChanged);
    _onAuthChanged();
  }

  void _onAuthChanged() {
    if (_authViewModel.isSignedIn) {
      fetchItems();
    }
  }

  void fetchItems() async {
    notifyListeners();
    try {

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

      final QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore.instance.collection('chats').where('members', arrayContains: _currentUser.username).get();

      currentChats = snapshot.docs.map((doc) => Chat.fromFirestore(doc)).toList();

    } catch (e) {
      print('Error fetching items: $e');
      // Keep empty list on error
    } finally {
      notifyListeners(); // Update the UI
    }
  }

  @override
  void dispose() {
    _authViewModel.removeListener(_onAuthChanged);
    super.dispose();
  }

    Future<void> addChat({
    required String name,
    required List<String> chatters,
  }) async {
    try {
      notifyListeners();

      // Creating a new document in firestore
      final docRef = FirebaseFirestore.instance.collection('chats').doc(name);

      // Creating the chat
      final newItem = Chat(
        name: name,
        members: chatters,
        messagesText: [],
        messagesSender: [],
        messages: []
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
    fetchItems();
  }
}