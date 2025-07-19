import 'package:cloud_firestore/cloud_firestore.dart';

class GroupMessage {
  final String id; 
  final String sender;
  final String text;
  final Timestamp timestamp;
  final List<String> deliveredTo;
  final List<String> readBy;

  GroupMessage({
    this.id = '', 
    required this.sender,
    required this.text,
    required this.timestamp,
    this.deliveredTo = const [],
    this.readBy = const [],
  });

  GroupMessage copyWith({
    String? id,
    String? sender,
    String? text,
    Timestamp? timestamp,
    List<String>? deliveredTo,
    List<String>? readBy,
  }) {
    return GroupMessage(
      id: id ?? this.id,
      sender: sender ?? this.sender,
      text: text ?? this.text,
      timestamp: timestamp ?? this.timestamp,
      deliveredTo: deliveredTo ?? this.deliveredTo,
      readBy: readBy ?? this.readBy,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sender': sender,
      'text': text,
      'timestamp': timestamp,
      'deliveredTo': deliveredTo,
      'readBy': readBy,
    };
  }

  factory GroupMessage.fromJson(Map<String, dynamic> json) {
    return GroupMessage(
      sender: json['sender'],
      text: json['text'],
      timestamp: json['timestamp'],
      deliveredTo: List<String>.from(json['deliveredTo'] ?? []),
      readBy: List<String>.from(json['readBy'] ?? []),
    );
  }
}