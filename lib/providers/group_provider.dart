import 'package:flutter/material.dart';

import '../features/group/data/group_service.dart';
import '../features/group/domain/group_chat_model.dart';
import '../features/group/domain/group_message_model.dart';

class GroupChatProvider extends ChangeNotifier {
  final _service = GroupChatService();
  List<GroupChat> _groups = [];
  List<GroupMessage> _messages = [];

  List<GroupChat> get groups => _groups;
  List<GroupMessage> get messages => _messages;

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
    await _service.sendGroupMessage(groupId, msg);
  }

  void listenToMessages(String groupId) {
    _service.getGroupMessages(groupId).listen((msgs) {
      _messages = msgs;
      notifyListeners();
    });
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

  Future<String?> findUserId(String username) {
    return _service.getUserIdByUsername(username);
  }

  Future<void> removeMember(String groupId, String username) async {
    await _service.removeUserFromGroup(groupId, username);

    final groupIndex = _groups.indexWhere((g) => g.groupId == groupId);
    if (groupIndex != -1) {
      _groups[groupIndex].participants.remove(username);
      notifyListeners();
    }
  }

  Future<void> deleteGroup(String groupId) async {
    await _service.deleteGroupChat(groupId);
    _groups.removeWhere((g) => g.groupId == groupId);
    notifyListeners();
  }

}