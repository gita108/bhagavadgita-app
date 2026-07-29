import 'dart:math' as math;

import 'package:flutter/material.dart';

class CircularReveal extends StatelessWidget {
  const CircularReveal({
    super.key,
    required this.revealPercent,
    required this.center,
    required this.child,
  });

  final double revealPercent; // 0..1
  final Offset center;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: _CircularRevealClipper(
        fraction: revealPercent.clamp(0, 1),
        center: center,
      ),
      child: child,
    );
  }
}

class _CircularRevealClipper extends CustomClipper<Path> {
  _CircularRevealClipper({
    required this.fraction,
    required this.center,
  });

  final double fraction;
  final Offset center;

  @override
  Path getClip(Size size) {
    final maxRadius = _distanceToFarthestCorner(size, center);
    final radius = maxRadius * fraction;
    return Path()..addOval(Rect.fromCircle(center: center, radius: radius));
  }

  static double _distanceToFarthestCorner(Size size, Offset p) {
    final corners = <Offset>[
      Offset.zero,
      Offset(size.width, 0),
      Offset(0, size.height),
      Offset(size.width, size.height),
    ];
    return corners
        .map((c) => (c - p).distance)
        .fold<double>(0, (a, b) => math.max(a, b));
  }

  @override
  bool shouldReclip(covariant _CircularRevealClipper oldClipper) {
    return oldClipper.fraction != fraction || oldClipper.center != center;
  }
}

