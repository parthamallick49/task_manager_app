import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import '../services/auth_service.dart';  // Make sure this file exists


class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  bool _isAuthenticated = false;
  String? _token;
  bool _isLoading = true;

  bool get isAuthenticated => _isAuthenticated;
  String? get token => _token;
  bool get isLoading => _isLoading;

  Future<bool> login(String email, String password) async {
    final token = await _authService.login(email, password);
    if (token != null) {
      _token = token;
      _isAuthenticated = true;
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<void> logout() async {
    await _authService.logout();
    _token = null;
    _isAuthenticated = false;
    notifyListeners();
  }

  /*Future<void> checkAuthStatus() async {
    // Check if the token exists and is valid, otherwise logout.
    _isLoading = true;        // start loading
    notifyListeners();
    _token = await _authService.getToken();
    if (_token != null) {
      _isAuthenticated = true;
    } else {
      _isAuthenticated = false;
    }
    _isLoading = false;       // done loading
    notifyListeners();
  }*/
  Future<void> checkAuthStatus() async {
    _isLoading = true;
    notifyListeners();

    _token = await _authService.getToken();

    if (_token != null) {
      bool hasExpired = JwtDecoder.isExpired(_token!);

      if (!hasExpired) {
        _isAuthenticated = true;
      } else {
        _isAuthenticated = false;
        await _authService.logout(); // remove expired token from storage
      }
    } else {
      _isAuthenticated = false;
    }

    _isLoading = false;
    notifyListeners();
  }
}
