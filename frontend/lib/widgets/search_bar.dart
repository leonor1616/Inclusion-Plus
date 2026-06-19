import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../theme/app_styles.dart';

enum AppSearchBarVariant {
  white,
  filled,
}

class AppSearchBar extends StatelessWidget {
  final String hintText;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final AppSearchBarVariant variant;
  final VoidCallback? onTap;
  final ValueChanged<String>? onChanged;
  final bool readOnly;

  const AppSearchBar({
    super.key,
    this.hintText = 'Search Here',
    this.controller,
    this.focusNode,
    this.variant = AppSearchBarVariant.filled,
    this.onTap,
    this.onChanged,
    this.readOnly = false,
  });

  Color get _backgroundColor {
    switch (variant) {
      case AppSearchBarVariant.white:
        return AppColors.White;
      case AppSearchBarVariant.filled:
        return AppColors.Tertiary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      textField: true,
      label: hintText,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: _backgroundColor,
            borderRadius: BorderRadius.circular(40),
          ),
          child: Row(
            children: [
              SvgPicture.asset(
                'assets/icons/search.svg',
                width: 22,
                height: 22,
                colorFilter: const ColorFilter.mode(
                  AppColors.Primary,
                  BlendMode.srcIn,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: controller,
                  focusNode: focusNode,
                  readOnly: readOnly,
                  onTap: onTap,
                  onChanged: onChanged,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    filled: false,
                    isDense: true,
                    hintText: hintText,
                    hintStyle: AppTextStyles.Body.copyWith(
                      color: AppColors.PrimaryLighter,
                    ),
                  ),
                  style: AppTextStyles.Body.copyWith(
                    color: AppColors.Primary,
                  ),
                ),
              ),
              SvgPicture.asset(
                'assets/icons/mic_rounded.svg',
                width: 24,
                height: 24,
                fit: BoxFit.contain,
                colorFilter: const ColorFilter.mode(
                  AppColors.Primary,
                  BlendMode.srcIn,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
