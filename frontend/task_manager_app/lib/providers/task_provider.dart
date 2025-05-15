import 'package:flutter/material.dart';
import 'package:task_manager_app/models/task.dart';
import 'package:task_manager_app/services/task_service.dart';  // Import the TaskService

class TaskProvider with ChangeNotifier {
  final TaskService _taskService = TaskService();
  List<Task> _tasks = [];
  bool _isLoading = false;
  List<Task> filteredTasks = [];
  String _errorMessage = ""; // Error message string

  List<Task> get tasks => _tasks;

  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage; // Expose error message to UI

  // Fetch tasks and notify listeners
  Future<void> fetchTasks() async {
    _isLoading = true;
    _errorMessage = "";
    notifyListeners();

    try {
      print('[DEBUG] Fetching tasks...');
      _tasks = await _taskService.getTasks();
      print('[DEBUG] Fetched ${_tasks.length} tasks.');
    } catch (e) {
      _errorMessage = "Failed to load tasks. Please check your connection or login.";
      print('[ERROR] fetchTasks failed: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  // Add a new task
  Future<void> addTask(Task task) async {
    final createdTask = await _taskService.createTask(task);
    _tasks.add(createdTask);
    notifyListeners();
  }

  // Update a task's completion status
  Future<void> updateTask(String id, bool isCompleted) async {
    await _taskService.updateTask(id, isCompleted);

    // Find the task in the list and update it
    final task = _tasks.firstWhere((task) => task.id == id);
    task.isCompleted = isCompleted;

    // Notify listeners to rebuild the UI
    notifyListeners();
  }

  // Delete a task
  Future<void> deleteTask(String id) async {
    await _taskService.deleteTask(id);

    // Remove the task from the list
    _tasks.removeWhere((task) => task.id == id);

    // Notify listeners to rebuild the UI
    notifyListeners();
  }

  // Clear the filtered tasks
  void clearFilteredTasks() {
    filteredTasks.clear();
    notifyListeners();
  }

  // Method to filter tasks based on the search query
  void filterTasks(String query) {
    if (query.isEmpty) {
      filteredTasks.clear();
      notifyListeners();
    } else {
      filteredTasks = tasks
          .where((task) =>
      task.title.toLowerCase().contains(query.toLowerCase()) ||
          task.description.toLowerCase().contains(query.toLowerCase()))
          .toList();
      notifyListeners();
    }
  }
}
