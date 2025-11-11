import 'package:blocparty/model/chat_model.dart';
import 'package:blocparty/model/message_model.dart';
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

  @override
  Widget buildMessage(BuildContext context, Message mes) {
    return ListTile(
      title: Text(mes.sender),
      subtitle: Text(mes.message),
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
            TextField(
              decoration: const InputDecoration(labelText: "Message"),
              controller: _messageText
            ),
            ElevatedButton(onPressed: _sendMessage, child: Text("Send Message")),
            if (_chatModel.isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: CircularProgressIndicator(),
              ),
            )
            else
            ..._chatModel.currentChat!.messages.map((mes) => buildMessage(context, mes)),
          ],
        ),
      ),
    );
  }
}
