import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../../../providers/auth_provider.dart';
import '../../../../providers/chat_provider.dart';
import 'package:intl/intl.dart';

import '../../../providers/group_provider.dart';
import '../../../providers/profile_provider.dart';
import '../../../providers/user_cache_provider.dart';
import '../../group/domain/group_chat_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    final username = context.read<AuthProvider>().username;
    if (username != null) {
      context.read<ChatProvider>().loadUserChats(username);
      context.read<GroupChatProvider>().loadUserGroups(username);
    }
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    final chats = context.watch<ChatProvider>().userChats;
    final username = context.read<AuthProvider>().username ?? '';
    final groups = context.watch<GroupChatProvider>().groups;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          'A N O M',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white54,
          tabs: [
            Tab(icon: Icon(Iconsax.chart), text: 'Chats'),
            Tab(icon: Icon(Iconsax.camera), text: 'Stories'),
            Tab(icon: Icon(Iconsax.people), text: 'Groups'),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: GestureDetector(
              onTap: () => context.go('/profile'),
              child: CircleAvatar(
                radius: 26,
                backgroundColor: Colors.white10,
                backgroundImage: context.watch<ProfileProvider>().avatarUrl.isNotEmpty
                    ? NetworkImage(context.watch<ProfileProvider>().avatarUrl)
                    : null,
                child: context.watch<ProfileProvider>().avatarUrl.isEmpty
                    ? const Icon(Icons.person, color: Colors.white70)
                    : null,
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final action = await showModalBottomSheet<String>(
            context: context,
            backgroundColor: Colors.grey[900],
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            builder: (context) {
              return Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      leading: const Icon(Iconsax.user, color: Colors.white),
                      title: const Text(
                        'Найти пользователя',
                        style: TextStyle(color: Colors.white),
                      ),
                      onTap: () {
                        Future.microtask(() => Navigator.pop(context, 'search'));
                      },
                    ),
                    ListTile(
                      leading: const Icon(Iconsax.people, color: Colors.white),
                      title: const Text(
                        'Создать группу',
                        style: TextStyle(color: Colors.white),
                      ),
                      onTap: () {
                        Future.microtask(() => Navigator.pop(context, 'create_group'));
                      },
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              );
            },
          );

          if (action == 'search') {
            context.go('/search');
          } else if (action == 'create_group') {
            _showCreateGroupDialog(context);
          }
        },
        backgroundColor: Colors.white,
        child: const Icon(Icons.add, color: Colors.black),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // --- Chats ---
          chats.isEmpty
              ? const Center(
                  child: Text(
                    'No secure chats yet',
                    style: TextStyle(color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  itemCount: chats.length,
                  itemBuilder: (_, i) {
                    final chat = chats[i];
                    final participants = chat['participants'] as List<String>;
                    final chatWith = participants.firstWhere(
                      (u) => u != username,
                    );
                    final lastMessage = chat['lastMessage'] ?? '';
                    final updatedAt = chat['updatedAt'] as DateTime?;

                    return Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey[900],
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 6,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        leading: FutureBuilder(
                          future: context.read<UserCacheProvider>().loadAvatar(chatWith),
                          builder: (_, __) {
                            final avatar = context.watch<UserCacheProvider>().getAvatar(chatWith);
                            return CircleAvatar(
                              radius: 24,
                              backgroundColor: Colors.white12,
                              backgroundImage: (avatar != null && avatar.isNotEmpty)
                                  ? NetworkImage(avatar)
                                  : null,
                              child: (avatar == null || avatar.isEmpty)
                                  ? Text(
                                chatWith[0].toUpperCase(),
                                style: const TextStyle(fontSize: 20, color: Colors.white),
                              )
                                  : null,
                            );
                          },
                        ),
                        title: Row(
                          children: [
                            Text(
                              chatWith,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            if (chat['pinned'] == true)
                              const Padding(
                                padding: EdgeInsets.only(left: 6),
                                child: Icon(
                                  Iconsax.activity,
                                  size: 16,
                                  color: Colors.white54,
                                ),
                              ),
                          ],
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            lastMessage,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              updatedAt != null
                                  ? DateFormat.Hm().format(updatedAt)
                                  : '',
                              style: const TextStyle(
                                color: Colors.white54,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                        onTap: () => context.go('/chat/${chat['chatId']}'),
                      ),
                    );
                  },
                ),

          // --- Stories  ---
          const Center(
            child: Text(
              'В Разработке',
              style: TextStyle(color: Colors.white54),
            ),
          ),

          // --- Groups ---
          Consumer<GroupChatProvider>(
            builder: (context, groupProvider, _) {
              final groups = groupProvider.groups;
              if (groups.isEmpty) {
                return const Center(
                  child: Text('Групп ещё нет', style: TextStyle(color: Colors.white54)),
                );
              }

              return ListView.builder(
                itemCount: groups.length,
                itemBuilder: (_, i) {
                  final group = groups[i];
                  final isPinned = group.isPinned;

                  return GestureDetector(
                    onTap: () => context.go('/group/${group.groupId}'),
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.grey[900],
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 6,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        leading: CircleAvatar(
                          radius: 24,
                          backgroundColor: Colors.white10,
                          child: Icon(
                            isPinned ? Iconsax.activity : Icons.group,
                            color: isPinned ? Colors.amber : Colors.white70,
                          ),
                        ),
                        title: Text(
                          group.groupName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        subtitle: Text(
                          'Участники: ${group.participants.length}',
                          style: const TextStyle(color: Colors.white60, fontSize: 13),
                        ),
                        trailing: isPinned
                            ? const Icon(Iconsax.activity, color: Colors.amber)
                            : null,
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }


  void _showCreateGroupDialog(BuildContext context) {
    final nameController = TextEditingController();
    bool isLoading = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.6),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              backgroundColor: const Color(0xFF1E1E1E),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Создание группы',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: nameController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white10,
                        hintText: 'Название группы',
                        hintStyle: const TextStyle(color: Colors.white38),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text('Отмена', style: TextStyle(color: Colors.white60)),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          onPressed: isLoading
                              ? null
                              : () async {
                            final name = nameController.text.trim();
                            if (name.isEmpty) return;

                            setState(() => isLoading = true);

                            try {
                              final currentUser = context.read<AuthProvider>().username!;
                              final groupId = const Uuid().v4();
                              final newGroup = GroupChat(
                                groupId: groupId,
                                groupName: name,
                                participants: [currentUser],
                                createdAt: Timestamp.now(),
                              );

                              await context.read<GroupChatProvider>().createGroup(newGroup);

                              if (context.mounted) {
                                Navigator.pop(context);
                                context.go('/group/$groupId');
                              }
                            } catch (_) {
                              setState(() => isLoading = false);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Ошибка при создании группы'),
                                  backgroundColor: Colors.redAccent,
                                ),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: isLoading
                              ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.black,
                            ),
                          )
                              : const Text('Создать'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
