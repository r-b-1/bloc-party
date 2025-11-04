import 'package:blocparty/model/chat_model.dart';
import 'package:blocparty/model/message_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:blocparty/model/auth_model.dart';

class MessagingModel extends ChangeNotifier {
  List<Chat>? currentChats;
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
      final QuerySnapshot<Map<String, dynamic>> snapshot =
          await FirebaseFirestore.instance.collection('chats').get();
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
}