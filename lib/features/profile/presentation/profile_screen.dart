import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../providers/auth_provider.dart';
import '../../../l10n/app_localizations.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final username = auth.username ?? 'Unknown';
    final t = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(t.profile),
        leading: IconButton(
          onPressed: () => context.go('/home'),
          icon: const Icon(Icons.keyboard_arrow_left),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await auth.logout();
              context.go('/login');
            },
            tooltip: t.logout,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const CircleAvatar(
            radius: 50,
            backgroundColor: Colors.white10,
            child: Icon(Icons.person, size: 60, color: Colors.white70),
          ),
          const SizedBox(height: 12),
          Center(
            child: Text(
              username,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 32),
          const Divider(color: Colors.white12),

          ListTile(
            leading: const Icon(Icons.language, color: Colors.white),
            title: Text(t.changeLanguage, style: const TextStyle(color: Colors.white)),
            onTap: () => _showLanguageDialog(context, t),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.white38),
          ),
          ListTile(
            leading: const Icon(Icons.lock, color: Colors.white),
            title: Text(t.changePassword, style: const TextStyle(color: Colors.white)),
            onTap: () => _showPasswordDialog(context, auth, t),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.white38),
          ),
          ListTile(
            leading: const Icon(Icons.info_outline, color: Colors.white),
            title: Text(t.about, style: const TextStyle(color: Colors.white)),
            onTap: () => _showAboutDialog(context, t),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.white38),
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip, color: Colors.white),
            title: Text(t.privacy, style: const TextStyle(color: Colors.white)),
            onTap: () => _showPolicyDialog(context, t),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.white38),
          ),
        ],
      ),
    );
  }

  void _showLanguageDialog(BuildContext context, AppLocalizations t) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(t.changeLanguage, style: const TextStyle(color: Colors.white, fontSize: 18)),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.language, color: Colors.white),
              title: const Text('English', style: TextStyle(color: Colors.white)),
              onTap: () {
                context.read<AuthProvider>().setLocale('en');
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.language, color: Colors.white),
              title: const Text('Русский', style: TextStyle(color: Colors.white)),
              onTap: () {
                context.read<AuthProvider>().setLocale('ru');
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showPasswordDialog(BuildContext context, AuthProvider auth, AppLocalizations t) {
    final current = TextEditingController();
    final newPass = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.grey[900],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          left: 24,
          right: 24,
          top: 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.lock_reset, size: 40, color: Colors.white),
            const SizedBox(height: 12),
            Text(
              t.changePassword,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 24),
            _blackTextField(controller: current, label: t.currentPassword, icon: Icons.lock_outline),
            const SizedBox(height: 16),
            _blackTextField(controller: newPass, label: t.newPassword, icon: Icons.lock),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: Colors.red),
                  label: Text(t.cancel, style: const TextStyle(color: Colors.red)),
                ),
                ElevatedButton.icon(
                  onPressed: () async {
                    final ok = await auth.changePassword(current.text, newPass.text);
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(ok ? t.passwordUpdated : t.wrongPassword),
                        backgroundColor: Colors.grey[900],
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  icon: const Icon(Icons.check, color: Colors.black),
                  label: Text(t.change, style: const TextStyle(color: Colors.black)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showAboutDialog(BuildContext context, AppLocalizations t) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.info_outline, size: 48, color: Colors.white),
            const SizedBox(height: 12),
            Text(
              'A N O M',
              style: TextStyle(fontSize: 28, color: Colors.white, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            const Text(
              'v1.0 • © 2025 Dubai Airlines',
              style: TextStyle(color: Colors.white38, fontSize: 12),
            ),
            const SizedBox(height: 16),
            Text(
              t.aboutDescription,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }

  void _showPolicyDialog(BuildContext context, AppLocalizations t) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      isScrollControlled: true,
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.privacy_tip, size: 48, color: Colors.white),
            const SizedBox(height: 12),
            Text(t.privacy, style: const TextStyle(fontSize: 18, color: Colors.white)),
            const SizedBox(height: 16),
            SingleChildScrollView(
              child: Text(
                t.privacyDescription,
                style: const TextStyle(color: Colors.white70),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _blackTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
  }) {
    return TextField(
      controller: controller,
      obscureText: true,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        prefixIcon: Icon(icon, color: Colors.white70),
        filled: true,
        fillColor: Colors.grey[850],
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.white12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.white),
        ),
      ),
    );
  }
}