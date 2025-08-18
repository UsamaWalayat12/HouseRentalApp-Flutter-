import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter/material.dart';

// Particle model for the floating particles system
class Particle {
  final double x;
  final double y;
  final double size;
  final double speed;
  final Color color;
  final double opacity;
  double currentX;
  double currentY;
  double currentOpacity;
  
  Particle({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.color,
    required this.opacity,
  }) : currentX = x,
       currentY = y,
       currentOpacity = opacity;
}

// Mesh gradient painter for dynamic background
class MeshGradientPainter extends CustomPainter {
  final double animationValue;
  final List<Color> colors;

  MeshGradientPainter({
    required this.animationValue,
    required this.colors,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    
    // Create multiple gradient layers with morphing positions
    for (int i = 0; i < colors.length; i++) {
      final progress = (animationValue + i * 0.25) % 1.0;
      final center = Offset(
        size.width * (0.2 + 0.6 * math.sin(progress * 2 * math.pi + i)),
        size.height * (0.2 + 0.6 * math.cos(progress * 2 * math.pi + i * 1.5)),
      );
      
      final gradient = RadialGradient(
        center: Alignment(
          (center.dx / size.width) * 2 - 1,
          (center.dy / size.height) * 2 - 1,
        ),
        radius: 0.8 + 0.4 * math.sin(progress * math.pi),
        colors: [
          colors[i],
          colors[i].withOpacity(0.3),
          Colors.transparent,
        ],
        stops: const [0.0, 0.5, 1.0],
      );
      
      paint.shader = gradient.createShader(Rect.fromLTWH(0, 0, size.width, size.height));
      
      canvas.drawCircle(
        center,
        size.width * (0.3 + 0.2 * math.sin(progress * 2 * math.pi)),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant MeshGradientPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}

// Light rays painter for dynamic lighting effects
class LightRaysPainter extends CustomPainter {
  final double animationValue;
  final int rayCount;
  final List<Color> rayColors;

  LightRaysPainter({
    required this.animationValue,
    required this.rayCount,
    required this.rayColors,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    final center = Offset(size.width * 0.5, size.height * 0.5);
    
    for (int i = 0; i < rayCount; i++) {
      final angle = (2 * math.pi * i / rayCount) + (animationValue * 2 * math.pi * 0.1);
      final colorIndex = i % rayColors.length;
      final rayColor = rayColors[colorIndex];
      
      final rayLength = size.width * (0.8 + 0.3 * math.sin(animationValue * 2 * math.pi + i));
      final rayWidth = 2.0 + 1.0 * math.sin(animationValue * 4 * math.pi + i * 0.5);
      
      final endPoint = Offset(
        center.dx + rayLength * math.cos(angle),
        center.dy + rayLength * math.sin(angle),
      );
      
      // Create gradient for the ray
      final gradient = LinearGradient(
        begin: Alignment.center,
        end: Alignment.centerRight,
        colors: [
          rayColor,
          rayColor.withOpacity(0.7),
          rayColor.withOpacity(0.3),
          Colors.transparent,
        ],
        stops: const [0.0, 0.3, 0.7, 1.0],
      );
      
      paint.shader = gradient.createShader(
        Rect.fromPoints(center, endPoint),
      );
      paint.strokeWidth = rayWidth;
      paint.strokeCap = StrokeCap.round;
      
      canvas.drawLine(center, endPoint, paint);
    }
  }

  @override
  bool shouldRepaint(covariant LightRaysPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}

// Particle system painter for floating particles
class ParticleSystemPainter extends CustomPainter {
  final List<Particle> particles;
  final double animationValue;

  ParticleSystemPainter({
    required this.particles,
    required this.animationValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    
    for (final particle in particles) {
      // Update particle position
      particle.currentX = size.width * ((particle.x + animationValue * particle.speed) % 1.0);
      particle.currentY = size.height * (particle.y + 
        0.1 * math.sin(animationValue * 2 * math.pi * particle.speed + particle.x * 10));
      
      // Update particle opacity with breathing effect
      particle.currentOpacity = particle.opacity * 
        (0.5 + 0.5 * math.sin(animationValue * 2 * math.pi * 0.5 + particle.x * 5));
      
      // Draw particle with glow effect
      paint.color = particle.color.withOpacity(particle.currentOpacity);
      
      // Draw glow
      paint.maskFilter = MaskFilter.blur(BlurStyle.normal, particle.size * 0.5);
      canvas.drawCircle(
        Offset(particle.currentX, particle.currentY),
        particle.size * 1.5,
        paint,
      );
      
      // Draw core
      paint.maskFilter = null;
      paint.color = particle.color.withOpacity(particle.currentOpacity * 1.2);
      canvas.drawCircle(
        Offset(particle.currentX, particle.currentY),
        particle.size * 0.6,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant ParticleSystemPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}

// Additional utility painters for enhanced effects
class NeonBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double glowIntensity;

  NeonBorderPainter({
    required this.color,
    this.strokeWidth = 2.0,
    this.glowIntensity = 1.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(16));

    // Draw glow layers
    for (int i = 0; i < 3; i++) {
      paint.maskFilter = MaskFilter.blur(BlurStyle.normal, (i + 1) * 2.0 * glowIntensity);
      paint.color = color.withOpacity(0.3 / (i + 1));
      canvas.drawRRect(rrect, paint);
    }

    // Draw main border
    paint.maskFilter = null;
    paint.color = color;
    canvas.drawRRect(rrect, paint);
  }

  @override
  bool shouldRepaint(covariant NeonBorderPainter oldDelegate) {
    return oldDelegate.color != color || 
           oldDelegate.strokeWidth != strokeWidth ||
           oldDelegate.glowIntensity != glowIntensity;
  }
}

class WaveformPainter extends CustomPainter {
  final double animationValue;
  final Color color;
  final int waveCount;

  WaveformPainter({
    required this.animationValue,
    required this.color,
    this.waveCount = 3,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(0.3)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    for (int wave = 0; wave < waveCount; wave++) {
      final path = Path();
      final waveHeight = size.height * 0.1 * (wave + 1);
      final frequency = 2 + wave;
      
      path.moveTo(0, size.height * 0.5);
      
      for (double x = 0; x <= size.width; x += 2) {
        final y = size.height * 0.5 + 
          waveHeight * math.sin((x / size.width) * frequency * 2 * math.pi + 
          animationValue * 2 * math.pi + wave * math.pi * 0.5);
        path.lineTo(x, y);
      }
      
      paint.color = color.withOpacity(0.2 / (wave + 1));
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant WaveformPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}
