import 'package:flutter/material.dart';

class AskAiScreen extends StatelessWidget {
  const AskAiScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ask AI Assistant'),
      ),
      body: const Center(
        child: Text('Ask AI Assistant Screen'),
      ),
    );
  }
}