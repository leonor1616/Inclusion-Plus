import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_model.dart';
import '../services/api_service.dart';

class AuthProvider extends ChangeNotifier {
  static const String _tokenKey = 'auth_token';

  String? _token;
  UserModel? _user;
  bool _isLoading = false;
  bool _isLoadingSession = true;
  String? _error;

  String? get token => _token;
  UserModel? get user => _user;
  bool get isAuthenticated => _token != null;
  bool get isLoading => _isLoading;
  bool get isLoadingSession => _isLoadingSession;
  String? get error => _error;

  Future<void> loadSession() async {
    _isLoadingSession = true;
    _error = null;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final savedToken = prefs.getString(_tokenKey);

      if (savedToken != null && savedToken.isNotEmpty) {
        _token = savedToken;

        try {
          _user = await ApiService.getMe(token: savedToken);
        } catch (_) {
          await prefs.remove(_tokenKey);
          _token = null;
          _user = null;
        }
      }
    } catch (e) {
      _error = e.toString();
      _token = null;
      _user = null;
    }

    _isLoadingSession = false;
    notifyListeners();
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final loginData = await ApiService.login(
        email: email,
        password: password,
      );

      final receivedToken = loginData['token'];

      if (receivedToken == null || receivedToken.toString().isEmpty) {
        throw ApiException('Token not received from server');
      }

      _token = receivedToken.toString();
      _user = await ApiService.getMe(token: _token!);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, _token!);
    } catch (e) {
      _error = e.toString();
      _token = null;
      _user = null;
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);

    _token = null;
    _user = null;
    _error = null;

    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}