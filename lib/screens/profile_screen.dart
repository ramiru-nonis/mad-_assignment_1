import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _pushNotifications = true;
  bool _emailOffers = false;

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        final initials = auth.userName.isNotEmpty
            ? auth.userName
                .split(' ')
                .where((w) => w.isNotEmpty)
                .map((w) => w[0].toUpperCase())
                .take(2)
                .join()
            : 'U';

        return Scaffold(
          appBar: AppBar(
            title: const Text('My Profile'),
            elevation: 0,
            backgroundColor: Colors.transparent,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // ── Avatar ──
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  child: Text(
                    initials,
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  auth.userName.isNotEmpty ? auth.userName : 'Guest',
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  auth.userEmail.isNotEmpty
                      ? auth.userEmail
                      : 'Not logged in',
                  style:
                      TextStyle(fontSize: 16, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 32),

                // ── Account Info ──
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    children: [
                      _buildListTile('My Orders', Icons.shopping_bag_outlined),
                      const Divider(height: 1),
                      _buildListTile(
                          'Saved Addresses', Icons.location_on_outlined),
                      const Divider(height: 1),
                      _buildListTile(
                          'Payment Methods', Icons.payment_outlined),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // ── Preferences ──
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Preferences',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 12),
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    children: [
                      SwitchListTile(
                        title: const Text('Push Notifications'),
                        secondary: const Icon(Icons.notifications_outlined),
                        value: _pushNotifications,
                        activeThumbColor: Theme.of(context).colorScheme.primary,
                        onChanged: (bool value) =>
                            setState(() => _pushNotifications = value),
                      ),
                      const Divider(height: 1),
                      SwitchListTile(
                        title: const Text('Email Offers'),
                        secondary: const Icon(Icons.email_outlined),
                        value: _emailOffers,
                        activeThumbColor: Theme.of(context).colorScheme.primary,
                        onChanged: (bool value) =>
                            setState(() => _emailOffers = value),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // ── Support ──
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    children: [
                      _buildListTile('Help & Support', Icons.help_outline),
                      const Divider(height: 1),
                      _buildListTile('About Cellario', Icons.info_outline),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // ── Logout Button ──
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: auth.isLoading
                        ? null
                        : () async {
                            await auth.logout();
                            if (context.mounted) {
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const LoginScreen()),
                                (route) => false,
                              );
                            }
                          },
                    icon: auth.isLoading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.logout, color: Colors.red),
                    label: const Text(
                      'Log Out',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.red),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(color: Colors.red),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildListTile(String title, IconData icon) {
    return ListTile(
      leading: Icon(icon, color: Colors.black87),
      title:
          Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: () {},
    );
  }
}
