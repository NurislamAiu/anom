import 'package:flutter/material.dart';

class ProfileProvider extends ChangeNotifier {
  String _bio = '';
  String _avatarUrl = '';

  String get bio => _bio;
  String get avatarUrl => _avatarUrl;

  void updateBio(String newBio) {
    _bio = newBio;
    notifyListeners();
  }

  void updateAvatar(String newUrl) {
    _avatarUrl = newUrl;
    notifyListeners();
  }

  void loadInitialProfile({String? bio, String? avatarUrl}) {
    _bio = bio ?? '';
    _avatarUrl = avatarUrl ?? '';
  }
}