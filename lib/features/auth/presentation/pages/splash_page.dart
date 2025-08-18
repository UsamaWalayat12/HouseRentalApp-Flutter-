import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:math' as math;
import 'dart:ui' as ui;
import '../bloc/auth_bloc.dart';
import 'welcome_page.dart';
import '../../../property/presentation/pages/home_page.dart';
import '../../../landlord/presentation/pages/landlord_home_page.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _particleController;
  late AnimationController _pulseController;
  late AnimationController _rotationController;
  late AnimationController _fadeController;

  late Animation<double> _logoScaleAnimation;
  late Animation<double> _logoOpacityAnimation;
  late Animation<double> _particleAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _fadeAnimation;

  final List<UltraParticle> _particles = List.generate(50, (_) => UltraParticle());

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimations();
    
    // Trigger auth check after animations start
    Future.delayed(const Duration(milliseconds: 500), () {
      context.read<AuthBloc>().add(AuthCheckRequested());
    });
  }

  void _initializeAnimations() {
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _particleController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _rotationController = AnimationController(
      duration: const Duration(seconds: 15),
      vsync: this,
    );

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _logoScaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: Curves.elasticOut,
    ));

    _logoOpacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: const Interval(0.0, 0.8, curve: Curves.easeOut),
    ));

    _particleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_particleController);

    _pulseAnimation = Tween<double>(
      begin: 0.95,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 2 * math.pi,
    ).animate(_rotationController);

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    ));
  }

  void _startAnimations() {
    _fadeController.forward();
    _logoController.forward();
    _particleController.repeat();
    _pulseController.repeat(reverse: true);
    _rotationController.repeat();
  }

  @override
  void dispose() {
    _logoController.dispose();
    _particleController.dispose();
    _pulseController.dispose();
    _rotationController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is Authenticated) {
          // Check user role and navigate to appropriate home page
          if (state.user.role == 'landlord') {
            Navigator.of(context).pushReplacement(
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) => const LandlordHomePage(),
                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                  return FadeTransition(opacity: animation, child: child);
                },
                transitionDuration: const Duration(milliseconds: 800),
              ),
            );
          } else {
            Navigator.of(context).pushReplacement(
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) => const HomePage(),
                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                  return FadeTransition(opacity: animation, child: child);
                },
                transitionDuration: const Duration(milliseconds: 800),
              ),
            );
          }
        } else if (state is Unauthenticated) {
          Navigator.of(context).pushReplacement(
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) => const WelcomePage(),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                return FadeTransition(opacity: animation, child: child);
              },
              transitionDuration: const Duration(milliseconds: 800),
            ),
          );
        }
      },
      child: Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.center,
              radius: 1.2,
              colors: [
                Color(0xFF0A0E27), // Primary background color as requested
                Color(0xFF1A1B3A),
                Color(0xFF0F0C29),
              ],
              stops: [0.0, 0.6, 1.0],
            ),
          ),
          child: Stack(
            children: [
              // Ultra Pro Particle Background
              _buildUltraProParticleBackground(size),
              
              // Animated Geometric Background
              _buildAnimatedGeometricBackground(size),
              
              // Main Content
              FadeTransition(
                opacity: _fadeAnimation,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Ultra Pro Logo with 3D Effects
                      _buildUltraProLogo(),
                      
                      const SizedBox(height: 60),
                      
                      // Enhanced Loading Indicator
                      _buildEnhancedLoadingIndicator(),
                      
                      const SizedBox(height: 40),
                      
                      // App Title with Gradient Text
                      _buildGradientTitle(),
                      
                      const SizedBox(height: 16),
                      
                      // Subtitle with Animation
                      _buildAnimatedSubtitle(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUltraProParticleBackground(Size size) {
    return AnimatedBuilder(
      animation: _particleAnimation,
      builder: (context, child) {
        return CustomPaint(
          size: size,
          painter: UltraProSplashParticlePainter(
            particles: _particles,
            animationValue: _particleAnimation.value,
            primaryColor: const Color(0xFF6366F1),
          ),
        );
      },
    );
  }

  Widget _buildAnimatedGeometricBackground(Size size) {
    return AnimatedBuilder(
      animation: _rotationAnimation,
      builder: (context, child) {
        return Positioned.fill(
          child: Stack(
            children: [
              // Floating geometric shapes
              for (int i = 0; i < 8; i++)
                Positioned(
                  left: (size.width * 0.1 + i * size.width * 0.12) % size.width,
                  top: (size.height * 0.2 + i * size.height * 0.15) % size.height,
                  child: Transform.rotate(
                    angle: _rotationAnimation.value + i * 0.5,
                    child: Container(
                      width: 20 + (i % 3) * 10,
                      height: 20 + (i % 3) * 10,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFF6366F1).withOpacity(0.3),
                            const Color(0xFF8B5CF6).withOpacity(0.2),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(i % 2 == 0 ? 8 : 20),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF6366F1).withOpacity(0.3),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildUltraProLogo() {
    return AnimatedBuilder(
      animation: Listenable.merge([_logoScaleAnimation, _pulseAnimation, _rotationAnimation]),
      builder: (context, child) {
        return Transform.scale(
          scale: _logoScaleAnimation.value * _pulseAnimation.value,
          child: FadeTransition(
            opacity: _logoOpacityAnimation,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF6366F1),
                    Color(0xFF8B5CF6),
                    Color(0xFF3B82F6),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF6366F1).withOpacity(0.4),
                    blurRadius: 30,
                    spreadRadius: 5,
                    offset: const Offset(0, 10),
                  ),
                  BoxShadow(
                    color: const Color(0xFF8B5CF6).withOpacity(0.3),
                    blurRadius: 20,
                    spreadRadius: 2,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Transform.rotate(
                angle: _rotationAnimation.value * 0.1,
                child: const Icon(
                  Icons.home_rounded,
                  size: 60,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEnhancedLoadingIndicator() {
    return AnimatedBuilder(
      animation: _rotationAnimation,
      builder: (context, child) {
        return SizedBox(
          width: 60,
          height: 60,
          child: Stack(
            children: [
              // Outer ring
              CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(
                  const Color(0xFF6366F1).withOpacity(0.3),
                ),
              ),
              // Inner animated ring
              Transform.rotate(
                angle: _rotationAnimation.value,
                child: CircularProgressIndicator(
                  strokeWidth: 4,
                  value: 0.7,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    Color(0xFF6366F1),
                  ),
                  backgroundColor: Colors.transparent,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGradientTitle() {
    return ShaderMask(
      shaderCallback: (bounds) => const LinearGradient(
        colors: [
          Color(0xFFFFFFFF),
          Color(0xFF6366F1),
          Color(0xFF8B5CF6),
        ],
        stops: [0.0, 0.5, 1.0],
      ).createShader(bounds),
      child: const Text(
        'Dream House',
        style: TextStyle(
          fontSize: 36,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  Widget _buildAnimatedSubtitle() {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: Text(
            'Find Your Perfect Home',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 18,
              fontWeight: FontWeight.w300,
              letterSpacing: 0.5,
            ),
          ),
        );
      },
    );
  }
}

// Ultra Pro Particle class for splash screen
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
    vx = (math.Random().nextDouble() - 0.5) * 0.0003;
    vy = (math.Random().nextDouble() - 0.5) * 0.0003;
    size = math.Random().nextDouble() * 3 + 1;
    opacity = math.Random().nextDouble() * 0.6 + 0.2;
    rotation = math.Random().nextDouble() * 2 * math.pi;
    rotationSpeed = (math.Random().nextDouble() - 0.5) * 0.01;
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

// Ultra Pro Splash Particle Painter
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

