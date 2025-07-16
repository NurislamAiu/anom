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
    _userChats.sort((a, b) {
      final aPinned = a['pinned'] == true ? 0 : 1;
      final bPinned = b['pinned'] == true ? 0 : 1;
      return aPinned.compareTo(bPinned);
    });
    notifyListeners();
  }

  Future<void> deleteChat(String chatId) async {
    await _chatService.deleteChat(chatId);

    _userChats.removeWhere((chat) => chat['chatId'] == chatId);
    notifyListeners();
  }

  Future<void> updateEncryption(String chatId, String algorithm) async {
    await _chatService.updateEncryption(chatId, algorithm);

    final index = _userChats.indexWhere((chat) => chat['chatId'] == chatId);
    if (index != -1) {
      _userChats[index]['encryption'] = algorithm;
      notifyListeners();
    }
  }

  Future<void> togglePin(String chatId, bool pinned) async {
    await _chatService.togglePinChat(chatId, pinned);

    final index = _userChats.indexWhere((c) => c['chatId'] == chatId);
    if (index != -1) {
      _userChats[index]['pinned'] = pinned;
      _userChats.sort((a, b) {
        final aPinned = a['pinned'] == true ? 0 : 1;
        final bPinned = b['pinned'] == true ? 0 : 1;
        return aPinned.compareTo(bPinned);
      });
      notifyListeners();
    }
  }
}