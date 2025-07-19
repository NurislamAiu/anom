import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:anom/features/chat/presentation/widgets/popup_menu_handler.dart';

class ChatMessageBubble extends StatelessWidget {
  final dynamic msg;
  final bool isMe;
  final String chatId;
  final TextEditingController controller;
  final TickerProvider vsync;

  const ChatMessageBubble({
    super.key,
    required this.msg,
    required this.isMe,
    required this.chatId,
    required this.controller,
    required this.vsync,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: GestureDetector(
        onLongPressStart: isMe
            ? (details) => ChatPopupMenu.show(
          context,
          details.globalPosition,
          chatId,
          msg.id,
          msg.text,
          msg.sender,
          controller,
          vsync,
        )
            : null,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
          padding: const EdgeInsets.all(12),
          constraints: const BoxConstraints(maxWidth: 300),
          decoration: BoxDecoration(
            color: isMe ? Colors.white : Colors.grey[900],
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
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
                      color: isMe ? Colors.grey[600] : Colors.grey[400],
                    ),
                  ),
                  if (isMe) ...[
                    const SizedBox(width: 4),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: _getStatusIcon(msg.status),
                      transitionBuilder: (child, animation) {
                        return ScaleTransition(scale: animation, child: child);
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
  }

  Icon _getStatusIcon(String status) {
    switch (status) {
      case 'read':
        return const Icon(Icons.done_all, color: Colors.lightBlueAccent, size: 18);
      case 'delivered':
        return const Icon(Icons.done_all, color: Colors.grey, size: 18);
      case 'sent':
      default:
        return const Icon(Icons.check, color: Colors.grey, size: 18);
    }
  }
}