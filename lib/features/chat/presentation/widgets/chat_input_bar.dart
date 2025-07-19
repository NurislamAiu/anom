import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class ChatInputBar extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  final bool isBlocked;

  const ChatInputBar({
    super.key,
    required this.controller,
    required this.onSend,
    required this.isBlocked,
  });

  @override
  Widget build(BuildContext context) {
    if (isBlocked) return const SizedBox();

    return Padding(
      padding: const EdgeInsets.only(left: 12, top: 10, right: 12, bottom: 30),
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
                onSubmitted: (_) => onSend(),
              ),
            ),
          ),
          const SizedBox(width: 6),
          IconButton(
            icon: const Icon(Iconsax.send_2, color: Colors.white),
            onPressed: onSend,
          ),
        ],
      ),
    );
  }
}