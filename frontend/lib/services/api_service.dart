import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/user_model.dart';
import '../models/country_model.dart';

import 'package:flutter/foundation.dart' show TargetPlatform, defaultTargetPlatform, kIsWeb;

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

// trocar isto para que chame a api baseada em ip atual
class ApiService {
  static String get baseUrl {
    const envUrl = String.fromEnvironment('API_BASE_URL');

    // Allows production builds to inject the backend URL at compile time with
    // --dart-define=API_BASE_URL=...
    if (envUrl.isNotEmpty) {
      return envUrl;
    }

    // Android emulators cannot reach the host through localhost; 10.0.2.2 maps
    // to the development machine running the backend.
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:3000';
    }

    return 'http://localhost:3000';
  }

  static Map<String, String> _headers({String? token}) {
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  static dynamic _decodeResponse(http.Response response) {
    final data = response.body.isEmpty ? null : jsonDecode(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return data;
    }

    // Backend errors consistently use { error: "..." }; convert them into a
    // typed exception so screens/providers can display friendly messages.
    final message = data is Map && data['error'] != null
        ? data['error'].toString()
        : 'Request failed';

    throw ApiException(message, statusCode: response.statusCode);
  }


  static Future<UserModel> register({
    required String email,
    required String password,
    required String fullName,
    String accountType = 'normal',
    int? universityId,
    String? countryCode,
    String? city,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: _headers(),
      body: jsonEncode({
        'email': email,
        'password': password,
        'full_name': fullName,
        'account_type': accountType,
        'university_id': universityId,
        'country_code': countryCode,
        'city': city,
      }),
    );

    final data = _decodeResponse(response);
    return UserModel.fromJson(data as Map<String, dynamic>);
  }

  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: _headers(),
      body: jsonEncode({'email': email, 'password': password}),
    );

    final data = _decodeResponse(response);
    return data as Map<String, dynamic>;
  }

  static Future<UserModel> getMe({required String token}) async {
    final response = await http.get(
      Uri.parse('$baseUrl/me'),
      headers: _headers(token: token),
    );

    final data = _decodeResponse(response);
    return UserModel.fromJson(data);
  }

  static Future<String> getHealth() async {
    final response = await http.get(Uri.parse('$baseUrl/health'));

    final data = _decodeResponse(response);
    return data['message'].toString();
  }

  static Future<List<CountryModel>> searchCountries({
    required String search,
  }) async {
    final uri = Uri.parse(
      '$baseUrl/countries',
    ).replace(queryParameters: {'search': search});

    final response = await http.get(uri, headers: _headers());

    final data = _decodeResponse(response) as List;

    return data
        .map((item) => CountryModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  static Future<Map<String, dynamic>> createHelpRequest({
    required String token,
    required int incampusUniversityLocationId,
    required String requestType,
    required String urgencyLevel,
    String? message,
    String? scheduledFor,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/help-requests'),
      headers: _headers(token: token),
      body: jsonEncode({
        'incampus_university_location_id': incampusUniversityLocationId,
        'request_type': requestType,
        'message': message,
        'urgency_level': urgencyLevel,
        'scheduled_for': scheduledFor,
      }),
    );

    final data = _decodeResponse(response);
    return data as Map<String, dynamic>;
  }


  static Future<List<dynamic>> fetchCommunityPosts({
    required String token,
    String? postType,
    int limit = 20,
    int offset = 0,
  }) async {
    final query = <String, String>{
      'limit': limit.toString(),
      'offset': offset.toString(),
      if (postType != null && postType.isNotEmpty) 'type': postType,
    };

    final response = await http.get(
      Uri.parse('$baseUrl/posts').replace(queryParameters: query),
      headers: _headers(token: token),
    );

    final data = _decodeResponse(response);
    if (data is Map && data['data'] is List) {
      return data['data'] as List<dynamic>;
    }
    if (data is List) {
      return data;
    }
    return <dynamic>[];
  }

  static Future<Map<String, dynamic>> createCommunityPost({
    required String token,
    required String postType,
    required String content,
    int? rating,
    String? imageUrl,
    int? incampusUniversityLocationId = 1,
  }) async {
    // The community UI currently passes a default in-campus location when the
    // user has not linked a real place to the post.
    final response = await http.post(
      Uri.parse('$baseUrl/posts'),
      headers: _headers(token: token),
      body: jsonEncode({
        'incampus_university_location_id': incampusUniversityLocationId,
        'external_location_id': null,
        'post_type': postType,
        'content': content,
        'rating': rating,
        'image_url': imageUrl,
      }),
    );

    final data = _decodeResponse(response);
    return data as Map<String, dynamic>;
  }

  static Future<List<dynamic>> fetchPostComments({
    required String token,
    required int postId,
  }) async {
    final response = await http.get(
      Uri.parse('$baseUrl/posts/$postId/comments'),
      headers: _headers(token: token),
    );

    final data = _decodeResponse(response);
    if (data is List) {
      return data;
    }
    return <dynamic>[];
  }

  static Future<Map<String, dynamic>> createPostComment({
    required String token,
    required int postId,
    required String content,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/posts/$postId/comments'),
      headers: _headers(token: token),
      body: jsonEncode({'content': content}),
    );

    final data = _decodeResponse(response);
    return data as Map<String, dynamic>;
  }

}
