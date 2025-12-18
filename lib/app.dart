
import 'package:flutter/material.dart';
import 'package:myapp/screens/home_screen.dart';
import 'package:myapp/theme.dart';

class SplitEasyApp extends StatelessWidget {
  const SplitEasyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SplitEasy',
      theme: appTheme,
      home: const HomeScreen(),
    );
  }
}
