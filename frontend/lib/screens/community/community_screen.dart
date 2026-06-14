import 'package:flutter/material.dart';

import '../../theme/app_styles.dart';
import '../../widgets/app_header.dart';
import '../../widgets/search_bar.dart';

class CommunityScreen extends StatelessWidget {
  const CommunityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const AppHeader(
              logoAsset: 'assets/logos/inclusion_logo_purple.svg',
            ),
          ],
        ),
      ),
    );
  }
}

