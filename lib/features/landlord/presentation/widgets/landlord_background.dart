import 'package:flutter/material.dart';
import 'dart:math' as math;

class LandlordBackground extends StatelessWidget {
  final Animation<double> backgroundAnimation;
  final Widget child;

  const LandlordBackground({
    Key? key,
    required this.backgroundAnimation,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: backgroundAnimation,
      builder: (context, _) {
        return Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.topLeft,
              radius: 1.5,
              colors: [
                Color.lerp(
                  const Color(0xFF1A1B3A),
                  const Color(0xFF2A2B4A),
                  math.sin(backgroundAnimation.value) * 0.5 + 0.5,
                )!,
                const Color(0xFF0A0E27),
                const Color(0xFF000000),
              ],
            ),
          ),
          child: child,
        );
      },
    );
  }
}
