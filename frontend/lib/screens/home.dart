import 'package:flutter/material.dart';
import '../services/api_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String message = 'Loading...';

  @override
  void initState() {
    super.initState();
    fetchHealth();
  }

  Future<void> fetchHealth() async {
    try {
      final result = await ApiService.getHealth();
      setState(() {
        message = result;
      });
    } catch (e) {
      setState(() {
        message = 'Error connecting to backend';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inclusion+'),
      ),
      body: Center(
        child: Text(message),
      ),
    );
  }
}