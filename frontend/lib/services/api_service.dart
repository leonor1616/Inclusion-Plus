import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/user_model.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

class ApiService {
  static const String baseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'http://localhost:3000',);

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

    throw ApiException(
      message,
      statusCode: response.statusCode,
    );
  }

  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: _headers(),
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    final data = _decodeResponse(response);
    return data as Map<String, dynamic>;
  }

  static Future<UserModel> getMe({
    required String token,
  }) async {
    final response = await http.get(
      Uri.parse('$baseUrl/me'),
      headers: _headers(token: token),
    );

    final data = _decodeResponse(response);
    return UserModel.fromJson(data);
  }

  static Future<String> getHealth() async {
    final response = await http.get(
      Uri.parse('$baseUrl/health'),
    );

    final data = _decodeResponse(response);
    return data['message'].toString();
  }
}