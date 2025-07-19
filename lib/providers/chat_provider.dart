import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../features/chat/data/chat_service.dart';
import '../features/chat/domain/chat_model.dart';

class ChatProvider extends ChangeNotifier {
  final ChatService _chatService = ChatService();

  List<ChatMessage> _messages = [];

  List<ChatMessage> get messages => _messages;

  List<Map<String, dynamic>> _userChats = [];

  List<Map<String, dynamic>> get userChats => _userChats;

  Stream<List<ChatMessage>>? _messageStream;

  Stream<List<ChatMessage>>? get messageStream => _messageStream;

  StreamSubscription<List<Map<String, dynamic>>>? _chatStreamSub;

  final Map<String, bool> _verificityCache = {};

  void startChatListListener(String username) {
    _chatStreamSub?.cancel();
    _chatStreamSub = _chatService.streamUserChats(username).listen((data) {
      _userChats = data;
      _userChats.sort((a, b) {
        final aPinned = a['pinned'] == true ? 0 : 1;
        final bPinned = b['pinned'] == true ? 0 : 1;
        return aPinned.compareTo(bPinned);
      });
      notifyListeners();
    });
  }

  void disposeChatStream() {
    _chatStreamSub?.cancel();
  }

  void startListening(String chatId, String currentUser) {
    _messageStream = _chatService.getMessages(chatId);
    _messageStream!.listen((data) {
      _messages = data;

      for (final msg in data) {
        if (msg.sender != currentUser &&
            msg.status != 'delivered' &&
            msg.status != 'read') {
          _chatService.updateMessageStatus(
            chatId: chatId,
            messageId: msg.id,
            currentUser: currentUser,
            newStatus: 'delivered',
          );
        }
      }

      notifyListeners();
    });
  }

  Future<void> sendMessage({
    required String chatId,
    required String sender,
    required String text,
  }) async {
    final msg = ChatMessage(
      id: '',
      sender: sender,
      text: text,
      timestamp: DateTime.now(),
      status: 'sent',
    );

    await _chatService.sendMessage(chatId, msg);
   
  }

  Future<void> sendMediaMessage({
    required String chatId,
    required String sender,
    required String mediaPath,
    required String mediaType,
  }) async {
    final docRef = FirebaseFirestore.instance
        .collection('messages')
        .doc(chatId)
        .collection('messages')
        .doc();

    final msg = ChatMessage(
      id: docRef.id,
      sender: sender,
      text: '',
      timestamp: DateTime.now(),
      status: 'sent',
      localMediaPath: mediaPath,
      mediaType: mediaType,
    );

    await docRef.set(msg.toJson());

    _messages.add(msg);
    notifyListeners();
  }

  Future<void> markMessagesAsRead(String chatId, String currentUser) async {
    for (final msg in _messages) {
      if (msg.status != 'read' && msg.sender != currentUser) {
        await _chatService.updateMessageStatus(
          chatId: chatId,
          messageId: msg.id,
          currentUser: currentUser,
          newStatus: 'read',
        );
      }
    }

    await FirebaseFirestore.instance.collection('chats').doc(chatId).update({
      'unreadBy': FieldValue.arrayRemove([currentUser]),
    });

    notifyListeners();
  }

  @Deprecated('Use startChatListListener instead')
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

  Future<bool> isUserVerified(String username) async {
    if (_verificityCache.containsKey(username)) {
      return _verificityCache[username]!;
    }

    final isVerified = await _chatService.isUserVerified(username);
    _verificityCache[username] = isVerified;
    return isVerified;
  }

  Future<void> editMessage(
    String chatId,
    String messageId,
    String newText,
  ) async {
    await _chatService.updateMessage(chatId, messageId, newText);
  }

  Future<void> removeMessage(String chatId, String messageId) async {
    await _chatService.deleteMessage(chatId, messageId);
  }

  void clear() {
    _messages = [];
    notifyListeners();
  }

  @override
  void dispose() {
    disposeChatStream();
    super.dispose();
  }
}
