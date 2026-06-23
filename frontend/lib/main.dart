import 'package:flutter/material.dart';
import 'package:frontend/navigation/auth_gate.dart';
import 'package:frontend/screens/home/home.dart';

import 'package:provider/provider.dart';

import 'state/auth_provider.dart';
import 'theme/app_theme.dart';
import 'screens/auth/login_screen.dart';
//import 'screens/home/home.dart';
import 'screens/test_screen.dart';
import 'screens/main/main_shell.dart';



Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
    

  // AuthProvider is registered at the root so any screen can read the current
  // session, user data, and auth actions through Provider.
  runApp(
    ChangeNotifierProvider(
      create: (_) => AuthProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Inclusion+',
      theme: AppTheme.lightTheme,

      home: Consumer<AuthProvider>(
        builder: (context, auth, child) {
          // The first screen is selected from auth state; AuthGate handles
          // restoring a saved token before showing login or the main shell.
          if (auth.isAuthenticated) {
            //return const HomeScreen();
            return const MainShell();
          }

          //return const LoginScreen();
          return const AuthGate();
        },
      ),
    );
  }
}
