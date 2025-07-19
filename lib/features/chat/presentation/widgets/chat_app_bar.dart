import 'package:another_flushbar/flushbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';

import '../../../../providers/auth_provider.dart';
import '../../../../providers/block_provider.dart';
import '../../../../providers/chat_provider.dart';
import '../../../../providers/user_cache_provider.dart';

class ChatAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String chatId;
  final VoidCallback onBack;

  const ChatAppBar({super.key, required this.chatId, required this.onBack});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthProvider>();
    final currentUser = auth.username!;
    final otherUser = chatId.split('_').firstWhere((u) => u != currentUser);
    final blockProvider = context.read<BlockProvider>();
    final isBlocked = blockProvider.isBlocked(otherUser);

    return AppBar(
      backgroundColor: Colors.black,
      foregroundColor: Colors.white,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new),
        onPressed: onBack,
      ),
      title: Row(
        children: [
          GestureDetector(
            onTap: () => _showAvatarDialog(context),
            child: FutureBuilder(
              future: context.read<UserCacheProvider>().loadAvatar(otherUser),
              builder: (_, __) {
                final avatar = context.watch<UserCacheProvider>().getAvatar(
                  otherUser,
                );
                return CircleAvatar(
                  radius: 16,
                  backgroundColor: Colors.white12,
                  backgroundImage: (avatar != null && avatar.isNotEmpty)
                      ? NetworkImage(avatar)
                      : null,
                  child: (avatar == null || avatar.isEmpty)
                      ? Text(
                          otherUser.isNotEmpty
                              ? otherUser[0].toUpperCase()
                              : '?',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : null,
                );
              },
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FutureBuilder<bool>(
                future: context.read<ChatProvider>().isUserVerified(otherUser),
                builder: (context, snapshot) {
                  final isVerified = snapshot.data ?? false;
                  return Row(
                    children: [
                      Text(
                        otherUser,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      if (isVerified)
                        const Padding(
                          padding: EdgeInsets.only(left: 4),
                          child: Icon(
                            Icons.verified,
                            color: Colors.red,
                            size: 16,
                          ),
                        ),
                    ],
                  );
                },
              ),
              StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('chats')
                    .doc(chatId)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Text('Offline', style: TextStyle(color: Colors.grey));
                  }

                  final data = snapshot.data!.data() as Map<String, dynamic>?;

                  final isOnline = data?['isOnline'] == true;
                  final lastSeen = (data?['lastSeen'] as Timestamp?)?.toDate();

                  return Text(
                    isOnline
                        ? 'Online'
                        : lastSeen != null
                        ? 'Last seen ${_timeAgo(lastSeen)}'
                        : 'Offline',
                    style: TextStyle(
                      fontSize: 12,
                      color: isOnline ? Colors.greenAccent : Colors.grey,
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Iconsax.call, color: Colors.white70),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Функция в разработке'),
                backgroundColor: Colors.grey[850],
              ),
            );
          },
        ),
        PopupMenuButton<String>(
          color: Colors.grey[900],
          icon: const Icon(Icons.more_vert_outlined, color: Colors.white70),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          onSelected: (value) =>
              _handleAction(context, value, chatId, otherUser),
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
              child: Text('Удалить чат', style: TextStyle(color: Colors.white)),
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
        ),
      ],
    );
  }

  void _showAvatarDialog(BuildContext context) {
    final currentUser = context.read<AuthProvider>().username ?? 'user';
    final otherUser = chatId.split('_').firstWhere((u) => u != currentUser);

    final userCache = Provider.of<UserCacheProvider>(context, listen: false);

    userCache.loadAvatar(otherUser);

    final avatarUrl = userCache.getAvatar(otherUser);

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
            child: CircleAvatar(
              radius: 100,
              backgroundColor: Colors.transparent,
              backgroundImage: (avatarUrl != null && avatarUrl.isNotEmpty)
                  ? NetworkImage(avatarUrl)
                  : null,
              child: (avatarUrl == null || avatarUrl.isEmpty)
                  ? Text(
                      otherUser[0].toUpperCase(),
                      style: const TextStyle(
                        fontSize: 100,
                        color: Colors.white70,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : null,
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

  static String _timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inSeconds < 60) return 'только что';
    if (diff.inMinutes < 60) return '${diff.inMinutes} мин назад';
    if (diff.inHours < 24) return '${diff.inHours} ч назад';
    return '${diff.inDays} дн назад';
  }

  void _handleAction(
    BuildContext context,
    String value,
    String chatId,
    String otherUser,
  ) async {
    final block = context.read<BlockProvider>();
    final chat = context.read<ChatProvider>();

    switch (value) {
      case 'block':
        await block.blockUser(otherUser);
        _showSnack(context, 'Контакт заблокирован');
        break;
      case 'unblock':
        await block.unblockUser(otherUser);
        _showSnack(context, 'Контакт разблокирован');
        break;
      case 'delete':
        final confirm = await _confirmDialog(
          context,
          'Удалить чат',
          'Вы уверены?',
        );
        if (!confirm) return;
        await chat.deleteChat(chatId);
        if (context.mounted) context.go('/home');
        break;
      case 'decrypt':
        final algo = await _chooseDecryption(context);
        if (algo != null) {
          await chat.updateEncryption(chatId, algo);
          _showSnack(context, 'Алгоритм: $algo');
        }
        break;
      case 'pin':
        final isPinned =
            chat.userChats.firstWhere((c) => c['chatId'] == chatId)['pinned'] ==
            true;
        await chat.togglePin(chatId, !isPinned);
        _showSnack(context, isPinned ? 'Чат откреплён' : 'Чат закреплён');
        break;
    }
  }

  void _showSnack(BuildContext context, String text) {
    Flushbar(
      message: text,
      duration: const Duration(seconds: 2),
      flushbarPosition: FlushbarPosition.TOP,
      margin: const EdgeInsets.all(16),
      borderRadius: BorderRadius.circular(8),
      backgroundColor: Colors.green,
    ).show(context);
  }

  Future<bool> _confirmDialog(
    BuildContext context,
    String title,
    String message,
  ) async {
    return await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            backgroundColor: Colors.grey[900],
            title: Text(title, style: const TextStyle(color: Colors.white)),
            content: Text(
              message,
              style: const TextStyle(color: Colors.white70),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Отмена'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Удалить'),
              ),
            ],
          ),
        ) ??
        false;
  }

  Future<String?> _chooseDecryption(BuildContext context) async {
    return await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.grey[900],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        const options = ['AES', 'RSA', 'ChaCha20', 'None'];
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
            ...options.map(
              (algo) => ListTile(
                title: Text(algo, style: const TextStyle(color: Colors.white)),
                onTap: () => Navigator.pop(context, algo),
              ),
            ),
            const SizedBox(height: 16),
          ],
        );
      },
    );
  }
}
