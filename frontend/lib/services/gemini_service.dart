import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/map_place_model.dart';
import 'api_service.dart';

class GeminiService {
  static String get baseUrl => ApiService.baseUrl;

  // Requests a concise accessibility-oriented summary for the selected place.
  // The backend owns the Gemini API key and prompt construction.
  Future<String> getPlaceSummary(MapPlace place) async {
    final response = await http.post(
      Uri.parse('$baseUrl/ai/place-summary'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'placeName': place.name,
        'category': place.category,
        'accessibilityTags': place.accessibilityTags
            .map((tag) => tag.label)
            .toList(),
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to generate AI summary: ${response.body}');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;

    return data['summary']?.toString() ??
        'The AI assistant could not generate a summary.';
  }
}
