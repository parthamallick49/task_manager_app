import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:install_plugin/install_plugin.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class UpdateScreen extends StatefulWidget {
  final String releaseNotes;
  final bool mandatory;
  final String apkUrl;
  final String latestVersion;

  const UpdateScreen({
    Key? key,
    required this.releaseNotes,
    required this.mandatory,
    required this.apkUrl,
    required this.latestVersion,
  }) : super(key: key);

  @override
  State<UpdateScreen> createState() => _UpdateScreenState();
}

class _UpdateScreenState extends State<UpdateScreen> {
  double _progress = 0;
  bool _isDownloading = false;
  bool _downloadCompleted = false;
  String? _apkFilePath;

  Future<void> _downloadApk() async {
    setState(() {
      _isDownloading = true;
      _progress = 0;
    });

    try {
      final request = http.Request('GET', Uri.parse(widget.apkUrl));
      final response = await http.Client().send(request);

      final contentLength = response.contentLength ?? 0;
      int downloaded = 0;

      // Save file in app-private external files dir (no permission needed)
      final dir = await getExternalStorageDirectory() ?? await getApplicationDocumentsDirectory();
      final filePath = '${dir.path}/task_manager_latest.apk';
      final file = File(filePath);
      final sink = file.openWrite();

      response.stream.listen(
            (List<int> newBytes) {
          downloaded += newBytes.length;
          sink.add(newBytes);
          setState(() {
            _progress = contentLength != 0 ? downloaded / contentLength : 0;
          });
        },
        onDone: () async {
          await sink.close();
          setState(() {
            _downloadCompleted = true;
            _apkFilePath = filePath;
            _isDownloading = false;
          });
        },
        onError: (e) {
          setState(() {
            _isDownloading = false;
            _progress = 0;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Download failed: $e')),
          );
        },
        cancelOnError: true,
      );
    } catch (e) {
      setState(() {
        _isDownloading = false;
        _progress = 0;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Download failed: $e')),
      );
    }
  }


  Future<void> _installApk() async {
    if (_apkFilePath != null) {
      try {
        await InstallPlugin.installApk(
          _apkFilePath!,
          appId: 'com.ppmdev.task_manager_app', // Your package name
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to install APK: $e')),
        );
      }
    }
  }
  Future<bool> _requestStoragePermission() async {
    final status = await Permission.storage.status;
    if (!status.isGranted) {
      final result = await Permission.storage.request();
      return result.isGranted;
    }
    return true;
  }


/*
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => !widget.mandatory,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.yellow[700],
          title: const Text('Update Available'),
          automaticallyImplyLeading: !widget.mandatory,
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'A new version of Task Manager is available!',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              const Text(
                'Release Notes:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: SingleChildScrollView(
                    child: Text(
                      widget.releaseNotes,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ),
              if (widget.mandatory)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Text(
                    'This update is mandatory to continue using the app.',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.red[700],
                      fontSize: 16,
                    ),
                  ),
                ),
              if (_isDownloading)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: LinearProgressIndicator(
                    value: _progress,
                    minHeight: 8,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation(Colors.yellow[700]),
                  ),
                ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (!widget.mandatory && !_isDownloading)
                    TextButton(
                      onPressed: () async {
                        print('[UpdateScreen] Later button pressed');
                        if (widget.mandatory) {
                          print('[UpdateScreen] Update is mandatory, showing dialog');
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text('Mandatory Update'),
                                content: const Text(
                                  'This update is mandatory. You need to update the app to continue using it.',
                                ),
                                actions: <Widget>[
                                  TextButton(
                                    child: const Text('OK'),
                                    onPressed: () {
                                      print('[UpdateScreen] Mandatory update dialog dismissed');
                                      Navigator.of(context).pop(); // Close dialog
                                    },
                                  ),
                                ],
                              );
                            },
                          );
                        } else {
                          print('[UpdateScreen] Update is NOT mandatory, popping update screen: >> ${widget.mandatory}');
                          // Wait for pop to complete before next navigation
                          final popped = await Navigator.of(context).maybePop();
                          print('[UpdateScreen] Pop completed with result: $popped');

                          print('[UpdateScreen] Checking authentication status...');
                          final authProvider = Provider.of<AuthProvider>(context, listen: false);
                          await authProvider.checkAuthStatus();

                          if (!mounted) {
                            print('[UpdateScreen] Widget no longer mounted, returning early');
                            return;
                          }

                          if (authProvider.isAuthenticated) {
                            print('[UpdateScreen] User authenticated, navigating to /home');
                            Navigator.pushReplacementNamed(context, '/home');
                          } else {
                            print('[UpdateScreen] User NOT authenticated, navigating to /login');
                            Navigator.pushReplacementNamed(context, '/login');
                          }
                        }
                      },
                      child: const Text('Later'),
                    ),
                  ElevatedButton(
                    onPressed: _downloadCompleted
                        ? _installApk
                        : (_isDownloading ? null : _downloadApk),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.yellow[700],
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      _downloadCompleted
                          ? 'Install Update'
                          : (_isDownloading ? 'Downloading...' : 'Update Now'),
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
*/

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async => !widget.mandatory,
        child: Scaffold(
          backgroundColor: Colors.grey[50],
          appBar: AppBar(
            backgroundColor: Colors.yellow[700],
            title: const Text(
              'Update Available',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
            elevation: 3,
            automaticallyImplyLeading: !widget.mandatory,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(12),
              ),
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'A new version of Task Manager is available!',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.4,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Release Notes',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                    letterSpacing: 0.25,
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade300),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          offset: Offset(0, 2),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: SingleChildScrollView(
                      physics: BouncingScrollPhysics(),
                      child: Text(
                        widget.releaseNotes,
                        style: const TextStyle(
                          fontSize: 17,
                          height: 1.4,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ),
                ),
                if (widget.mandatory)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Text(
                      'This update is mandatory to continue using the app.',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Colors.red[800],
                        fontSize: 17,
                      ),
                    ),
                  ),
                if (_isDownloading)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: _progress,
                        minHeight: 10,
                        backgroundColor: Colors.grey.shade300,
                        valueColor: AlwaysStoppedAnimation(Colors.yellow.shade700),
                      ),
                    ),
                  ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (!widget.mandatory && !_isDownloading)
                      TextButton(
                        onPressed: () async {
                          print('[UpdateScreen] Later button pressed');
                          if (widget.mandatory) {
                            print('[UpdateScreen] Update is mandatory, showing dialog');
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  title: const Text('Mandatory Update'),
                                  content: const Text(
                                    'This update is mandatory. You need to update the app to continue using it.',
                                  ),
                                  actions: <Widget>[
                                    TextButton(
                                      child: const Text('OK'),
                                      onPressed: () {
                                        print('[UpdateScreen] Mandatory update dialog dismissed');
                                        Navigator.of(context).pop(); // Close dialog
                                      },
                                    ),
                                  ],
                                );
                              },
                            );
                          } else {
                            print('[UpdateScreen] Update is NOT mandatory, popping update screen: >> ${widget.mandatory}');
                            final popped = await Navigator.of(context).maybePop();
                            print('[UpdateScreen] Pop completed with result: $popped');

                            final authProvider = Provider.of<AuthProvider>(context, listen: false);
                            await authProvider.checkAuthStatus();

                            if (!mounted) {
                              print('[UpdateScreen] Widget no longer mounted, returning early');
                              return;
                            }

                            if (authProvider.isAuthenticated) {
                              print('[UpdateScreen] User authenticated, navigating to /home');
                              Navigator.pushReplacementNamed(context, '/home');
                            } else {
                              print('[UpdateScreen] User NOT authenticated, navigating to /login');
                              Navigator.pushReplacementNamed(context, '/login');
                            }
                          }
                        },
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                          foregroundColor: Colors.yellow[700],
                          textStyle: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        child: const Text('Later'),
                      ),
                    ElevatedButton(
                      onPressed: _downloadCompleted
                          ? _installApk
                          : (_isDownloading ? null : _downloadApk),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.yellow[700],
                        foregroundColor: Colors.black87,
                        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 4,
                        shadowColor: Colors.yellow.shade900,
                      ),
                      child: Text(
                        _downloadCompleted
                            ? 'Install Update'
                            : (_isDownloading ? 'Downloading...' : 'Update Now'),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        )
    );
    }
}
