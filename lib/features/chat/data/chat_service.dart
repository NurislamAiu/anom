import 'package:cloud_firestore/cloud_firestore.dart';
import '../domain/chat_model.dart';

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
          .map((doc) => ChatMessage.fromJson(doc.data(), doc.id)) // ← передаём doc.id
          .toList(),
    );
  }

  Future<void> sendMessage(String chatId, ChatMessage message) async {
    final docRef = _db
        .collection('messages')
        .doc(chatId)
        .collection('messages')
        .doc(message.id.isEmpty ? null : message.id);

    final docId = docRef.id;

    final msgWithId = ChatMessage(
      id: docId,
      sender: message.sender,
      text: message.text,
      timestamp: message.timestamp,
      status: message.status,
    );

    await docRef.set(msgWithId.toJson());

    await _db.collection('chats').doc(chatId).set({
      'lastMessage': message.text,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> updateMessage(String chatId, String messageId, String newText) async {
    final messageRef = _db
        .collection('messages')
        .doc(chatId)
        .collection('messages')
        .doc(messageId);

    await messageRef.update({
      'text': newText,
      'status': 'edited',
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteMessage(String chatId, String messageId) async {
    final messageRef = _db
        .collection('messages')
        .doc(chatId)
        .collection('messages')
        .doc(messageId);

    await messageRef.delete();
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

    final chatMessagesDoc = FirebaseFirestore.instance
        .collection('messages')
        .doc(chatId);
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

  Future<bool> isUserVerified(String username) async {
    final query = await FirebaseFirestore.instance
        .collection('users')
        .where('username', isEqualTo: username)
        .limit(1)
        .get();

    if (query.docs.isEmpty) return false;

    final data = query.docs.first.data();
    return data['isVerified'] == true;
  }

  Future<DocumentSnapshot?> getUserDocByUsername(String username) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('username', isEqualTo: username)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) return null;
    return snapshot.docs.first;
  }

  Future<void> updateMessageStatus(
    String chatId,
    ChatMessage msg,
    String newStatus,
  ) async {
    final query = await _db
        .collection('messages')
        .doc(chatId)
        .collection('messages')
        .where('timestamp', isEqualTo: msg.timestamp.toIso8601String())
        .where('sender', isEqualTo: msg.sender)
        .limit(1)
        .get();

    if (query.docs.isEmpty) return;

    final docRef = query.docs.first.reference;
    await docRef.update({'status': newStatus});
  }

}
