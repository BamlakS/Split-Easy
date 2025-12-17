
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:myapp/providers/expense_provider.dart';
import 'package:myapp/screens/home_screen.dart';
import 'package:myapp/theme.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => ExpenseProvider(),
      child: const SplitEasyApp(),
    ),
  );
}

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
