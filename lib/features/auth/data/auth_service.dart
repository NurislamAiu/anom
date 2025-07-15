import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../domain/user_model.dart';

class AuthService {
  final _db = FirebaseFirestore.instance;

  Future<UserModel?> getUser(String username) async {
    final query = await _db
        .collection('users')
        .where('username', isEqualTo: username)
        .get();

    if (query.docs.isEmpty) return null;

    return UserModel.fromJson(query.docs.first.data());
  }

  String hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<bool> isUsernameTaken(String username) async {
    final query = await _db
        .collection('users')
        .where('username', isEqualTo: username)
        .get();
    return query.docs.isNotEmpty;
  }

  Future<void> registerUser(String username, String password) async {
    final passwordHash = hashPassword(password);
    await _db.collection('users').add({
      'username': username,
      'passwordHash': passwordHash,
    });
  }
}