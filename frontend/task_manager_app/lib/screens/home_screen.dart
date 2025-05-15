import 'package:flutter/material.dart';
import 'package:task_manager_app/utils/shared_prefs.dart';
import 'package:task_manager_app/widgets/task_card.dart';
import 'package:task_manager_app/providers/task_provider.dart';
import 'package:provider/provider.dart';
import 'package:task_manager_app/screens/add_task_screen.dart';

import '../providers/user_provider.dart';
import '../widgets/custom_drawer.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isSearchMode = false;
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    print('[DEBUG] HomeScreen initState running...');

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        final token = await SharedPrefs.getToken(); // Use your SharedPrefs helper
        print('[DEBUG] Retrieved token: $token');

        if (token == null || token.isEmpty) {
          print('[ERROR] No token found. Redirecting to login...');
          // You can navigate to login screen here if needed
        } else {
          final taskProvider = Provider.of<TaskProvider>(context, listen: false);
          print('[DEBUG] Fetching tasks from provider...');
          await taskProvider.fetchTasks(); // Await the fetch
          Provider.of<UserProvider>(context, listen: false).fetchUser();
        }
      } catch (e) {
        print('[ERROR] Exception in initState: $e');
      }
    });
  }


  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context);

    return Scaffold(
      drawer: CustomDrawer(),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(80), // AppBar height
        child: AppBar(
          title: _isSearchMode
              ? TextField(
            controller: _searchController,
            autofocus: true,
            style: TextStyle(color: Colors.black),
            decoration: InputDecoration(
              hintText: "Search tasks...",
              hintStyle: TextStyle(color: Colors.black38),
              border: InputBorder.none,
              focusedBorder: InputBorder.none,
              enabledBorder: InputBorder.none,
              prefixIcon: Icon(Icons.search, color: Colors.black),
            ),
            onChanged: (query) {
              taskProvider.filterTasks(query);
            },
          )
              : Text(
            "Task Manager",
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
          ),
          backgroundColor: Colors.white,
          elevation: 6.0,
          iconTheme: IconThemeData(color: Colors.black),
          actions: [
            _isSearchMode
                ? IconButton(
              icon: Icon(Icons.cancel, color: Colors.black),
              onPressed: () {
                setState(() {
                  _isSearchMode = false;
                  _searchController.clear();
                  taskProvider.clearFilteredTasks();
                });
              },
            )
                : IconButton(
              icon: Icon(Icons.search, color: Colors.black),
              onPressed: () {
                setState(() {
                  _isSearchMode = true;
                });
              },
            ),
          ],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(25),
              bottomRight: Radius.circular(25),
            ),
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          print('[DEBUG] Refreshing tasks...');
          await taskProvider.fetchTasks();
        },
        child: Consumer<TaskProvider>(
          builder: (context, taskProvider, child) {
            if (taskProvider.isLoading) {
              print('[DEBUG] Loading tasks...');
              return Center(child: CircularProgressIndicator());
            }

            if (taskProvider.errorMessage.isNotEmpty) {
              print('[ERROR] Error fetching tasks: ${taskProvider.errorMessage}');
              return Center(
                child: Card(
                  color: Colors.white,
                  margin: EdgeInsets.symmetric(horizontal: 20, vertical: 50),
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.error_outline,
                          color: Colors.red,
                          size: 40,
                        ),
                        SizedBox(height: 15),
                        Text(
                          taskProvider.errorMessage,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.red[800],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () {
                            taskProvider.fetchTasks();
                          },
                          child: Text("Retry"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.yellow[700],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: EdgeInsets.symmetric(
                              vertical: 12,
                              horizontal: 25,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }

            if (taskProvider.tasks.isEmpty) {
              print('[DEBUG] No tasks available.');
              return Center(
                child: Text(
                  'No tasks available.',
                  style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                ),
              );
            }

            print('[DEBUG] Displaying tasks...');
            return ListView.builder(
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
              itemCount: taskProvider.filteredTasks.isEmpty
                  ? taskProvider.tasks.length
                  : taskProvider.filteredTasks.length,
              itemBuilder: (context, index) {
                var task = taskProvider.filteredTasks.isEmpty
                    ? taskProvider.tasks[index]
                    : taskProvider.filteredTasks[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: TaskCard(task: task),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          print('[DEBUG] Navigating to Add Task screen...');
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddTaskScreen()),
          );
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.yellow[700],
        elevation: 8.0,
        splashColor: Colors.white.withOpacity(0.3),
      ),
    );
  }
}
