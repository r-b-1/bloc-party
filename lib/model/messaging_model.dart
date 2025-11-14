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

      // Gets all chats with the current user's username in the 'members' list
      final QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore.instance.collection('chats').where('members', arrayContains: _currentUser.username).get();
      currentChats = snapshot.docs.map((doc) => Chat.fromFirestore(doc)).toList();

    } catch (e) {
      print('Error fetching items: $e');
    } finally {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _authViewModel.removeListener(_onAuthChanged);
    super.dispose();
  }

    Future<void> addChat({required String name, required List<String> chatters}) async {
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

  // Method to create borrow request chat and navigate to it
  Future<Chat?> createBorrowRequestChat({
    required String itemName,
    required String lenderUsername,
    required String currentUsername,
  }) async {
    try {
      notifyListeners();

      // Creates chat name with format: "name of person requesting requests wants name of item"
      final chatName = '$currentUsername requests $itemName';

      // Create members list (current user and lender)
      final chatters = [currentUsername, lenderUsername];

      // Create initial message
      final initialMessage = 'Hi! I would like to borrow your $itemName.';

      // Create the chat with initial message
      final newChat = Chat(
        name: chatName,
        members: chatters,
        messagesText: [initialMessage],
        messagesSender: [currentUsername],
        messages: [Message(sender: currentUsername, message: initialMessage)]
      );

      // Save to Firestore
      final docRef = FirebaseFirestore.instance.collection('chats').doc(chatName);
      await docRef.set(newChat.toFirestore());

      // Update local chats list
      currentChats.add(newChat);

      // Update UI
      notifyListeners();
      
      return newChat;

    } catch (e) {
      print('Error creating borrow request chat: $e');
      notifyListeners();
      rethrow;
    }
  }
}