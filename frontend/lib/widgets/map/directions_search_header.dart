import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../theme/app_styles.dart';

class DirectionsSearchHeader extends StatelessWidget {
  final String originLabel;
  final String destinationLabel;
  final VoidCallback onBack;
  final VoidCallback onOriginTap;
  final VoidCallback onDestinationTap;
  final VoidCallback onSwap;

  const DirectionsSearchHeader({
    super.key,
    required this.originLabel,
    required this.destinationLabel,
    required this.onBack,
    required this.onOriginTap,
    required this.onDestinationTap,
    required this.onSwap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.Background,
      padding: EdgeInsets.fromLTRB(
        AppSpacing.screenMargin,
        MediaQuery.of(context).padding.top + 8,
        AppSpacing.screenMargin,
        16,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 50,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: InkWell(
                    onTap: onBack,
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.arrow_back,
                            size: 20,
                            color: AppColors.Primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Back',
                            style: AppTextStyles.Body.copyWith(
                              color: AppColors.Primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 50,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: InkWell(
                    onTap: onSwap,
                    borderRadius: BorderRadius.circular(999),
                    child: const SizedBox(
                      width: 50,
                      height: 50,
                      child: Icon(
                        Icons.swap_vert,
                        size: 32,
                        color: AppColors.Primary,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              children: [
                _DirectionsInputPill(
                  text: originLabel,
                  iconAsset: 'assets/icons/navigate_black.svg',
                  fallbackIcon: Icons.my_location,
                  iconColor: AppColors.Accent,
                  onTap: onOriginTap,
                ),
                const SizedBox(height: 8),
                _DirectionsInputPill(
                  text: 'To: $destinationLabel',
                  iconAsset: 'assets/icons/location_on.svg',
                  fallbackIcon: Icons.location_on_outlined,
                  iconColor: AppColors.Error,
                  onTap: onDestinationTap,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DirectionsInputPill extends StatelessWidget {
  final String text;
  final String iconAsset;
  final IconData fallbackIcon;
  final Color iconColor;
  final VoidCallback onTap;

  const _DirectionsInputPill({
    required this.text,
    required this.iconAsset,
    required this.fallbackIcon,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.Tertiary,
      borderRadius: BorderRadius.circular(40),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(40),
        child: Container(
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              SvgPicture.asset(
                iconAsset,
                width: 22,
                height: 22,
                colorFilter: ColorFilter.mode(
                  iconColor,
                  BlendMode.srcIn,
                ),
                placeholderBuilder: (_) => Icon(
                  fallbackIcon,
                  size: 22,
                  color: iconColor,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  text,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.Body.copyWith(
                    color: AppColors.Primary,
                  ),
                ),
              ),
              const SizedBox(width: 8),
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