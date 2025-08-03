import 'package:flutter/material.dart';
import 'package:task_manager_app/models/task.dart';
import 'package:task_manager_app/providers/task_provider.dart';
import 'package:provider/provider.dart';

import '../widgets/custom_app_bar.dart';

class TaskDetailScreen extends StatefulWidget {
  final Task task;

  TaskDetailScreen({required this.task});

  @override
  _TaskDetailScreenState createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  bool _isUpdating = false; // Track if the task update is in progress

  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);

    return Scaffold(
      appBar: /*AppBar(
        backgroundColor: Colors.transparent,  // Transparent background
        elevation: 4,  // Add a soft shadow for better separation
        title: Padding(
          padding: const EdgeInsets.only(left: 10),  // Add some padding to the left
          child: Text(
            widget.task.title,
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 24,  // Slightly larger font size for the title
            ),
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black), // Black back icon
          onPressed: () => Navigator.pop(context),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.white.withOpacity(0.8),  // A white shade with slight opacity
                Colors.grey.withOpacity(0.1),   // Subtle grey for more depth
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      )*/CustomAppBar(title: 'Task Details',),

        body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
        child: ListView(
          children: [
            // Title Card
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Title',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      widget.task.title,
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.black.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),

            // Description Card
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Description',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      widget.task.description,
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.black.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),

            // Status and Mark as Complete button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  decoration: BoxDecoration(
                    color: widget.task.isCompleted
                        ? Colors.green.withOpacity(0.2)
                        : Colors.orange.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Status: ${widget.task.isCompleted ? 'Completed' : 'Pending'}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: widget.task.isCompleted
                          ? Colors.green
                          : Colors.orange,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: _isUpdating
                      ? null
                      : () async {
                    setState(() {
                      _isUpdating = true;
                    });

                    try {
                      await taskProvider.updateTask(
                          widget.task.id!, !widget.task.isCompleted);
                      await taskProvider.fetchTasks();
                      Navigator.pop(context);
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Failed to update task. Please try again.'),
                        ),
                      );
                    } finally {
                      setState(() {
                        _isUpdating = false;
                      });
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: widget.task.isCompleted ? Colors.orange : Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
                  ),
                  child: _isUpdating
                      ? const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  )
                      : Text(
                    widget.task.isCompleted ? 'Mark as Pending' : 'Mark as Completed',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (widget.task.id != null && widget.task.id!.isNotEmpty) {
            taskProvider.deleteTask(widget.task.id!);
            Navigator.pop(context); // Go back to the home screen after deletion
          } else {
            print('Error: Task ID is empty or null');
          }
        },
        backgroundColor: Colors.redAccent,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
    );
  }
}
