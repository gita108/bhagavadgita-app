import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_colors.dart';
import 'app_text.dart';

/// Builds the global [ThemeData] for the Bhagavad Gita app.
///
/// Material 3 turned off here — the legacy designs (Swift + Java) sit
/// closer to Material 2's flat AppBar with a strong red, and we want
/// pixel-precise control over component shapes.
ThemeData buildAppTheme() {
  final base = ThemeData(
    useMaterial3: false,
    primaryColor: AppColors.red1,
    scaffoldBackgroundColor: AppColors.white,
    colorScheme: const ColorScheme.light(
      primary: AppColors.red1,
      secondary: AppColors.red2,
      surface: AppColors.white,
      onPrimary: AppColors.white,
      onSecondary: AppColors.white,
      onSurface: AppColors.gray1,
      error: AppColors.red3,
      onError: AppColors.white,
    ),
    dividerColor: AppColors.gray3,
    canvasColor: AppColors.white,
  );

  return base.copyWith(
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.red1,
      foregroundColor: AppColors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: AppText.navTitle(),
      iconTheme: const IconThemeData(color: AppColors.white, size: 22),
      systemOverlayStyle: const SystemUiOverlayStyle(
        statusBarColor: AppColors.red3,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
    ),
    listTileTheme: ListTileThemeData(
      tileColor: AppColors.white,
      iconColor: AppColors.gray2,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      titleTextStyle: AppText.body().copyWith(fontWeight: FontWeight.w600),
      subtitleTextStyle: AppText.caption(),
    ),
    dividerTheme: const DividerThemeData(
      color: AppColors.gray4,
      thickness: 1,
      space: 1,
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? AppColors.white
            : AppColors.gray5,
      ),
      trackColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? AppColors.red1
            : AppColors.gray3,
      ),
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: AppColors.red1,
      linearTrackColor: AppColors.gray4,
      circularTrackColor: AppColors.gray4,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.gray5,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.gray3),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.gray3),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.red1, width: 1.5),
      ),
      hintStyle: AppText.body().copyWith(color: AppColors.gray2),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.red1,
        foregroundColor: AppColors.white,
        textStyle: AppText.body().copyWith(fontWeight: FontWeight.w700),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.red1,
        side: const BorderSide(color: AppColors.red1),
        textStyle: AppText.body().copyWith(fontWeight: FontWeight.w700),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: AppColors.red1),
    ),
    iconTheme: const IconThemeData(color: AppColors.gray1),
  );
}
