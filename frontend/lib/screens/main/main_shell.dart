import 'package:flutter/material.dart';

import '../../widgets/navbars/nav_items.dart';
import '../../widgets/navbars/navbar.dart';

import '../home/home.dart';
import '../map/map_screen.dart';
import '../community/community_screen.dart';
import '../ai/ask_ai_screen.dart';
import '../more/more_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int selectedIndex = 0;

  final List<Widget> pages = const [
    HomeScreen(),
    MapScreen(),
    CommunityScreen(),
    AskAiScreen(),
    MoreScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: selectedIndex,
        children: pages,
      ),
      bottomNavigationBar: AppNavigationBar(
        currentIndex: selectedIndex,
        items: AppNavItems.items,
        onTap: (index) {
          setState(() {
            selectedIndex = index;
          });
        },
      ),
    );
  }
}