import 'package:flutter/material.dart';

import '../../models/route_option_model.dart';
import '../../theme/app_styles.dart';
import '../buttons/button.dart';

class RouteOptionCard extends StatelessWidget {
  final RouteOption route;
  final bool isSelected;
  final VoidCallback onSelected;
  final VoidCallback onSavePressed;
  final VoidCallback onGoPressed;

  const RouteOptionCard({
    super.key,
    required this.route,
    required this.isSelected,
    required this.onSelected,
    required this.onSavePressed,
    required this.onGoPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: isSelected,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onSelected,
          borderRadius: BorderRadius.circular(12),
          splashColor: AppColors.Accent.withOpacity(0.12),
          highlightColor: AppColors.Accent.withOpacity(0.08),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.White,
              border: Border.all(
                color: isSelected ? AppColors.Accent : AppColors.Primary,
                width: isSelected ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    Text(
                      route.durationText,
                      style: AppTextStyles.BodyBold.copyWith(
                        color: AppColors.Primary,
                      ),
                    ),
                    Text(
                      '•',
                      style: AppTextStyles.BodyBold.copyWith(
                        color: AppColors.Primary,
                      ),
                    ),
                    Text(
                      route.arrivalTimeText,
                      style: AppTextStyles.BodyBold.copyWith(
                        color: AppColors.Primary,
                      ),
                    ),
                    if (isSelected)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.check_circle,
                            size: 16,
                            color: AppColors.Accent,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Selected',
                            style: AppTextStyles.TinyBody.copyWith(
                              color: AppColors.Accent,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  '${route.distanceText}  •  ${route.modeSummary}',
                  style: AppTextStyles.Body.copyWith(
                    color: AppColors.Primary,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Icon(
                      Icons.directions_walk,
                      size: 26,
                      color: AppColors.Primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      route.durationText,
                      style: AppTextStyles.Body.copyWith(
                        color: AppColors.Primary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.chevron_right,
                      size: 24,
                      color: AppColors.Primary,
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.route,
                      size: 26,
                      color: AppColors.Primary,
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        route.modeSummary,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.Body.copyWith(
                          color: AppColors.Primary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: AppButton(
                        text: 'Save Route',
                        onPressed: onSavePressed,
                        iconAsset: 'assets/icons/save_black.svg',
                        variant: AppButtonVariant.outline,
                        fullWidth: true,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AppButton(
                        text: 'Go',
                        onPressed: onGoPressed,
                        iconAsset: 'assets/icons/Send.svg',
                        fullWidth: true,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}