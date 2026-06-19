import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../state/auth_provider.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Account'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                title: Text(user?.fullName ?? 'User'),
                subtitle: Text(user?.email ?? 'No email available'),
                trailing: const CircleAvatar(
                  child: Icon(Icons.person),
                ),
              ),
            ),
            const SizedBox(height: 24),
            _AccountOption(
              icon: Icons.person_outline,
              title: 'Personal Information',
              onTap: () {},
            ),
            _AccountOption(
              icon: Icons.bookmark_border,
              title: 'Saved',
              onTap: () {},
            ),
            _AccountOption(
              icon: Icons.groups_outlined,
              title: 'Community Activity',
              onTap: () {},
            ),
            _AccountOption(
              icon: Icons.tune,
              title: 'Settings',
              onTap: () {},
            ),
            _AccountOption(
              icon: Icons.logout,
              title: 'Logout',
              onTap: () {
                context.read<AuthProvider>().logout();
                Navigator.pop(context);
              },
            ),
            _AccountOption(
              icon: Icons.delete_outline,
              title: 'Delete Account',
              isDanger: true,
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }
}

class _AccountOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool isDanger;
  final VoidCallback onTap;

  const _AccountOption({
    required this.icon,
    required this.title,
    required this.onTap,
    this.isDanger = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isDanger ? Colors.red : null;

    return Card(
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(
          title,
          style: TextStyle(color: color),
        ),
        trailing: Icon(
          Icons.arrow_forward,
          color: color,
        ),
        onTap: onTap,
      ),
    );
  }
}