import 'package:flutter/material.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';

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
    final searchProvider = context.watch<SearchProvider>();
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
          'Поиск пользователей',
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
              onSubmitted: (value) => _searchUser(context),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey[900],
                hintText: 'Введите username...',
                hintStyle: const TextStyle(color: Colors.white54),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search, color: Colors.white),
                  onPressed: () => _searchUser(context),
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


            
            if (searchProvider.isLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: SizedBox(
                  height: 60,
                  width: 60,
                  child: LoadingIndicator(
                    indicatorType: Indicator.ballSpinFadeLoader,
                    colors: [Colors.white],
                    strokeWidth: 2,
                  ),
                ),
              ),

            
            if (!searchProvider.isLoading && searchProvider.results.isEmpty)
              const Text(
                'Пользователи не найдены',
                style: TextStyle(color: Colors.white54),
              ),

            
            if (searchProvider.results.isNotEmpty)
              Expanded(
                child: ListView.builder(
                  itemCount: searchProvider.results.length,
                  itemBuilder: (_, i) {
                    final user = searchProvider.results[i];
                    if (user.username == currentUser) return const SizedBox.shrink();

                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.grey[900],
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.white10),
                      ),
                      child: ListTile(
                        leading: const Icon(Iconsax.user, color: Colors.white),
                        title: Text(
                          user.username,
                          style: const TextStyle(color: Colors.white),
                        ),
                        trailing: const Icon(Iconsax.message, color: Colors.white70),
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

  void _searchUser(BuildContext context) {
    final query = controller.text.trim();
    if (query.isEmpty) return;

    context.read<SearchProvider>().search(query);
  }
}