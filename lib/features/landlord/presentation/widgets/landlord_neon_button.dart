import 'package:flutter/material.dart';

class LandlordNeonButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color color;
  final IconData? icon;
  final bool isOutlined;
  final Animation<double> glowAnimation;

  const LandlordNeonButton({
    Key? key,
    required this.text,
    required this.onPressed,
    required this.color,
    required this.glowAnimation,
    this.icon,
    this.isOutlined = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: AnimatedBuilder(
        animation: glowAnimation,
        builder: (context, child) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              gradient: isOutlined
                  ? null
                  : LinearGradient(
                colors: [color.withOpacity(0.8), color.withOpacity(0.6)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              color: isOutlined ? Colors.transparent : null,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: color.withOpacity(glowAnimation.value),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(glowAnimation.value * 0.3),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  Icon(icon, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                ],
                Text(
                  text,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
