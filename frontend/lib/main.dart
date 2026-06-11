import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'navigation/auth_gate.dart';
import 'state/auth_provider.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider()..loadSession(),
        ),
      ],
      child: const InclusionPlusApp(),
    ),
  );
}

class InclusionPlusApp extends StatelessWidget {
  const InclusionPlusApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Inclusion+',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const AuthGate(),
    );
  }
}