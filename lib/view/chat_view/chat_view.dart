import 'package:blocparty/model/chat_model.dart';
import 'package:blocparty/model/message_model.dart';
import 'package:flutter/material.dart';

class ChatView extends StatefulWidget {
  const ChatView({super.key, });

  @override
  State<ChatView> createState() => _chatViewState();
}

class _chatViewState extends State<ChatView> {
  late ChatModel _chatModel;
  late String chatDocID;

  @override
  void initState() {
    super.initState();
    _chatModel = ChatModel(chatDocID);
    _chatModel.addListener(_onViewModelChanged);
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

  @override
  Widget buildMessage(BuildContext context, Message message) {
    return ListTile(
      title: Text(message.sender),
      subtitle: Text(message.message),
      trailing: Text(message.timestamp as String)
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
            ..._chatModel.currentChat!.messages.map((item) => buildMessage(context, item))
          ],
        ),
      ),
    );
  }
}
