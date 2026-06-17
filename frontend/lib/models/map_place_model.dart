import 'accessibility_tag_model.dart';

class MapPlace {
  final int externalLocationId;
  final String name;
  final String category;
  final double latitude;
  final double longitude;
  final String source;
  final String? sourceUrl;
  final double distanceMeters;
  final double rating;
  final String? imageUrl;
  final List<AccessibilityTagModel> accessibilityTags;

  MapPlace({
    required this.externalLocationId,
    required this.name,
    required this.category,
    required this.latitude,
    required this.longitude,
    required this.source,
    required this.sourceUrl,
    required this.distanceMeters,
    required this.accessibilityTags,
    this.rating = 4.2,
    this.imageUrl,
  });

  factory MapPlace.fromJson(Map<String, dynamic> json) {
    return MapPlace(
      externalLocationId: int.parse(json['external_location_id'].toString()),
      name: json['name'] ?? 'Unnamed location',
      category: json['category'] ?? 'Unknown',
      latitude: double.tryParse(json['latitude'].toString()) ?? 0,
      longitude: double.tryParse(json['longitude'].toString()) ?? 0,
      source: json['source'] ?? '',
      sourceUrl: json['source_url'],
      distanceMeters:
          double.tryParse(json['distance_meters']?.toString() ?? '0') ?? 0,
      rating: 4.2,
      imageUrl: json['image_url'],
      accessibilityTags: _mapAccessibilityTags(json),
    );
  }
}
//trocar para os caminhos dos icones certos
const Map<String, AccessibilityTagModel> _knownAccessibilityTags = {
  'wheelchair_access': AccessibilityTagModel(
    name: 'wheelchair_access',
    label: 'Wheelchair Access',
    iconAsset: 'assets/icons/wheelchair.svg',
  ),
  'accessible_restroom': AccessibilityTagModel(
    name: 'accessible_restroom',
    label: 'Accessible Restroom',
    iconAsset: 'assets/icons/restroom.svg',
  ),
  'elevator_access': AccessibilityTagModel(
    name: 'elevator_access',
    label: 'Elevator Access',
    iconAsset: 'assets/icons/elevator.svg',
  ),
  'ramp_access': AccessibilityTagModel(
    name: 'ramp_access',
    label: 'Ramp Access',
    iconAsset: 'assets/icons/ramp.svg',
  ),
  'step_free_access': AccessibilityTagModel(
    name: 'step_free_access',
    label: 'Step-free Access',
    iconAsset: 'assets/icons/stairs.svg',
  ),
  'automatic_door': AccessibilityTagModel(
    name: 'automatic_door',
    label: 'Automatic Door',
    iconAsset: 'assets/icons/door.svg',
  ),
  'tactile_paving': AccessibilityTagModel(
    name: 'tactile_paving',
    label: 'Tactile Paving',
    iconAsset: 'assets/icons/tactile.svg',
  ),
};

List<AccessibilityTagModel> _mapAccessibilityTags(
  Map<String, dynamic> json,
) {
  final raw = json['raw_accessibility_data'];

  if (raw == null || raw is! Map<String, dynamic>) {
    return [];
  }

  final tagNames = <String>{};

  // Accessibility Cloud / Wheelmap style data.
  final accessibleWith = _asMap(raw['accessibleWith']);
  final partiallyAccessibleWith = _asMap(raw['partiallyAccessibleWith']);

  final isWheelchairAccessible =
      accessibleWith['wheelchair'] == true ||
      partiallyAccessibleWith['wheelchair'] == true;

  if (isWheelchairAccessible) {
    tagNames.add('wheelchair_access');
  }

  final areas = raw['areas'];
  if (areas is List) {
    for (final area in areas) {
      final areaMap = _asMap(area);
      final restrooms = areaMap['restrooms'];

      if (restrooms is List) {
        final hasAccessibleRestroom = restrooms.any((restroom) {
          final restroomMap = _asMap(restroom);
          return restroomMap['isAccessibleWithWheelchair'] == true;
        });

        if (hasAccessibleRestroom) {
          tagNames.add('accessible_restroom');
        }
      }
    }
  }

  // Google Places style data, if raw_accessibility_data later stores
  // accessibilityOptions from Google Places API.
  final googleAccessibilityOptions = _asMap(raw['accessibilityOptions']);

  if (googleAccessibilityOptions['wheelchairAccessibleEntrance'] == true) {
    tagNames.add('wheelchair_access');
    tagNames.add('step_free_access');
  }

  if (googleAccessibilityOptions['wheelchairAccessibleRestroom'] == true) {
    tagNames.add('accessible_restroom');
  }

  if (googleAccessibilityOptions['wheelchairAccessibleSeating'] == true) {
    tagNames.add('wheelchair_access');
  }

  final elevatorAccess =
      raw['elevator_access'] == true ||
      raw['elevatorAccess'] == true ||
      raw['hasElevator'] == true;

  if (elevatorAccess) {
    tagNames.add('elevator_access');
  }

  final rampAccess =
      raw['ramp_access'] == true ||
      raw['rampAccess'] == true ||
      raw['hasRamp'] == true;

  if (rampAccess) {
    tagNames.add('ramp_access');
  }

  final automaticDoor =
      raw['automatic_door'] == true ||
      raw['automaticDoor'] == true ||
      raw['hasAutomaticDoor'] == true;

  if (automaticDoor) {
    tagNames.add('automatic_door');
  }

  final tactilePaving =
      raw['tactile_paving'] == true ||
      raw['tactilePaving'] == true ||
      raw['hasTactilePaving'] == true;

  if (tactilePaving) {
    tagNames.add('tactile_paving');
  }

  return tagNames
      .map((name) => _knownAccessibilityTags[name])
      .whereType<AccessibilityTagModel>()
      .toList();
}

Map<String, dynamic> _asMap(dynamic value) {
  if (value is Map<String, dynamic>) {
    return value;
  }

  if (value is Map) {
    return value.map(
      (key, value) => MapEntry(
        key.toString(),
        value,
      ),
    );
  }

  return {};
}