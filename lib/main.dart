
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:myapp/providers/expense_provider.dart';
import 'package:myapp/screens/home_screen.dart';
import 'package:myapp/theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
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
