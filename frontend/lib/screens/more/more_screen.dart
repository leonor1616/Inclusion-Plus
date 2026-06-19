import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../theme/app_styles.dart';
import '../../widgets/app_header.dart';
import '../../widgets/search_bar.dart';

class MoreScreen extends StatelessWidget {
  final VoidCallback? onUniversityTap;
  final VoidCallback? onFoodTap;
  final VoidCallback? onActivitiesTap;
  final VoidCallback? onSearchTap;

  const MoreScreen({
    super.key,
    this.onUniversityTap,
    this.onFoodTap,
    this.onActivitiesTap,
    this.onSearchTap,
  });

  TextStyle get _pageHeading => AppTextStyles.Header.copyWith(
        fontSize: 25,
        fontWeight: FontWeight.w700,
        color: AppColors.Primary,
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.Background,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          children: [
            const _MoreStatusBar(),
            const SizedBox(height: 8),
            const AppHeader(
              logoAsset: 'assets/logos/inclusion_logo_blue.svg',
              horizontalPadding: 0,
            ),
            const SizedBox(height: 16),
            AppSearchBar(readOnly: true, onTap: onSearchTap),
            const SizedBox(height: 24),
            Text('All Categories', style: _pageHeading),
            const SizedBox(height: 16),
            _CategoryCard(
              title: 'From Iscte-IUL',
              description:
                  'Find campus information, accessible material, and make accommodation request.',
              imageAsset: 'assets/images/iscte_building_wide.png',
              onTap: onUniversityTap,
            ),
            const SizedBox(height: 16),
            _CategoryCard(
              title: 'Food & Drink',
              description: 'Find places to eat a meal nearby.',
              imageAsset: 'assets/images/food_drink_wide.png',
              onTap: onFoodTap,
            ),
            const SizedBox(height: 16),
            _CategoryCard(
              title: 'Social & Cultural Activities',
              description:
                  'Get tuned with the upcoming activities near your campus.',
              imageAsset: 'assets/images/activities_wide.png',
              onTap: onActivitiesTap,
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _MoreStatusBar extends StatelessWidget {
  const _MoreStatusBar();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 37,
      child: Row(
        children: [
          const SizedBox(width: 38),
          Text('9:41', style: AppTextStyles.TinyBodyBold),
          const Spacer(),
          const Icon(Icons.signal_cellular_alt, size: 16, color: AppColors.Primary),
          const SizedBox(width: 6),
          const Icon(Icons.wifi, size: 16, color: AppColors.Primary),
          const SizedBox(width: 6),
          const Icon(Icons.battery_full, size: 18, color: AppColors.Primary),
          const SizedBox(width: 16),
        ],
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final String title;
  final String description;
  final String imageAsset;
  final VoidCallback? onTap;

  const _CategoryCard({
    required this.title,
    required this.description,
    required this.imageAsset,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: title,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: 222),
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.Background,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.Primary, width: 1),
            boxShadow: const [
              BoxShadow(
                color: Color(0x26000000),
                blurRadius: 6,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: AppTextStyles.Header.copyWith(
                        fontSize: 24,
                        height: 1,
                        color: AppColors.Primary,
                      ),
                    ),
                  ),
                  SvgPicture.asset(
                    'assets/icons/arrow_go_blue.svg',
                    width: 33,
                    height: 33,
                    fit: BoxFit.contain,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                description,
                style: AppTextStyles.Body.copyWith(
                  color: AppColors.Primary,
                  height: 1.25,
                ),
              ),
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  imageAsset,
                  width: double.infinity,
                  height: 110,
                  fit: BoxFit.cover,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
