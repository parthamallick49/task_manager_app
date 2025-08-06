// lib/screens/add_task_screen.dart

import 'package:flutter/material.dart';
import 'package:task_manager_app/models/task.dart';
import 'package:task_manager_app/providers/task_provider.dart';
import 'package:provider/provider.dart';
import 'package:task_manager_app/widgets/custom_app_bar.dart';

class AddTaskScreen extends StatefulWidget {
  @override
  _AddTaskScreenState createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isLoading = false; // Track loading state

  // Function to add task
  void _addTask() async {
    setState(() {
      _isLoading = true; // Start loading
    });

    final task = Task(
      title: _titleController.text,
      description: _descriptionController.text,
      // don't include id
    );


    try {
      // Add task to provider and database
      await Provider.of<TaskProvider>(context, listen: false).addTask(task);

      // Once task is added, navigate back to the home screen
      Navigator.pop(context);
    } catch (e) {
      // Handle any errors that may occur during task addition
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding task. Please try again.')),
      );
    } finally {
      setState(() {
        _isLoading = false; // Stop loading
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:CustomAppBar( title: 'Add New Task',),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title Field
            Text(
              'Task Title',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 8.0),
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                hintText: 'Enter task title',
                hintStyle: TextStyle(color: Colors.grey),
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
              ),
              style: TextStyle(color: Colors.black, fontSize: 16),
            ),
            SizedBox(height: 15.0),

            // Description Field
            Text(
              'Task Description',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 8.0),
            TextField(
              controller: _descriptionController,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: 'Enter task description',
                hintStyle: TextStyle(color: Colors.grey),
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
              ),
              style: TextStyle(color: Colors.black, fontSize: 16),
            ),
            Spacer(), // Push the button to the bottom

            // Add Task Button
            ElevatedButton(
              onPressed: _isLoading ? null : _addTask, // Disable button when loading
              child: _isLoading
                  ? SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 3,
                ),
              )
                  : Text(
                'Add Task',
                style: TextStyle(fontWeight: FontWeight.bold,
                color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.yellow[700],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: EdgeInsets.symmetric(vertical: 15),
                minimumSize: Size(double.infinity, 50),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
