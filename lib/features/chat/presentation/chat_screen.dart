import 'package:anom/features/chat/presentation/widgets/chat_app_bar.dart';
import 'package:anom/features/chat/presentation/widgets/chat_message_bubble.dart';
import 'package:anom/features/chat/presentation/widgets/chat_input_bar.dart';
import 'package:flutter/material.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../../../providers/auth_provider.dart';
import '../../../../providers/chat_provider.dart';
import '../../../providers/block_provider.dart';
import '../../../providers/search_provider.dart';

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
      context.read<SearchProvider>().clear();
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

                return ChatMessageBubble(
                  msg: msg,
                  isMe: isMe,
                  chatId: widget.chatId,
                  controller: controller,
                  vsync: this,
                );
              },
            ),
          ),
          ChatInputBar(
            controller: controller,
            isBlocked: isBlocked,
            onSend: _sendMessage,
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
}