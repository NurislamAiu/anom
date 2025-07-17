import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ProfileProvider extends ChangeNotifier {
  String _bio = '';
  String _avatarUrl = '';

  String get bio => _bio;
  String get avatarUrl => _avatarUrl;

  /// Загрузка при старте (например, после логина)
  void loadInitialProfile({String? bio, String? avatarUrl}) {
    _bio = bio ?? '';
    _avatarUrl = avatarUrl ?? '';
  }

  Future<void> loadProfile(String username) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('username', isEqualTo: username)
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      final doc = snapshot.docs.first;
      _bio = doc['bio'] ?? '';
      _avatarUrl = doc.data()?['avatarUrl'] ?? '';
      notifyListeners();
    }
  }

  /// Обновление bio по username
  Future<void> updateBio(String username, String newBio) async {
    final query = await FirebaseFirestore.instance
        .collection('users')
        .where('username', isEqualTo: username)
        .limit(1)
        .get();

    if (query.docs.isNotEmpty) {
      final docId = query.docs.first.id;

      await FirebaseFirestore.instance
          .collection('users')
          .doc(docId)
          .update({'bio': newBio});

      _bio = newBio;
      notifyListeners();
    }
  }

  /// Обновление аватара по username (если нужно)
  Future<void> updateAvatar(String username, String newUrl) async {
    final query = await FirebaseFirestore.instance
        .collection('users')
        .where('username', isEqualTo: username)
        .limit(1)
        .get();

    if (query.docs.isNotEmpty) {
      final docId = query.docs.first.id;

      await FirebaseFirestore.instance
          .collection('users')
          .doc(docId)
          .update({'avatarUrl': newUrl});

      _avatarUrl = newUrl;
      notifyListeners();
    }
  }
}