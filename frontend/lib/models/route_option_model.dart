class RouteOption {
  final String id;
  final String durationText;
  final String distanceText;
  final String arrivalTimeText;
  final String modeSummary;
  final String lineSummary;
  final String? encodedPolyline;
  final String googleMapsUrl;

  const RouteOption({
    required this.id,
    required this.durationText,
    required this.distanceText,
    required this.arrivalTimeText,
    required this.modeSummary,
    required this.lineSummary,
    required this.googleMapsUrl,
    this.encodedPolyline,
  });

  factory RouteOption.fromJson(Map<String, dynamic> json) {
    return RouteOption(
      id: json['id']?.toString() ?? '',
      durationText: json['durationText']?.toString() ?? '',
      distanceText: json['distanceText']?.toString() ?? '',
      arrivalTimeText: json['arrivalTimeText']?.toString() ?? '',
      modeSummary: json['modeSummary']?.toString() ?? '',
      lineSummary: json['lineSummary']?.toString() ??
          json['modeSummary']?.toString() ??
          '',
      encodedPolyline: json['encodedPolyline']?.toString(),
      googleMapsUrl: json['googleMapsUrl']?.toString() ?? '',
    );
  }
}