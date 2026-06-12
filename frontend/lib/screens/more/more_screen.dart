import 'package:flutter/material.dart';

import '../../theme/app_styles.dart';
import '../../widgets/app_header.dart';
import '../../widgets/search_bar.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: const [
            AppHeader(
              logoAsset: 'assets/logos/inclusion_logo_blue.svg',
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: AppSearchBar(),
            ),
            SizedBox(height: 32),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'All Categories',
                style: AppTextStyles.Header,
              ),
            )
          ],
        ),
      ),
    );
  }
}