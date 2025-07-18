import 'package:anom/providers/block_provider.dart';
import 'package:anom/providers/chat_provider.dart';
import 'package:anom/providers/group_provider.dart';
import 'package:anom/providers/presence_provider.dart';
import 'package:anom/providers/profile_provider.dart';
import 'package:anom/providers/user_cache_provider.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/app.dart';
import 'providers/auth_provider.dart';
import 'providers/search_provider.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final prefs = await SharedPreferences.getInstance();
  final seenOnboarding = prefs.getBool('seenOnboarding') ?? false;

  final authProvider = AuthProvider();
  await authProvider.loadSession();
  final profileProvider = ProfileProvider();
  if (authProvider.username != null) {
    await profileProvider.loadProfile(authProvider.username!);
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
        ChangeNotifierProvider<SearchProvider>(create: (_) => SearchProvider()),
        ChangeNotifierProvider<ChatProvider>(create: (_) => ChatProvider()),
        ChangeNotifierProvider<ProfileProvider>(create: (_) => profileProvider),
        ChangeNotifierProvider<GroupChatProvider>(
          create: (_) => GroupChatProvider(),
        ),
        ChangeNotifierProxyProvider<AuthProvider, BlockProvider>(
          create: (_) => BlockProvider.loading(),
          update: (_, auth, previous) {
            final username = auth.username;
            if (username == null || username.isEmpty) return previous!;
            return BlockProvider(username);
          },
        ),
        ChangeNotifierProvider(create: (_) => UserCacheProvider()),
        ChangeNotifierProvider(
          create: (_) => PresenceProvider(authProvider.username),
        ),
      ],
      child: MyApp(showOnboarding: !seenOnboarding),
    ),
  );
}
