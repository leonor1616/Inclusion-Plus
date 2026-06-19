import 'package:flutter/material.dart';

import '../../models/map_place_model.dart';
import '../../theme/app_styles.dart';
import '../buttons/bottom_sheet_toggle_button.dart';
import 'map_location_preview_card.dart';

class MapResultsBottomSheet extends StatefulWidget {
  final List<MapPlace> places;
  final Function(MapPlace) onGoPressed;

  const MapResultsBottomSheet({
    super.key,
    required this.places,
    required this.onGoPressed,
  });

  @override
  State<MapResultsBottomSheet> createState() => _MapResultsBottomSheetState();
}

class _MapResultsBottomSheetState extends State<MapResultsBottomSheet> {
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
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
    );

    setState(() {
      _isExpanded = !shouldMinimize;
    });
  }

  @override
  void dispose() {
    _sheetController.removeListener(_handleSheetSizeChanged);
    _sheetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      controller: _sheetController,
      initialChildSize: _initialSize,
      minChildSize: _minSize,
      maxChildSize: _maxSize,
      snap: true,
      snapSizes: const [_minSize, _initialSize, _maxSize],
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
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screenMargin,
                  8,
                  AppSpacing.screenMargin,
                  8,
                ),
                child: BottomSheetToggleButton(
                  isExpanded: _isExpanded,
                  collapsedText: 'Click to see results',
                  expandedText: 'Click to minimize results',
                  onTap: _toggleSheetExpansion,
                  leading: Text(
                    'Showing ${widget.places.length} Results Near You',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.BodyMedium.copyWith(
                      color: AppColors.Primary,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: ListView.separated(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.screenMargin,
                    8,
                    AppSpacing.screenMargin,
                    120,
                  ),
                  itemCount: widget.places.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final place = widget.places[index];
                    return MapLocationPreviewCard(
                      name: place.name,
                      category: place.category,
                      distanceMeters: place.distanceMeters,
                      imageUrl: place.imageUrl,
                      rating: place.rating,
                      onGoPressed: () => widget.onGoPressed(place),
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
