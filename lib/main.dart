import 'package:flutter/material.dart';
import 'package:surveyflow/home/home.dart';
import 'package:surveyflow/screens/splash_screen.dart';
import 'package:surveyflow/theme/app_theme.dart';

void main() {
  runApp(const Surveyflow());
}

class Surveyflow extends StatelessWidget {
  const Surveyflow({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ChildSafe',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const SplashScreen(),
    );
  }
}
