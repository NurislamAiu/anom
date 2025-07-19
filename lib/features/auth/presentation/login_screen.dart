import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../providers/auth_provider.dart';
import '../../../../l10n/app_localizations.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final identifierController = TextEditingController();
  final passwordController = TextEditingController();
  String error = '';
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthProvider>();
    final t = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/logo.png', height: MediaQuery.of(context).size.height * 0.12),
              Text(
                t.welcomeBack,
                style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Text(
                t.loginSubtitle,
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
              const SizedBox(height: 32),

              TextField(
                controller: identifierController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: t.emailOrUsername,
                  labelStyle: const TextStyle(color: Colors.white70),
                  filled: true,
                  fillColor: Colors.grey[900],
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 16),

              TextField(
                controller: passwordController,
                obscureText: true,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: t.password,
                  labelStyle: const TextStyle(color: Colors.white70),
                  filled: true,
                  fillColor: Colors.grey[900],
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),

              const SizedBox(height: 8),

              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: _showForgotPasswordDialog,
                  child: Text(t.forgotPassword, style: const TextStyle(color: Colors.blueAccent)),
                ),
              ),
              const SizedBox(height: 8),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: isLoading
                      ? null
                      : () async {
                    setState(() {
                      isLoading = true;
                      error = '';
                    });

                    final identifier = identifierController.text.trim();
                    final password = passwordController.text.trim();

                    final result = await auth.login(
                      identifier: identifier,
                      password: password,
                    );

                    setState(() => isLoading = false);

                    if (result == null) {
                      context.go('/home');
                    } else {
                      setState(() {
                        error = result;
                      });
                    }
                  },
                  child: isLoading
                      ? const SizedBox(
                    height: 22,
                    child: LoadingIndicator(
                      indicatorType: Indicator.ballPulse,
                      colors: [Colors.white],
                      strokeWidth: 2,
                    ),
                  )
                      : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.login),
                      const SizedBox(width: 8),
                      Text(t.login),
                    ],
                  ),
                ),
              ),

              if (error.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(error, style: const TextStyle(color: Colors.redAccent)),
                ),
              const SizedBox(height: 12),

              TextButton(
                onPressed: () => context.go('/register'),
                child: Text(
                  t.dontHaveAccount,
                  style: const TextStyle(color: Colors.white70),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showForgotPasswordDialog() {
    final t = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text(t.forgotPassword, style: const TextStyle(color: Colors.white)),
        content: Text(
          t.forgotPasswordDialog,
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            child: Text(t.cancel, style: const TextStyle(color: Colors.white60)),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.email, color: Colors.white),
            label: Text(t.contactSupport, style: const TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
            onPressed: () {
              Navigator.pop(context);
              launchUrl(Uri.parse('mailto:Cyberwest.kz@gmail.com?subject=Password Reset Request'));
            },
          ),
        ],
      ),
    );
  }
}