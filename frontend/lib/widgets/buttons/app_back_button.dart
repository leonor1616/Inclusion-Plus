import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../theme/app_styles.dart';

class AppBackButton extends StatelessWidget {
  final VoidCallback onTap;
  final String text;
  final String iconAsset;

  const AppBackButton({
    super.key,
    required this.onTap,
    this.text = 'Back',
    this.iconAsset = 'assets/icons/arrow-back.svg',
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              iconAsset,
              width: 20,
              height: 20,
            ),
            const SizedBox(width: 8),
            Text(
              text,
              style: AppTextStyles.Body.copyWith(
                color: AppColors.Primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}