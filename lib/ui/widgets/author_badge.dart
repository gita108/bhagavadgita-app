import 'package:flutter/material.dart';

import '../../ui/theme/app_colors.dart';
import '../../ui/theme/app_text.dart';

/// Circle-with-initials badge for commentary authors — matches the legacy
/// Swift `circle_initials` asset (red border, red letters).
class AuthorBadge extends StatelessWidget {
  const AuthorBadge({super.key, required this.initials, this.size = 32});

  final String initials;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.white,
        border: Border.all(color: AppColors.red1, width: 1.5),
      ),
      child: Text(
        initials,
        style: AppText.label().copyWith(
          color: AppColors.red1,
          fontSize: size * 0.36,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
