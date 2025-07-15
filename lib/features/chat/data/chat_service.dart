import 'package:cloud_firestore/cloud_firestore.dart';
import '../domain/chat_model.dart';
import '../domain/message_model.dart';

class ChatService {
  final _db = FirebaseFirestore.instance;

  String getChatId(String user1, String user2) {
    final sorted = [user1, user2]..sort();
    return '${sorted[0]}_${sorted[1]}';
  }

  Future<bool> chatExists(String chatId) async {
    final doc = await _db.collection('chats').doc(chatId).get();
    return doc.exists;
  }

  Future<void> createChat(String chatId, List<String> participants) async {
    await _db.collection('chats').doc(chatId).set({
      'participants': participants,
      'lastMessage': '',
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<List<ChatMessage>> getMessages(String chatId) {
    return _db
        .collection('messages')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => ChatMessage.fromJson(doc.data()))
        .toList());
  }

  Future<void> sendMessage(String chatId, ChatMessage message) async {
    final messageRef = _db
        .collection('messages')
        .doc(chatId)
        .collection('messages');

    await messageRef.add(message.toJson());

    await _db.collection('chats').doc(chatId).update({
      'lastMessage': message.text,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<List<Map<String, dynamic>>> getUserChats(String username) async {
    final snapshot = await _db
        .collection('chats')
        .where('participants', arrayContains: username)
        .orderBy('updatedAt', descending: true)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      return {
        'chatId': doc.id,
        'lastMessage': data['lastMessage'] ?? '',
        'updatedAt': (data['updatedAt'] as Timestamp?)?.toDate(),
        'participants': List<String>.from(data['participants'] ?? []),
      };
    }).toList();
  }
}