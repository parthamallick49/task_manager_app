// lib/utils/constants.dart

import 'package:flutter/material.dart';

const Color primaryColor = Colors.blueAccent;
const Color accentColor = Colors.orange;
Color? appThemeColor = Colors.yellow[700];


// =====================
// API Config
// =====================

// Base URLs
const String baseUrlLocal = 'http://10.0.2.2:5000/api'; // Android emulator
const String baseUrlLive = 'https://task-manager-backend-4g65.onrender.com/api'; // Live Api

// Switch between environments
const String baseUrl = baseUrlLocal; // Change to baseUrlLocal for dev

// Api-Endpoints
const String loginEndpoint = '/users/login';
const String registerEndpoint = '/users/register';
const String getTasksEndpoint = '/tasks';
const String addTaskEndpoint = '/tasks';
const String updateTaskEndpoint = '/tasks';
const String deleteTaskEndpoint = '/tasks';
const String getUserProfileEndpoint = '/users/me';
const String getLatestAppInfoEndpoint = '/app/version';

// Full URLs
String get loginUrl => '$baseUrl$loginEndpoint';
String get registerUrl => '$baseUrl$registerEndpoint';
String get getTasksUrl => '$baseUrl$getTasksEndpoint';
String get addTaskUrl => '$baseUrl$addTaskEndpoint';
String get updateTaskUrl => '$baseUrl$updateTaskEndpoint';
String get deleteTaskUrl => '$baseUrl$deleteTaskEndpoint';
String get getUserProfileUrl => '$baseUrl$getUserProfileEndpoint';
String get getLatestAppInfoUrl => '$baseUrl$getLatestAppInfoEndpoint';