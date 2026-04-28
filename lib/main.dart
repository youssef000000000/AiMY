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
      home: const AimySplashScreen(),
      routes: {
        '/home': (_) => const MainMenuScreen(),
      },
    );
  }
}

class AimySplashScreen extends StatefulWidget {
  const AimySplashScreen({super.key});

  @override
  State<AimySplashScreen> createState() => _AimySplashScreenState();
}

class _AimySplashScreenState extends State<AimySplashScreen> {
  @override
  void initState() {
    super.initState();
    Future<void>.delayed(const Duration(milliseconds: 1800), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        PageRouteBuilder<void>(
          transitionDuration: const Duration(milliseconds: 450),
          pageBuilder: (_, animation, __) => FadeTransition(
            opacity: animation,
            child: const MainMenuScreen(),
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.background,
      body: SizedBox.expand(
        child: Image(
          image: AssetImage('assets/images/aimy_splash_screen_concept.png'),
          fit: BoxFit.cover,
          filterQuality: FilterQuality.high,
        ),
      ),
    );
  }
}
