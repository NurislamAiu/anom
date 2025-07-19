import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:iconsax/iconsax.dart';

class ChatInputBar extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  final bool isBlocked;
  final Function(File file, String type) onMediaSelected;

  const ChatInputBar({
    super.key,
    required this.controller,
    required this.onSend,
    required this.isBlocked,
    required this.onMediaSelected,
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
            onPressed: () async {
              final picker = ImagePicker();
              final picked = await picker.pickImage(source: ImageSource.gallery);
              if (picked != null) {
                onMediaSelected(File(picked.path), 'image');
              }
            },
          ),
          IconButton(
            icon: const Icon(Iconsax.video, color: Colors.white70),
            onPressed: () async {
              final result = await FilePicker.platform.pickFiles(
                type: FileType.video,
              );
              if (result != null && result.files.isNotEmpty) {
                final file = File(result.files.first.path!);
                onMediaSelected(file, 'video');
              }
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
                  hintText: 'Введите сообщение...',
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