import 'package:flutter/material.dart';
import 'dart:math' as math;

mixin LandlordAnimationsMixin<T extends StatefulWidget> on State<T>, TickerProviderStateMixin<T> {
  // Animation Controllers
  late AnimationController backgroundController;
  late AnimationController glowController;
  late AnimationController slideController;
  late AnimationController fadeController;
  late AnimationController scaleController;
  late AnimationController pulseController;

  // Animations
  late Animation<double> backgroundAnimation;
  late Animation<double> glowAnimation;
  late Animation<Offset> slideAnimation;
  late Animation<double> fadeAnimation;
  late Animation<double> scaleAnimation;
  late Animation<double> pulseAnimation;

  void initializeLandlordAnimations() {
    backgroundController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    );
    backgroundAnimation = Tween<double>(
      begin: 0.0,
      end: 2 * math.pi,
    ).animate(backgroundController);

    glowController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    glowAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: glowController,
      curve: Curves.easeInOut,
    ));

    slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: slideController,
      curve: Curves.easeOutCubic,
    ));

    fadeController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: fadeController,
      curve: Curves.easeOut,
    ));

    scaleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: scaleController,
      curve: Curves.easeOutBack,
    ));

    pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: pulseController,
      curve: Curves.easeInOut,
    ));
  }

  void startLandlordAnimations() {
    backgroundController.repeat();
    glowController.repeat(reverse: true);
    slideController.forward();
    fadeController.forward();
    scaleController.forward();
    pulseController.repeat(reverse: true);
  }

  void disposeLandlordAnimations() {
    backgroundController.dispose();
    glowController.dispose();
    slideController.dispose();
    fadeController.dispose();
    scaleController.dispose();
    pulseController.dispose();
  }
}
