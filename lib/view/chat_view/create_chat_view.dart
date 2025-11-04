import 'package:flutter/material.dart';

class CreateChatView extends StatefulWidget {
  const CreateChatView({super.key});

  @override
  State<CreateChatView> createState() => _CreateChatViewState();
}

class _CreateChatViewState extends State<CreateChatView> {
  final _chatName = TextEditingController();
  final _chatReceiver = TextEditingController();

  void _save() {
    print("Chat created");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create chat')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            TextFormField(
              controller: _chatName,
              decoration: const InputDecoration(labelText: "Chat name"),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a chat name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _chatReceiver,
              decoration: const InputDecoration(labelText: "Chat Recipient"),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a chat recipient';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _save, child: Text("Create Chat")),
          ],
        ),
      ),
    );
  }
}
