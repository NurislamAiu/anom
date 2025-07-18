// ChatScreen.dart
import 'dart:ui';
import 'package:anom/features/chat/presentation/widgets/chat_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  late AnimationController _popupAnimationController;
  late Animation<double> _popupScaleAnimation;
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();
    currentUser = context.read<AuthProvider>().username ?? 'unknown';
    context.read<ChatProvider>().startListening(widget.chatId, currentUser);

    _popupAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _popupScaleAnimation = CurvedAnimation(
      parent: _popupAnimationController,
      curve: Curves.linearToEaseOut,
    );
  }

  @override
  void dispose() {
    controller.dispose();
    scrollController.dispose();
    _popupAnimationController.dispose();
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
                  Text('Контакт заблокирован', style: TextStyle(color: Colors.redAccent, fontSize: 14)),
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
                  child: GestureDetector(
                    onLongPressStart: isMe
                        ? (details) => _showPopupMenu(context, details.globalPosition, msg.id, msg.text, sender: msg.sender)
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
                        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
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
                            children: [
                              Text(
                                DateFormat.Hm().format(msg.timestamp),
                                style: TextStyle(
                                  fontSize: 11,
                                  color: isMe ? Colors.grey[600] : Colors.grey[400],
                                ),
                              ),
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
          IconButton(icon: const Icon(Iconsax.image, color: Colors.white70), onPressed: () {}),
          IconButton(icon: const Icon(Iconsax.video, color: Colors.white70), onPressed: () {}),
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
    scrollController.animateTo(0, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
  }

  void _showPopupMenu(
      BuildContext context,
      Offset position,
      String messageId,
      String text, {
        required String sender,
      }) {
    _removeOverlay();
    final screenSize = MediaQuery.of(context).size;
    const double menuWidth = 220;
    const double menuHeight = 320;
    final bool showAbove = (position.dy + menuHeight) > screenSize.height;
    final double dx = (position.dx + menuWidth > screenSize.width) ? screenSize.width - menuWidth - 16 : position.dx;
    final double dy = showAbove ? position.dy - menuHeight - 10 : position.dy + 10;

    _overlayEntry = OverlayEntry(
      builder: (_) => Stack(
        children: [
          GestureDetector(
            onTap: _removeOverlay,
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
              child: Container(
                width: screenSize.width,
                height: screenSize.height,
                color: Colors.black45,
              ),
            ),
          ),
          Positioned(
            left: dx,
            top: dy.clamp(16.0, screenSize.height - menuHeight - 16),
            child: Material(
              color: Colors.transparent,
              child: ScaleTransition(
                scale: _popupScaleAnimation,
                child: FadeTransition(
                  opacity: _popupScaleAnimation,
                  child: Container(
                    width: menuWidth,
                    decoration: BoxDecoration(
                      color: Colors.grey[900],
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.25),
                          blurRadius: 12,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _popupItem(Icons.reply, 'Ответить', () {
                          controller.text = '@$sender: $text\n';
                          controller.selection = TextSelection.fromPosition(
                            TextPosition(offset: controller.text.length),
                          );
                          _removeOverlay();
                        }),
                        _popupItem(Icons.forward, 'Переслать', _removeOverlay),
                        _popupItem(Icons.copy, 'Копировать', () {
                          Clipboard.setData(ClipboardData(text: text));
                          _removeOverlay();
                        }),
                        _popupItem(Icons.star_border, 'В избранное', _removeOverlay),
                        _popupItem(Icons.push_pin_outlined, 'Закрепить', _removeOverlay),
                        _popupItem(Icons.warning_amber_rounded, 'Пожаловаться', _removeOverlay),
                        const Divider(color: Colors.white12),
                        _popupItem(Icons.delete, 'Удалить', () async {
                          await context.read<ChatProvider>().removeMessage(widget.chatId, messageId);
                          _removeOverlay();
                        }, color: Colors.redAccent),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
    _popupAnimationController.forward();
  }

  void _removeOverlay() {
    if (_overlayEntry != null) {
      _popupAnimationController.reverse().then((_) {
        _overlayEntry?.remove();
        _overlayEntry = null;
      });
    }
  }

  Widget _popupItem(IconData icon, String text, VoidCallback onTap, {Color color = Colors.white}) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(text, style: TextStyle(color: color)),
      onTap: onTap,
    );
  }
}