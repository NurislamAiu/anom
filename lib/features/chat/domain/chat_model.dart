import 'package:cloud_firestore/cloud_firestore.dart';

class ChatMessage {
  final String id;
  final String sender;
  final String text;
  final DateTime timestamp;
  final String status;
  final bool edited;

  final String? localMediaPath; // 🔥 новое
  final String? mediaType;      // 🔥 новое: 'image' / 'video'

  ChatMessage({
    required this.id,
    required this.sender,
    required this.text,
    required this.timestamp,
    required this.status,
    this.edited = false,
    this.localMediaPath,
    this.mediaType,
  });

  Map<String, dynamic> toJson() => {
    'sender': sender,
    'text': text,
    'timestamp': timestamp.toIso8601String(),
    'status': status,
    'edited': edited,
    'localMediaPath': localMediaPath,
    'mediaType': mediaType,
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
      localMediaPath: json['localMediaPath'],
      mediaType: json['mediaType'],
    );
  }
}