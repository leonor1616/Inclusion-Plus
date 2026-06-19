import 'dart:async';

import 'package:flutter/material.dart';

import '../../models/map_place_model.dart';
import '../../services/map_place_service.dart';
import '../../theme/app_styles.dart';
import '../../widgets/cards/map_search_result_card.dart';
import '../../widgets/search_bar.dart';

class MapSearchResultsScreen extends StatefulWidget {
  final double? currentLatitude;
  final double? currentLongitude;
  final String? initialQuery;

  const MapSearchResultsScreen({
    super.key,
    this.currentLatitude,
    this.currentLongitude,
    this.initialQuery,
  });

  @override
  State<MapSearchResultsScreen> createState() => _MapSearchResultsScreenState();
}

class _MapSearchResultsScreenState extends State<MapSearchResultsScreen> {
  final TextEditingController _controller = TextEditingController();
  final MapPlaceService _mapPlaceService = MapPlaceService();
  final FocusNode _searchFocusNode = FocusNode();

  Timer? _debounce;

  List<MapPlace> _results = [];
  List<MapPlace> _recentPlaces = [];

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _searchFocusNode.requestFocus();

      final initialQuery = widget.initialQuery?.trim();
      if (initialQuery != null && initialQuery.isNotEmpty) {
        _controller.text = initialQuery;
        _controller.selection = TextSelection.fromPosition(
          TextPosition(offset: _controller.text.length),
        );
        _search(initialQuery);
      }
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchFocusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _debounce?.cancel();

    _debounce = Timer(const Duration(milliseconds: 350), () {
      _search(query);
    });
  }

  Future<void> _search(String query) async {
    final cleanQuery = query.trim();

    if (cleanQuery.length < 2) {
      setState(() {
        _results = _recentPlaces;
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      debugPrint(
        'Search location: ${widget.currentLatitude}, ${widget.currentLongitude}',
      );
      final results = await _mapPlaceService.searchPlaces(
        query: cleanQuery,
        latitude: widget.currentLatitude,
        longitude: widget.currentLongitude,
      );

      if (!mounted) return;

      setState(() {
        _results = results;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Failed to search places: $e');

      if (!mounted) return;

      setState(() {
        _results = [];
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Search error: $e'),
        ),
      );
    }
  }

  void _selectPlace(MapPlace place) {
    setState(() {
      _recentPlaces.removeWhere(
        (recentPlace) =>
            recentPlace.externalLocationId == place.externalLocationId,
      );
      _recentPlaces.insert(0, place);

      if (_recentPlaces.length > 5) {
        _recentPlaces = _recentPlaces.take(5).toList();
      }
    });

    Navigator.pop(context, place);
  }

  @override
  Widget build(BuildContext context) {
    final queryIsEmpty = _controller.text.trim().isEmpty;

    return Scaffold(
      backgroundColor: AppColors.Background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenMargin,
                8,
                AppSpacing.screenMargin,
                16,
              ),
              child: Row(
                children: [
                  InkWell(
                    onTap: () => Navigator.pop(context),
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
                  Expanded(
                    child: AppSearchBar(
                      controller: _controller,
                      focusNode: _searchFocusNode,
                      hintText: 'Search Here',
                      variant: AppSearchBarVariant.filled,
                      onChanged: _onSearchChanged,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Builder(
                builder: (context) {
                  if (_isLoading) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (queryIsEmpty && _recentPlaces.isEmpty) {
                    return const SizedBox.shrink();
                  }

                  if (_results.isEmpty) {
                    return Center(
                      child: Text(
                        'No results found',
                        style: AppTextStyles.Body.copyWith(
                          color: AppColors.PrimaryLighter,
                        ),
                      ),
                    );
                  }

                  return ListView.separated(
                    padding: AppSpacing.screenPadding,
                    itemCount: _results.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final place = _results[index];

                      return MapSearchResultCard(
                        place: place,
                        onTap: () => _selectPlace(place),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}