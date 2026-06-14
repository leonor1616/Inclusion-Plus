import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../theme/app_styles.dart';
import 'nav_item.dart';

class AppNavigationBar extends StatelessWidget {
  final int currentIndex;
  final List<AppNavItem> items;
  final ValueChanged<int> onTap;

  const AppNavigationBar({
    super.key,
    required this.currentIndex,
    required this.items,
    required this.onTap,
  });

@override
Widget build(BuildContext context) {
  return Container(
    color: AppColors.White,
    padding: const EdgeInsets.only(
      left: 12,
      right: 12,
      bottom: 24,
    ),
    child: Row(
      children: List.generate(
        items.length,
        (index) {
          return Expanded(
            child: _NavigationBarItem(
              item: items[index],
              selected: currentIndex == index,
              onTap: () {
                if (currentIndex != index) {
                  HapticFeedback.lightImpact();
                  onTap(index);
                }
              },
            ),
          );
        },
      ),
    ),
  );
}
}

class _NavigationBarItem extends StatelessWidget {
  static const double itemHeight = 72;
  static const double indicatorHeight = 3;
  static const double indicatorWidth = 53;
  static const double iconSize = 25;

  final AppNavItem item;
  final bool selected;
  final VoidCallback onTap;

  const _NavigationBarItem({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final textStyle = selected
        ? AppTextStyles.BodyBold
        : AppTextStyles.TinyBody.copyWith(
            color: AppColors.Primary,
          );

    return Semantics(
      button: true,
      selected: selected,
      label: '${item.label} tab',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          height: itemHeight,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOut,
                width: selected ? indicatorWidth : 0,
                height: indicatorHeight,
                decoration: BoxDecoration(
                  color: const Color(0x7F0078CF),
                  borderRadius: BorderRadius.circular(30),
                ),
              ),

              const SizedBox(height: 16),

              SvgPicture.asset(
                selected ? item.selectedIconAsset : item.iconAsset,
                width: iconSize,
                height: iconSize,
              ),

              const SizedBox(height: 8),

              SizedBox(
                height: 20,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    item.label,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    style: textStyle,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}