// lib/screens/profile/profile_sidebar.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';

class ProfileSidebar extends StatefulWidget {
  const ProfileSidebar({super.key});

  @override
  State<ProfileSidebar> createState() => _ProfileSidebarState();
}

class _ProfileSidebarState extends State<ProfileSidebar> {
  bool _editingUsername = false;
  bool _editingEmail = false;
  bool _editingPassword = false;

  final _usernameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _oldPasswordCtrl = TextEditingController();
  final _newPasswordCtrl = TextEditingController();

  bool _loading = false;
  String? _message;
  bool _isError = false;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().user;
    if (user != null) {
      _usernameCtrl.text = user.username;
      _emailCtrl.text = user.email;
    }
  }

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _emailCtrl.dispose();
    _oldPasswordCtrl.dispose();
    _newPasswordCtrl.dispose();
    super.dispose();
  }

  Future<void> _saveUsername() async {
    setState(() { _loading = true; _message = null; });
    final result = await context.read<AuthProvider>().updateUsername(_usernameCtrl.text.trim());
    setState(() {
      _loading = false;
      _editingUsername = false;
      _message = result['message'];
      _isError = !result['success'];
    });
  }

  Future<void> _saveEmail() async {
    setState(() { _loading = true; _message = null; });
    final result = await context.read<AuthProvider>().updateEmail(_emailCtrl.text.trim());
    setState(() {
      _loading = false;
      _editingEmail = false;
      _message = result['message'];
      _isError = !result['success'];
    });
  }

  Future<void> _savePassword() async {
    setState(() { _loading = true; _message = null; });
    final result = await context.read<AuthProvider>().updatePassword(
      _oldPasswordCtrl.text,
      _newPasswordCtrl.text,
    );
    setState(() {
      _loading = false;
      _editingPassword = false;
      _oldPasswordCtrl.clear();
      _newPasswordCtrl.clear();
      _message = result['message'];
      _isError = !result['success'];
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = themeProvider.isDark;
    final colorScheme = Theme.of(context).colorScheme;

    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              color: const Color(0xFF05B6D3),
              child: Column(
                children: [
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: Colors.white,
                        child: Text(
                          user?.username.isNotEmpty == true
                              ? user!.username[0].toUpperCase()
                              : 'U',
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF05B6D3),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    user?.username ?? '',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    user?.email ?? '',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Message
                  if (_message != null) ...[
                    Container(
                      padding: const EdgeInsets.all(10),
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: _isError ? Colors.red.shade50 : Colors.green.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: _isError ? Colors.red.shade200 : Colors.green.shade200,
                        ),
                      ),
                      child: Text(
                        _message!,
                        style: TextStyle(
                          color: _isError ? Colors.red.shade700 : Colors.green.shade700,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],

                  // Username
                  _sectionTitle('Username'),
                  if (_editingUsername) ...[
                    TextField(
                      controller: _usernameCtrl,
                      decoration: const InputDecoration(hintText: 'New username'),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _loading ? null : _saveUsername,
                            child: _loading
                                ? const SizedBox(height: 18, width: 18,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                : const Text('Save'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => setState(() => _editingUsername = false),
                            child: const Text('Cancel'),
                          ),
                        ),
                      ],
                    ),
                  ] else ...[
                    _infoTile(
                      icon: Icons.person_outline,
                      value: user?.username ?? '',
                      onEdit: () => setState(() => _editingUsername = true),
                    ),
                  ],

                  const SizedBox(height: 12),

                  // Email
                  _sectionTitle('Email'),
                  if (_editingEmail) ...[
                    TextField(
                      controller: _emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(hintText: 'New email'),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _loading ? null : _saveEmail,
                            child: _loading
                                ? const SizedBox(height: 18, width: 18,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                : const Text('Save'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => setState(() => _editingEmail = false),
                            child: const Text('Cancel'),
                          ),
                        ),
                      ],
                    ),
                  ] else ...[
                    _infoTile(
                      icon: Icons.email_outlined,
                      value: user?.email ?? '',
                      onEdit: () => setState(() => _editingEmail = true),
                    ),
                  ],

                  const SizedBox(height: 12),

                  // Password
                  _sectionTitle('Password'),
                  if (_editingPassword) ...[
                    TextField(
                      controller: _oldPasswordCtrl,
                      obscureText: true,
                      decoration: const InputDecoration(hintText: 'Current password'),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _newPasswordCtrl,
                      obscureText: true,
                      decoration: const InputDecoration(hintText: 'New password'),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _loading ? null : _savePassword,
                            child: _loading
                                ? const SizedBox(height: 18, width: 18,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                : const Text('Save'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => setState(() => _editingPassword = false),
                            child: const Text('Cancel'),
                          ),
                        ),
                      ],
                    ),
                  ] else ...[
                    _infoTile(
                      icon: Icons.lock_outline,
                      value: '••••••••',
                      onEdit: () => setState(() => _editingPassword = true),
                    ),
                  ],

                  const SizedBox(height: 20),
                  const Divider(),
                  const SizedBox(height: 8),

                  // Dark mode toggle
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(
                      isDark ? Icons.dark_mode : Icons.light_mode,
                      color: const Color(0xFF05B6D3),
                    ),
                    title: Text(isDark ? 'Dark Mode' : 'Light Mode'),
                    trailing: Switch(
                      value: isDark,
                      activeColor: const Color(0xFF05B6D3),
                      onChanged: (_) => themeProvider.toggleTheme(),
                    ),
                  ),
                ],
              ),
            ),

            // Logout button
            Padding(
              padding: const EdgeInsets.all(16),
              child: OutlinedButton.icon(
                onPressed: () async {
                  Navigator.pop(context);
                  await context.read<AuthProvider>().signout();
                },
                icon: const Icon(Icons.logout, color: Colors.red),
                label: const Text('Sign Out', style: TextStyle(color: Colors.red)),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                  side: const BorderSide(color: Colors.red),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Colors.grey.shade500,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _infoTile({
    required IconData icon,
    required String value,
    required VoidCallback onEdit,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey.shade500),
          const SizedBox(width: 10),
          Expanded(
            child: Text(value, style: const TextStyle(fontSize: 14)),
          ),
          IconButton(
            icon: const Icon(Icons.edit_outlined, size: 18),
            color: const Color(0xFF05B6D3),
            onPressed: onEdit,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}