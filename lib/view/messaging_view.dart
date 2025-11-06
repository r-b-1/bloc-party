import 'package:blocparty/model/chat_model.dart';
import 'package:blocparty/model/login_model/auth_model.dart';
import 'package:blocparty/model/messaging_model.dart';
import 'package:blocparty/view/chat_view/create_chat_view.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MessagesView extends StatefulWidget {
  const MessagesView({super.key});

  @override
  State<MessagesView> createState() => _MessagesViewState();
}

class _MessagesViewState extends State<MessagesView> {
  late MessagingModel _messagingModel;
  late AuthViewModel _authViewModel;

  @override
  void initState() {
    super.initState();
    _authViewModel = AuthViewModel();
    _messagingModel = MessagingModel(_authViewModel);
    _messagingModel.addListener(_onViewModelChanged);
  }

  void _onViewModelChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _messagingModel.removeListener(_onViewModelChanged);
    super.dispose();
  }

  void _navigateToAddChat() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => CreateChatView(messagingModel: _messagingModel,)));
  }

  @override
  Widget buildChatTile(BuildContext context, Chat chat) {
    if(chat.messages.isEmpty) {
      return ListTile(
        leading: CircleAvatar(child: Text(chat.name.characters.first),),
        title: Text(chat.name),
        subtitle: Text("No messages yet..."),
        onTap: () {
          context.push('/chat', extra: chat);
        },
      );
    } else {
      return ListTile(
        leading: CircleAvatar(child: Text(chat.name.characters.first),),
        title: Text(chat.name),
        subtitle: Text(chat.messages.last.sender + ": " + chat.messages.last.message),
        onTap: () {
          context.push('/chat', extra: chat);
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Messages')),
      body: ListView(
        children: [
          ..._messagingModel.currentChats!.map((item) => buildChatTile(context, item)),
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
