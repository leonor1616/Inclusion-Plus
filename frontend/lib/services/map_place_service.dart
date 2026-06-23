import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../models/map_place_model.dart';
import 'api_service.dart';

class MapPlaceService {
  static String get baseUrl => ApiService.baseUrl;

  // Loads nearby map places from the backend cache/aggregation endpoint.
  Future<List<MapPlace>> getPlaces({
    required double latitude,
    required double longitude,
    double radius = 500,
    String? token,
  }) async {
    final uri = Uri.parse(
      '$baseUrl/map/places?latitude=$latitude&longitude=$longitude&radius=$radius',
    );

    final response = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to fetch map places: ${response.statusCode} ${response.body}',
      );
    }

    final data = jsonDecode(response.body);
    if (data['places'] == null || data['places'] is! List) {
      throw Exception('Invalid map places response: missing places list');
    }
    final places = data['places'] as List;

    return places.map((place) => MapPlace.fromJson(place)).toList();
  }

  Future<List<MapPlace>> searchPlaces({
    required String query,
    double? latitude,
    double? longitude,
  }) async {
    // Search may trigger a backend fallback to Google Places when the local
    // external_location cache has too few matching results.
    final uri = Uri.parse('$baseUrl/map/search').replace(
      queryParameters: {
        'query': query,
        if (latitude != null) 'latitude': latitude.toString(),
        if (longitude != null) 'longitude': longitude.toString(),
      },
    );

    final response = await http.get(
      uri,
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to search map places: ${response.statusCode} ${response.body}',
      );
    }

    final data = jsonDecode(response.body);
    final places = data['places'] as List;

    return places.map((place) => MapPlace.fromJson(place)).toList();
  }
}
