import 'package:flutter/material.dart';

import 'widgets/circular_reveal.dart';

class CircularRevealPageRoute<T> extends PageRouteBuilder<T> {
  CircularRevealPageRoute({
    required WidgetBuilder builder,
    required this.center,
    super.settings,
  }) : super(
          transitionDuration: const Duration(milliseconds: 300),
          reverseTransitionDuration: const Duration(milliseconds: 300),
          pageBuilder: (context, animation, secondaryAnimation) => builder(
            context,
          ),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final curved = CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
              reverseCurve: Curves.easeInCubic,
            );
            return AnimatedBuilder(
              animation: curved,
              builder: (context, _) {
                return CircularReveal(
                  revealPercent: curved.value,
                  center: center,
                  child: child,
                );
              },
            );
          },
        );

  final Offset center;
}

