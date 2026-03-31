import 'package:aimy/core/core.dart';
import 'package:aimy/presentation/presentation.dart';
import 'package:flutter/material.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  TwilioConfig.debugLogMissing();
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
