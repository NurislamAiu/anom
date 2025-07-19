import 'package:another_flushbar/flushbar.dart';
import 'package:firebase_auth/firebase_auth.dart';
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

  String? email;

  void setLocale(String langCode) {
    _locale = langCode;
    notifyListeners();
  }

  Future<void> loadSession() async {
    final token = await _storage.read(key: _tokenKey);
    if (token != null) {
      final user = FirebaseAuth.instance.currentUser;
      await user?.reload();
      final refreshedUser = FirebaseAuth.instance.currentUser;

      final isVerified = refreshedUser?.emailVerified ?? false;
      final userEmail = refreshedUser?.email;

      if (isVerified) {
        final userName = await _authService.getCurrentUsername();
        if (userName != null) {
          _username = userName;
          email = userEmail;
          _isLoggedIn = true;
          notifyListeners();
        }
      } else {
        _isLoggedIn = false;
        notifyListeners();
      }
    }
  }

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

    if (result == null) {
      this.email = email;
      _username = username;
      _isLoggedIn = false;
      notifyListeners();
    }

    return result;
  }

  Future<String?> login({
    required String identifier,
    required String password,
  }) async {
    final error = await _authService.loginUser(
      identifier: identifier,
      password: password,
    );

    if (error == null) {
      final user = FirebaseAuth.instance.currentUser;
      await user?.reload();
      final refreshedUser = FirebaseAuth.instance.currentUser;

      final isVerified = refreshedUser?.emailVerified ?? false;

      if (!isVerified) {
        return 'Пожалуйста, подтвердите ваш email перед входом.';
      }

      _username = await _authService.getCurrentUsername();
      email = await _authService.getCurrentEmail();
      _isLoggedIn = true;
      await _storage.write(key: _tokenKey, value: identifier);
      notifyListeners();
    }

    return error;
  }

  Future<void> logout() async {
    await _authService.logout();
    await _storage.delete(key: _tokenKey);
    _isLoggedIn = false;
    _username = null;
    email = null;
    notifyListeners();
  }

  Future<bool> checkEmailVerified() async {
    final user = FirebaseAuth.instance.currentUser;
    await user?.reload();
    return user?.emailVerified ?? false;
  }

  Future<void> resendEmailVerification() async {
    await _authService.resendEmailVerification();
  }

  Future<void> resetPasswordViaEmail(BuildContext context) async {
    if (email == null || email!.isEmpty) {
      Flushbar(
        title: 'No Email Found',
        message: 'Your account is missing an email address.',
        backgroundColor: Colors.red[400]!,
        icon: const Icon(Icons.error_outline, color: Colors.white),
        flushbarPosition: FlushbarPosition.TOP,
        margin: const EdgeInsets.all(16),
        borderRadius: BorderRadius.circular(16),
        duration: const Duration(seconds: 3),
      ).show(context);
      return;
    }

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email!);
      Flushbar(
        title: 'Check Your Email',
        message: 'A password reset link has been sent to $email',
        backgroundColor: Colors.green[600]!,
        icon: const Icon(Icons.email_outlined, color: Colors.white),
        flushbarPosition: FlushbarPosition.TOP,
        margin: const EdgeInsets.all(16),
        borderRadius: BorderRadius.circular(16),
        duration: const Duration(seconds: 4),
      ).show(context);
    } catch (e) {
      Flushbar(
        title: 'Failed to Send Email',
        message: 'Please try again later or contact support.',
        backgroundColor: Colors.red[400]!,
        icon: const Icon(Icons.warning_amber_rounded, color: Colors.white),
        flushbarPosition: FlushbarPosition.TOP,
        margin: const EdgeInsets.all(16),
        borderRadius: BorderRadius.circular(16),
        duration: const Duration(seconds: 4),
      ).show(context);
    }
  }
}