import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/route_option_model.dart';

class MapDirectionsService {
  static const String baseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'http://localhost:3000',
);
  Future<List<RouteOption>> getDirections({
    required double originLat,
    required double originLng,
    required double destinationLat,
    required double destinationLng,
  }) async {
    final uri = Uri.parse('$baseUrl/map/directions').replace(
      queryParameters: {
        'originLat': originLat.toString(),
        'originLng': originLng.toString(),
        'destinationLat': destinationLat.toString(),
        'destinationLng': destinationLng.toString(),
      },
    );

    final response = await http.get(uri);

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to load directions: ${response.statusCode} ${response.body}',
      );
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final routesJson = data['routes'] as List<dynamic>? ?? [];

    return routesJson
        .map((routeJson) => RouteOption.fromJson(
              routeJson as Map<String, dynamic>,
            ))
        .toList();
  }
}