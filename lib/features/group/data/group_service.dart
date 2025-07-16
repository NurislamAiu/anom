import 'package:cloud_firestore/cloud_firestore.dart';

import '../domain/group_chat_model.dart';
import '../domain/group_message_model.dart';

class GroupChatService {
  final _db = FirebaseFirestore.instance;

  Future<void> createGroupChat(GroupChat group) async {
    await _db.collection('groupChats').doc(group.groupId).set(group.toJson());
  }

  Future<void> sendGroupMessage(String groupId, GroupMessage message) async {
    await _db
        .collection('groupChats')
        .doc(groupId)
        .collection('messages')
        .add(message.toJson());

    await _db.collection('groupChats').doc(groupId).update({
      'lastMessage': message.text,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<List<GroupMessage>> getGroupMessages(String groupId) {
    return _db
        .collection('groupChats')
        .doc(groupId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) =>
        snapshot.docs.map((doc) => GroupMessage.fromJson(doc.data())).toList());
  }

  Future<List<GroupChat>> getUserGroups(String username) async {
    final snapshot = await _db
        .collection('groupChats')
        .where('participants', arrayContains: username)
        .get();

    return snapshot.docs
        .map((doc) => GroupChat.fromJson(doc.data()))
        .toList();
  }

  Future<void> deleteGroup(String groupId) async {
    final messages = await _db
        .collection('groupChats')
        .doc(groupId)
        .collection('messages')
        .get();

    for (var doc in messages.docs) {
      await doc.reference.delete();
    }

    await _db.collection('groupChats').doc(groupId).delete();
  }

  Future<void> addUserToGroup(String groupId, String username) async {
    final groupRef = FirebaseFirestore.instance.collection('groupChats').doc(groupId);
    await groupRef.update({
      'participants': FieldValue.arrayUnion([username])
    });
  }

  Future<String?> getUserIdByUsername(String username) async {
    final query = await FirebaseFirestore.instance
        .collection('users')
        .where('username', isEqualTo: username)
        .limit(1)
        .get();

    if (query.docs.isEmpty) return null;

    return query.docs.first.id;
  }

  Future<void> removeUserFromGroup(String groupId, String username) async {
    final docRef = _db.collection('groupChats').doc(groupId);
    await docRef.update({
      'participants': FieldValue.arrayRemove([username]),
    });
  }

  Future<void> deleteGroupChat(String groupId) async {
    await _db.collection('groupChats').doc(groupId).delete();
  }

  Future<void> togglePinGroup(String groupId, bool value) async {
    await _db.collection('groupChats').doc(groupId).update({
      'isPinned': value,
    });
  }
}