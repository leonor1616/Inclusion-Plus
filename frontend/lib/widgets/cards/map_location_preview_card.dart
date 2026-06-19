import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../theme/app_styles.dart';

class MapLocationPreviewCard extends StatelessWidget {
  final String name;
  final String category;
  final double distanceMeters;
  final String? imageUrl;
  final double rating;
  final VoidCallback onGoPressed;
  final VoidCallback? onTap;

  const MapLocationPreviewCard({
    super.key,
    required this.name,
    required this.category,
    required this.distanceMeters,
    required this.onGoPressed,
    this.onTap,
    this.imageUrl,
    this.rating = 4.2,
  });

  String get formattedDistance {
    if (distanceMeters < 100) {
      return '${distanceMeters.round()} m';
    }

    final km = distanceMeters / 1000;
    return '${km.toStringAsFixed(1)} Km';
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 361,
          height: 122,
          decoration: const BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Color(0x26000000),
                blurRadius: 6,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.White,
              border: Border.all(
                color: AppColors.Accent,
                width: 1,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: imageUrl != null && imageUrl!.isNotEmpty
                      ? Image.network(
                          imageUrl!,
                          width: 90,
                          height: 90,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _placeholderImage(),
                        )
                      : _placeholderImage(),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 90,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                name,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyles.Heading2.copyWith(
                                  color: AppColors.Primary,
                                ),
                              ),
                              Text(
                                _formatCategory(category),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyles.TinyBody.copyWith(
                                  color: AppColors.Primary,
                                ),
                              ),
                              Row(
                                children: [
                                  Flexible(
                                    flex: 0,
                                    child: Text(
                                      rating.toStringAsFixed(1),
                                      style: AppTextStyles.TinyBody.copyWith(
                                        color: AppColors.Primary,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Flexible(
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: List.generate(
                                        5,
                                        (index) => Padding(
                                          padding: EdgeInsets.only(
                                            right: index == 4 ? 0 : 2,
                                          ),
                                          child: SvgPicture.asset(
                                            'assets/icons/star_filled.svg',
                                            width: 14,
                                            height: 14,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 100,
                        height: 90,
                        padding: const EdgeInsets.only(left: 8),
                        decoration: const BoxDecoration(
                          border: Border(
                            left: BorderSide(
                              color: AppColors.Secondary,
                              width: 1,
                            ),
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              formattedDistance,
                              style: AppTextStyles.Heading1.copyWith(
                                color: AppColors.Primary,
                              ),
                            ),
                            SizedBox(
                              height: 50,
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                iconAlignment: IconAlignment.end,
                                onPressed: onGoPressed,
                                icon: const Icon(
                                  Icons.near_me_outlined,
                                  size: 20,
                                  color: AppColors.White,
                                ),
                                label: Text(
                                  'Go',
                                  style: AppTextStyles.Body.copyWith(
                                    color: AppColors.White,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 8,
                                  ),
                                  backgroundColor: AppColors.Accent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 3,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _placeholderImage() {
    return Container(
      width: 90,
      height: 90,
      color: AppColors.Tertiary,
      child: const Icon(
        Icons.location_on_outlined,
        color: AppColors.PrimaryLighter,
        size: 32,
      ),
    );
  }

  String _formatCategory(String value) {
    return value
        .replaceAll('_', ' ')
        .split(' ')
        .map(
          (word) => word.isEmpty
              ? word
              : word[0].toUpperCase() + word.substring(1),
        )
        .join(' ');
  }
}