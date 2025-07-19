import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../features/auth/data/auth_service.dart';
import '../features/group/data/group_service.dart';
import '../features/group/domain/group_chat_model.dart';
import '../features/group/domain/group_message_model.dart';

class GroupChatProvider extends ChangeNotifier {
  final _service = GroupChatService();
  final _authService = AuthService();

  List<GroupChat> _groups = [];
  List<GroupMessage> _messages = [];

  List<GroupChat> get groups => _groups;

  List<GroupMessage> get messages => _messages;

  void listenToMessages(String groupId) {
    _service.getGroupMessages(groupId).listen((msgs) async {
      final currentUser = await _authService.getCurrentUsername();
      final batch = FirebaseFirestore.instance.batch();

      for (final msg in msgs) {
        final docRef = FirebaseFirestore.instance
            .collection('groupChats')
            .doc(groupId)
            .collection('messages')
            .doc(msg.id);

        if (msg.sender != currentUser) {
          if (!msg.deliveredTo.contains(currentUser)) {
            batch.update(docRef, {
              'deliveredTo': FieldValue.arrayUnion([currentUser]),
            });
          }

          if (!msg.readBy.contains(currentUser)) {
            batch.update(docRef, {
              'readBy': FieldValue.arrayUnion([currentUser]),
            });
          }
        }
      }

      await batch.commit();

      _messages = msgs;
      notifyListeners();
    });
  }

  Future<void> loadUserGroups(String username) async {
    _groups = await _service.getUserGroups(username);
    notifyListeners();
  }

  Future<void> createGroup(GroupChat group) async {
    await _service.createGroupChat(group);
    _groups.add(group);
    notifyListeners();
  }

  Future<void> sendMessage(String groupId, GroupMessage msg) async {
    await _service.sendGroupMessage(
      groupId,
      msg.copyWith(deliveredTo: [], readBy: []),
    );
  }

  void clearMessages() {
    _messages = [];
    notifyListeners();
  }

  Future<void> addMember(String groupId, String username) async {
    await _service.addUserToGroup(groupId, username);

    final groupIndex = _groups.indexWhere((g) => g.groupId == groupId);
    if (groupIndex != -1) {
      _groups[groupIndex].participants.add(username);
      notifyListeners();
    }
  }

  Future<void> removeMember(String groupId, String username) async {
    await _service.removeUserFromGroup(groupId, username);

    final groupIndex = _groups.indexWhere((g) => g.groupId == groupId);
    if (groupIndex != -1) {
      _groups[groupIndex].participants.remove(username);
      notifyListeners();
    }
  }

  Future<String?> findUserId(String username) {
    return _service.getUserIdByUsername(username);
  }

  Future<void> deleteGroup(String groupId) async {
    await _service.deleteGroupChat(groupId);
    _groups.removeWhere((g) => g.groupId == groupId);
    notifyListeners();
  }

  Future<void> togglePinned(String groupId) async {
    final index = _groups.indexWhere((g) => g.groupId == groupId);
    if (index != -1) {
      final current = _groups[index];
      final newValue = !current.isPinned;

      await _service.togglePinGroup(groupId, newValue);

      _groups[index] = GroupChat(
        groupId: current.groupId,
        groupName: current.groupName,
        participants: current.participants,
        createdAt: current.createdAt,
        isPinned: newValue,
      );

      notifyListeners();
    }
  }

  Future<void> renameGroup(String groupId, String newName) async {
    final doc = FirebaseFirestore.instance
        .collection('groupChats')
        .doc(groupId);
    await doc.update({'groupName': newName});
    notifyListeners();
  }

  Future<void> markMessageAsDelivered(
    String groupId,
    GroupMessage msg,
    String currentUser,
  ) async {
    if (!msg.deliveredTo.contains(currentUser)) {
      await _service.markMessageDelivered(groupId, msg.id, currentUser);
    }
  }

  Future<void> markMessageAsRead(
    String groupId,
    GroupMessage msg,
    String currentUser,
  ) async {
    if (!msg.readBy.contains(currentUser)) {
      await _service.markMessageRead(groupId, msg.id, currentUser);
    }
  }
}
