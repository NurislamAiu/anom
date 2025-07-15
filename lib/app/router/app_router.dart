import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../providers/auth_provider.dart';

class AppRouter {
  static GoRouter router(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context, listen: true);

    return GoRouter(
      initialLocation: '/login',
      refreshListenable: auth, // ✅ слушаем изменения в AuthProvider
      redirect: (context, state) {
        final isLoggedIn = auth.isLoggedIn;
        final isLoggingIn = state.uri.toString() == '/login';

        if (!isLoggedIn && !isLoggingIn) return '/login';
        if (isLoggedIn && isLoggingIn) return '/home';
        return null;
      },
      routes: [
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/home',
          builder: (context, state) => const HomeScreen(),
        ),
      ],
    );
  }
}