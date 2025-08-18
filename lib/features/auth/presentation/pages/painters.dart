import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'dart:ui' as ui;

// Ultra Pro Splash Screen Painters
class UltraProSplashParticlePainter extends CustomPainter {
  final List<UltraParticle> particles;
  final double animationValue;
  final Color primaryColor;

  UltraProSplashParticlePainter({
    required this.particles,
    required this.animationValue,
    required this.primaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final particle in particles) {
      particle.update();
      
      final paint = Paint()
        ..color = primaryColor.withOpacity(particle.opacity * 0.5)
        ..style = PaintingStyle.fill;

      final x = particle.x * size.width;
      final y = particle.y * size.height;

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(particle.rotation);
      
      // Draw particle as a small diamond
      final path = Path()
        ..moveTo(0, -particle.size)
        ..lineTo(particle.size, 0)
        ..lineTo(0, particle.size)
        ..lineTo(-particle.size, 0)
        ..close();
      
      canvas.drawPath(path, paint);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Ultra Pro Welcome Screen Painters
class UltraProWelcomeParticlePainter extends CustomPainter {
  final List<UltraParticle> particles;
  final List<FloatingElement> floatingElements;
  final double animationValue;
  final double rotationValue;
  final Color primaryColor;

  UltraProWelcomeParticlePainter({
    required this.particles,
    required this.floatingElements,
    required this.animationValue,
    required this.rotationValue,
    required this.primaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Draw particles
    for (final particle in particles) {
      particle.update();
      
      final paint = Paint()
        ..color = primaryColor.withOpacity(particle.opacity * 0.4)
        ..style = PaintingStyle.fill;

      final x = particle.x * size.width;
      final y = particle.y * size.height;

      canvas.drawCircle(
        Offset(x, y),
        particle.size,
        paint,
      );
    }

    // Draw floating elements
    for (final element in floatingElements) {
      element.update();
      
      canvas.save();
      canvas.translate(element.x * size.width, element.y * size.height);
      canvas.rotate(element.rotation);
      
      final paint = Paint()
        ..color = element.color.withOpacity(element.opacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;
      
      final rect = Rect.fromCenter(
        center: Offset.zero,
        width: element.size,
        height: element.size,
      );
      
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, Radius.circular(element.size * 0.2)),
        paint,
      );
      
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Ultra Pro Login Screen Painters
class UltraProLoginParticlePainter extends CustomPainter {
  final List<UltraParticle> particles;
  final List<FloatingElement> floatingElements;
  final double animationValue;
  final double rotationValue;
  final Color primaryColor;

  UltraProLoginParticlePainter({
    required this.particles,
    required this.floatingElements,
    required this.animationValue,
    required this.rotationValue,
    required this.primaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Draw particles
    for (final particle in particles) {
      particle.update();
      
      final paint = Paint()
        ..color = primaryColor.withOpacity(particle.opacity * 0.4)
        ..style = PaintingStyle.fill;

      final x = particle.x * size.width;
      final y = particle.y * size.height;

      canvas.drawCircle(
        Offset(x, y),
        particle.size,
        paint,
      );
    }

    // Draw floating elements
    for (final element in floatingElements) {
      element.update();
      
      canvas.save();
      canvas.translate(element.x * size.width, element.y * size.height);
      canvas.rotate(element.rotation);
      
      final paint = Paint()
        ..color = element.color.withOpacity(element.opacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;
      
      final rect = Rect.fromCenter(
        center: Offset.zero,
        width: element.size,
        height: element.size,
      );
      
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, Radius.circular(element.size * 0.3)),
        paint,
      );
      
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Interactive 3D Human Painter
class Interactive3DHumanPainter extends CustomPainter {
  final double rotationAngle;
  final double pointingIntensity;
  final String currentFocus;

  Interactive3DHumanPainter({
    required this.rotationAngle,
    required this.pointingIntensity,
    required this.currentFocus,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    
    // Enhanced 3D human figure with gradient effects
    final bodyGradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        const Color(0xFF6366F1).withOpacity(0.8),
        const Color(0xFF8B5CF6).withOpacity(0.6),
        const Color(0xFF3B82F6).withOpacity(0.7),
      ],
    );

    final bodyPaint = Paint()
      ..shader = bodyGradient.createShader(Rect.fromCenter(
        center: center,
        width: size.width,
        height: size.height,
      ))
      ..style = PaintingStyle.fill;

    // Head with 3D effect
    canvas.save();
    canvas.translate(center.dx, center.dy - 50);
    canvas.scale(1.0 + math.sin(rotationAngle) * 0.1);
    
    final headPaint = Paint()
      ..color = const Color(0xFF6366F1).withOpacity(0.8)
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(Offset.zero, 25, headPaint);
    
    // Eyes
    final eyePaint = Paint()
      ..color = Colors.white.withOpacity(0.9)
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(const Offset(-8, -5), 3, eyePaint);
    canvas.drawCircle(const Offset(8, -5), 3, eyePaint);
    
    // Pupils
    final pupilPaint = Paint()
      ..color = const Color(0xFF0A0E27)
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(const Offset(-8, -5), 1.5, pupilPaint);
    canvas.drawCircle(const Offset(8, -5), 1.5, pupilPaint);
    
    canvas.restore();

    // Body with 3D transformation
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.scale(1.0 + math.cos(rotationAngle * 0.5) * 0.05);
    
    final bodyRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset.zero,
        width: 40,
        height: 80,
      ),
      const Radius.circular(20),
    );
    
    canvas.drawRRect(bodyRect, bodyPaint);
    canvas.restore();

    // Arms with pointing gesture
    final armPaint = Paint()
      ..color = const Color(0xFF8B5CF6).withOpacity(0.9)
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    // Left arm (pointing when focused)
    if (currentFocus != 'none') {
      final pointingOffset = pointingIntensity * 15;
      canvas.drawLine(
        Offset(center.dx - 20, center.dy - 15),
        Offset(center.dx - 50 - pointingOffset, center.dy - 25 + pointingOffset),
        armPaint,
      );
      
      // Pointing finger effect
      final fingerPaint = Paint()
        ..color = const Color(0xFFFFFFFF).withOpacity(0.8)
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round;
      
      canvas.drawLine(
        Offset(center.dx - 50 - pointingOffset, center.dy - 25 + pointingOffset),
        Offset(center.dx - 60 - pointingOffset, center.dy - 30 + pointingOffset),
        fingerPaint,
      );
    } else {
      // Normal arm position
      canvas.drawLine(
        Offset(center.dx - 20, center.dy - 15),
        Offset(center.dx - 35, center.dy + 10),
        armPaint,
      );
    }

    // Right arm
    canvas.drawLine(
      Offset(center.dx + 20, center.dy - 15),
      Offset(center.dx + 35, center.dy + 10),
      armPaint,
    );

    // Legs with 3D effect
    final legPaint = Paint()
      ..color = const Color(0xFF3B82F6).withOpacity(0.8)
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    canvas.drawLine(
      Offset(center.dx - 10, center.dy + 40),
      Offset(center.dx - 15, center.dy + 80),
      legPaint,
    );

    canvas.drawLine(
      Offset(center.dx + 10, center.dy + 40),
      Offset(center.dx + 15, center.dy + 80),
      legPaint,
    );

    // Add floating particles around the character
    if (currentFocus != 'none') {
      final particlePaint = Paint()
        ..color = const Color(0xFF6366F1).withOpacity(0.6)
        ..style = PaintingStyle.fill;

      for (int i = 0; i < 8; i++) {
        final angle = (i / 8) * 2 * math.pi + rotationAngle;
        final radius = 60 + pointingIntensity * 20;
        final x = center.dx + math.cos(angle) * radius;
        final y = center.dy + math.sin(angle) * radius;
        
        canvas.drawCircle(
          Offset(x, y),
          2 + pointingIntensity * 2,
          particlePaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Cozy Modern Home 3D Painter
class CozyModernHome3DPainter extends CustomPainter {
  final double rotationAngle;

  CozyModernHome3DPainter({
    required this.rotationAngle,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    
    // Enhanced 3D house with modern design
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.scale(1.0 + math.sin(rotationAngle) * 0.1);

    // House base with gradient
    final baseGradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        const Color(0xFF6366F1).withOpacity(0.8),
        const Color(0xFF8B5CF6).withOpacity(0.6),
        const Color(0xFF3B82F6).withOpacity(0.7),
      ],
    );

    final basePaint = Paint()
      ..shader = baseGradient.createShader(Rect.fromCenter(
        center: Offset.zero,
        width: 100,
        height: 80,
      ))
      ..style = PaintingStyle.fill;

    final baseRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: const Offset(0, 25),
        width: 100,
        height: 80,
      ),
      const Radius.circular(8),
    );
    
    canvas.drawRRect(baseRect, basePaint);

    // Modern roof with 3D effect
    final roofPaint = Paint()
      ..color = const Color(0xFF8B5CF6).withOpacity(0.9)
      ..style = PaintingStyle.fill;

    final roofPath = Path()
      ..moveTo(-60, -5)
      ..lineTo(0, -45)
      ..lineTo(60, -5)
      ..lineTo(50, 5)
      ..lineTo(0, -35)
      ..lineTo(-50, 5)
      ..close();
    
    canvas.drawPath(roofPath, roofPaint);

    // Windows with glow effect
    final windowPaint = Paint()
      ..color = const Color(0xFFFFFFFF).withOpacity(0.9)
      ..style = PaintingStyle.fill;

    final windowGlowPaint = Paint()
      ..color = const Color(0xFF6366F1).withOpacity(0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);

    // Left window
    final leftWindow = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: const Offset(-25, 15),
        width: 20,
        height: 25,
      ),
      const Radius.circular(4),
    );
    
    canvas.drawRRect(leftWindow, windowGlowPaint);
    canvas.drawRRect(leftWindow, windowPaint);

    // Right window
    final rightWindow = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: const Offset(25, 15),
        width: 20,
        height: 25,
      ),
      const Radius.circular(4),
    );
    
    canvas.drawRRect(rightWindow, windowGlowPaint);
    canvas.drawRRect(rightWindow, windowPaint);

    // Modern door with gradient
    final doorGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        const Color(0xFF3B82F6).withOpacity(0.9),
        const Color(0xFF1E40AF).withOpacity(0.8),
      ],
    );

    final doorPaint = Paint()
      ..shader = doorGradient.createShader(Rect.fromCenter(
        center: const Offset(0, 35),
        width: 25,
        height: 40,
      ))
      ..style = PaintingStyle.fill;

    final door = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: const Offset(0, 35),
        width: 25,
        height: 40,
      ),
      const Radius.circular(6),
    );
    
    canvas.drawRRect(door, doorPaint);

    // Door handle
    final handlePaint = Paint()
      ..color = const Color(0xFFFFFFFF).withOpacity(0.9)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(const Offset(8, 35), 2, handlePaint);

    // Chimney with 3D effect
    final chimneyPaint = Paint()
      ..color = const Color(0xFF6B7280).withOpacity(0.8)
      ..style = PaintingStyle.fill;

    final chimney = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: const Offset(30, -25),
        width: 12,
        height: 30,
      ),
      const Radius.circular(2),
    );
    
    canvas.drawRRect(chimney, chimneyPaint);

    // Smoke particles
    final smokePaint = Paint()
      ..color = Colors.white.withOpacity(0.6)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 5; i++) {
      final smokeX = 30.0 + math.sin(rotationAngle * 2 + i * 0.5) * (5 + i * 2);
      final smokeY = -40.0 - i * 8.0;
      final smokeSize = 3.0 - i * 0.4;
      
      canvas.drawCircle(
        Offset(smokeX, smokeY),
        smokeSize,
        smokePaint,
      );
    }

    // Garden elements
    final grassPaint = Paint()
      ..color = const Color(0xFF10B981).withOpacity(0.6)
      ..style = PaintingStyle.fill;

    // Grass patches
    for (int i = 0; i < 6; i++) {
      final grassX = -40.0 + i * 15.0 + math.sin(rotationAngle + i) * 3.0;
      final grassY = 65.0;
      
      final grassPath = Path()
        ..moveTo(grassX, grassY)
        ..lineTo(grassX - 2.0, grassY - 8.0)
        ..lineTo(grassX + 2.0, grassY - 8.0)
        ..close();
      
      canvas.drawPath(grassPath, grassPaint);
    }

    canvas.restore();

    // Add floating sparkles around the house
    final sparklePaint = Paint()
      ..color = const Color(0xFF6366F1).withOpacity(0.7)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 12; i++) {
      final angle = (i / 12) * 2 * math.pi + rotationAngle * 0.5;
      final radius = 80 + math.sin(rotationAngle + i * 0.3) * 15;
      final x = center.dx + math.cos(angle) * radius;
      final y = center.dy + math.sin(angle) * radius;
      
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(rotationAngle + i * 0.5);
      
      final sparklePath = Path()
        ..moveTo(0, -3)
        ..lineTo(1, -1)
        ..lineTo(3, 0)
        ..lineTo(1, 1)
        ..lineTo(0, 3)
        ..lineTo(-1, 1)
        ..lineTo(-3, 0)
        ..lineTo(-1, -1)
        ..close();
      
      canvas.drawPath(sparklePath, sparklePaint);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Ultra Pro Particle Classes
class UltraParticle {
  late double x;
  late double y;
  late double vx;
  late double vy;
  late double size;
  late double opacity;
  late double rotation;
  late double rotationSpeed;

  UltraParticle() {
    reset();
  }

  void reset() {
    x = math.Random().nextDouble();
    y = math.Random().nextDouble();
    vx = (math.Random().nextDouble() - 0.5) * 0.0005;
    vy = (math.Random().nextDouble() - 0.5) * 0.0005;
    size = math.Random().nextDouble() * 2.5 + 1;
    opacity = math.Random().nextDouble() * 0.6 + 0.2;
    rotation = math.Random().nextDouble() * 2 * math.pi;
    rotationSpeed = (math.Random().nextDouble() - 0.5) * 0.015;
  }

  void update() {
    x += vx;
    y += vy;
    rotation += rotationSpeed;
    if (x < -0.1 || x > 1.1 || y < -0.1 || y > 1.1) {
      reset();
    }
  }
}

// Floating Element class
class FloatingElement {
  late double x;
  late double y;
  late double vx;
  late double vy;
  late double size;
  late double opacity;
  late double rotation;
  late double rotationSpeed;
  late Color color;

  FloatingElement() {
    reset();
  }

  void reset() {
    x = math.Random().nextDouble();
    y = math.Random().nextDouble();
    vx = (math.Random().nextDouble() - 0.5) * 0.0004;
    vy = (math.Random().nextDouble() - 0.5) * 0.0004;
    size = math.Random().nextDouble() * 18 + 12;
    opacity = math.Random().nextDouble() * 0.4 + 0.1;
    rotation = math.Random().nextDouble() * 2 * math.pi;
    rotationSpeed = (math.Random().nextDouble() - 0.5) * 0.015;
    color = Color.fromRGBO(
      99 + math.Random().nextInt(40),
      102 + math.Random().nextInt(40),
      241,
      1.0,
    );
  }

  void update() {
    x += vx;
    y += vy;
    rotation += rotationSpeed;
    if (x < -0.1 || x > 1.1 || y < -0.1 || y > 1.1) {
      reset();
    }
  }
}

// Ultra Pro Background Gradient Painter
class UltraProBackgroundPainter extends CustomPainter {
  final double animationValue;
  final Color primaryColor;

  UltraProBackgroundPainter({
    required this.animationValue,
    required this.primaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final gradient = RadialGradient(
      center: Alignment.topLeft,
      radius: 1.5 + math.sin(animationValue * 2 * math.pi) * 0.3,
      colors: [
        const Color(0xFF0A0E27), // Primary background color
        Color.lerp(
          const Color(0xFF0A0E27),
          const Color(0xFF1A1B3A),
          math.sin(animationValue * 2 * math.pi) * 0.3 + 0.7,
        )!,
        Color.lerp(
          const Color(0xFF1A1B3A),
          const Color(0xFF2D1B69),
          math.cos(animationValue * 2 * math.pi) * 0.3 + 0.7,
        )!,
        const Color(0xFF0F0C29),
        const Color(0xFF24243e),
      ],
      stops: const [0.0, 0.25, 0.5, 0.75, 1.0],
    );

    final paint = Paint()
      ..shader = gradient.createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);

    // Add animated overlay patterns
    final overlayPaint = Paint()
      ..color = primaryColor.withOpacity(0.05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    for (int i = 0; i < 20; i++) {
      final x = (i * size.width / 20) + math.sin(animationValue * 2 * math.pi + i * 0.3) * 20;
      final y1 = 0.0;
      final y2 = size.height;
      
      canvas.drawLine(Offset(x, y1), Offset(x, y2), overlayPaint);
    }

    for (int i = 0; i < 15; i++) {
      final y = (i * size.height / 15) + math.cos(animationValue * 2 * math.pi + i * 0.4) * 15;
      final x1 = 0.0;
      final x2 = size.width;
      
      canvas.drawLine(Offset(x1, y), Offset(x2, y), overlayPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Ultra Pro Glass Morphism Painter
class UltraProGlassMorphismPainter extends CustomPainter {
  final double blurRadius;
  final Color backgroundColor;
  final double borderRadius;

  UltraProGlassMorphismPainter({
    required this.blurRadius,
    required this.backgroundColor,
    required this.borderRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = backgroundColor.withOpacity(0.1)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, blurRadius)
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = Colors.white.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Radius.circular(borderRadius),
    );

    canvas.drawRRect(rect, paint);
    canvas.drawRRect(rect, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Ultra Pro Neumorphism Painter
class UltraProNeumorphismPainter extends CustomPainter {
  final Color backgroundColor;
  final double borderRadius;
  final bool isPressed;

  UltraProNeumorphismPainter({
    required this.backgroundColor,
    required this.borderRadius,
    this.isPressed = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Radius.circular(borderRadius),
    );

    // Base color
    final basePaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.fill;

    canvas.drawRRect(rect, basePaint);

    // Shadow effects
    if (!isPressed) {
      // Light shadow (top-left)
      final lightShadowPaint = Paint()
        ..color = Colors.white.withOpacity(0.1)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;

      canvas.drawRRect(rect, lightShadowPaint);

      // Dark shadow (bottom-right)
      final darkShadowPaint = Paint()
        ..color = Colors.black.withOpacity(0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0;

      final shadowRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(2, 2, size.width - 2, size.height - 2),
        Radius.circular(borderRadius),
      );

      canvas.drawRRect(shadowRect, darkShadowPaint);
    } else {
      // Inset shadow for pressed state
      final insetPaint = Paint()
        ..color = Colors.black.withOpacity(0.2)
        ..maskFilter = const MaskFilter.blur(BlurStyle.inner, 6)
        ..style = PaintingStyle.fill;

      canvas.drawRRect(rect, insetPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

