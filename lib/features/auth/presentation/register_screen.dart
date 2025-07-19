import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:provider/provider.dart';

import '../../../../providers/auth_provider.dart';
import '../../../../l10n/app_localizations.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmController = TextEditingController();

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
              Text(t.createAccount, style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              Text(t.joinSubtitle, style: const TextStyle(color: Colors.white70, fontSize: 14)),
              const SizedBox(height: 32),

              _buildTextField(controller: usernameController, hint: t.username),
              const SizedBox(height: 16),
              _buildTextField(controller: emailController, hint: t.email, type: TextInputType.emailAddress),
              const SizedBox(height: 16),
              _buildTextField(controller: passwordController, hint: t.password, obscure: true),
              const SizedBox(height: 16),
              _buildTextField(controller: confirmController, hint: t.confirmPassword, obscure: true),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.greenAccent[700],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: isLoading ? null : () => _onRegisterPressed(auth, t),
                  child: isLoading
                      ? const SizedBox(
                    height: 24,
                    child: LoadingIndicator(
                      indicatorType: Indicator.ballPulse,
                      colors: [Colors.white],
                      strokeWidth: 2,
                    ),
                  )
                      : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.person_add_alt_1),
                      const SizedBox(width: 8),
                      Text(t.register),
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
                onPressed: () => context.go('/login'),
                child: Text(t.alreadyHaveAccount, style: const TextStyle(color: Colors.white70)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    TextInputType type = TextInputType.text,
    bool obscure = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      keyboardType: type,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white54),
        filled: true,
        fillColor: Colors.grey[900],
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _onRegisterPressed(AuthProvider auth, AppLocalizations t) async {
    setState(() {
      error = '';
      isLoading = true;
    });

    final username = usernameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text;
    final confirm = confirmController.text;

    if (username.isEmpty || email.isEmpty || password.isEmpty || confirm.isEmpty) {
      setState(() {
        error = t.fillAllFields;
        isLoading = false;
      });
      return;
    }

    if (password.length < 8) {
      setState(() {
        error = t.passwordTooShort;
        isLoading = false;
      });
      return;
    }

    if (password != confirm) {
      setState(() {
        error = t.passwordsDontMatch;
        isLoading = false;
      });
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.grey[900],
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        contentTextStyle: const TextStyle(color: Colors.white70, fontSize: 15),
        title: Text(t.confirmEmailTitle),
        content: Text(t.confirmEmailDesc(email)),
        actions: [
          TextButton(
            child: Text(t.cancel, style: const TextStyle(color: Colors.white60)),
            onPressed: () => Navigator.pop(context, false),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.greenAccent[700]),
            child: Text(t.confirm, style: const TextStyle(color: Colors.black)),
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );

    if (confirmed != true) {
      setState(() => isLoading = false);
      return;
    }

    final msg = await auth.register(username: username, email: email, password: password);

    if (msg == null) {
      setState(() => isLoading = false);
      await showDialog(
        context: context,
        builder: (_) => AlertDialog(
          backgroundColor: Colors.grey[900],
          titleTextStyle: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          contentTextStyle: const TextStyle(color: Colors.white70, fontSize: 15),
          title: Text(t.emailSent),
          content: Text(t.emailSentDesc(email)),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.greenAccent[700]),
              child: Text(t.ok, style: const TextStyle(color: Colors.black)),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      );
      context.go('/login');
    } else {
      setState(() {
        error = msg;
        isLoading = false;
      });
    }
  }
}