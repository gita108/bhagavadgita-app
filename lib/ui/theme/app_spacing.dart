import 'package:flutter/material.dart';

/// Spacing scale. The 2012 apps used 16px gutters everywhere; normalized
/// here to a 4px scale (cross-checked against the design system's
/// `tokens/spacing.css`).
class AppSpacing {
  AppSpacing._();

  static const double space1 = 4;
  static const double space2 = 8;
  static const double space3 = 12;
  static const double space4 = 16;
  static const double space5 = 24;
  static const double space6 = 32;
  static const double space7 = 40;
  static const double space8 = 64;

  /// Universal screen edge inset.
  static const double gutter = 16;

  /// List row vertical padding.
  static const double rowPadY = 12;

  /// Max text width for shloka reading on large screens (tablet/desktop).
  static const double readingMeasure = 640;

  /// Minimum tap target (2026 addition — 2012 icons were smaller).
  static const double hitTarget = 44;
}

/// Corner radii. 2012 apps used 7px on bordered controls; 12px "modern
/// card" radius is a 2026 addition, used alongside (not replacing) 7px.
class AppRadius {
  AppRadius._();

  static const double control = 7;
  static const double card = 12;
  static const double pill = 999;
}

/// Motion + shadow tokens. 2012 apps had abrupt transitions and a single
/// 5px `shadow_bottom` under bars; both modernized here per the design
/// system, used sparingly.
class AppEffects {
  AppEffects._();

  static const Duration durFast = Duration(milliseconds: 120);
  static const Duration durMed = Duration(milliseconds: 240);
  static const Curve easeStandard = Cubic(0.2, 0, 0, 1);

  static const List<BoxShadow> shadowBar = [
    BoxShadow(color: Color(0x1A000000), offset: Offset(0, 2), blurRadius: 6),
  ];

  static const List<BoxShadow> shadowCard = [
    BoxShadow(color: Color(0x14000000), offset: Offset(0, 1), blurRadius: 3),
  ];
}
