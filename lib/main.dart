import 'package:flutter/material.dart';
import 'screens/main_screen.dart';

// this is the main method which runs app

void main() {
  runApp(MainApp());
}

// material app
class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: MainScreen(), debugShowCheckedModeBanner: false);
  }
}

