import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../providers/auth_provider.dart';
import '../../../l10n/app_localizations.dart';
import '../../../providers/profile_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final profile = context.watch<ProfileProvider>();
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
          Center(
            child: Stack(
              alignment: Alignment.bottomRight,
              children: [
                CircleAvatar(
                  radius: 70,
                  backgroundColor: Colors.white10,
                  backgroundImage: profile.avatarUrl.isNotEmpty
                      ? NetworkImage(profile.avatarUrl)
                      : null,
                  child: profile.avatarUrl.isEmpty
                      ? const Icon(Icons.person, size: 60, color: Colors.white70)
                      : null,
                ),
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    border: Border.all(color: Colors.black, width: 2),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.edit, size: 18, color: Colors.black),
                    onPressed: () {
                      // TODO: реализовать выбор или загрузку аватарки
                    },
                    tooltip: 'Change avatar',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  username,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                  ),
                ),
                if (profile.isVerified) ...[
                  const SizedBox(width: 6),
                  const Icon(Icons.verified, color: Colors.red, size: 20),
                ],
              ],
            )
          ),
          ListTile(
            leading: const Icon(Icons.person_outline, color: Colors.white),
            title: const Text('About Me', style: TextStyle(color: Colors.white)),
            subtitle: Text(
              profile.bio.isEmpty ? 'No bio yet' : profile.bio,
              style: const TextStyle(color: Colors.white54),
            ),
            onTap: () => _showEditBioDialog(context),
            trailing: const Icon(Icons.edit, color: Colors.white38),
          ),
          const Divider(color: Colors.white12),

          // Language
          ListTile(
            leading: const Icon(Icons.language, color: Colors.white),
            title: Text(t.changeLanguage, style: const TextStyle(color: Colors.white)),
            onTap: () => _showLanguageDialog(context, t),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.white38),
          ),

          // Password
          ListTile(
            leading: const Icon(Icons.lock, color: Colors.white),
            title: Text(t.changePassword, style: const TextStyle(color: Colors.white)),
            onTap: () => _showPasswordDialog(context, auth, t),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.white38),
          ),

          // About
          ListTile(
            leading: const Icon(Icons.info_outline, color: Colors.white),
            title: Text(t.about, style: const TextStyle(color: Colors.white)),
            onTap: () => _showAboutDialog(context, t),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.white38),
          ),

          // Privacy
          ListTile(
            leading: const Icon(Icons.privacy_tip, color: Colors.white),
            title: Text(t.privacy, style: const TextStyle(color: Colors.white)),
            onTap: () => _showPolicyDialog(context, t),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.white38),
          ),

          const Divider(color: Colors.white12),

          // Offline Communication
          ListTile(
            leading: const Icon(Icons.wifi_off, color: Colors.white),
            title: const Text('Offline Communication', style: TextStyle(color: Colors.white)),
            subtitle: const Text('Encrypted messaging without internet', style: TextStyle(color: Colors.white54, fontSize: 12)),
            onTap: () {
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  backgroundColor: Colors.grey[900],
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  title: const Row(
                    children: [
                      Icon(Icons.wifi_off, color: Colors.white),
                      SizedBox(width: 8),
                      Text('Offline Chat', style: TextStyle(color: Colors.white)),
                    ],
                  ),
                  content: const Text(
                    '🔒 Offline secure messaging is under development.\n\nSoon you’ll be able to chat even without internet using Bluetooth or local mesh.',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('OK', style: TextStyle(color: Colors.blueAccent)),
                    ),
                  ],
                ),
              );
            },
            trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.white38),
          ),

          // VPN
          ListTile(
            leading: const Icon(Icons.vpn_lock, color: Colors.white),
            title: const Text('Built-in VPN', style: TextStyle(color: Colors.white)),
            subtitle: const Text('Protect your traffic using integrated VPN', style: TextStyle(color: Colors.white54, fontSize: 12)),
            onTap: () {
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  backgroundColor: Colors.grey[900],
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  title: const Row(
                    children: [
                      Icon(Icons.vpn_lock, color: Colors.white),
                      SizedBox(width: 8),
                      Text('VPN Module', style: TextStyle(color: Colors.white)),
                    ],
                  ),
                  content: const Text(
                    '🛰 A secure VPN module is on its way!\n\nYou’ll soon be able to route all your messages through our encrypted VPN tunnel.',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Close', style: TextStyle(color: Colors.blueAccent)),
                    ),
                  ],
                ),
              );
            },
            trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.white38),
          ),

          // Proxy
          ListTile(
            leading: const Icon(Icons.security, color: Colors.white),
            title: const Text('Proxy Settings', style: TextStyle(color: Colors.white)),
            subtitle: const Text('Custom proxy or Tor support', style: TextStyle(color: Colors.white54, fontSize: 12)),
            onTap: () {
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  backgroundColor: Colors.grey[900],
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  title: const Row(
                    children: [
                      Icon(Icons.security, color: Colors.white),
                      SizedBox(width: 8),
                      Text('Proxy & Tor', style: TextStyle(color: Colors.white)),
                    ],
                  ),
                  content: const Text(
                    '🌍 Proxy and Tor support will be available soon.\n\nCustomize your connection to bypass censorship and stay anonymous.',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Got it', style: TextStyle(color: Colors.blueAccent)),
                    ),
                  ],
                ),
              );
            },
            trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.white38),
          ),

          // Verification
          ListTile(
            leading: const Icon(Icons.verified_user, color: Colors.white),
            title: const Text('Request Verification', style: TextStyle(color: Colors.white)),
            subtitle: const Text('Apply for the blue checkmark', style: TextStyle(color: Colors.white54, fontSize: 12)),
            onTap: () {
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
                      const Text('Choose Verification Type', style: TextStyle(color: Colors.white, fontSize: 18)),
                      const SizedBox(height: 16),
                      ListTile(
                        leading: const Icon(Icons.person, color: Colors.white),
                        title: const Text('Personal Identity', style: TextStyle(color: Colors.white)),
                        onTap: () {
                          Navigator.pop(context);
                          context.push('/verify/personal');
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.business, color: Colors.white),
                        title: const Text('Business/Organization', style: TextStyle(color: Colors.white)),
                        onTap: () {
                          Navigator.pop(context);
                          context.push('/verify/business');
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
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
              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
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
                  onPressed: (){},
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
            const SizedBox(height: 12),
            const Text('A N O M', style: TextStyle(fontSize: 28, color: Colors.white, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            const Text('v1.0 • © 2025 Dubai Airlines', style: TextStyle(color: Colors.white38, fontSize: 12)),
            const SizedBox(height: 16),
            Text(t.aboutDescription, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white70)),
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

  void _showEditBioDialog(BuildContext context) {
    final profile = context.read<ProfileProvider>();
    final controller = TextEditingController(text: profile.bio);

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
          top: 24,
          left: 24,
          right: 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Edit Bio',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              maxLines: 4,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Write something fun or meaningful...',
                hintStyle: const TextStyle(color: Colors.white38),
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
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  final username = context.read<AuthProvider>().username;
                  if (username != null) {
                    Navigator.pop(context);
                    await profile.updateBio(username, controller.text.trim());
                  }
                },
                icon: const Icon(Icons.edit, color: Colors.black),
                label: const Text('Save', style: TextStyle(color: Colors.black)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
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