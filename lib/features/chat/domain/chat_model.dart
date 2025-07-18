import 'package:cloud_firestore/cloud_firestore.dart';

class ChatMessage {
  final String id; // <-- нужно для update/delete
  final String sender;
  final String text;
  final DateTime timestamp;
  final String status; // sent, delivered, read
  final bool edited;

  ChatMessage({
    required this.id,
    required this.sender,
    required this.text,
    required this.timestamp,
    required this.status,
    this.edited = false,
  });

  Map<String, dynamic> toJson() => {
    'sender': sender,
    'text': text,
    'timestamp': timestamp.toIso8601String(),
    'status': status,
    'edited': edited,
  };

  static ChatMessage fromJson(Map<String, dynamic> json, String id) {
    return ChatMessage(
      id: id,
      sender: json['sender'],
      text: json['text'],
      timestamp: (json['timestamp'] is Timestamp)
          ? (json['timestamp'] as Timestamp).toDate()
          : DateTime.tryParse(json['timestamp'] ?? '') ?? DateTime.now(),
      status: json['status'] ?? 'sent',
      edited: json['edited'] ?? false,
    );
  }
}