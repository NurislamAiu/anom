import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class BlockProvider extends ChangeNotifier {
  final _firestore = FirebaseFirestore.instance;
  final String? currentUser;

  final Set<String> _blockedUsers = {};
  final Set<String> _blockedByUsers = {};

  bool _isInitialized = false;

  BlockProvider(this.currentUser) {
    _init();
  }

  Set<String> get blockedUsers => _blockedUsers;

  Set<String> get blockedByUsers => _blockedByUsers;

  bool get isInitialized => _isInitialized;

  BlockProvider.loading() : currentUser = null;

  Future<void> _init() async {
    if (currentUser == null || currentUser!.isEmpty) return;

    final myBlocked = await _firestore
        .collection('blocked')
        .doc(currentUser)
        .collection('blockedUsers')
        .get();
    _blockedUsers.clear();
    for (final doc in myBlocked.docs) {
      _blockedUsers.add(doc.id);
    }

    final blockedBy = await _firestore.collection('blocked').get();
    _blockedByUsers.clear();
    for (final userDoc in blockedBy.docs) {
      final blockedList = await _firestore
          .collection('blocked')
          .doc(userDoc.id)
          .collection('blockedUsers')
          .doc(currentUser)
          .get();

      if (blockedList.exists) {
        _blockedByUsers.add(userDoc.id);
      }
    }

    _isInitialized = true;
    notifyListeners();
  }

  bool isBlocked(String targetUser) => _blockedUsers.contains(targetUser);

  bool isBlockedBy(String targetUser) => _blockedByUsers.contains(targetUser);

  bool isChatBlocked(String otherUser) =>
      isBlocked(otherUser) || isBlockedBy(otherUser);

  Future<void> blockUser(String targetUser) async {
    if (currentUser == null) return;

    await _firestore
        .collection('blocked')
        .doc(currentUser)
        .collection('blockedUsers')
        .doc(targetUser)
        .set({"blockedAt": FieldValue.serverTimestamp()});

    _blockedUsers.add(targetUser);
    notifyListeners();
  }

  Future<void> unblockUser(String targetUser) async {
    if (currentUser == null) return;

    await _firestore
        .collection('blocked')
        .doc(currentUser)
        .collection('blockedUsers')
        .doc(targetUser)
        .delete();

    _blockedUsers.remove(targetUser);
    notifyListeners();
  }
}
