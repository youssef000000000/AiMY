import 'package:flutter/material.dart';
import 'core/theme/theme.dart';
import 'screens/screens.dart';

void main() {
  runApp(const AiMYApp());
}

class AiMYApp extends StatelessWidget {
  const AiMYApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AiMY',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: const DashboardScreen(),
    );
  }
}
