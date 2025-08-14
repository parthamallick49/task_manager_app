import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:task_manager_app/utils/constants.dart';
import 'package:task_manager_app/utils/shared_prefs.dart';

class AuthService {
  //static const baseUrl = 'http://10.0.2.2:5000/api/users';
  //static const baseUrl = 'https://task-manager-backend-4g65.onrender.com/api/users';

  Future<String?> login(String email, String password) async {
    print('[DEBUG] Attempting to login with email: $email');
    final response = await http.post(
      Uri.parse(loginUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    print('[DEBUG] POST $loginUrl');
    print('[DEBUG] Status code: ${response.statusCode}');
    print('[DEBUG] Response body: ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final token = data['token'];
      await SharedPrefs.saveToken(token); // Unified storage
      print('[DEBUG] Token saved: $token');
      return token;
    } else {
      print('[ERROR] Login failed: ${response.body}');
      return null;
    }
  }

  Future<bool> register(String name, String email, String password) async {
    print('[DEBUG] Attempting to register user: $email');
    final response = await http.post(
      Uri.parse(registerUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'name': name, 'email': email, 'password': password}),
    );
    print('[DEBUG] Register response: ${response.statusCode}, ${response.body}');
    return response.statusCode == 201;
  }

  Future<void> logout() async {
    await SharedPrefs.removeToken(); // Unified token clearing
    print('[DEBUG] Token cleared from SharedPreferences');
  }

  Future<String?> getToken() async {
    final token = await SharedPrefs.getToken();
    print('[DEBUG] Retrieved token from SharedPreferences: $token');
    return token;
  }
}
