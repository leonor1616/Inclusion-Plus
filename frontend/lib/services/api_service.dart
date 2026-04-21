import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://localhost:3000'; //trocar quando testar em android

  static Future<String> getHealth() async {
    final response = await http.get(Uri.parse('$baseUrl/health'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['message'];
    } else {
      throw Exception('Failed to connect to backend');
    }
  }
}