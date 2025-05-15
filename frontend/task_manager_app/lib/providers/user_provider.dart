import 'package:flutter/material.dart';
import 'package:task_manager_app/services/task_service.dart';

class UserProvider with ChangeNotifier {
  final TaskService _taskService = TaskService();
  Map<String, dynamic>? _user;

  Map<String, dynamic>? get user => _user;

  Future<void> fetchUser() async {
    try {
      _user = await _taskService.getCurrentUser();
      notifyListeners();
    } catch (e) {
      print('[ERROR] Failed to fetch user: $e');
    }
  }

  void clearUser() {
    _user = null;
    notifyListeners();
  }
}
