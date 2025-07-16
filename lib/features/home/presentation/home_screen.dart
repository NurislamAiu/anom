import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../../providers/auth_provider.dart';
import '../../../../providers/chat_provider.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    final username = context.read<AuthProvider>().username;
    if (username != null) {
      context.read<ChatProvider>().loadUserChats(username);
    }
  }

  @override
  Widget build(BuildContext context) {
    final chats = context.watch<ChatProvider>().userChats;
    final username = context.read<AuthProvider>().username ?? '';

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          'ANOM',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),

        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: GestureDetector(
              onTap: () => context.go('/profile'),
              child: const CircleAvatar(
                radius: 26,
                backgroundColor: Colors.white10,
                child: Icon(Icons.person, color: Colors.white70),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/search'),
        backgroundColor: Colors.white,
        child: const Icon(Icons.search, color: Colors.black),
      ),
      body: chats.isEmpty
          ? const Center(
        child: Text(
          '🔒 No secure chats yet',
          style: TextStyle(color: Colors.grey),
        ),
      )
          : ListView.builder(
        itemCount: chats.length,
        itemBuilder: (_, i) {
          final chat = chats[i];
          final participants = chat['participants'] as List<String>;
          final chatWith = participants.firstWhere((u) => u != username);
          final lastMessage = chat['lastMessage'] ?? '';
          final updatedAt = chat['updatedAt'] as DateTime?;

          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 6,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              leading: CircleAvatar(
                radius: 24,
                backgroundColor: Colors.white12,
                child: Text(
                  chatWith[0].toUpperCase(),
                  style: const TextStyle(fontSize: 20, color: Colors.white),
                ),
              ),
              title: Text(
                chatWith,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  lastMessage,
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    updatedAt != null ? DateFormat.Hm().format(updatedAt) : '',
                    style: const TextStyle(color: Colors.white54, fontSize: 11),
                  ),
                ],
              ),
              onTap: () => context.go('/chat/${chat['chatId']}'),
            ),
          );
        },
      ),
    );
  }
}