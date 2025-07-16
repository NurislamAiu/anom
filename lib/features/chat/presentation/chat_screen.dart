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
    final otherUser = widget.chatId.split('_').firstWhere((u) => u != currentUser);
    final blockProvider = context.watch<BlockProvider>();
    final isBlocked = blockProvider.isBlocked(otherUser);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Row(
          children: [
            GestureDetector(
              onTap: () => _showAvatarDialog(context),
              child: const CircleAvatar(
                radius: 16,
                backgroundColor: Colors.white12,
                child: Icon(Icons.person, color: Colors.white, size: 18),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              otherUser,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => context.go('/home'),
        ),
          actions: [
            IconButton(
              onPressed: () {
                // TODO: Звонок
              },
              icon: const Icon(Iconsax.call, color: Colors.white70),
            ),
            Consumer2<BlockProvider, ChatProvider>(
              builder: (context, block, chat, _) {
                final auth = context.read<AuthProvider>();
                final otherUser = widget.chatId.split('_').firstWhere(
                      (u) => u != auth.username,
                );
                final isBlocked = block.isBlocked(otherUser);

                return PopupMenuButton<String>(
                  color: Colors.grey[900],
                  icon: const Icon(Icons.more_vert_outlined, color: Colors.white70),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  onSelected: (value) async {
                    switch (value) {
                      case 'block':
                        await block.blockUser(otherUser);
                        _showActionSnack(context, 'Контакт заблокирован');
                        break;
                      case 'unblock':
                        await block.unblockUser(otherUser);
                        _showActionSnack(context, 'Контакт разблокирован');
                        break;
                      case 'delete':
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            backgroundColor: Colors.grey[900],
                            title: const Text('Удалить чат', style: TextStyle(color: Colors.white)),
                            content: const Text(
                              'Вы уверены, что хотите удалить этот чат?',
                              style: TextStyle(color: Colors.white70),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx, false),
                                child: const Text('Отмена', style: TextStyle(color: Colors.grey)),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(ctx, true),
                                child: const Text('Удалить', style: TextStyle(color: Colors.redAccent)),
                              ),
                            ],
                          ),
                        );

                        if (confirm != true) return;

                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          barrierColor: Colors.black.withOpacity(0.5),
                          builder: (_) => Center(
                            child: Container(
                              width: 70,
                              height: 70,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.grey[900],
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const LoadingIndicator(
                                indicatorType: Indicator.ballSpinFadeLoader,
                                colors: [Colors.white],
                                strokeWidth: 2,
                              ),
                            ),
                          ),
                        );

                        try {
                          await chat.deleteChat(widget.chatId);
                          if (context.mounted) {
                            Navigator.pop(context);
                            context.go('/home');
                          }
                        } catch (e) {
                          Navigator.pop(context);
                          _showActionSnack(context, 'Ошибка при удалении чата');
                        }
                        break;
                      case 'decrypt':
                        final selected = await showModalBottomSheet<String>(
                          context: context,
                          backgroundColor: Colors.grey[900],
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                          ),
                          builder: (context) {
                            final options = ['AES', 'RSA', 'ChaCha20', 'None'];
                            return Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 16),
                                  child: Text(
                                    'Выберите тип расшифровки',
                                    style: TextStyle(color: Colors.white70, fontSize: 16),
                                  ),
                                ),
                                ...options.map((algo) => ListTile(
                                  title: Text(algo, style: const TextStyle(color: Colors.white)),
                                  onTap: () => Navigator.pop(context, algo),
                                )),
                                const SizedBox(height: 16),
                              ],
                            );
                          },
                        );

                        if (selected != null) {
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (_) => Center(
                              child: Container(
                                width: 70,
                                height: 70,
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.grey[900],
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: const LoadingIndicator(
                                  indicatorType: Indicator.ballSpinFadeLoader,
                                  colors: [Colors.white],
                                  strokeWidth: 2,
                                ),
                              ),
                            ),
                          );

                          try {
                            await chat.updateEncryption(widget.chatId, selected);
                            if (context.mounted) {
                              Navigator.pop(context);
                              _showActionSnack(context, 'Алгоритм установлен: $selected');
                            }
                          } catch (e) {
                            Navigator.pop(context);
                            _showActionSnack(context, 'Ошибка при обновлении');
                          }
                        }
                        break;
                      case 'pin':
                        _showActionSnack(context, 'Чат закреплён');
                        // TODO: Логика закрепления
                        break;
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: isBlocked ? 'unblock' : 'block',
                      child: Text(
                        isBlocked ? 'Разблокировать контакт' : 'Заблокировать контакт',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Text(
                        'Удалить чат',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'decrypt',
                      child: Text(
                        'Изменить расшифровку',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'pin',
                      child: Text(
                        'Закрепить чат',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                );
              },
            ),
          ]
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
                  alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
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

    await context.read<ChatProvider>().sendMessage(
      chatId: widget.chatId,
      sender: currentUser,
      text: text,
    );

    controller.clear();
    scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  void _showAvatarDialog(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Avatar',
      barrierColor: Colors.white.withOpacity(0.2),
      pageBuilder: (context, anim1, anim2) {
        return Center(
          child: Container(
            width: 220,
            height: 220,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey[900],
              border: Border.all(color: Colors.white24, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.6),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: const CircleAvatar(
              radius: 100,
              backgroundColor: Colors.transparent,
              child: Icon(Icons.person, size: 100, color: Colors.white70),
            ),
          ),
        );
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return ScaleTransition(
          scale: CurvedAnimation(parent: anim1, curve: Curves.ease),
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 300),
    );
  }

  void _showActionSnack(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.grey[850],
      ),
    );
  }
}