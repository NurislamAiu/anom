import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:provider/provider.dart';
import 'package:iconsax/iconsax.dart';
import '../../../providers/group_provider.dart';
import 'add_group_members_screen.dart';

class GroupInfoScreen extends StatelessWidget {
  final String groupId;

  const GroupInfoScreen({super.key, required this.groupId});

  @override
  Widget build(BuildContext context) {
    final group = context.read<GroupChatProvider>().groups
        .firstWhere((g) => g.groupId == groupId);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          'Информация',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Group avatar
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

            // Group name
            Text(
              group.groupName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),

            // Participants
            Text(
              'Участники: ${group.participants.length}',
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 24),

            // Buttons section
            _buildActionTile(
              context,
              icon: Iconsax.user_add,
              label: 'Добавить участников',
              onTap: () {
                context.push('/group_add/${group.groupId}');
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
              onTap: () {
                _showEncryptionPicker(context);
              },
            ),
            _buildActionTile(
              context,
              icon: group.isPinned ? Iconsax.tick_circle : Iconsax.activity,
              label: group.isPinned ? 'Открепить группу' : 'Закрепить группу',
              onTap: () async {
                _showSnack(context, group.isPinned ? 'Группа откреплена' : 'Группа закреплена');
                context.pop();
                await context.read<GroupChatProvider>().togglePinned(group.groupId);
              },
            ),
          ],
        ),
      ),
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.grey[850],
        behavior: SnackBarBehavior.floating,
      ),
    );
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
              padding: EdgeInsets.symmetric(vertical: 16,horizontal: 16),
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
}