import 'package:flutter/material.dart';
import 'package:aimy/core/core.dart';
import 'package:aimy/presentation/presentation.dart';

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
      home: const IncomingCallScreen(),
    );
  }
}
