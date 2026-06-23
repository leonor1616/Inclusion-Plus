import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../screens/auth/login_screen.dart';
import '../screens/main/main_shell.dart';
import '../state/auth_provider.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  @override
  void initState() {
    super.initState();

    // Session loading is deferred until after build context is available.
    Future.microtask(() {
      if (mounted) {
        context.read<AuthProvider>().loadSession();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    if (auth.isLoadingSession) {
      // Prevents a flash of the login screen while SharedPreferences is checked.
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (auth.isAuthenticated) {
      return const MainShell();
    }

    return const LoginScreen();
  }
}
