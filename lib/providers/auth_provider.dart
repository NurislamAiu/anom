import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../features/auth/data/auth_service.dart';
import '../features/auth/domain/user_model.dart';

class AuthProvider extends ChangeNotifier {
  static const _key = 'session_token';
  final _storage = const FlutterSecureStorage();
  final _authService = AuthService();

  bool _isLoggedIn = false;
  bool get isLoggedIn => _isLoggedIn;

  String? _username;
  String? get username => _username;

  Future<void> loadSession() async {
    final token = await _storage.read(key: _key);
    if (token != null) {
      _isLoggedIn = true;
      _username = token;
      notifyListeners();
    }
  }

  Future<bool> login(String username, String password) async {
    final user = await _authService.getUser(username);
    if (user == null) return false;

    final hashedInput = _authService.hashPassword(password);
    if (hashedInput == user.passwordHash) {
      _isLoggedIn = true;
      _username = username;
      await _storage.write(key: _key, value: username);
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<String?> register(String username, String password) async {
    final taken = await _authService.isUsernameTaken(username);
    if (taken) return 'Username already taken';

    await _authService.registerUser(username, password);
    return null;
  }

  Future<bool> changePassword(String current, String newPassword) async {
    final user = await _authService.getUser(_username!);
    if (user == null) return false;

    final currentHash = _authService.hashPassword(current);
    if (user.passwordHash != currentHash) return false;

    final newHash = _authService.hashPassword(newPassword);
    await _authService.updateUserPassword(_username!, newHash);
    return true;
  }

  Future<void> logout() async {
    await _storage.delete(key: _key);
    _isLoggedIn = false;
    _username = null;
    notifyListeners();
  }
}