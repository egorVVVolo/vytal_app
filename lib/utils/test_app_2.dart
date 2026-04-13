import 'package:flutter/material.dart';
import '../screens/dashboard_screen.dart';

void main() {
  runApp(
    MaterialApp(
      home: Scaffold(body: DashboardScreen(userName: 'Test User')),
    ),
  );
}
