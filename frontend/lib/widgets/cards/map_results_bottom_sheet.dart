import 'package:flutter/material.dart';

import '../../models/map_place_model.dart';
import '../../theme/app_styles.dart';
import '../buttons/bottom_sheet_toggle_button.dart';
import '../buttons/button.dart';
import 'map_location_preview_card.dart';


class MapResultsBottomSheet extends StatelessWidget {
  final List<MapPlace> places;
  final Function(MapPlace) onGoPressed;

  const MapResultsBottomSheet({
    super.key,
    required this.places,
    required this.onGoPressed,
  });

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.32,
      minChildSize: 0.12,
      maxChildSize: 0.6,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.Background,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(20),
            ),
            boxShadow: [
              BoxShadow(
                color: Color(0x26000000),
                blurRadius: 6,
                offset: Offset(0, -3),
              ),
            ],
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Center(
                child: Container(
                  width: 56,
                  height: 5,
                  decoration: BoxDecoration(
                    color: AppColors.Secondary,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.separated(
                  controller: scrollController,
                  padding: AppSpacing.screenPadding,
                  itemCount: places.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final place = places[index];
                    return MapLocationPreviewCard(
                      name: place.name,
                      category: place.category,
                      distanceMeters: place.distanceMeters,
                      imageUrl: place.imageUrl,
                      rating: place.rating,
                      onGoPressed: () => onGoPressed(place),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
