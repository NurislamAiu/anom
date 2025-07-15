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
      appBar: AppBar(
        title: Text('Chats ($username)'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => context.go('/search'),
          ),
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              context.go('/profile');
            },
          ),
        ],
      ),
      body: chats.isEmpty
          ? const Center(child: Text('No chats yet'))
          : ListView.builder(
        itemCount: chats.length,
        itemBuilder: (_, i) {
          final chat = chats[i];
          final participants = chat['participants'] as List<String>;
          final chatWith = participants.firstWhere((u) => u != username);
          final lastMessage = chat['lastMessage'] ?? '';
          final updatedAt = chat['updatedAt'] as DateTime?;

          return ListTile(
            title: Text(chatWith),
            subtitle: Text(lastMessage),
            trailing: Text(
              updatedAt != null
                  ? DateFormat.Hm().format(updatedAt)
                  : '',
              style: const TextStyle(fontSize: 12),
            ),
            onTap: () {
              context.go('/chat/${chat['chatId']}');
            },
          );
        },
      ),
    );
  }
}