import 'package:blocparty/model/message_model.dart';
import 'package:flutter/material.dart';

class ChatView extends StatelessWidget {
  const ChatView({super.key});

  @override
  Widget buildMessage(BuildContext context, Message message) {
    return ListTile(
      leading: Text(message.timestamp as String),
      title: Text(message.sender.username),
      subtitle: Text(message.message),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chat Name')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: ListView(
          children: [
            ListTile(
              leading: const CircleAvatar(child: Text('EM')),
              title: const Text('Example Messager'),
              subtitle: const Text('This is a message!'),
            ),
            ListTile(
              leading: const CircleAvatar(child: Text('You')),
              title: const Text('You'),
              subtitle: const Text('Wow!'),
            ),
          ],
        ),
      ),
    );
  }
}
