import 'package:cloud_firestore/cloud_firestore.dart';

class GroupMessage {
  final String sender;
  final String text;
  final Timestamp timestamp;

  GroupMessage({
    required this.sender,
    required this.text,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
    'sender': sender,
    'text': text,
    'timestamp': timestamp,
  };

  factory GroupMessage.fromJson(Map<String, dynamic> json) {
    return GroupMessage(
      sender: json['sender'],
      text: json['text'],
      timestamp: json['timestamp'],
    );
  }
}