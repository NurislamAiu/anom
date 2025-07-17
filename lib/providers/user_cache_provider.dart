import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class UserCacheProvider extends ChangeNotifier {
  final Map<String, String> _avatarUrls = {};

  String? getAvatar(String username) => _avatarUrls[username];

  Future<void> loadAvatar(String username) async {
    if (_avatarUrls.containsKey(username)) return;

    final query = await FirebaseFirestore.instance
        .collection('users')
        .where('username', isEqualTo: username)
        .limit(1)
        .get();

    if (query.docs.isNotEmpty) {
      final avatar = query.docs.first['avatarUrl'] ?? '';
      _avatarUrls[username] = avatar;
      notifyListeners();
    }
  }
}