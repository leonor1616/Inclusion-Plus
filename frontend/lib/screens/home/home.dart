import 'package:flutter/material.dart';

import '../account/account_screen.dart';
import '../ai/ask_ai_screen.dart';
import '../community/community_screen.dart';
import '../request_help/request_help_screen.dart';
import '../map/map_screen.dart';
import '../more/more_screen.dart';
import '../reports/report_issue_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int selectedIndex = 0;

  final List<Widget> pages = const [
    HomeTab(),
    MapScreen(),
    CommunityScreen(),
    MoreScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.explore_outlined),
            selectedIcon: Icon(Icons.explore),
            label: 'Map',
          ),
          NavigationDestination(
            icon: Icon(Icons.groups_outlined),
            selectedIcon: Icon(Icons.groups),
            label: 'Community',
          ),
          NavigationDestination(
            icon: Icon(Icons.grid_view_outlined),
            selectedIcon: Icon(Icons.grid_view),
            label: 'More',
          ),
        ],
      ),
    );
  }
}

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('inclusion+'),
        actions: [
          IconButton(
            tooltip: 'Open account',
            icon: const Icon(Icons.account_circle_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const AccountScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextField(
              decoration: InputDecoration(
                hintText: 'Search Here',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: const Icon(Icons.mic_none),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Quick Actions',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _QuickActionButton(
                  icon: Icons.near_me,
                  label: 'Plan\nRoute',
                  onTap: () {},
                ),
                _QuickActionButton(
                  icon: Icons.not_accessible,
                  label: 'Report\nIssue',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ReportIssueScreen(),
                      ),
                    );
                  },
                ),
                _QuickActionButton(
                  icon: Icons.support_agent,
                  label: 'Request\nHelp',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const RequestHelpScreen(),
                      ),
                    );
                  },
                ),
                _QuickActionButton(
                  icon: Icons.help_outline,
                  label: 'Ask AI\nAssistant',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AskAiScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 28),
            const _AlertCard(
              title: 'Metro Yellow Line Closed',
              description: 'Yellow line closed due to weather conditions.',
              icon: Icons.train,
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.warning_amber_outlined),
              label: const Text('See all ongoing issues'),
            ),
            const SizedBox(height: 28),
            Text(
              'From your University',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            const _AlertCard(
              title: 'Elevator Issues',
              description: 'Temporary elevator issue reported on campus.',
              icon: Icons.elevator,
            ),
            const SizedBox(height: 12),
            const _AlertCard(
              title: 'Schedule Changes',
              description: 'Applied Mathematics I room update.',
              icon: Icons.calendar_month,
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label.replaceAll('\n', ' '),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: SizedBox(
          width: 76,
          child: Column(
            children: [
              CircleAvatar(
                radius: 28,
                child: Icon(icon),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AlertCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;

  const _AlertCard({
    required this.title,
    required this.description,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          child: Icon(icon),
        ),
        title: Text(title),
        subtitle: Text(description),
        trailing: const Icon(Icons.arrow_forward),
      ),
    );
  }
}