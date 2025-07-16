import 'package:cloud_firestore/cloud_firestore.dart';

class GroupChat {
  final String groupId;
  final String groupName;
  final List<String> participants;
  final String? lastMessage;
  final Timestamp createdAt;
  final Timestamp? updatedAt;

  GroupChat({
    required this.groupId,
    required this.groupName,
    required this.participants,
    required this.createdAt,
    this.lastMessage,
    this.updatedAt,
  });

  Map<String, dynamic> toJson() => {
    'groupId': groupId,
    'groupName': groupName,
    'participants': participants,
    'lastMessage': lastMessage,
    'createdAt': createdAt,
    'updatedAt': updatedAt,
  };

  factory GroupChat.fromJson(Map<String, dynamic> json) {
    return GroupChat(
      groupId: json['groupId'],
      groupName: json['groupName'],
      participants: List<String>.from(json['participants']),
      lastMessage: json['lastMessage'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }
}