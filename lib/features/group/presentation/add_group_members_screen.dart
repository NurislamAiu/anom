import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import '../../../providers/group_provider.dart';

class AddGroupMembersScreen extends StatefulWidget {
  final String groupId;

  const AddGroupMembersScreen({super.key, required this.groupId});

  @override
  State<AddGroupMembersScreen> createState() => _AddGroupMembersScreenState();
}

class _AddGroupMembersScreenState extends State<AddGroupMembersScreen> {
  final TextEditingController _usernameController = TextEditingController();
  String? _foundUsername;
  bool _isLoading = false;

  Future<void> _searchUser() async {
    final input = _usernameController.text.trim();
    if (input.isEmpty) return;

    setState(() {
      _isLoading = true;
      _foundUsername = null;
    });

    final provider = context.read<GroupChatProvider>();
    final userId = await provider.findUserId(input);
    final group = provider.groups.firstWhere((g) => g.groupId == widget.groupId);

    if (userId != null) {
      if (group.participants.contains(input)) {
        _showSnack('Пользователь уже в группе');
      } else {
        setState(() {
          _foundUsername = input;
        });
      }
    } else {
      _showSnack('Пользователь не найден');
    }

    setState(() => _isLoading = false);
  }

  Future<void> _addUser() async {
    if (_foundUsername != null) {
      await context.read<GroupChatProvider>().addMember(widget.groupId, _foundUsername!);
      _showSnack('Добавлен: $_foundUsername');
      _usernameController.clear();
      setState(() {
        _foundUsername = null;
      });
    }
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.grey[850],
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final group = context.watch<GroupChatProvider>().groups
        .firstWhere((g) => g.groupId == widget.groupId);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Добавить участников'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            children: [
              TextField(
                controller: _usernameController,
                onSubmitted: (_) => _searchUser(),
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Введите username',
                  hintStyle: const TextStyle(color: Colors.white54),
                  filled: true,
                  fillColor: Colors.white10,
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.search, color: Colors.white),
                    onPressed: _searchUser,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              if (_isLoading) const CircularProgressIndicator(color: Colors.white),

              if (_foundUsername != null)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.only(top: 8),
                  child: ElevatedButton.icon(
                    onPressed: _addUser,
                    icon: const Icon(Icons.person_add),
                    label: Text('Добавить $_foundUsername'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
                    ),
                  ),
                ),

              const SizedBox(height: 24),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text('Текущие участники:',
                    style: TextStyle(color: Colors.white70, fontSize: 16)),
              ),
              const SizedBox(height: 8),

              // Список участников
              Expanded(
                child: ListView.separated(
                  itemCount: group.participants.length,
                  separatorBuilder: (_, __) => const Divider(color: Colors.white12),
                  itemBuilder: (_, i) {
                    final user = group.participants[i];
                    return ListTile(
                      leading: Icon(Iconsax.user, color: Colors.white54),
                      title: Text(user, style: const TextStyle(color: Colors.white)),
                      trailing: IconButton(
                        icon: const Icon(Iconsax.box_remove, color: Colors.redAccent),
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (_) => AlertDialog(
                              backgroundColor: Colors.white12,
                              title: const Text('Удалить участника?', style: TextStyle(color: Colors.white)),
                              content: Text('Вы уверены, что хотите удалить $user из группы?', style: TextStyle(color: Colors.white),),
                              actions: [
                                TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Отмена',style: TextStyle(color: Colors.white))),
                                TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Удалить', style: TextStyle(color: Colors.white))),
                              ],
                            ),
                          );

                          if (confirm == true) {
                            await context.read<GroupChatProvider>().removeMember(widget.groupId, user);
                            _showSnack('Удален: $user');
                          }
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}