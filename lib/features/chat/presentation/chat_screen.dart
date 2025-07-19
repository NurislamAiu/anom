import 'package:anom/features/chat/presentation/widgets/chat_app_bar.dart';
import 'package:anom/features/chat/presentation/widgets/popup_menu_handler.dart';

import 'package:flutter/material.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../providers/auth_provider.dart';
import '../../../../providers/chat_provider.dart';
import '../../../providers/block_provider.dart';

class ChatScreen extends StatefulWidget {
  final String chatId;

  const ChatScreen({super.key, required this.chatId});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {
  final controller = TextEditingController();
  final scrollController = ScrollController();
  late String currentUser;

  @override
  void initState() {
    super.initState();
    currentUser = context.read<AuthProvider>().username!;
    final chatId = widget.chatId;
    context.read<ChatProvider>().startListening(chatId, currentUser);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChatProvider>().markMessagesAsRead(chatId, currentUser);
    });
  }

  @override
  void dispose() {
    controller.dispose();
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final messages = context.watch<ChatProvider>().messages;
    final isBlocked = context.watch<BlockProvider>().isBlocked(
      widget.chatId.split('_').firstWhere((u) => u != currentUser),
    );

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
            child: messages.isEmpty
                ? const Center(
                    child: SizedBox(
                      width: 60,
                      height: 60,
                      child: LoadingIndicator(
                        indicatorType: Indicator.ballSpinFadeLoader,
                        colors: [Colors.white],
                        strokeWidth: 2,
                      ),
                    ),
                  )
                : ListView.builder(
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
                        child: GestureDetector(
                          onLongPressStart: isMe
                              ? (details) => ChatPopupMenu.show(
                                  context,
                                  details.globalPosition,
                                  widget.chatId,
                                  msg.id,
                                  msg.text,
                                  msg.sender,
                                  controller,
                                  this,
                                )
                              : null,
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
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Text(
                                      DateFormat.Hm().format(msg.timestamp),
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: isMe
                                            ? Colors.grey[600]
                                            : Colors.grey[400],
                                      ),
                                    ),
                                    if (isMe) ...[
                                      const SizedBox(width: 4),
                                      AnimatedSwitcher(
                                        duration: const Duration(
                                          milliseconds: 300,
                                        ),
                                        child: _getStatusIcon(msg.status),
                                        transitionBuilder: (child, animation) {
                                          return ScaleTransition(
                                            scale: animation,
                                            child: child,
                                          );
                                        },
                                      ),
                                    ],
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
          _buildInputBar(isBlocked),
        ],
      ),
    );
  }

  Widget _buildInputBar(bool isBlocked) {
    if (isBlocked) return const SizedBox();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Iconsax.image, color: Colors.white70),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Iconsax.video, color: Colors.white70),
            onPressed: () {},
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
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
          ),
          const SizedBox(width: 6),
          IconButton(
            icon: const Icon(Iconsax.send_2, color: Colors.white),
            onPressed: _sendMessage,
          ),
        ],
      ),
    );
  }

  Future<void> _sendMessage() async {
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

  Icon _getStatusIcon(String status) {
    switch (status) {
      case 'read':
        return const Icon(
          Icons.done_all,
          color: Colors.lightBlueAccent,
          size: 18,
        );
      case 'delivered':
        return const Icon(Icons.done_all, color: Colors.grey, size: 18);
      case 'sent':
      default:
        return const Icon(Icons.check, color: Colors.grey, size: 18);
    }
  }
}
