import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_model.dart';
import '../services/api_service.dart';

class AuthProvider extends ChangeNotifier {
  static const String _tokenKey = 'auth_token';

  // Holds the current JWT and user profile in memory; the token is also stored
  // in SharedPreferences so the session can survive app restarts.
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
          // Validate the saved token with the backend before trusting it.
          _user = await ApiService.getMe(token: savedToken);
        } catch (_) {
          await prefs.remove(_tokenKey);
          _token = null;
          _user = null;
        }
      }
    } catch (e) {
      _error = _formatAuthError(e);
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

      // After login, fetch /me so the app state has the normalized user model
      // returned by the backend instead of relying on the login payload.
      _token = receivedToken.toString();
      _user = await ApiService.getMe(token: _token!);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, _token!);
    } catch (e) {
      _error = _formatAuthError(e);
      _token = null;
      _user = null;
    }

    _isLoading = false;
    notifyListeners();
  }


  Future<void> register({
    required String email,
    required String password,
    required String fullName,
    String accountType = 'normal',
    int? universityId,
    String? countryCode,
    String? city,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await ApiService.register(
        email: email,
        password: password,
        fullName: fullName,
        accountType: accountType,
        universityId: universityId,
        countryCode: countryCode,
        city: city,
      );

      // Registration does not automatically return a token, so the provider
      // immediately logs in with the same credentials.
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
      _error = _formatAuthError(e);
      _token = null;
      _user = null;
    }

    _isLoading = false;
    notifyListeners();
  }


  String _formatAuthError(Object error) {
    final message = error.toString();

    if (message.contains('Failed to fetch') ||
        message.contains('SocketException') ||
        message.contains('Connection refused') ||
        message.contains('XMLHttpRequest error')) {
      return 'Could not connect to the authentication service. Make sure the backend is running at http://localhost:3000.';
    }

    return message;
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
