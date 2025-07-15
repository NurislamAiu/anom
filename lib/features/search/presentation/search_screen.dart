import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../../providers/search_provider.dart';
import '../../../../providers/auth_provider.dart';
import '../../chat/data/chat_service.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final controller = TextEditingController();
  final _chatService = ChatService();

  @override
  Widget build(BuildContext context) {
    final search = context.watch<SearchProvider>();
    final currentUser = context.read<AuthProvider>().username ?? 'guest';

    return Scaffold(
      appBar: AppBar(title: const Text('Search Users')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: 'Enter username...',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {
                    context.read<SearchProvider>().search(controller.text);
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (search.results.isEmpty)
              const Text('No users found')
            else
              Expanded(
                child: ListView.builder(
                  itemCount: search.results.length,
                  itemBuilder: (_, i) {
                    final user = search.results[i];
                    if (user.username == currentUser) return const SizedBox.shrink();

                    return ListTile(
                      title: Text(user.username),
                      onTap: () async {
                        final otherUser = user.username;
                        final chatId = _chatService.getChatId(currentUser, otherUser);
                        final exists = await _chatService.chatExists(chatId);

                        if (!exists) {
                          await _chatService.createChat(chatId, [currentUser, otherUser]);
                        }

                        context.go('/chat/$chatId');
                      },
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}