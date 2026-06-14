import 'nav_item.dart';

class AppNavItems {
  static const items = [
    AppNavItem(
      label: 'Home',
      iconAsset: 'assets/icons/home.svg',
      selectedIconAsset: 'assets/icons/home_filled.svg',
    ),
    AppNavItem(
      label: 'Map',
      iconAsset: 'assets/icons/map.svg',
      selectedIconAsset: 'assets/icons/map_filled.svg',
    ),
    AppNavItem(
      label: 'Community',
      iconAsset: 'assets/icons/community.svg',
      selectedIconAsset: 'assets/icons/community_filled.svg',
    ),
    AppNavItem(
      label: 'Ask AI',
      iconAsset: 'assets/icons/ai.svg',
      selectedIconAsset: 'assets/icons/ai_filled.svg',
    ),
    AppNavItem(
      label: 'More',
      iconAsset: 'assets/icons/more.svg',
      selectedIconAsset: 'assets/icons/more_filled.svg',
    ),
  ];
}