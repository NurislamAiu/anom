import 'package:anom/features/chat/presentation/widgets/chat_app_bar.dart';
import 'package:another_flushbar/flushbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../providers/chat_provider.dart';
import '../../../../providers/auth_provider.dart';
import '../../../providers/block_provider.dart';
import '../../../providers/presence_provider.dart';
import '../../../providers/user_cache_provider.dart';
import '../data/chat_service.dart';

class ChatScreen extends StatefulWidget {
  final String chatId;

  const ChatScreen({super.key, required this.chatId});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final controller = TextEditingController();
  final scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    context.read<ChatProvider>().startListening(widget.chatId);
  }

  @override
  void dispose() {
    controller.dispose();
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final chatProvider = context.watch<ChatProvider>();
    final currentUser = context.read<AuthProvider>().username ?? 'unknown';
    final messages = chatProvider.messages;
    final otherUser = widget.chatId
        .split('_')
        .firstWhere((u) => u != currentUser);
    final blockProvider = context.watch<BlockProvider>();
    final isBlocked = blockProvider.isBlocked(otherUser);
    final presence = context.read<PresenceProvider>();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: ChatAppBar(
        chatId: widget.chatId,
        onBack: () => context.go('/home'),
      ),
      body: Column(
        children: [
          if (isBlocked)
            Container(
              color: Colors.red.withOpacity(0.1),
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.block, color: Colors.redAccent, size: 18),
                  SizedBox(width: 8),
                  Text(
                    'Контакт заблокирован',
                    style: TextStyle(color: Colors.redAccent, fontSize: 14),
                  ),
                ],
              ),
            ),
          Expanded(
            child: ListView.builder(
              controller: scrollController,
              reverse: true,
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final msg = messages[messages.length - 1 - index];
                final isMe = msg.sender == currentUser;

                return Align(
                  alignment: isMe
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                      vertical: 4,
                      horizontal: 10,
                    ),
                    padding: const EdgeInsets.all(12),
                    constraints: const BoxConstraints(maxWidth: 300),
                    decoration: BoxDecoration(
                      color: isMe ? Colors.white : Colors.grey[900],
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: isMe
                          ? CrossAxisAlignment.end
                          : CrossAxisAlignment.start,
                      children: [
                        Text(
                          msg.text,
                          style: TextStyle(
                            color: isMe ? Colors.black : Colors.white,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          DateFormat.Hm().format(msg.timestamp),
                          style: TextStyle(
                            fontSize: 11,
                            color: isMe ? Colors.grey[600] : Colors.grey[400],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const Divider(height: 1, color: Colors.white12),

          // Поле ввода сообщений:
          if (!isBlocked)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Iconsax.health, color: Colors.white70),
                    onPressed: () {
                      // TODO: отправка фото
                    },
                  ),
                  IconButton(
                    icon: const Icon(Iconsax.video, color: Colors.white70),
                    onPressed: () {
                      // TODO: отправка видео
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
                        controller: controller,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          hintText: 'Type a message...',
                          hintStyle: TextStyle(color: Colors.white38),
                          border: InputBorder.none,
                        ),
                        onSubmitted: (_) => _sendMessage(currentUser),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  IconButton(
                    icon: const Icon(Iconsax.send1, color: Colors.white),
                    onPressed: () => _sendMessage(currentUser),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _sendMessage(String currentUser) async {
    final text = controller.text.trim();
    if (text.isEmpty) return;

    controller.clear();

    await context.read<ChatProvider>().sendMessage(
      chatId: widget.chatId,
      sender: currentUser,
      text: text,
    );

    scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }



}
