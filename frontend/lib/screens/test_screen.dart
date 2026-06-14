import 'package:flutter/material.dart';
import '../theme/app_styles.dart';

import 'package:provider/provider.dart';

import '../widgets/buttons/button.dart';

class InputTestScreen extends StatefulWidget {
  const InputTestScreen({super.key});

  @override
  State<InputTestScreen> createState() => _InputTestScreenState();
}

class _InputTestScreenState extends State<InputTestScreen> {
  final testController = TextEditingController();
  bool systemSettingsSelected = false;
  bool lightModeSelected = false;

  @override
  void dispose() {
    testController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 120, 16, 0),
        child: Center(
          child: AppButton(
            text: 'See on Map',
            fullWidth: true,
            variant: AppButtonVariant.dark,
            onPressed: () {
              print('pressed');
            },
          ),
        ),
      ),
    );
  }
}
