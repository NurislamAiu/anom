import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/register_screen.dart';
import '../../features/chat/presentation/chat_screen.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/onboarding/onboarding_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/search/presentation/search_screen.dart';
import '../../providers/auth_provider.dart';

class AppRouter {
  static GoRouter router(BuildContext context, bool showOnboarding) {
    final auth = Provider.of<AuthProvider>(context, listen: true);

    return GoRouter(
      initialLocation: showOnboarding ? '/onboarding' : '/login',
      refreshListenable: auth,
      redirect: (context, state) {
        final auth = Provider.of<AuthProvider>(context, listen: false);
        final isLoggedIn = auth.isLoggedIn;
        final isLoggingIn = state.uri.toString() == '/login';
        final isRegistering = state.uri.toString() == '/register';
        final isOnboarding = state.uri.toString() == '/onboarding';

        // Если ещё не авторизован — можно показать login/register/onboarding
        if (!isLoggedIn && !isLoggingIn && !isRegistering && !isOnboarding) {
          return '/login';
        }

        // Если уже вошёл — не показываем login/register/onboarding
        if (isLoggedIn && (isLoggingIn || isRegistering || isOnboarding)) {
          return '/home';
        }

        return null;
      },
      routes: [
        GoRoute(
          path: '/onboarding',
          builder: (context, state) => const OnboardingScreen(),
        ),
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
        GoRoute(
          path: '/search',
          builder: (context, state) => const SearchScreen(),
        ),
        GoRoute(
          path: '/profile',
          builder: (context, state) => const ProfileScreen(),
        ),
        GoRoute(
          path: '/chat/:chatId',
          name: 'chat',
          builder: (context, state) {
            final chatId = state.pathParameters['chatId']!;
            return ChatScreen(chatId: chatId);
          },
        ),
      ],
    );
  }
}