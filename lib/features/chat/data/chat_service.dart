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
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => ChatMessage.fromJson(doc.data()))
              .toList(),
        );
  }

  Future<void> sendMessage(String chatId, ChatMessage message) async {
    final messageRef = _db
        .collection('messages')
        .doc(chatId)
        .collection('messages');


    await messageRef.add(message.toJson());


    await _db.collection('chats').doc(chatId).set({
      'lastMessage': message.text,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<List<Map<String, dynamic>>> getUserChats(String username) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('chats')
        .where('participants', arrayContains: username)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      return {
        'chatId': doc.id,
        'lastMessage': data['lastMessage'],
        'updatedAt': (data['updatedAt'] as Timestamp).toDate(),
        'pinned': data['pinned'] ?? false,
        'participants': List<String>.from(data['participants'] ?? []),
      };
    }).toList();
  }

  Future<void> deleteChat(String chatId) async {
    final batch = FirebaseFirestore.instance.batch();

    final messagesRef = FirebaseFirestore.instance
        .collection('messages')
        .doc(chatId)
        .collection('messages');

    final messagesSnapshot = await messagesRef.get();
    for (final doc in messagesSnapshot.docs) {
      batch.delete(doc.reference);
    }

    final chatDoc = FirebaseFirestore.instance.collection('chats').doc(chatId);
    batch.delete(chatDoc);

    final chatMessagesDoc = FirebaseFirestore.instance.collection('messages').doc(chatId);
    batch.delete(chatMessagesDoc);

    await batch.commit();
  }

  Future<void> updateEncryption(String chatId, String algorithm) async {
    await _db.collection('chats').doc(chatId).update({'encryption': algorithm});
  }

  Future<void> togglePinChat(String chatId, bool pinned) async {
    await FirebaseFirestore.instance.collection('chats').doc(chatId).update({
      'pinned': pinned,
    });
  }
}
