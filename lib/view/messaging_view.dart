import 'package:flutter/material.dart';

class MessagesView extends StatelessWidget {
  const MessagesView({super.key});

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
              Navigator.pushNamed(context, '/chat');
            },
          ),
          ListTile(
            leading: const CircleAvatar(child: Text('J')),
            title: const Text('Jane Doe'),
            subtitle: const Text('Okay, sounds good.'),
            onTap: () {
               Navigator.pushNamed(context, '/chat');
            },
          ),
        ],
      ),
    );
  }
}
