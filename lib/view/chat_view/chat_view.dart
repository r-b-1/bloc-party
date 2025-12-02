import 'package:blocparty/model/chat_model.dart';
import 'package:blocparty/model/message_model.dart';
import 'package:blocparty/view/navigation/routs.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ChatView extends StatefulWidget {
  final Chat curChat;
  const ChatView({super.key, required this.curChat});

  @override
  State<ChatView> createState() => _chatViewState(curChat);
}

class _chatViewState extends State<ChatView> {
  late ChatModel _chatModel;
  Chat? currChat;
  final _messageText = TextEditingController();

  _chatViewState(Chat curChat) {
    currChat = curChat;
  }

  @override
  void initState() {
    super.initState();
    _chatModel = ChatModel(currChat!);
    _chatModel.addListener(_onViewModelChanged);
    _chatModel.docRef.snapshots().listen((DocumentSnapshot snapshot) {
      _chatModel.updateChat();
    });
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
    _messageText.text = '';
  }

  Widget buildMessage(BuildContext context, Message mes) {
    if (_chatModel.currentUser?.username == mes.sender) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.blue.shade600, width: 3),
              borderRadius: BorderRadius.circular(8),
              color: Colors.blue.shade700,
            ),
            margin: const EdgeInsets.symmetric(vertical: 4),
            padding: const EdgeInsets.all(8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  mes.sender,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  mes.message,
                  style: TextStyle(fontSize: 12, color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      );
    } else {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade600, width: 3),
              borderRadius: BorderRadius.circular(8),
              color: Colors.grey.shade700,
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
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  mes.message,
                  style: TextStyle(fontSize: 12, color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(currChat!.name)),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: ListView(
          children: [
            FloatingActionButton(
              onPressed: _chatModel.leaveChat,
              child: const Text("Permanently Leave Chat"),
            ),
            if (_chatModel.isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(20.0),
                  child: CircularProgressIndicator(),
                ),
              )
            else
              ..._chatModel.currentChat!.messages.map(
                (mes) => buildMessage(context, mes),
              ),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(labelText: "Message"),
              controller: _messageText,
            ),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _sendMessage, child: Icon(Icons.send)),
          ],
        ),
      ),
    );
  }
}
