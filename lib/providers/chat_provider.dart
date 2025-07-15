import 'package:flutter/material.dart';
import '../features/chat/data/chat_service.dart';
import '../features/chat/domain/chat_model.dart';
import '../features/chat/domain/message_model.dart';

class ChatProvider extends ChangeNotifier {
  final ChatService _chatService = ChatService();

  List<ChatMessage> _messages = [];
  List<ChatMessage> get messages => _messages;
  List<Map<String, dynamic>> _userChats = [];
  List<Map<String, dynamic>> get userChats => _userChats;


  Stream<List<ChatMessage>>? _messageStream;
  Stream<List<ChatMessage>>? get messageStream => _messageStream;

  void startListening(String chatId) {
    _messageStream = _chatService.getMessages(chatId);
    _messageStream!.listen((data) {
      _messages = data;
      notifyListeners();
    });
  }

  Future<void> sendMessage({
    required String chatId,
    required String sender,
    required String text,
  }) async {
    final msg = ChatMessage(
      sender: sender,
      text: text,
      timestamp: DateTime.now(),
    );

    await _chatService.sendMessage(chatId, msg);
  }

  void clear() {
    _messages = [];
    notifyListeners();
  }

  Future<void> loadUserChats(String username) async {
    _userChats = await _chatService.getUserChats(username);
    notifyListeners();
  }
}