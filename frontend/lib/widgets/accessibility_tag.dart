import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../models/accessibility_tag_model.dart';
import '../theme/app_styles.dart';

class AccessibilityTag extends StatelessWidget {
  final AccessibilityTagModel tag;

  const AccessibilityTag({
    super.key,
    required this.tag,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 32,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.Tertiary,
        border: Border.all(color: AppColors.PrimaryLighter),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (tag.iconAsset != null) ...[
            SvgPicture.asset(
              tag.iconAsset!,
              width: 16,
              height: 16,
              colorFilter: const ColorFilter.mode(
                AppColors.Primary,
                BlendMode.srcIn,
              ),
            ),
            const SizedBox(width: 6),
          ],
          Text(
            tag.label,
            style: AppTextStyles.TinyBody.copyWith(
              color: AppColors.Primary,
            ),
          ),
        ],
      ),
    );
  }
}