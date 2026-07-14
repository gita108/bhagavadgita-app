import 'package:flutter/material.dart';

import '../ui/theme/app_theme.dart';
import '../features/splash/splash_screen.dart';

class GitaBookApp extends StatelessWidget {
  const GitaBookApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bhagavad Gita',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      home: const SplashScreen(),
    );
  }
}
