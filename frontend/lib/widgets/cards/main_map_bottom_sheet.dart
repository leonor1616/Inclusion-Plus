import 'package:flutter/material.dart';

import '../../models/map_place_model.dart';
import '../../theme/app_styles.dart';
import '../buttons/bottom_sheet_toggle_button.dart';
// import 'action_card.dart';
import 'map_location_preview_card.dart';

class MainMapBottomSheet extends StatefulWidget {
  final MapPlace universityPlace;
  final VoidCallback onUniversityGoPressed;

  const MainMapBottomSheet({
    super.key,
    required this.universityPlace,
    required this.onUniversityGoPressed,
  });

  @override
  State<MainMapBottomSheet> createState() => _MainMapBottomSheetState();
}

class _MainMapBottomSheetState extends State<MainMapBottomSheet> {
  static const double _initialSize = 0.42;
  static const double _minSize = 0.24;
  static const double _maxSize = 0.86;

  final DraggableScrollableController _sheetController =
      DraggableScrollableController();

  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _sheetController.addListener(_handleSheetSizeChanged);
  }

  @override
  void dispose() {
    _sheetController.removeListener(_handleSheetSizeChanged);
    _sheetController.dispose();
    super.dispose();
  }

  void _handleSheetSizeChanged() {
    if (!_sheetController.isAttached) return;

    final isExpanded = _sheetController.size >= 0.70;

    if (_isExpanded != isExpanded) {
      setState(() {
        _isExpanded = isExpanded;
      });
    }
  }

  void _toggleSheetExpansion() {
    if (!_sheetController.isAttached) return;

    final shouldMinimize = _sheetController.size >= 0.70;
    final targetSize = shouldMinimize ? _initialSize : _maxSize;

    _sheetController.animateTo(
      targetSize,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      controller: _sheetController,
      initialChildSize: _initialSize,
      minChildSize: _minSize,
      maxChildSize: _maxSize,
      snap: true,
      snapSizes: const [0.24, 0.42, 0.86],
      builder: (context, scrollController) {
        return Container(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screenMargin,
            12,
            AppSpacing.screenMargin,
            0,
          ),
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
              const SizedBox(height: 8),
              BottomSheetToggleButton(
                isExpanded: _isExpanded,
                collapsedText: 'Click to see map overview',
                expandedText: 'Click to minimize map overview',
                onTap: _toggleSheetExpansion,
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: EdgeInsets.zero,
                  children: [
                    Text(
                      'City Map Status (0 Alerts)',
                      style: AppTextStyles.Heading2.copyWith(
                        color: AppColors.Primary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No accessibility alerts in your city.',
                      style: AppTextStyles.TinyBody.copyWith(
                        color: AppColors.PrimaryLighter,
                      ),
                    ),
                    const SizedBox(height: 28),
                    Text(
                      'Your University',
                      style: AppTextStyles.Heading2.copyWith(
                        color: AppColors.Primary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    MapLocationPreviewCard(
                      name: widget.universityPlace.name,
                      category: widget.universityPlace.category,
                      distanceMeters: widget.universityPlace.distanceMeters,
                      imageUrl: widget.universityPlace.imageUrl,
                      rating: widget.universityPlace.rating,
                      onGoPressed: widget.onUniversityGoPressed,
                    ),
                    const SizedBox(height: 120),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}