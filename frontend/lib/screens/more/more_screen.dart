import 'package:flutter/material.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('inclusion+'),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 12),
            child: Icon(Icons.account_circle_outlined),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: const [
            TextField(
              decoration: InputDecoration(
                hintText: 'Search Here',
                prefixIcon: Icon(Icons.search),
                suffixIcon: Icon(Icons.mic_none),
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 24),
            Text(
              'All Categories',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            _CategoryCard(
              title: 'From Iscte-IUL',
              description:
                  'Find campus information, accessible material, and make accommodation request.',
              icon: Icons.school_outlined,
            ),
            _CategoryCard(
              title: 'Food & Drink',
              description: 'Find places to eat a meal nearby.',
              icon: Icons.restaurant_outlined,
            ),
            _CategoryCard(
              title: 'Social & Cultural Activities',
              description: 'Get tuned with the upcoming activities near you.',
              icon: Icons.local_activity_outlined,
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;

  const _CategoryCard({
    required this.title,
    required this.description,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          child: Icon(icon),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text(description),
        ),
        trailing: const Icon(Icons.arrow_forward),
      ),
    );
  }
}