import 'package:flutter/material.dart';

import '../../theme/app_styles.dart';
import '../../widgets/app_header.dart';
import '../../widgets/search_bar.dart';
import '../../widgets/navbars/nav_item.dart';
import '../../widgets/navbars/nav_items.dart';

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
    HomeScreen(),
    MapScreen(),
    CommunityScreen(),
    MoreScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const AppHeader(
              logoAsset: 'assets/logos/inclusion_logo_magenta.svg',
            ),
            // Add more widgets here as needed
          ],
        ),
      ),
    );
  }
}