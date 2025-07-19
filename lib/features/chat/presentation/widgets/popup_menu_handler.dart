import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../../providers/chat_provider.dart';

class ChatPopupMenu {
  static OverlayEntry? _overlayEntry;
  static late AnimationController _popupAnimationController;
  static late Animation<double> _popupScaleAnimation;

  static void show(
      BuildContext context,
      Offset position,
      String chatId,
      String messageId,
      String text,
      String sender,
      TextEditingController inputController,
      TickerProvider vsync,
      ) {
    FocusScope.of(context).unfocus();
    remove();

    final screenSize = MediaQuery.of(context).size;
    const double menuWidth = 220;
    const double menuHeight = 370;
    final bool showAbove = (position.dy + menuHeight) > screenSize.height;
    final double dx = (position.dx + menuWidth > screenSize.width)
        ? screenSize.width - menuWidth - 16
        : position.dx;
    final double dy = showAbove
        ? position.dy - menuHeight - 10
        : position.dy + 10;

    _popupAnimationController = AnimationController(
      vsync: vsync,
      duration: const Duration(milliseconds: 300),
    );
    _popupScaleAnimation = CurvedAnimation(
      parent: _popupAnimationController,
      curve: Curves.easeOutBack,
    );

    _overlayEntry = OverlayEntry(
      builder: (_) => Stack(
        children: [
          GestureDetector(
            onTap: remove,
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
                        _item(Icons.reply, 'Ответить', () {
                          inputController.text = '@$sender: $text\n';
                          inputController.selection = TextSelection.fromPosition(
                            TextPosition(offset: inputController.text.length),
                          );
                          remove();
                        }),
                        _item(Icons.forward, 'Переслать', remove),
                        _item(Icons.copy, 'Копировать', () {
                          Clipboard.setData(ClipboardData(text: text));
                          remove();
                        }),
                        _item(Icons.edit, 'Редактировать', () {
                          remove();
                          _showEditDialog(context, chatId, messageId, text);
                        }),
                        _item(Icons.star_border, 'В избранное', remove),
                        _item(Icons.push_pin_outlined, 'Закрепить', remove),
                        _item(Icons.warning_amber_rounded, 'Пожаловаться', remove),
                        const Divider(color: Colors.white12),
                        _item(Icons.delete, 'Удалить', () async {
                          await context.read<ChatProvider>().removeMessage(chatId, messageId);
                          remove();
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

  static void remove() {
    if (_overlayEntry != null) {
      _popupAnimationController.reverse().then((_) {
        _overlayEntry?.remove();
        _overlayEntry = null;
      });
    }
  }

  static Widget _item(IconData icon, String label, VoidCallback onTap, {Color color = Colors.white}) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(label, style: TextStyle(color: color)),
      onTap: onTap,
    );
  }

  static void _showEditDialog(BuildContext context, String chatId, String messageId, String oldText) {
    final editController = TextEditingController(text: oldText);

    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Редактировать сообщение', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              TextField(
                controller: editController,
                style: const TextStyle(color: Colors.white),
                maxLines: null,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white10,
                  hintText: 'Введите новое сообщение...',
                  hintStyle: const TextStyle(color: Colors.white38),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.white24),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.lightBlueAccent),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Отмена', style: TextStyle(color: Colors.white54)),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                    onPressed: () async {
                      final newText = editController.text.trim();
                      if (newText.isNotEmpty) {
                        Navigator.pop(context);
                        await context.read<ChatProvider>().editMessage(chatId, messageId, newText);
                      }
                    },
                    child: const Text('Сохранить', style: TextStyle(color: Colors.black)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}