import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class BlockProvider extends ChangeNotifier {
  final _firestore = FirebaseFirestore.instance;
  final String? currentUser;

  final Set<String> _blockedUsers = {};
  bool _isInitialized = false;

  BlockProvider(this.currentUser) {
    _init();
  }

  BlockProvider.loading() : currentUser = null;

  Set<String> get blockedUsers => _blockedUsers;
  bool get isInitialized => _isInitialized;

  Future<void> _init() async {
    if (currentUser == null || currentUser!.isEmpty) return;

    final snapshot = await _firestore
        .collection('blocked')
        .doc(currentUser)
        .collection('blockedUsers')
        .get();

    _blockedUsers.clear();
    for (final doc in snapshot.docs) {
      _blockedUsers.add(doc.id);
    }

    _isInitialized = true;
    notifyListeners();
  }

  bool isBlocked(String targetUser) => _blockedUsers.contains(targetUser);

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