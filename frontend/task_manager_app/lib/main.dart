import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:task_manager_app/auth/login_screen.dart';
import 'package:task_manager_app/providers/task_provider.dart';
import 'package:task_manager_app/providers/auth_provider.dart';  // Import AuthProvider
import 'package:task_manager_app/providers/user_provider.dart';
import 'package:task_manager_app/screens/home_screen.dart';
import 'package:task_manager_app/screens/add_task_screen.dart';
import 'package:task_manager_app/screens/splash_screen.dart';
import 'package:task_manager_app/utils/constants.dart';
import 'package:task_manager_app/utils/shared_prefs.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Ensure AuthProvider is checked for authentication status
  final token = await SharedPrefs.getToken();


  runApp(MyApp(token: token));
}

class MyApp extends StatelessWidget {
  final String? token;

  MyApp({required this.token});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Provide both TaskProvider and AuthProvider
        ChangeNotifierProvider(create: (context) => AuthProvider()..checkAuthStatus()), // Initialize AuthProvider
        ChangeNotifierProvider(create: (context) => TaskProvider()),  // Provide TaskProvider
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Task Manager',
        theme: ThemeData(
          primaryColor: primaryColor,
          appBarTheme: AppBarTheme(
            color: primaryColor,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
          ),
          textTheme: TextTheme(
            bodyMedium: TextStyle(color: Colors.black),
            titleLarge: TextStyle(color: Colors.black),
          ),
        ),
        home: SplashScreen(),
        routes: {
          '/login': (_) => LoginScreen(),
          '/home': (_) => HomeScreen(),
          '/add-task': (_) => AddTaskScreen(),
        },
        /*home: AuthGate(),
        routes: {
          '/login': (_) => LoginScreen(),
          //'/': (_) => HomeScreen(),
          '/add-task': (_) => AddTaskScreen(),
        },*/
      ),
    );
  }
}

class AuthGate extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    if (authProvider.isLoading) {
      // While checking token/loading
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (authProvider.isAuthenticated) {
      return HomeScreen();
    } else {
      return LoginScreen();
    }
  }
}