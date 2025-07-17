import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../features/auth/data/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  static const _tokenKey = 'auth_token';
  final _storage = const FlutterSecureStorage();
  final _authService = AuthService();

  String? _username;
  String? get username => _username;

  String _locale = 'ru';
  String get locale => _locale;

  bool _isLoggedIn = false;
  bool get isLoggedIn => _isLoggedIn;

  /// Загрузка сессии при запуске приложения
  Future<void> loadSession() async {
    final token = await _storage.read(key: _tokenKey);
    if (token != null) {
      final user = await _authService.getCurrentUsername();
      if (user != null) {
        _isLoggedIn = true;
        _username = user;
        notifyListeners();
      }
    }
  }

  /// Установка языка
  void setLocale(String langCode) {
    _locale = langCode;
    notifyListeners();
  }

  /// Регистрация пользователя
  Future<String?> register({
    required String username,
    required String email,
    required String password,
  }) async {
    final result = await _authService.registerUser(
      username: username,
      email: email,
      password: password,
    );
    return result;
  }

  /// Вход в систему
  Future<String?> login({
    required String email,
    required String password,
  }) async {
    final error = await _authService.loginUser(
      email: email,
      password: password,
    );

    if (error == null) {
      _username = await _authService.getCurrentUsername();
      _isLoggedIn = true;
      await _storage.write(key: _tokenKey, value: email);
      notifyListeners();
    }

    return error;
  }

  /// Выход из системы
  Future<void> logout() async {
    await _authService.logout();
    await _storage.delete(key: _tokenKey);
    _isLoggedIn = false;
    _username = null;
    notifyListeners();
  }

  /// Проверка подтверждён ли email
  Future<bool> checkEmailVerified() async {
    return await _authService.isEmailVerified();
  }

  /// Повторная отправка письма для подтверждения email
  Future<void> resendEmailVerification() async {
    await _authService.resendEmailVerification();
  }
}