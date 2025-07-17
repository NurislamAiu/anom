import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String username;
  final String email;
  final bool isVerified;
  final DateTime createdAt;
  final String bio;
  final String avatarUrl;

  UserModel({
    required this.username,
    required this.email,
    required this.isVerified,
    required this.createdAt,
    required this.bio,
    required this.avatarUrl,
  });

  Map<String, dynamic> toJson() => {
    'username': username,
    'email': email,
    'isVerified': isVerified,
    'createdAt': createdAt.toIso8601String(),
    'bio': bio,
    'avatarUrl': avatarUrl,
  };

  static UserModel fromJson(Map<String, dynamic> json) => UserModel(
    username: json['username'],
    email: json['email'],
    isVerified: json['isVerified'],
    createdAt: (json['createdAt'] as Timestamp).toDate(),
    bio: json['bio'],
    avatarUrl: json['avatarUrl'],
  );
}