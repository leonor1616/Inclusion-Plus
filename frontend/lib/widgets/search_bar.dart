import 'package:flutter/material.dart';

import '../theme/app_styles.dart';

class AppSearchBar extends StatelessWidget {
  const AppSearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    return TextField(
      style: AppTextStyles.Body,
      decoration: InputDecoration(
        hintText: 'Search Here',
        hintStyle: AppTextStyles.Body.copyWith(
          color: AppColors.PrimaryLighter,
        ),
        prefixIcon: const Icon(Icons.search),
        suffixIcon: const Icon(Icons.mic_none),
        filled: true,
        fillColor: AppColors.Secondary,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}