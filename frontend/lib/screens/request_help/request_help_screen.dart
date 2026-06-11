import 'package:flutter/material.dart';

class RequestHelpScreen extends StatelessWidget {
  const RequestHelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Request Help'),
      ),
      body: const Center(
        child: Text('Request Help Screen'),
      ),
    );
  }
}