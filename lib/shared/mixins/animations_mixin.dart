import 'package:flutter/material.dart';

mixin LandlordAnimationsMixin<T extends StatefulWidget> on State<T>, TickerProviderStateMixin<T> {
  late AnimationController glowController;
  late AnimationController slideController;
  late AnimationController fadeController;
  late AnimationController scaleController;

  late Animation<double> glowAnimation;
  late Animation<Offset> slideAnimation;
  late Animation<double> fadeAnimation;
  late Animation<double> scaleAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimations();
  }

  void _initializeAnimations() {
    // Glow animation for neon effects
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

    // Slide animation for page transitions
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

    // Fade animation for smooth transitions
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

    // Scale animation for interactive elements
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
  }

  void _startAnimations() {
    slideController.forward();
    fadeController.forward();
    scaleController.forward();
  }

  @override
  void dispose() {
    glowController.dispose();
    slideController.dispose();
    fadeController.dispose();
    scaleController.dispose();
    super.dispose();
  }
}
