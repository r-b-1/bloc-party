import 'package:blocparty/view/chat_view/create_chat_view.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MessagesView extends StatefulWidget {
  const MessagesView({super.key});

  @override
  State<MessagesView> createState() => _MessagesViewState();
}

class _MessagesViewState extends State<MessagesView> {
  void _navigateToAddChat() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => CreateChatView()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Messages')),
      body: ListView(
        children: [
          ListTile(
            leading: const CircleAvatar(child: Text('N')),
            title: const Text('Neighborhood Group'),
            subtitle: const Text('John: See you there!'),
            onTap: () {
              context.push('/chat');
            },
          ),
          ListTile(
            leading: const CircleAvatar(child: Text('J')),
            title: const Text('John Message'),
            subtitle: const Text('I have a message for you...'),
            onTap: () {
              context.push('/chat');
            },
          ),
          Positioned(
            right: 16,
            bottom: 16,
            child: FloatingActionButton(
              onPressed: _navigateToAddChat,
              child: const Icon(Icons.add),
            ),
          ),
        ],
      ),
    );
  }
}
