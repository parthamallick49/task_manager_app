import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:task_manager_app/utils/constants.dart';
import 'package:url_launcher/url_launcher.dart';

class VersionCheckService {
  /*static const String versionCheckUrl = 'https://task-manager-backend-4g65.onrender.com/api/app/version';*/
  //static const String versionCheckUrl = 'http://10.0.2.2:5000/api/app/version';

  // Fetch version info from backend
  static Future<Map<String, dynamic>?> fetchLatestVersionInfo() async {
    try {
      print('[VersionCheck] Fetching version info from backend...');
      final response = await http.get(Uri.parse(getLatestAppInfoUrl));
      print('[VersionCheck] Response status: ${response.statusCode}');
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        print('[VersionCheck] Response body: $decoded');
        return decoded;
      }
      print('[VersionCheck] Failed to fetch version info, status: ${response.statusCode}');
      return null;
    } catch (e) {
      print('[VersionCheck] Error fetching version info: $e');
      return null;
    }
  }

  // Get current app version installed on device
  static Future<String?> getCurrentAppVersion() async {
    print('[VersionCheck] Getting current app version...');
    final info = await PackageInfo.fromPlatform();
    print('[VersionCheck] Current app version: ${info.version}');
    return info.version; // e.g. '1.0.0'
  }

  // Compare versions, returns true if update needed
  static bool isUpdateAvailable(String currentVersion, String latestVersion) {
    print('[VersionCheck] Comparing versions: current=$currentVersion, latest=$latestVersion');
    List<int> current = currentVersion.split('.').map(int.parse).toList();
    List<int> latest = latestVersion.split('.').map(int.parse).toList();

    for (int i = 0; i < latest.length; i++) {
      if (i >= current.length) {
        print('[VersionCheck] Current version has fewer segments, update needed.');
        return true;
      }
      if (latest[i] > current[i]) {
        print('[VersionCheck] Latest version segment ${latest[i]} > current ${current[i]}, update needed.');
        return true;
      } else if (latest[i] < current[i]) {
        print('[VersionCheck] Latest version segment ${latest[i]} < current ${current[i]}, no update needed.');
        return false;
      }
    }
    print('[VersionCheck] Versions are equal, no update needed.');
    return false;
  }
}
