import 'package:flutter/material.dart';

import '../../../ui/theme/app_colors.dart';
import '../../../ui/theme/app_text.dart';

class AuthorBadge extends StatelessWidget {
  const AuthorBadge({
    super.key,
    required this.initials,
    this.name,
    this.size = 28,
  });

  final String initials;
  final String? name;
  final double size;

  @override
  Widget build(BuildContext context) {
    final textStyle = AppText.label().copyWith(
      color: AppColors.red1,
    );

    final badge = Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.white,
        border: Border.all(color: AppColors.red1, width: 1.5),
      ),
      child: Text(initials, style: textStyle),
    );

    if (name == null) return badge;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        badge,
        const SizedBox(width: 8),
        Text(
          name!,
          style: AppText.caption().copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.gray2,
          ),
        ),
      ],
    );
  }
}

