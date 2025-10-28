import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MessagesView extends StatelessWidget {
  const MessagesView({super.key});

  void _navigateToAddChat() {
    print("add chat");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
      ),
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
            title: const Text('Jane Doe'),
            subtitle: const Text('Okay, sounds good.'),
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
