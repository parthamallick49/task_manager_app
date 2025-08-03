import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:task_manager_app/models/task.dart'; // Import the Task model
import '../utils/shared_prefs.dart';

class TaskService {
  static const String baseUrl =
      'http://10.0.2.2:5000/api/tasks'; // Change to your API URL
  static const String authUrl =
      'http://10.0.2.2:5000/api/auth'; // URL for authentication

  // Get tasks
  Future<List<Task>> getTasks() async {
    try {
      final token = await SharedPrefs.getToken(); // Using SharedPrefs to get the token
      print('[DEBUG] Retrieved token: $token');

      if (token == null || token.isEmpty) {
        print('[ERROR] No token found. User not authenticated.');
        throw Exception('User not authenticated');
      }

      final response = await http.get(
        Uri.parse(baseUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print('[DEBUG] GET $baseUrl');
      print('[DEBUG] Status code: ${response.statusCode}');
      print('[DEBUG] Response body: ${response.body}');

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        print('[DEBUG] Parsed ${data.length} tasks.');
        return data.isNotEmpty
            ? data.map((taskJson) => Task.fromJson(taskJson)).toList()
            : [];
      } else if (response.statusCode == 401) {
        print('[ERROR] Unauthorized. Token might be invalid or expired.');
        throw Exception('User not authenticated');
      } else {
        print('[ERROR] Failed to load tasks. Status: ${response.statusCode}');
        throw Exception('Failed to load tasks');
      }
    } catch (e) {
      print('[ERROR] Error in fetching tasks: $e');
      throw Exception('Failed to load tasks');
    }
  }

  // POST a new task
  Future<Task> createTask(Task task) async {
    try {
      final token = await SharedPrefs.getToken();

      if (token == null || token.isEmpty) {
        throw Exception('User not authenticated');
      }

      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(task.toJson()),
      );

      if (response.statusCode != 201) {
        print('[ERROR] Failed to create task: ${response.body}');
        throw Exception('Failed to create task');
      } else {
        final data = json.decode(response.body);
        print('[DEBUG] Task created: $data');
        return Task.fromJson(data);
      }
    } catch (e) {
      print('[ERROR] Error in creating task: $e');
      throw Exception('Failed to create task');
    }
  }


  // For updateTask
  Future<void> updateTask(String id, bool isCompleted) async {
    try {
      final token = await SharedPrefs.getToken(); // Using SharedPrefs to get the token

      if (token == null || token.isEmpty) {
        throw Exception('User not authenticated');
      }

      print('[DEBUG] Sending request to update task with ID: $id');

      final response = await http.put(
        Uri.parse('$baseUrl/$id'), // Correct URL with task ID
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({'isCompleted': isCompleted}),
      );

      if (response.statusCode != 200) {
        print('[ERROR] Failed to update task: ${response.body}');
        throw Exception('Failed to update task');
      } else {
        print('[DEBUG] Task updated successfully');
      }
    } catch (e) {
      print('[ERROR] Error in updating task: $e');
      throw Exception('Failed to update task');
    }
  }

// For deleteTask
  Future<void> deleteTask(String id) async {
    try {
      final token = await SharedPrefs.getToken(); // Using SharedPrefs to get the token

      if (token == null || token.isEmpty) {
        throw Exception('User not authenticated');
      }

      print('[DEBUG] Sending request to delete task with ID: $id');

      final response = await http.delete(
        Uri.parse('$baseUrl/$id'), // Correct URL with task ID
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode != 200) {
        print('[ERROR] Failed to delete task: ${response.body}');
        throw Exception('Failed to delete task');
      } else {
        print('[DEBUG] Task deleted successfully');
      }
    } catch (e) {
      print('[ERROR] Error in deleting task: $e');
      throw Exception('Failed to delete task');
    }
  }

  // getCurrentUser
  Future<Map<String, dynamic>> getCurrentUser() async {
    final token = await SharedPrefs.getToken();
    print('[DEBUG] Token: $token'); // ✅ Check token

    if (token == null || token.isEmpty) {
      throw Exception('User not authenticated');
    }

    final response = await http.get(
      Uri.parse('http://10.0.2.2:5000/api/users/me'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    print('[DEBUG] Response code: ${response.statusCode}');
    print('[DEBUG] Response body: ${response.body}');
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load user info');
    }
  }


}
