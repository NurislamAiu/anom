import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthProvider extends ChangeNotifier {
  static const _key = 'session_token';
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  bool _isLoggedIn = false;
  bool get isLoggedIn => _isLoggedIn;


  Future<void> loadSession() async {
    final token = await _storage.read(key: _key);
    _isLoggedIn = token != null;
    debugPrint('[AuthProvider] Loaded session: $_isLoggedIn');
    notifyListeners();
  }

  Future<void> login(String username, String password) async {

    await _storage.write(key: _key, value: 'mock_token');
    _isLoggedIn = true;
    debugPrint('[AuthProvider] Logged in');
    notifyListeners();
  }


  Future<void> logout() async {
    await _storage.delete(key: _key);
    _isLoggedIn = false;
    debugPrint('[AuthProvider] Logged out');
    notifyListeners();
  }
}