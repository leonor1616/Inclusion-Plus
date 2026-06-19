import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'navigation/auth_gate.dart';
import 'state/auth_provider.dart';
import 'theme/app_theme.dart';
import 'widgets/phone_viewport.dart';

void main() {
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
      builder: (context, child) => PhoneViewport(
        child: child ?? const SizedBox.shrink(),
      ),
      home: const AuthGate(),
    );
  }
}
