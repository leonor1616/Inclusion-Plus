import 'package:flutter/material.dart';

import '../../models/map_place_model.dart';
import '../../theme/app_styles.dart';

class MapSearchResultCard extends StatelessWidget {
  final MapPlace place;
  final VoidCallback onTap;

  const MapSearchResultCard({
    super.key,
    required this.place,
    required this.onTap,
  });

  String get formattedCategory {
    return place.category.replaceAll('_', ' ');
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.only(bottom: 16),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(
              width: 0.9,
              color: AppColors.Secondary,
            ),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 63,
              height: 63,
              decoration: BoxDecoration(
                color: AppColors.Tertiary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.location_on_outlined,
                color: AppColors.PrimaryLighter,
                size: 32,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      place.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.BodyMedium.copyWith(
                        color: AppColors.Primary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      formattedCategory,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.TinyBody.copyWith(
                        color: AppColors.PrimaryLighter,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Row(
              children: [
                Text(
                  'Details',
                  style: AppTextStyles.BodyMedium.copyWith(
                    color: AppColors.Primary,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(
                  Icons.arrow_forward,
                  size: 33,
                  color: AppColors.Primary,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}