// lib/screens/task_search_delegate.dart
import 'package:flutter/material.dart';
import 'package:task_manager_app/providers/task_provider.dart';
import 'package:task_manager_app/models/task.dart';
import 'package:provider/provider.dart';
import 'package:task_manager_app/screens/task_detail_screen.dart';

class TaskSearchDelegate extends SearchDelegate {
  @override
  List<Widget>? buildActions(BuildContext context) {
    // Add clear button when searching
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = ''; // Clear the search query
        },
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    // Back button
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null); // Close the search screen
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    // Filter the tasks based on the search query
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);
    final results = taskProvider.tasks.where((task) {
      return task.title.toLowerCase().contains(query.toLowerCase()) ||
          task.description.toLowerCase().contains(query.toLowerCase());
    }).toList();

    if (results.isEmpty) {
      return Center(child: Text('No tasks found.'));
    } else {
      return ListView.builder(
        itemCount: results.length,
        itemBuilder: (context, index) {
          final task = results[index];
          return ListTile(
            title: Text(task.title),
            subtitle: Text(task.description),
            onTap: () {
              // Handle task tap, navigate to task detail screen
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => TaskDetailScreen(task: task)),
              );
            },
          );
        },
      );
    }
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    // Show suggestions as the user types
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);
    final suggestions = taskProvider.tasks.where((task) {
      return task.title.toLowerCase().contains(query.toLowerCase()) ||
          task.description.toLowerCase().contains(query.toLowerCase());
    }).toList();

    if (suggestions.isEmpty) {
      return Center(child: Text('No suggestions.'));
    } else {
      return ListView.builder(
        itemCount: suggestions.length,
        itemBuilder: (context, index) {
          final task = suggestions[index];
          return ListTile(
            title: Text(task.title),
            subtitle: Text(task.description),
            onTap: () {
              // Handle task tap, navigate to task detail screen
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => TaskDetailScreen(task: task)),
              );
            },
          );
        },
      );
    }
  }
}
