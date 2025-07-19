import 'package:cloud_firestore/cloud_firestore.dart';

class PresenceService {
  final _db = FirebaseFirestore.instance;

  Future<void> setUserOnline(String uid) async {
    await _db.collection('users').doc(uid).update({
      'isOnline': true,
      'lastSeen': FieldValue.serverTimestamp(),
    });
  }

  Future<void> setUserOffline(String uid) async {
    await _db.collection('users').doc(uid).update({
      'isOnline': false,
      'lastSeen': FieldValue.serverTimestamp(),
    });
  }
}