import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:provider/provider.dart';
import '../../../../providers/auth_provider.dart';

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

    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/logo.png', height: MediaQuery.of(context).size.height * 0.12),
              const Text(
                'Create Account',
                style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              const Text(
                'Join the most secure messenger',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
              const SizedBox(height: 32),

              _buildTextField(controller: usernameController, hint: 'Username'),
              const SizedBox(height: 16),
              _buildTextField(controller: emailController, hint: 'Email', type: TextInputType.emailAddress),
              const SizedBox(height: 16),
              _buildTextField(controller: passwordController, hint: 'Password', obscure: true),
              const SizedBox(height: 16),
              _buildTextField(controller: confirmController, hint: 'Confirm Password', obscure: true),
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
                  onPressed: isLoading ? null : () => _onRegisterPressed(auth),
                  child: isLoading
                      ? const SizedBox(
                    height: 24,
                    child: LoadingIndicator(
                      indicatorType: Indicator.ballPulse,
                      colors: [Colors.white],
                      strokeWidth: 2,
                    ),
                  )
                      : const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.person_add_alt_1),
                      SizedBox(width: 8),
                      Text('Register'),
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
                child: const Text('Already have an account? Login', style: TextStyle(color: Colors.white70)),
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

  void _onRegisterPressed(AuthProvider auth) async {
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
        error = 'Please fill in all fields';
        isLoading = false;
      });
      return;
    }

    if (password.length < 8) {
      setState(() {
        error = 'Password must be at least 8 characters';
        isLoading = false;
      });
      return;
    }

    if (password != confirm) {
      setState(() {
        error = 'Passwords do not match';
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
        title: const Text('📧 Confirm Email'),
        content: Text('Do you really want to register with this email?\n\n$email'),
        actions: [
          TextButton(
            child: const Text('Cancel', style: TextStyle(color: Colors.white60)),
            onPressed: () => Navigator.pop(context, false),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.greenAccent[700],
            ),
            child: const Text('Yes, Register', style: TextStyle(color: Colors.black)),
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
      // Успешная регистрация: показываем инструкцию
      setState(() => isLoading = false);
      await showDialog(
        context: context,
        builder: (_) => AlertDialog(
          backgroundColor: Colors.grey[900],
          titleTextStyle: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          contentTextStyle: const TextStyle(color: Colors.white70, fontSize: 15),
          title: const Text('📨 Email Sent'),
          content: Text(
            'A verification email has been sent to:\n\n$email\n\n'
                'Please check your inbox or spam folder before logging in.',
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.greenAccent[700],
              ),
              child: const Text('OK', style: TextStyle(color: Colors.black)),
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