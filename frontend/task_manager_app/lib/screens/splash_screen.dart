import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import '../screens/UpdateScreen.dart';
import '../providers/auth_provider.dart';
import '../services/version_check_service.dart';

class SplashScreen extends StatefulWidget {
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkVersionAndAuth();
  }

  Future<void> _checkVersionAndAuth() async {
    try {
      // 1. Fetch latest version info from backend
      final versionInfo = await VersionCheckService.fetchLatestVersionInfo();

      if (versionInfo != null) {
        final latestVersion = versionInfo['version'] ?? '';
        final apkUrl = versionInfo['apkUrl'] ?? '';
        final releaseNotes = versionInfo['releaseNotes'] ?? '';
        final isMandatory = versionInfo['mandatory'] ?? false;

        // 2. Get current installed version
        final currentVersion = await VersionCheckService.getCurrentAppVersion();

        // 3. Compare versions
        if (currentVersion != null &&
            VersionCheckService.isUpdateAvailable(currentVersion, latestVersion)) {
          // Navigate to UpdateScreen
          if (!mounted) return;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => UpdateScreen(
                latestVersion: latestVersion,
                apkUrl: apkUrl,
                releaseNotes: releaseNotes,
                mandatory: isMandatory,
              ),
            ),
          );
          return;
        }
      }

      // 4. Check authentication
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.checkAuthStatus();

      if (!mounted) return;

      if (authProvider.isAuthenticated) {
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        Navigator.pushReplacementNamed(context, '/login');
      }
    } catch (e) {
      print('[ERROR] Splash init failed: $e');
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/login');
    }
  }


  Future<Map<String, dynamic>> fetchLatestAppInfoFromBackend() async {
    final response = await http.get(
      Uri.parse('https://task-manager-backend-4g65.onrender.com/api/app/version'),
      //Uri.parse('http://10.0.2.2:5000/api/app/version'),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to fetch version info');
    }
  }

  Future<String> getCurrentAppVersion() async {
    // Use package_info_plus to get current app version
    // Add package_info_plus in pubspec.yaml
    final packageInfo = await PackageInfo.fromPlatform();
    return packageInfo.version;
  }

  bool _isVersionOlder(String current, String latest) {
    // Simple version comparison, assuming format: major.minor.patch
    List<int> parseVersion(String v) => v.split('.').map(int.parse).toList();

    final currentParts = parseVersion(current);
    final latestParts = parseVersion(latest);

    for (int i = 0; i < currentParts.length; i++) {
      if (currentParts[i] < latestParts[i]) return true;
      if (currentParts[i] > latestParts[i]) return false;
    }
    return false; // versions are equal
  }

  @override
  Widget build(BuildContext context) {
    print('[SplashScreen] build() called - showing smart splash screen');

    return Scaffold(
      backgroundColor: Colors.yellow[700],
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App Logo or Icon
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.task_alt_rounded,
                  color: Colors.yellow[700],
                  size: 80,
                ),
              ),

              const SizedBox(height: 24),

              // App Name
              const Text(
                'Task Manager',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1.2,
                ),
              ),

              const SizedBox(height: 16),

              // Loading animation
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                strokeWidth: 4,
              ),

              const SizedBox(height: 12),

              // Loading text
              Text(
                'Loading your workspace...',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


}
