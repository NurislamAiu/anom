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
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => context.go('/home'),
        ),
        title: const Text(
          '🔍 Search Users',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: controller,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey[900],
                hintText: 'Enter username...',
                hintStyle: const TextStyle(color: Colors.white54),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search, color: Colors.white),
                  onPressed: () {
                    context.read<SearchProvider>().search(controller.text);
                  },
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.white24),
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.white),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (search.results.isEmpty)
              const Text(
                'No users found',
                style: TextStyle(color: Colors.white54),
              )
            else
              Expanded(
                child: ListView.builder(
                  itemCount: search.results.length,
                  itemBuilder: (_, i) {
                    final user = search.results[i];
                    if (user.username == currentUser) return const SizedBox.shrink();

                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.grey[900],
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.white10),
                      ),
                      child: ListTile(
                        title: Text(
                          user.username,
                          style: const TextStyle(color: Colors.white),
                        ),
                        trailing: const Icon(Icons.message, color: Colors.white70),
                        onTap: () async {
                          final otherUser = user.username;
                          final chatId = _chatService.getChatId(currentUser, otherUser);
                          final exists = await _chatService.chatExists(chatId);

                          if (!exists) {
                            await _chatService.createChat(chatId, [currentUser, otherUser]);
                          }

                          context.go('/chat/$chatId');
                        },
                      ),
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