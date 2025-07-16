import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:iconsax/iconsax.dart';
import '../../../providers/group_provider.dart';

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
                  image: AssetImage('assets/group_placeholder.png'),
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
                _showSnack(context, 'Добавление участников (в разработке)');
              },
            ),
            _buildActionTile(
              context,
              icon: Iconsax.trash,
              label: 'Удалить группу',
              onTap: () {
                _showSnack(context, 'Удаление группы (в разработке)');
              },
            ),
            _buildActionTile(
              context,
              icon: Iconsax.shield,
              label: 'Тип шифрования: AES-256',
              onTap: () {
                _showSnack(context, 'Шифрование: AES-256 (муляж)');
              },
            ),
            _buildActionTile(
              context,
              icon: Iconsax.activity,
              label: 'Закрепить группу',
              onTap: () {
                _showSnack(context, 'Закрепление (в разработке)');
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
}