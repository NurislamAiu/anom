import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:provider/provider.dart';
import 'package:iconsax/iconsax.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:another_flushbar/flushbar.dart';

import '../../../providers/group_provider.dart';

class GroupInfoScreen extends StatelessWidget {
  final String groupId;

  const GroupInfoScreen({super.key, required this.groupId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('groupChats').doc(groupId).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Scaffold(
            backgroundColor: Colors.black,
            body: Center(child: buildLoadingIndicator()),
          );
        }

        final rawData = snapshot.data!.data();
        if (rawData == null) {
          return const Scaffold(
            backgroundColor: Colors.black,
            body: Center(
              child: Text('Группа не найдена', style: TextStyle(color: Colors.white)),
            ),
          );
        }
        final data = rawData as Map<String, dynamic>;
        final groupName = data['groupName'] ?? 'Группа';
        final participants = List<String>.from(data['participants'] ?? []);
        final isPinned = data['isPinned'] ?? false;

        return Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            title: const Text(
              'Информация',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Iconsax.edit, color: Colors.white),
                onPressed: () => _showRenameDialog(context, groupId, groupName),
                tooltip: 'Переименовать',
              ),
            ],
            centerTitle: true,
            elevation: 0,
            foregroundColor: Colors.white,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white24, width: 2),
                    image: const DecorationImage(
                      image: AssetImage('assets/icon.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  groupName,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Участники: ${participants.length}',
                  style: const TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 24),
                _buildActionTile(
                  context,
                  icon: Iconsax.user_add,
                  label: 'Добавить участников',
                  onTap: () {
                    context.push('/group_add/$groupId');
                  },
                ),
                _buildActionTile(
                  context,
                  icon: Iconsax.trash,
                  label: 'Удалить группу',
                  onTap: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (_) => AlertDialog(
                        backgroundColor: Colors.grey[900],
                        title: const Text('Удалить группу?', style: TextStyle(color: Colors.white)),
                        content: const Text('Вы уверены, что хотите удалить эту группу?', style: TextStyle(color: Colors.white70)),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Отмена', style: TextStyle(color: Colors.grey)),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text('Удалить', style: TextStyle(color: Colors.redAccent)),
                          ),
                        ],
                      ),
                    );

                    if (confirm == true) {
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (_) => Dialog(
                          backgroundColor: Colors.transparent,
                          elevation: 0,
                          child: buildLoadingIndicator(),
                        ),
                      );

                      await context.read<GroupChatProvider>().deleteGroup(groupId);

                      if (context.mounted) {
                        Navigator.pop(context);
                        context.go('/home');
                      }
                    }
                  },
                ),
                _buildActionTile(
                  context,
                  icon: Iconsax.shield,
                  label: 'Тип шифрования: AES-256',
                  onTap: () => _showEncryptionPicker(context),
                ),
                _buildActionTile(
                  context,
                  icon: isPinned ? Iconsax.tick_circle : Iconsax.activity,
                  label: isPinned ? 'Открепить группу' : 'Закрепить группу',
                  onTap: () async {
                    _showSnack(context, isPinned ? 'Группа откреплена' : 'Группа закреплена');
                    context.pop();
                    await context.read<GroupChatProvider>().togglePinned(groupId);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildActionTile(
      BuildContext context, {
        required IconData icon,
        required String label,
        required VoidCallback onTap,
      }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        splashColor: Colors.white10,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white10,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              Icon(icon, color: Colors.white, size: 22),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.white54),
            ],
          ),
        ),
      ),
    );
  }

  void _showSnack(BuildContext context, String message) {
    Flushbar(
      message: message,
      backgroundColor: Colors.grey[850]!,
      duration: const Duration(seconds: 2),
      margin: const EdgeInsets.all(16),
      borderRadius: BorderRadius.circular(8),
      flushbarPosition: FlushbarPosition.TOP,
    ).show(context);
  }

  Widget buildLoadingIndicator() {
    return Center(
      child: SizedBox(
        height: 60,
        width: 60,
        child: const LoadingIndicator(
          indicatorType: Indicator.ballSpinFadeLoader,
          colors: [Colors.white],
          strokeWidth: 2,
          backgroundColor: Colors.transparent,
        ),
      ),
    );
  }

  void _showEncryptionPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              child: Text(
                'Выберите тип шифрования',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            _buildEncryptionOption(context, Icons.lock, 'AES-256'),
            _buildEncryptionOption(context, Icons.vpn_key, 'RSA'),
            _buildEncryptionOption(context, Icons.security, 'ECC'),
            _buildEncryptionOption(context, Icons.cancel, 'None'),
            const SizedBox(height: 16),
          ],
        );
      },
    );
  }

  Widget _buildEncryptionOption(BuildContext context, IconData icon, String label) {
    return ListTile(
      title: Text(label, style: const TextStyle(color: Colors.white)),
      onTap: () {
        Navigator.pop(context);
        _showSnack(context, 'Вы выбрали: $label');
      },
    );
  }

  void _showRenameDialog(BuildContext context, String groupId, String currentName) {
    final controller = TextEditingController(text: currentName);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.grey[900],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: Text(
                  'Переименовать группу',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                style: const TextStyle(color: Colors.white),
                cursorColor: Colors.white,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white10,
                  hintText: 'Введите новое название',
                  hintStyle: const TextStyle(color: Colors.white),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.white24),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Отмена', style: TextStyle(color: Colors.white54)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () async {
                        final newName = controller.text.trim();
                        if (newName.isNotEmpty) {
                          Navigator.pop(context);
                          await context.read<GroupChatProvider>().renameGroup(groupId, newName);
                          _showSnack(context, 'Название обновлено');
                        }
                      },
                      child: const Text('Сохранить', style: TextStyle(color: Colors.black)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
