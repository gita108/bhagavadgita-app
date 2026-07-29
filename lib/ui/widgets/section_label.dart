import 'package:flutter/material.dart';

import '../../ui/theme/app_colors.dart';
import '../../ui/theme/app_text.dart';

/// Section label used on Settings + Sloka detail pages. Uppercase, gray2,
/// 12pt — taken from the legacy Swift `Style.swift`.
class SectionLabel extends StatelessWidget {
  const SectionLabel(this.text, {super.key, this.padding});

  final String text;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? const EdgeInsets.fromLTRB(20, 20, 20, 8),
      child: Text(text.toUpperCase(), style: AppText.label()),
    );
  }
}

/// Hairline divider matching the legacy app — gray3 1px line.
class HairlineDivider extends StatelessWidget {
  const HairlineDivider({super.key, this.indent = 0});
  final double indent;
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: indent),
      height: 1,
      color: AppColors.gray4,
    );
  }
}
