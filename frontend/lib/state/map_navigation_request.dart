import '../models/map_place_model.dart';

/// Small command object used by screens outside the Map tab to open the map
/// with the correct context already selected.
enum MapNavigationMode {
  overview,
  search,
  showPlace,
  directionsToPlace,
}

class MapNavigationRequest {
  // id lets MapScreen distinguish a new navigation command from the previous
  // one even if both commands have the same mode/place values.
  final int id;
  final MapNavigationMode mode;
  final MapPlace? place;
  final String? searchQuery;

  const MapNavigationRequest({
    required this.id,
    required this.mode,
    this.place,
    this.searchQuery,
  });

  factory MapNavigationRequest.overview(int id) {
    return MapNavigationRequest(id: id, mode: MapNavigationMode.overview);
  }

  factory MapNavigationRequest.search(int id, {String? query}) {
    return MapNavigationRequest(
      id: id,
      mode: MapNavigationMode.search,
      searchQuery: query,
    );
  }

  factory MapNavigationRequest.showPlace(int id, MapPlace place) {
    return MapNavigationRequest(
      id: id,
      mode: MapNavigationMode.showPlace,
      place: place,
    );
  }

  factory MapNavigationRequest.directionsToPlace(int id, MapPlace place) {
    return MapNavigationRequest(
      id: id,
      mode: MapNavigationMode.directionsToPlace,
      place: place,
    );
  }
}

class AppMapPlaces {
  static MapPlace university() {
    return MapPlace(
      externalLocationId: -1,
      name: 'ISCTE-IUL',
      category: 'Public University',
      latitude: 38.7478,
      longitude: -9.1534,
      source: 'app_static',
      sourceUrl: null,
      distanceMeters: 200,
      rating: 4.2,
      imageUrl: 'assets/images/iscte_building_wide.png',
      accessibilityTags: const [],
    );
  }

  static MapPlace room1E08() {
    return MapPlace(
      externalLocationId: -2,
      name: 'Room 1E08',
      category: 'Classroom',
      latitude: 38.74795,
      longitude: -9.15335,
      source: 'app_static',
      sourceUrl: null,
      distanceMeters: 200,
      rating: 4.2,
      imageUrl: 'assets/images/room_1e08.png',
      accessibilityTags: const [],
    );
  }

  static MapPlace elevator1() {
    return MapPlace(
      externalLocationId: -3,
      name: 'Elevator 1',
      category: 'Elevator Issue',
      latitude: 38.74785,
      longitude: -9.15342,
      source: 'app_static',
      sourceUrl: null,
      distanceMeters: 200,
      rating: 4.2,
      accessibilityTags: const [],
    );
  }

  static MapPlace library() {
    return MapPlace(
      externalLocationId: -4,
      name: 'Iscte-IUL Library',
      category: 'Library',
      latitude: 38.74805,
      longitude: -9.15385,
      source: 'app_static',
      sourceUrl: null,
      distanceMeters: 290,
      rating: 4.2,
      accessibilityTags: const [],
    );
  }

  static MapPlace emergencyServices() {
    return MapPlace(
      externalLocationId: -5,
      name: 'Emergency Services near Iscte-IUL',
      category: 'Emergency Services',
      latitude: 38.7481,
      longitude: -9.1536,
      source: 'app_static',
      sourceUrl: null,
      distanceMeters: 250,
      rating: 4.2,
      accessibilityTags: const [],
    );
  }
}
