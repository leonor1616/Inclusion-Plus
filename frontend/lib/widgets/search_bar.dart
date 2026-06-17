import 'package:flutter/material.dart';

import '../theme/app_styles.dart';

enum AppSearchBarVariant {
  white,
  filled,
}

class AppSearchBar extends StatelessWidget {
  final String hintText;
  final TextEditingController? controller;
  final AppSearchBarVariant variant;
  final VoidCallback? onTap;
  final ValueChanged<String>? onChanged;
  final bool readOnly;

  const AppSearchBar({
    super.key,
    this.hintText = 'Search Here',
    this.controller,
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
    return Material(
      color: _backgroundColor,
      borderRadius: BorderRadius.circular(40),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(40),
        child: Container(
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: _backgroundColor,
            borderRadius: BorderRadius.circular(40),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.search,
                size: 22,
                color: AppColors.Primary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: controller,
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
              const Icon(
                Icons.mic_none,
                size: 24,
                color: AppColors.PrimaryLighter,
              ),
            ],
          ),
        ),
      ),
    );
  }
}