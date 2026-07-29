import 'package:flutter/material.dart';

import '../../ui/theme/app_colors.dart';
import '../../ui/theme/app_text.dart';

/// Logo mark — the syllable Om rendered in Devanagari, set within a
/// soft circular plate. Drawn with text so it scales without bitmap assets.
class OmLogo extends StatelessWidget {
  const OmLogo({super.key, this.size = 96, this.dark = false});

  final double size;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    final fg = dark ? AppColors.red1 : AppColors.white;
    final bg = dark ? AppColors.white : AppColors.white30;
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: bg,
        shape: BoxShape.circle,
        border: Border.all(color: fg.withValues(alpha: 0.6), width: 2),
      ),
      child: Text(
        'ॐ',
        style: AppText.sanskrit().copyWith(
          fontSize: size * 0.6,
          color: fg,
          height: 1.0,
        ),
      ),
    );
  }
}

/// Splash wordmark — "Bhagavad / Gita" stacked under the logo.
class SplashWordmark extends StatelessWidget {
  const SplashWordmark({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const OmLogo(size: 110),
        const SizedBox(height: 28),
        Text('BHAGAVAD', style: AppText.splashTitle()),
        const SizedBox(height: 4),
        Text('GITA', style: AppText.splashTitle()),
      ],
    );
  }
}
