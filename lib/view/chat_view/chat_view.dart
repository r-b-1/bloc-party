import 'package:blocparty/model/chat_model.dart';
import 'package:blocparty/model/login_model/user_model.dart';
import 'package:blocparty/model/message_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/material.dart';

class ChatView extends StatefulWidget {
  final Chat curChat;
  const ChatView({super.key, required this.curChat});

  @override
  State<ChatView> createState() => _chatViewState(curChat);
}

class _chatViewState extends State<ChatView> {
  late ChatModel _chatModel;
  Chat ?currChat;
  final _messageText = TextEditingController();

  _chatViewState(Chat curChat) {
    currChat = curChat;
  }

  @override
  void initState() {
    super.initState();
    _chatModel = ChatModel(currChat!);
    _chatModel.addListener(_onViewModelChanged);
    _chatModel.docRef.snapshots().listen((DocumentSnapshot snapshot) {_chatModel.updateChat();});
  }

  void _onViewModelChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _chatModel.removeListener(_onViewModelChanged);
    super.dispose();
  }

  Future<void> _sendMessage() async {
    await _chatModel.addMessage(_messageText.text);
  }

  Future<AddUser> _getCurrentUser() async {
    final authUser = auth.FirebaseAuth.instance.currentUser;
    if (authUser == null) {
      throw Exception('No user logged in');
    }
    final userDoc = await FirebaseFirestore.instance.collection('users').doc(authUser.uid).get();
    if (!userDoc.exists) {
      throw Exception('User document not found');
    }
    return AddUser.fromFirestore(userDoc);
  }


  Widget buildMessage(BuildContext context, Message mes) {
  final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,

      
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [ 
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey, width: 1),
            borderRadius: BorderRadius.circular(8),
            color: theme.primaryColorLight,
          ),
          margin: const EdgeInsets.symmetric(vertical: 4),
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                mes.sender,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(mes.message),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(currChat!.name)),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: ListView(
          children: [
            if (_chatModel.isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: CircularProgressIndicator(),
              ),
            )
            else
            ..._chatModel.currentChat!.messages.map((mes) => buildMessage(context, mes)),
            const SizedBox(height: 16,),
            TextField(
              decoration: const InputDecoration(labelText: "Message"),
              controller: _messageText
            ),
            const SizedBox(height: 16,),
            ElevatedButton(onPressed: _sendMessage, child: Text("Send Message")),
          ],
        ),
      ),
    );
  }
}
