import 'package:flutter/material.dart';

/// Brand colors lifted from the legacy Swift + Java apps.
class AppColors {
  AppColors._();

  // Reds
  static const red1 = Color(0xFFFF5252); // primary, AppBar
  static const red2 = Color(0xFFFB9A6A); // gradient end / splash
  static const red3 = Color(0xFFC94545); // dark accents, status bar (Android)

  // Grays
  static const gray1 = Color(0xFF4A4A4A); // primary text
  static const gray2 = Color(0xFF9B9B9B); // secondary text
  static const gray3 = Color(0xFFC7C7CC); // borders, dividers
  static const gray4 = Color(0xFFE8E8E8); // light bg
  static const gray5 = Color(0xFFF9F9F9); // very light bg

  // Neutrals
  static const white = Color(0xFFFFFFFF);
  static const black = Color(0xFF000000);
  static const white30 = Color(0x4DFFFFFF);
  static const black20 = Color(0x33000000);

  // Splash gradient
  static const splashGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [red2, red1],
  );
}
