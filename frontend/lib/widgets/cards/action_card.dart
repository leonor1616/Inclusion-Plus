import 'package:flutter/material.dart';

import 'package:flutter_svg/flutter_svg.dart';

import '../../theme/app_styles.dart';

class ActionCard extends StatelessWidget {
  final String title;
  final String iconPath;
  final VoidCallback? onTap;
  final Widget? trailing;

  const ActionCard({
    super.key,
    required this.title,
    required this.iconPath,
    this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 18,
        ),
        decoration: BoxDecoration(
          color: AppColors.White,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.PrimaryLighter,
            width: 1.4,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x26000000),
              blurRadius: 6,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            SvgPicture.asset(
              iconPath,
              width: 32,
              height: 32,
            ),

            const SizedBox(width: 16),

            Expanded(
              child: Text(
                title,
                style: AppTextStyles.BodyBold,
              ),
            ),

            trailing ??
                const Icon(
                  Icons.arrow_forward,
                  color: AppColors.Accent,
                ),
          ],
        ),
      ),
    );
  }
}