import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/register_screen.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../providers/auth_provider.dart';

class AppRouter {
  static GoRouter router(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context, listen: true);

    return GoRouter(
      initialLocation: '/login',
      refreshListenable: auth,
      redirect: (context, state) {
        final auth = Provider.of<AuthProvider>(context, listen: false);
        final isLoggedIn = auth.isLoggedIn;
        final isLoggingIn = state.uri.toString() == '/login';
        final isRegistering = state.uri.toString() == '/register';

        if (!isLoggedIn && !isLoggingIn && !isRegistering) return '/login';
        if (isLoggedIn && (isLoggingIn || isRegistering)) return '/home';
        return null;
      },
      routes: [
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/register',
          builder: (context, state) => const RegisterScreen(),
        ),
        GoRoute(
          path: '/home',
          builder: (context, state) => const HomeScreen(),
        ),
      ],
    );
  }
}