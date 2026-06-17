import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../models/map_place_model.dart';
import '../../services/map_place_service.dart';
import '../../theme/app_styles.dart';
import '../../widgets/cards/map_results_bottom_sheet.dart';
import '../../widgets/search_bar.dart';
import 'search_results_screen.dart';

import '../../widgets/cards/place_profile_info_card.dart';
import '../../widgets/accessibility_tag.dart';
import '../../widgets/buttons/button.dart';
import '../../widgets/buttons/bottom_sheet_toggle_button.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? mapController;

  final DraggableScrollableController _placeSheetController =
      DraggableScrollableController();

  final MapPlaceService _mapPlaceService = MapPlaceService();

  List<MapPlace> _places = [];
  bool _isLoadingPlaces = true;

  MapPlace? _selectedPlace;
  bool _isPlaceSheetExpanded = false;

  //trocar para a posição do utilizador
  static const LatLng initialPosition = LatLng(38.7477, -9.1530);

  Set<Marker> get _markers {
    final markers = <Marker>{
      const Marker(
        markerId: MarkerId('iscte'),
        position: LatLng(38.7477, -9.1530),
      ),
    };

    if (_selectedPlace != null) {
      markers.add(
        Marker(
          markerId: MarkerId('selected_${_selectedPlace!.externalLocationId}'),
          position: LatLng(_selectedPlace!.latitude, _selectedPlace!.longitude),
          infoWindow: InfoWindow(
            title: _selectedPlace!.name,
            snippet: _selectedPlace!.category,
          ),
        ),
      );
    }

    return markers;
  }

  @override
  void initState() {
    super.initState();
    _loadPlaces();
    _placeSheetController.addListener(_handlePlaceSheetSizeChanged);
  }

  void _handlePlaceSheetSizeChanged() {
    if (!_placeSheetController.isAttached) return;

    final isExpanded = _placeSheetController.size >= 0.70;

    if (_isPlaceSheetExpanded != isExpanded) {
      setState(() {
        _isPlaceSheetExpanded = isExpanded;
      });
    }
  }

  Future<void> _loadPlaces() async {
    try {
      final places = await _mapPlaceService.getPlaces(
        latitude: initialPosition.latitude,
        longitude: initialPosition.longitude,
        radius: 500,
      );

      if (!mounted) return;

      setState(() {
        _places = places;
        _isLoadingPlaces = false;
      });
    } catch (e) {
      debugPrint('Failed to load map places: $e');

      if (!mounted) return;

      setState(() {
        _isLoadingPlaces = false;
      });
    }
  }

  Future<void> _openSearch() async {
    final selectedPlace = await Navigator.push<MapPlace>(
      context,
      MaterialPageRoute(builder: (_) => const MapSearchResultsScreen()),
    );

    if (selectedPlace == null) return;

    setState(() {
      _selectedPlace = selectedPlace;
      _isPlaceSheetExpanded = false;
    });

    mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(
        LatLng(selectedPlace.latitude, selectedPlace.longitude),
        17,
      ),
    );
  }

  void _clearSelectedPlace() {
    setState(() {
      _selectedPlace = null;
      _isPlaceSheetExpanded = false;
    });

    mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(initialPosition, 16),
    );
  }

  void _togglePlaceSheet() {
    if (!_placeSheetController.isAttached) return;

    final shouldMinimize = _placeSheetController.size >= 0.70;
    final targetSize = shouldMinimize ? 0.32 : 0.86;

    _placeSheetController.animateTo(
      targetSize,
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
    );

    setState(() {
      _isPlaceSheetExpanded = !shouldMinimize;
    });
  }

  bool _isStudentUniversityPlace(MapPlace place) {
    final name = place.name.toLowerCase();
    return name.contains('iscte');
  }

  @override
  void dispose() {
    _placeSheetController.removeListener(_handlePlaceSheetSizeChanged);
    _placeSheetController.dispose();
    mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchText = _selectedPlace?.name ?? 'Search Here';

    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: const CameraPosition(
              target: initialPosition,
              zoom: 16,
            ),
            markers: _markers,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
            compassEnabled: true,
            onMapCreated: (controller) {
              mapController = controller;
            },
          ),

          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              color: AppColors.Background,
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenMargin,
                56,
                AppSpacing.screenMargin,
                16,
              ),
              child: Row(
                children: [
                  if (_selectedPlace != null) ...[
                    InkWell(
                      onTap: _clearSelectedPlace,
                      child: Row(
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
                    const SizedBox(width: 16),
                  ],
                  Expanded(
                    child: AppSearchBar(
                      hintText: searchText,
                      variant: AppSearchBarVariant.filled,
                      readOnly: true,
                      onTap: _openSearch,
                    ),
                  ),
                ],
              ),
            ),
          ),

          if (_isLoadingPlaces)
            const Positioned(
              left: 0,
              right: 0,
              bottom: 140,
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_selectedPlace != null)
            DraggableScrollableSheet(
              controller: _placeSheetController,
              initialChildSize: 0.32,
              minChildSize: 0.32,
              maxChildSize: 0.86,
              builder: (context, scrollController) {
                final place = _selectedPlace!;
                final isStudentUniversity = _isStudentUniversityPlace(place);

                return Container(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
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
                  child: ListView(
                    controller: scrollController,
                    padding: EdgeInsets.zero,
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
                        isExpanded: _isPlaceSheetExpanded,
                        collapsedText: "Click to see this place's details",
                        expandedText: "Click to minimize this place's details",
                        onTap: _togglePlaceSheet,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 85,
                            height: 85,
                            decoration: BoxDecoration(
                              color: AppColors.Tertiary,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.location_on_outlined,
                              size: 40,
                              color: AppColors.PrimaryLighter,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  place.name,
                                  style: AppTextStyles.Heading1.copyWith(
                                    color: AppColors.Primary,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  place.category.replaceAll('_', ' '),
                                  style: AppTextStyles.Body.copyWith(
                                    color: AppColors.PrimaryLighter,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      if (isStudentUniversity)
                        Row(
                          children: [
                            Expanded(
                              child: AppButton(
                                text: 'Get Directions',
                                onPressed: () {},
                                iconAsset: 'assets/icons/Send.svg',
                                fullWidth: true,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: AppButton(
                                text: 'Indoor Map',
                                onPressed: () {},
                                iconAsset: 'assets/icons/map.svg',
                                variant: AppButtonVariant.outline,
                                fullWidth: true,
                              ),
                            ),
                          ],
                        )
                      else
                        AppButton(
                          text: 'Get Directions',
                          onPressed: () {},
                          iconAsset: 'assets/icons/Send.svg',
                          fullWidth: true,
                        ),

                      const SizedBox(height: 16),

                      AppButton(
                        text: 'Ask AI Assistant about this place',
                        onPressed: () {},
                        iconAsset: 'assets/icons/help.svg',
                        variant: AppButtonVariant.outline,
                        fullWidth: true,
                      ),

                      const SizedBox(height: 28),

                      Text(
                        'Accessibility Rating',
                        style: AppTextStyles.Heading2.copyWith(
                          color: AppColors.Primary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '4.2/5  ★★★★★  (35 Ratings by users)',
                        style: AppTextStyles.Body.copyWith(
                          color: AppColors.Primary,
                        ),
                      ),

                      const SizedBox(height: 28),

                      Text(
                        'Accessibility Features',
                        style: AppTextStyles.Heading2.copyWith(
                          color: AppColors.Primary,
                        ),
                      ),
                      const SizedBox(height: 12),

                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: place.accessibilityTags
                            .map((tag) => AccessibilityTag(tag: tag))
                            .toList(),
                      ),

                      const SizedBox(height: 28),

                      Text(
                        'Details',
                        style: AppTextStyles.Heading2.copyWith(
                          color: AppColors.Primary,
                        ),
                      ),
                      const SizedBox(height: 12),

                      PlaceProfileInfoCard(
                        status: 'Open',
                        address: place.sourceUrl,
                        email: null,
                        phone: null,
                      ),

                      const SizedBox(height: 24),

                      AppButton(
                        text: 'Save This Location',
                        onPressed: () {},
                        iconAsset: 'assets/icons/save_black.svg',
                        variant: AppButtonVariant.outline,
                        fullWidth: true,
                      ),

                      const SizedBox(height: 120),
                    ],
                  ),
                );
              },
            )
          else
            MapResultsBottomSheet(
              places: _places,
              onGoPressed: (place) {
                debugPrint('Go to ${place.name}');
              },
            ),
        ],
      ),
    );
  }
}
