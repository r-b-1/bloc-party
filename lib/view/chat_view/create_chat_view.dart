import 'package:blocparty/model/messaging_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/material.dart';
import 'package:blocparty/model/login_model/user_model.dart';

class CreateChatView extends StatefulWidget {
  final MessagingModel messagingModel;

  const CreateChatView({super.key, required this.messagingModel});

  @override
  State<CreateChatView> createState() => _CreateChatViewState();
}

class _CreateChatViewState extends State<CreateChatView> {
  final _chatName = TextEditingController();
  final _chatRecipeients = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  AddUser? _currentUser;

  Future<void> _submitItem() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Parse tags from comma-separated string
      List<String> chatters = _chatRecipeients.text.split(',').map((tag) => tag.trim()).where((tag) => tag.isNotEmpty).toList();

      final authUser = auth.FirebaseAuth.instance.currentUser;
      if (authUser == null) {
        throw Exception('No user logged in');
      }

      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(authUser.uid)
          .get();

      if (!userDoc.exists) {
        throw Exception('User document not found');
      }

      _currentUser = AddUser.fromFirestore(userDoc);
      chatters.add(_currentUser!.username);

      final QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore.instance.collection('chats').where('name', isEqualTo: _chatName.text).get();
      if (snapshot.docs.isNotEmpty) {
        throw Exception('Same name as another chat');
      }

      await widget.messagingModel.addChat(
        name: _chatName.text,
        chatters: chatters
      );

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Item added successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to add item: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create chat')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _chatName,
                decoration: const InputDecoration(labelText: "Chat name (must be unique across the platform)"),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a chat name';
                 }
                  return null;
                },
              ) ,
              const SizedBox(height: 16),
              TextFormField(
                controller: _chatRecipeients,
                decoration: const InputDecoration(labelText: "Chat Recipient"),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a chat recipients comma seperated (eg. John, Dale)';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              ElevatedButton(onPressed: _submitItem, child: Text("Create Chat")),
            ],
          ),
        ),
      )
    );
  }
}
