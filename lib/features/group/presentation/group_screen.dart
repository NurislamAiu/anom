import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/group_provider.dart';
import '../domain/group_chat_model.dart';
import '../domain/group_message_model.dart';

class GroupChatScreen extends StatefulWidget {
  final String groupId;

  const GroupChatScreen({super.key, required this.groupId});

  @override
  State<GroupChatScreen> createState() => _GroupChatScreenState();
}

class _GroupChatScreenState extends State<GroupChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    final provider = context.read<GroupChatProvider>();
    provider.listenToMessages(widget.groupId);
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage(String username) async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    final msg = GroupMessage(
      sender: username,
      text: text,
      timestamp: Timestamp.now(),
    );

    _controller.clear();

    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );

    unawaited(
      context.read<GroupChatProvider>().sendMessage(widget.groupId, msg),
    );
  }

  @override
  Widget build(BuildContext context) {
    final messages = context.watch<GroupChatProvider>().messages;
    final currentUser = context.read<AuthProvider>().username ?? '';

    final group = context.read<GroupChatProvider>().groups.firstWhere(
      (g) => g.groupId == widget.groupId,
      orElse: () => GroupChat(
        groupId: widget.groupId,
        groupName: 'Групповой чат (не найден)',
        participants: [],
        isPinned: false,
        createdAt: Timestamp.now(),
      ),
    );

    if (group == null) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Text(
            'Группа не найдена или была удалена',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: GestureDetector(
          onTap: () => context.push('/group_info/${widget.groupId}'),
          child: Text(
            group.groupName,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        leading: IconButton(
          onPressed: () => context.go('/home'),
          icon: const Icon(Icons.arrow_back_ios),
        ),
        actions: [IconButton(onPressed: () {}, icon: const Icon(Iconsax.call))],
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              reverse: true,
              itemCount: messages.length,
              itemBuilder: (_, i) {
                final msg = messages[i];
                final isMe = msg.sender == currentUser;

                return Align(
                  alignment: isMe
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isMe ? Colors.blueGrey : Colors.grey[800],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: isMe
                          ? CrossAxisAlignment.end
                          : CrossAxisAlignment.start,
                      children: [
                        Text(
                          msg.sender,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: Colors.white54,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          msg.text,
                          style: const TextStyle(color: Colors.white),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              DateFormat.Hm().format(msg.timestamp.toDate()),
                              style: const TextStyle(
                                fontSize: 10,
                                color: Colors.white38,
                              ),
                            ),
                            if (isMe) ...[
                              const SizedBox(width: 6),
                              Icon(
                                msg.readBy.length > 1
                                    ? Icons.done_all
                                    : Icons.done,
                                size: 16,
                                color: msg.readBy.length > 1
                                    ? Colors.blueAccent
                                    : Colors.white38,
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          Padding(
            padding: const EdgeInsets.only(
              left: 12,
              top: 10,
              right: 12,
              bottom: 30,
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Iconsax.image, color: Colors.white70),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Отправка фото (в разработке)'),
                      ),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Iconsax.video, color: Colors.white70),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Отправка видео (в разработке)'),
                      ),
                    );
                  },
                ),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white24),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: TextField(
                      controller: _controller,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        hintText: 'Введите сообщение...',
                        hintStyle: TextStyle(color: Colors.white38),
                        border: InputBorder.none,
                      ),
                      onSubmitted: (_) => _sendMessage(currentUser),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                IconButton(
                  icon: const Icon(Iconsax.send_2, color: Colors.white),
                  onPressed: () => _sendMessage(currentUser),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
