import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../providers/search_provider.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SearchProvider>();
    final results = provider.results;

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
            if (results.isEmpty)
              const Text('No users found')
            else
              Expanded(
                child: ListView.builder(
                  itemCount: results.length,
                  itemBuilder: (_, i) {
                    final user = results[i];
                    return ListTile(
                      title: Text(user.username),
                      onTap: () {
                        // TODO: начать чат
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Selected: ${user.username}')),
                        );
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