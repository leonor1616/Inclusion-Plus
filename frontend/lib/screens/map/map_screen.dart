import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

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
import '../../widgets/map/directions_search_header.dart';
import '../../widgets/cards/main_map_bottom_sheet.dart';

import 'package:url_launcher/url_launcher.dart';

import '../../models/route_option_model.dart';
import '../../services/map_directions_service.dart';
import '../../utils/polyline_decoder.dart';
import '../../widgets/cards/route_results_bottom_sheet.dart';
import 'ai_chat_screen.dart';
import '../../widgets/buttons/app_back_button.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? mapController;

  final DraggableScrollableController _placeSheetController =
      DraggableScrollableController();

  final DraggableScrollableController _routeSheetController =
      DraggableScrollableController();

  final MapPlaceService _mapPlaceService = MapPlaceService();

  final MapDirectionsService _mapDirectionsService = MapDirectionsService();

  List<RouteOption> _routes = [];
  RouteOption? _selectedRoute;
  bool _isLoadingRoutes = false;
  String? _routeErrorMessage;
  bool _isShowingRouteResults = false;
  bool _isRouteSheetExpanded = false;

  Set<Polyline> _polylines = {};

  List<MapPlace> _places = [];
  bool _isLoadingPlaces = true;
  LatLng? _userPosition;
  MapPlace? _routeOriginPlace;
  LatLng? _routeDestinationOverridePosition;
  String? _routeDestinationOverrideLabel;

  MapPlace? _selectedPlace;
  bool _isPlaceSheetExpanded = false;

  static const LatLng initialPosition = LatLng(38.7477, -9.1530);

  LatLng get _routeOrigin {
    final originPlace = _routeOriginPlace;

    if (originPlace != null) {
      return LatLng(originPlace.latitude, originPlace.longitude);
    }

    return _userPosition ?? initialPosition;
  }

  String get _routeOriginLabel {
    final originPlace = _routeOriginPlace;

    if (originPlace != null) {
      return 'From: ${originPlace.name}';
    }

    return 'From: Your Location';
  }

  LatLng? get _routeDestination {
    final overridePosition = _routeDestinationOverridePosition;

    if (overridePosition != null) {
      return overridePosition;
    }

    final destinationPlace = _selectedPlace;

    if (destinationPlace == null) {
      return null;
    }

    return LatLng(destinationPlace.latitude, destinationPlace.longitude);
  }

  String get _routeDestinationLabel {
    final overrideLabel = _routeDestinationOverrideLabel;

    if (overrideLabel != null && overrideLabel.isNotEmpty) {
      return overrideLabel;
    }

    return _selectedPlace?.name ?? 'Destination';
  }

  MapSearchResultsScreen _buildSearchResultsScreen() {
    final searchOrigin = _userPosition ?? initialPosition;

    return MapSearchResultsScreen(
      currentLatitude: searchOrigin.latitude,
      currentLongitude: searchOrigin.longitude,
    );
  }

  Set<Marker> get _markers {
    final markers = <Marker>{};

    if (_userPosition != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('user_location'),
          position: _userPosition!,
          infoWindow: const InfoWindow(title: 'Your location'),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueAzure,
          ),
        ),
      );
    }

    if (_routeOriginPlace != null) {
      markers.add(
        Marker(
          markerId: MarkerId(
            'route_origin_${_routeOriginPlace!.externalLocationId}',
          ),
          position: LatLng(
            _routeOriginPlace!.latitude,
            _routeOriginPlace!.longitude,
          ),
          infoWindow: InfoWindow(
            title: _routeOriginPlace!.name,
            snippet: 'Route origin',
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueGreen,
          ),
        ),
      );
    }

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
    _loadUserLocation();
    _placeSheetController.addListener(_handlePlaceSheetSizeChanged);
    _routeSheetController.addListener(_handleRouteSheetSizeChanged);
  }

  Future<void> _loadUserLocation() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;

      var permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      if (!mounted) return;

      final detectedLatLng = LatLng(position.latitude, position.longitude);

      final isSimulatorDefaultLocation =
          detectedLatLng.latitude > 37.0 &&
          detectedLatLng.latitude < 38.5 &&
          detectedLatLng.longitude > -123.0 &&
          detectedLatLng.longitude < -121.0;

      final userLatLng = isSimulatorDefaultLocation
          ? initialPosition
          : detectedLatLng;
      setState(() {
        _userPosition = userLatLng;
      });

      mapController?.animateCamera(CameraUpdate.newLatLngZoom(userLatLng, 16));
    } catch (e) {
      debugPrint('Failed to load user location: $e');
    }
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

  void _handleRouteSheetSizeChanged() {
    if (!_routeSheetController.isAttached) return;

    final isExpanded = _routeSheetController.size >= 0.70;

    if (_isRouteSheetExpanded != isExpanded) {
      setState(() {
        _isRouteSheetExpanded = isExpanded;
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
      MaterialPageRoute(builder: (_) => _buildSearchResultsScreen()),
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

  Future<void> _changeRouteOrigin() async {
    final selectedOrigin = await Navigator.push<MapPlace>(
      context,
      MaterialPageRoute(builder: (_) => _buildSearchResultsScreen()),
    );

    if (selectedOrigin == null) return;

    setState(() {
      _routeOriginPlace = selectedOrigin;
    });

    await _loadDirectionsForSelectedPlace();
  }

  Future<void> _changeRouteDestination() async {
    final selectedDestination = await Navigator.push<MapPlace>(
      context,
      MaterialPageRoute(builder: (_) => _buildSearchResultsScreen()),
    );

    if (selectedDestination == null) return;

    setState(() {
      _selectedPlace = selectedDestination;
      _isPlaceSheetExpanded = false;
    });

    mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(
        LatLng(selectedDestination.latitude, selectedDestination.longitude),
        17,
      ),
    );

    await _loadDirectionsForSelectedPlace();
  }

  Future<void> _swapRoutePlaces() async {
    final originPlace = _routeOriginPlace;
    final destinationPlace = _selectedPlace;
    final destinationOverride = _routeDestinationOverridePosition;

    if (destinationPlace == null) return;

    if (destinationOverride != null && originPlace != null) {
      setState(() {
        _routeOriginPlace = null;
        _selectedPlace = originPlace;
        _routeDestinationOverridePosition = null;
        _routeDestinationOverrideLabel = null;
      });

      mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(originPlace.latitude, originPlace.longitude),
          17,
        ),
      );

      await _loadDirectionsForSelectedPlace();
      return;
    }

    if (originPlace == null) {
      final currentDestination = _userPosition ?? initialPosition;

      setState(() {
        _routeOriginPlace = destinationPlace;
        _routeDestinationOverridePosition = currentDestination;
        _routeDestinationOverrideLabel = 'Your Location';
      });

      mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(destinationPlace.latitude, destinationPlace.longitude),
          17,
        ),
      );

      await _loadDirectionsForSelectedPlace();
      return;
    }

    setState(() {
      _routeOriginPlace = destinationPlace;
      _selectedPlace = originPlace;
      _routeDestinationOverridePosition = null;
      _routeDestinationOverrideLabel = null;
    });

    mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(
        LatLng(originPlace.latitude, originPlace.longitude),
        17,
      ),
    );

    await _loadDirectionsForSelectedPlace();
  }

  void _clearSelectedPlace() {
    setState(() {
      _selectedPlace = null;
      _isPlaceSheetExpanded = false;
      _isShowingRouteResults = false;
      _routes = [];
      _selectedRoute = null;
      _routeErrorMessage = null;
      _isLoadingRoutes = false;
      _polylines = {};
      _routeOriginPlace = null;
    });

    mapController?.animateCamera(CameraUpdate.newLatLngZoom(_routeOrigin, 16));
  }

  void _togglePlaceSheet() {
    if (!_placeSheetController.isAttached) return;

    final shouldMinimize = _placeSheetController.size >= 0.70;
    final targetSize = shouldMinimize ? 0.42 : 0.86;

    _placeSheetController.animateTo(
      targetSize,
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
    );

    setState(() {
      _isPlaceSheetExpanded = !shouldMinimize;
    });
  }

  void _toggleRouteSheet() {
    if (!_routeSheetController.isAttached) return;

    final shouldMinimize = _routeSheetController.size >= 0.70;
    final targetSize = shouldMinimize ? 0.42 : 0.86;

    _routeSheetController.animateTo(
      targetSize,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
    );

    setState(() {
      _isRouteSheetExpanded = !shouldMinimize;
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
    _routeSheetController.removeListener(_handleRouteSheetSizeChanged);
    _routeSheetController.dispose();
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
            myLocationEnabled: _userPosition != null,
            myLocationButtonEnabled: true,
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
            compassEnabled: true,
            polylines: _polylines,
            onMapCreated: (controller) {
              mapController = controller;
            },
          ),

          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: _isShowingRouteResults && _selectedPlace != null
                ? DirectionsSearchHeader(
                    originLabel: _routeOriginLabel,
                    destinationLabel: _routeDestinationLabel,
                    onBack: _clearRouteResults,
                    onOriginTap: _changeRouteOrigin,
                    onDestinationTap: _changeRouteDestination,
                    onSwap: _swapRoutePlaces,
                  )
                : Container(
                    color: AppColors.Background,
                    padding: EdgeInsets.fromLTRB(
                      AppSpacing.screenMargin,
                      MediaQuery.of(context).padding.top + 8,
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
          else if (_selectedPlace != null && _isShowingRouteResults)
            RouteResultsBottomSheet(
              routes: _routes,
              selectedRoute: _selectedRoute,
              controller: _routeSheetController,
              isExpanded: _isRouteSheetExpanded,
              onToggleExpanded: _toggleRouteSheet,
              isLoading: _isLoadingRoutes,
              errorMessage: _routeErrorMessage,
              onRetry: _loadDirectionsForSelectedPlace,
              onRouteSelected: _selectRoute,
              onRouteSavePressed: (route) {
                debugPrint('Save route ${route.id}');
              },
              onRouteGoPressed: _openRouteInGoogleMaps,
            )
          else if (_selectedPlace != null)
            DraggableScrollableSheet(
              controller: _placeSheetController,
              initialChildSize: 0.42,
              minChildSize: 0.24,
              maxChildSize: 0.86,
              snap: true,
              snapSizes: const [0.24, 0.42, 0.86],
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
                        isExpanded: _isPlaceSheetExpanded,
                        collapsedText: "Click to see this place's details",
                        expandedText: "Click to minimize this place's details",
                        onTap: _togglePlaceSheet,
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: ListView(
                          controller: scrollController,
                          padding: EdgeInsets.zero,
                          children: [
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                      onPressed:
                                          _loadDirectionsForSelectedPlace,
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
                                onPressed: _loadDirectionsForSelectedPlace,
                                iconAsset: 'assets/icons/Send.svg',
                                fullWidth: true,
                              ),

                            const SizedBox(height: 16),

                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(1.4),
                              child: AppButton(
                                text: 'Ask AI Assistant about this place',
                                onPressed: () {
                                  if (_selectedPlace == null) return;
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          AIChatScreen(place: _selectedPlace!),
                                    ),
                                  );
                                },
                                iconAsset: 'assets/icons/ai.svg',
                                variant: AppButtonVariant.gradientOutline,
                                fullWidth: true,
                              ),
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
                      ),
                    ],
                  ),
                );
              },
            )
          else
            MainMapBottomSheet(
              universityPlace: _mainUniversityPlace,
              onUniversityGoPressed: _openDirectionsToUniversity,
            ),
        ],
      ),
    );
  }

  Future<void> _loadDirectionsForSelectedPlace() async {
    final place = _selectedPlace;
    if (place == null) return;

    final destination = _routeDestination;
    if (destination == null) return;

    setState(() {
      _isShowingRouteResults = true;
      _isRouteSheetExpanded = false;
      _isLoadingRoutes = true;
      _routeErrorMessage = null;
      _routes = [];
      _selectedRoute = null;
      _polylines = {};
    });

    try {
      final routes = await _mapDirectionsService.getDirections(
        originLat: _routeOrigin.latitude,
        originLng: _routeOrigin.longitude,
        destinationLat: destination.latitude,
        destinationLng: destination.longitude,
      );

      if (!mounted) return;

      final firstRoute = routes.isNotEmpty ? routes.first : null;
      final encodedPolyline = firstRoute?.encodedPolyline;

      setState(() {
        _routes = routes;
        _selectedRoute = firstRoute;
        _isLoadingRoutes = false;

        if (encodedPolyline != null && encodedPolyline.isNotEmpty) {
          _polylines = {
            Polyline(
              polylineId: const PolylineId('selected_route'),
              points: PolylineDecoder.decode(encodedPolyline),
              width: 5,
              color: AppColors.Accent,
            ),
          };
        }
      });
    } catch (e) {
      debugPrint('Failed to load directions: $e');

      if (!mounted) return;

      setState(() {
        _isLoadingRoutes = false;
        _routeErrorMessage = 'Could not calculate route. Please try again.';
      });
    }
  }

  void _selectRoute(RouteOption route) {
    setState(() {
      _selectedRoute = route;

      final encodedPolyline = route.encodedPolyline;

      if (encodedPolyline != null && encodedPolyline.isNotEmpty) {
        _polylines = {
          Polyline(
            polylineId: const PolylineId('selected_route'),
            points: PolylineDecoder.decode(encodedPolyline),
            width: 5,
            color: AppColors.Accent,
          ),
        };
      }
    });
  }

  Future<void> _openRouteInGoogleMaps(RouteOption route) async {
    final uri = Uri.parse(route.googleMapsUrl);

    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      debugPrint('Could not open Google Maps URL: ${route.googleMapsUrl}');
    }
  }

  void _clearRouteResults() {
    setState(() {
      _isShowingRouteResults = false;
      _isRouteSheetExpanded = false;
      _routes = [];
      _selectedRoute = null;
      _routeErrorMessage = null;
      _isLoadingRoutes = false;
      _polylines = {};
      _routeOriginPlace = null;
    });
  }

  MapPlace get _fallbackUniversityPlace {
    return MapPlace(
      externalLocationId: -1,
      name: 'ISCTE-IUL',
      category: 'Public University',
      latitude: 38.7478,
      longitude: -9.1534,
      source: 'fallback',
      sourceUrl: null,
      distanceMeters: 200,
      rating: 4.2,
      imageUrl: 'assets/images/iscte_iul.png',
      accessibilityTags: const [],
    );
  }

  MapPlace get _mainUniversityPlace {
    final isctePlace = _places.where((place) {
      final name = place.name.toLowerCase();
      final category = place.category.toLowerCase();

      return name.contains('iscte') ||
          name.contains('instituto universitário') ||
          category.contains('university');
    }).toList();

    if (isctePlace.isNotEmpty) {
      return isctePlace.first;
    }

    return _fallbackUniversityPlace;
  }

  Future<void> _openDirectionsToUniversity() async {
    final universityPlace = _mainUniversityPlace;

    setState(() {
      _selectedPlace = universityPlace;
      _isPlaceSheetExpanded = false;
      _isShowingRouteResults = false;
      _isRouteSheetExpanded = false;
      _routes = [];
      _selectedRoute = null;
      _routeErrorMessage = null;
      _isLoadingRoutes = false;
      _polylines = {};
      _routeOriginPlace = null;
    });

    mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(
        LatLng(universityPlace.latitude, universityPlace.longitude),
        17,
      ),
    );

    await _loadDirectionsForSelectedPlace();
  }
}
