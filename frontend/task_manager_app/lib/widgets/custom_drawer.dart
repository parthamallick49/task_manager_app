import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:task_manager_app/providers/user_provider.dart';

class CustomDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.user;

    /*if (user == null) {
      // Show loading or guest state
      return Drawer(
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }*/
    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(user?['name'] ?? 'User'),
            accountEmail: Text(user?['email'] ?? ''),
            currentAccountPicture: CircleAvatar(
              child: Text(user?['name'] != null ? user!['name'][0].toUpperCase() : '?'),
            ),
            decoration: BoxDecoration(color: Colors.yellow[700]),
          ),
          ListTile(
            leading: Icon(Icons.logout),
            title: Text('Logout'),
            onTap: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.remove('auth_token');
              userProvider.clearUser();
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
    );
  }
}
