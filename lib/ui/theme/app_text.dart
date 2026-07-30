import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Typography system following the spec.
///
/// PT Sans (bundled in `assets/fonts/`, sourced from the legacy Swift app)
/// for all UI text; Noto Sans Devanagari (via `google_fonts`) for Sanskrit
/// — a freely-licensed substitute for Kohinoor Devanagari, which is not.
class AppText {
  AppText._();

  static const String _family = 'PTSans';

  static TextStyle _pt({
    required double size,
    FontWeight weight = FontWeight.w400,
    FontStyle style = FontStyle.normal,
    Color? color,
    double? height,
    double? letterSpacing,
  }) => TextStyle(
    fontFamily: _family,
    fontSize: size,
    fontWeight: weight,
    fontStyle: style,
    color: color,
    height: height,
    letterSpacing: letterSpacing,
  );

  static TextStyle navTitle() => _pt(size: 18, color: AppColors.white);

  static TextStyle heading() =>
      _pt(size: 20, weight: FontWeight.w700, color: AppColors.gray1);

  static TextStyle body() => _pt(size: 16, color: AppColors.gray1, height: 1.5);

  static TextStyle bodyItalic() => _pt(
    size: 16,
    style: FontStyle.italic,
    color: AppColors.gray1,
    height: 1.5,
  );

  static TextStyle sanskrit() => const TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w400,
    color: AppColors.gray1,
    height: 1.7,
    fontFamilyFallback: [
      // Prefer system fonts; avoid runtime fetching on restricted networks.
      'Noto Sans Devanagari',
      'Kohinoor Devanagari',
      'Devanagari Sangam MN',
    ],
  );

  static TextStyle caption() => _pt(size: 14, color: AppColors.gray2);

  static TextStyle label() => _pt(
    size: 12,
    weight: FontWeight.w700,
    color: AppColors.gray2,
    letterSpacing: 1.2,
  );

  /// Language-pill / author-initials text (e.g. `divider_language` label,
  /// `circlre_initials` initials).
  static TextStyle pillLabel() =>
      _pt(size: 12, weight: FontWeight.w700, color: AppColors.red1);

  /// Settings' section headers ("CHOOSE LANGUAGE", "DISPLAY", ...). Caller is
  /// responsible for uppercasing the text — this style is color/size/weight
  /// only, matching iOS's `settingsSubtitleLabel` (resolved over Android's
  /// red1 version, 2026-07-30 — see vdd-bhagavadgita-app-uiux specs).
  static TextStyle settingsSectionHeader() =>
      _pt(size: 14, color: AppColors.gray2, letterSpacing: 0.5);

  /// "Quote of the Day" card/screen header label.
  static TextStyle quoteTitle() => _pt(size: 18, color: AppColors.red1);

  static TextStyle splashTitle() =>
      _pt(size: 30, color: AppColors.white, letterSpacing: 4);

  static TextStyle guideTitle() =>
      _pt(size: 20, weight: FontWeight.w700, color: AppColors.white);

  static TextStyle guideText() =>
      _pt(size: 15, color: AppColors.white, height: 1.55);
}
