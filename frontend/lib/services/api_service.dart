import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/user_model.dart';
import '../models/country_model.dart';

import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

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

  if (envUrl.isNotEmpty) {
    return envUrl;
  }

  if (kIsWeb) {
    return 'http://localhost:3000';
  }

  if (Platform.isAndroid) {
    return 'http://10.0.2.2:3000';
  }

  if (Platform.isIOS) {
    return 'http://localhost:3000';
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

    final message = data is Map && data['error'] != null
        ? data['error'].toString()
        : 'Request failed';

    throw ApiException(message, statusCode: response.statusCode);
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
}
