import 'package:blocparty/model/chat_model.dart';
import 'package:blocparty/model/message_model.dart';
import 'package:blocparty/model/user_model.dart';
import 'package:flutter/material.dart';

class MessagingModel extends ChangeNotifier {
  Chat? currentChat;
  AddUser? currentUser;
  List<Message>? currentMessages;
}