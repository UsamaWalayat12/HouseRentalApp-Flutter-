import 'package:flutter/material.dart';
import 'dart:ui' as ui;

class LandlordTokens {
  // Colors
  static const Color primary = Color(0xFF00D4FF);
  static const Color secondary = Color(0xFF5B73FF);
  static const Color success = Color(0xFF00FF80);
  static const Color warning = Color(0xFFFFB800);
  static const Color danger = Color(0xFFFF6B9D);
  static const Color bg = Color(0xFF0A0E27);

  // Radii
  static const double rLg = 24;
  static const double rMd = 16;
  static const double rSm = 12;

  // Spacing
  static const double sXs = 6;
  static const double sSm = 10;
  static const double sMd = 16;
  static const double sLg = 20;
  static const double sXl = 28;

  // Shadows
  static List<BoxShadow> glow(Color c, {double b = 25, double s = 3}) => [
        BoxShadow(color: c.withOpacity(0.15), blurRadius: b, spreadRadius: s, offset: const Offset(0, 8)),
        BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 4)),
      ];

  // Typography
  static const TextStyle title = TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold);
  static const TextStyle subtitle = TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600);
  static TextStyle muted(double size) => TextStyle(color: Colors.white.withOpacity(0.7), fontSize: size);
}

class GlassCard extends StatelessWidget {
  final Widget child;
  final Color accent;
  final EdgeInsets padding;
  final EdgeInsets margin;
  final double radius;
  final double blur;
  final double? width;
  final double? height;

  const GlassCard({super.key, required this.child, this.accent = LandlordTokens.primary, this.padding = const EdgeInsets.all(20), this.margin = EdgeInsets.zero, this.radius = LandlordTokens.rLg, this.blur = 15, this.width, this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(radius), boxShadow: LandlordTokens.glow(accent)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(radius),
              border: Border.all(color: accent.withOpacity(0.3), width: 1.5),
              gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [accent.withOpacity(0.15), const Color(0xFF1A1B3A).withOpacity(0.9), accent.withOpacity(0.1)]),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color accent;
  final Widget? trailing;

  const SectionHeader({super.key, required this.icon, required this.title, this.accent = LandlordTokens.primary, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Icon(icon, color: accent, size: 24),
      const SizedBox(width: LandlordTokens.sMd),
      Text(title, style: LandlordTokens.title),
      const Spacer(),
      if (trailing != null) trailing!,
    ]);
  }
}

class PrimaryButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final VoidCallback onPressed;
  final Color color1;
  final Color color2;
  final double height;
  final double? width;
  const PrimaryButton({super.key, required this.text, required this.icon, required this.onPressed, this.color1 = LandlordTokens.primary, this.color2 = LandlordTokens.secondary, this.height = 52, this.width});
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: width,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(LandlordTokens.rMd), side: BorderSide(color: Colors.white.withOpacity(0.2))),
        ).merge(ButtonStyle(
          backgroundColor: WidgetStatePropertyAll(Colors.transparent),
        )),
        icon: Icon(icon, color: Colors.white, size: 20),
        label: Ink(
          decoration: BoxDecoration(gradient: LinearGradient(colors: [color1, color2], begin: Alignment.topLeft, end: Alignment.bottomRight), borderRadius: BorderRadius.circular(LandlordTokens.rMd)),
          child: Container(alignment: Alignment.center, child: Text(text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600))),
        ),
      ),
    );
  }
}

class StatPill extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const StatPill({super.key, required this.label, required this.value, this.color = LandlordTokens.primary});
  @override
  Widget build(BuildContext context) {
    return GlassCard(
      accent: color,
      padding: const EdgeInsets.all(14),
      radius: LandlordTokens.rMd,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
        Text(value, style: TextStyle(color: color, fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        Text(label, style: LandlordTokens.muted(12)),
      ]),
    );
  }
}

class ResponsiveGrid extends StatelessWidget {
  final List<Widget> children;
  final int minColumnCount;
  final double spacing;
  const ResponsiveGrid({super.key, required this.children, this.minColumnCount = 2, this.spacing = 16});
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, c) {
      final width = c.maxWidth;
      final cols = width > 1100 ? 4 : width > 800 ? 3 : minColumnCount;
      return GridView.count(crossAxisCount: cols, crossAxisSpacing: spacing, mainAxisSpacing: spacing, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), children: children);
    });
  }
}
