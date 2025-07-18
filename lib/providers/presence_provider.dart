import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../core/utils/lifecycle_event_handler.dart';

class PresenceProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String? username;
  late final LifecycleEventHandler _lifecycleHandler;

  PresenceProvider(this.username) {
    if (username != null) {
      _setOnline();
      _setupLifecycleTracking();
    }
  }

  Future<DocumentSnapshot?> _getUserDocByUsername(String username) async {
    final snapshot = await _firestore
        .collection('users')
        .where('username', isEqualTo: username)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) return null;
    return snapshot.docs.first;
  }

  Future<void> _setOnline() async {
    if (username == null) return;
    final doc = await _getUserDocByUsername(username!);
    if (doc == null) return;
    final userId = doc.id;

    print('Setting ONLINE for $username');
    await _firestore.collection('users').doc(userId).update({
      'isOnline': true,
      'lastSeen': FieldValue.serverTimestamp(),
    });
  }

  Future<void> _goOffline() async {
    if (username == null) return;
    final doc = await _getUserDocByUsername(username!);
    if (doc == null) return;
    final userId = doc.id;

    print('Setting OFFLINE for $username');
    await _firestore.collection('users').doc(userId).update({
      'isOnline': false,
      'lastSeen': FieldValue.serverTimestamp(),
    });
  }

  void _setupLifecycleTracking() {
    _lifecycleHandler = LifecycleEventHandler(
      onPaused: _goOffline,
      onDetached: _goOffline,
    );
    WidgetsBinding.instance.addObserver(_lifecycleHandler);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(_lifecycleHandler);
    super.dispose();
  }

  Future<String?> getUserIdPublic(String username) async {
    final doc = await _getUserDocByUsername(username);
    return doc?.id;
  }
}