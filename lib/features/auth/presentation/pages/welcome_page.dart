import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import 'dart:ui';
import 'dart:ui' as ui;
import 'login_page.dart';
import 'register_page.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage>
    with TickerProviderStateMixin {
  // Ultra Pro Animation Controllers
  late AnimationController _logoController;
  late AnimationController _textController;
  late AnimationController _buttonController;
  late AnimationController _backgroundController;
  late AnimationController _rotationController;
  late AnimationController _particleController;
  late AnimationController _glowController;

  // Ultra Pro Animations
  late Animation<Offset> _logoSlideAnimation;
  late Animation<double> _logoOpacityAnimation;
  late Animation<double> _logoScaleAnimation;
  
  late Animation<Offset> _titleSlideAnimation;
  late Animation<double> _titleOpacityAnimation;
  
  late Animation<Offset> _subtitleSlideAnimation;
  late Animation<double> _subtitleOpacityAnimation;
  
  late Animation<Offset> _buttonSlideAnimation;
  late Animation<double> _buttonOpacityAnimation;
  late Animation<double> _buttonScaleAnimation;
  
  late Animation<double> _backgroundAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _particleAnimation;
  late Animation<double> _glowAnimation;

  // Ultra Pro Particle Systems
  final List<UltraParticle> _particles = List.generate(60, (_) => UltraParticle());
  final List<FloatingElement> _floatingElements = List.generate(15, (_) => FloatingElement());

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _initializeAnimations();
    _startAnimations();
  }

  void _initializeControllers() {
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    );

    _textController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _buttonController = AnimationController(
      duration: const Duration(milliseconds: 1600),
      vsync: this,
    );

    _backgroundController = AnimationController(
      duration: const Duration(milliseconds: 5000),
      vsync: this,
    );

    _rotationController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    );

    _particleController = AnimationController(
      duration: const Duration(seconds: 25),
      vsync: this,
    );

    _glowController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
  }

  void _initializeAnimations() {
    // Logo animations
    _logoSlideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: Curves.elasticOut,
    ));

    _logoOpacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: const Interval(0.0, 0.8, curve: Curves.easeIn),
    ));

    _logoScaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: Curves.elasticOut,
    ));

    // Text animations
    _titleSlideAnimation = Tween<Offset>(
      begin: const Offset(-1, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _textController,
      curve: Curves.elasticOut,
    ));

    _titleOpacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _textController,
      curve: const Interval(0.0, 0.8, curve: Curves.easeIn),
    ));

    _subtitleSlideAnimation = Tween<Offset>(
      begin: const Offset(1, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _textController,
      curve: const Interval(0.3, 1.0, curve: Curves.elasticOut),
    ));

    _subtitleOpacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _textController,
      curve: const Interval(0.3, 1.0, curve: Curves.easeIn),
    ));

    // Button animations
    _buttonSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _buttonController,
      curve: Curves.elasticOut,
    ));

    _buttonOpacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _buttonController,
      curve: const Interval(0.0, 0.8, curve: Curves.easeIn),
    ));

    _buttonScaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _buttonController,
      curve: Curves.elasticOut,
    ));

    // Background animations
    _backgroundAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _backgroundController,
      curve: Curves.easeInOut,
    ));

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_rotationController);

    _particleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_particleController);

    _glowAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _glowController,
      curve: Curves.easeInOut,
    ));
  }

  void _startAnimations() {
    Future.delayed(const Duration(milliseconds: 500), () {
      _logoController.forward();
    });

    Future.delayed(const Duration(milliseconds: 1000), () {
      _textController.forward();
    });

    Future.delayed(const Duration(milliseconds: 1500), () {
      _buttonController.forward();
    });

    _backgroundController.forward();
    _rotationController.repeat();
    _particleController.repeat();
    _glowController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    _buttonController.dispose();
    _backgroundController.dispose();
    _rotationController.dispose();
    _particleController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 600;
    
    return Scaffold(
      body: Container(
        decoration: _buildAnimatedBackground(),
        child: SafeArea(
          child: Stack(
            children: [
              // Ultra Pro Particle Background
              _buildUltraProParticleBackground(size),
              
              // Floating 3D Elements
              _buildFloating3DElements(size),
              
              // Main Content with Overflow Protection
              LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: IntrinsicHeight(
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: isSmallScreen ? 24.0 : 48.0,
                            vertical: 24.0,
                          ),
                          child: _buildMainContent(isSmallScreen),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  BoxDecoration _buildAnimatedBackground() {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          const Color(0xFF0A0E27), // Primary background color as requested
          Color.lerp(
            const Color(0xFF0A0E27),
            const Color(0xFF1A1B3A),
            math.sin(_rotationAnimation.value * 2 * math.pi) * 0.3 + 0.7,
          )!,
          Color.lerp(
            const Color(0xFF1A1B3A),
            const Color(0xFF2D1B69),
            math.cos(_rotationAnimation.value * 2 * math.pi) * 0.3 + 0.7,
          )!,
          const Color(0xFF0F0C29),
        ],
        stops: const [0.0, 0.3, 0.7, 1.0],
      ),
    );
  }

  Widget _buildUltraProParticleBackground(Size size) {
    return AnimatedBuilder(
      animation: _particleAnimation,
      builder: (context, child) {
        return CustomPaint(
          size: size,
          painter: UltraProWelcomeParticlePainter(
            particles: _particles,
            floatingElements: _floatingElements,
            animationValue: _particleAnimation.value,
            rotationValue: _rotationAnimation.value,
            primaryColor: const Color(0xFF6366F1),
          ),
        );
      },
    );
  }

  Widget _buildFloating3DElements(Size size) {
    return AnimatedBuilder(
      animation: Listenable.merge([_rotationAnimation, _glowAnimation]),
      builder: (context, child) {
        return Stack(
          children: List.generate(12, (i) {
            return Positioned(
              left: (60 + i * 80 + math.sin(_rotationAnimation.value * 2 * math.pi + i * 0.8) * (50 + i % 4 * 20)) % size.width,
              top: (100 + i * 70 + math.cos(_rotationAnimation.value * 2 * math.pi + i * 0.6) * (40 + i % 3 * 15)) % size.height,
              child: Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.001)
                  ..rotateX(math.sin(_rotationAnimation.value * 2 * math.pi + i) * 0.3)
                  ..rotateY(math.cos(_rotationAnimation.value * 2 * math.pi + i) * 0.2)
                  ..rotateZ(_rotationAnimation.value * 2 * math.pi + i * 0.5)
                  ..scale(_glowAnimation.value * (0.5 + (i % 4) * 0.2)),
                child: Container(
                  width: 12 + (i % 3) * 6,
                  height: 12 + (i % 3) * 6,
                  decoration: BoxDecoration(
                    shape: i % 2 == 0 ? BoxShape.circle : BoxShape.rectangle,
                    borderRadius: i % 2 == 1 ? BorderRadius.circular(4) : null,
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF6366F1).withOpacity(0.8),
                        const Color(0xFF8B5CF6).withOpacity(0.6),
                        const Color(0xFF3B82F6).withOpacity(0.4),
                      ],
                      stops: const [0.0, 0.5, 1.0],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF6366F1).withOpacity(0.4),
                        blurRadius: 12,
                        spreadRadius: 3,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }

  Widget _buildMainContent(bool isSmallScreen) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Ultra Pro 3D Logo
        _buildUltraPro3DLogo(isSmallScreen),
        
        SizedBox(height: isSmallScreen ? 40 : 60),
        
        // Enhanced Title
        _buildEnhancedTitle(isSmallScreen),
        
        SizedBox(height: isSmallScreen ? 20 : 30),
        
        // Enhanced Subtitle
        _buildEnhancedSubtitle(isSmallScreen),
        
        SizedBox(height: isSmallScreen ? 60 : 80),
        
        // Ultra Pro Buttons
        _buildUltraProButtons(isSmallScreen),
      ],
    );
  }

  Widget _buildUltraPro3DLogo(bool isSmallScreen) {
    final logoSize = isSmallScreen ? 160.0 : 200.0;
    
    return AnimatedBuilder(
      animation: Listenable.merge([
        _logoController,
        _rotationAnimation,
        _glowAnimation,
      ]),
      builder: (context, child) {
        return SlideTransition(
          position: _logoSlideAnimation,
          child: FadeTransition(
            opacity: _logoOpacityAnimation,
            child: Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.001)
                ..rotateX(math.sin(_rotationAnimation.value * 2 * math.pi) * 0.1)
                ..rotateY(math.cos(_rotationAnimation.value * 2 * math.pi) * 0.05)
                ..scale(_logoScaleAnimation.value * _glowAnimation.value),
              child: Hero(
                tag: 'welcome_page_logo',
                child: Container(
                  width: logoSize,
                  height: logoSize,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(40),
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF6366F1),
                        Color(0xFF8B5CF6),
                        Color(0xFF3B82F6),
                      ],
                      stops: [0.0, 0.5, 1.0],
                    ),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 2.0,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF6366F1).withOpacity(0.4),
                        blurRadius: 40,
                        spreadRadius: 8,
                        offset: const Offset(0, 15),
                      ),
                      BoxShadow(
                        color: const Color(0xFF8B5CF6).withOpacity(0.3),
                        blurRadius: 25,
                        spreadRadius: 4,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Icon(
                      Icons.home_rounded,
                      size: logoSize * 0.5,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEnhancedTitle(bool isSmallScreen) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _textController,
        _rotationAnimation,
        _glowAnimation,
      ]),
      builder: (context, child) {
        return SlideTransition(
          position: _titleSlideAnimation,
          child: FadeTransition(
            opacity: _titleOpacityAnimation,
            child: Transform.scale(
              scale: _glowAnimation.value,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [
                      Color(0xFFFFFFFF),
                      Color(0xFF6366F1),
                      Color(0xFF8B5CF6),
                    ],
                    stops: [0.0, 0.5, 1.0],
                  ).createShader(bounds),
                  child: Text(
                    'Welcome to Dream House',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: isSmallScreen ? 28 : 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1.2,
                      height: 1.2,
                      shadows: [
                        Shadow(
                          color: const Color(0xFF6366F1).withOpacity(0.5),
                          blurRadius: 20,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEnhancedSubtitle(bool isSmallScreen) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _textController,
        _glowAnimation,
      ]),
      builder: (context, child) {
        return SlideTransition(
          position: _subtitleSlideAnimation,
          child: FadeTransition(
            opacity: _subtitleOpacityAnimation,
            child: Transform.scale(
              scale: _glowAnimation.value,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Discover your perfect home with our premium real estate platform',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: isSmallScreen ? 16 : 20,
                    fontWeight: FontWeight.w300,
                    color: Colors.white.withOpacity(0.9),
                    letterSpacing: 0.5,
                    height: 1.4,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildUltraProButtons(bool isSmallScreen) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _buttonController,
        _glowAnimation,
      ]),
      builder: (context, child) {
        return SlideTransition(
          position: _buttonSlideAnimation,
          child: FadeTransition(
            opacity: _buttonOpacityAnimation,
            child: Transform.scale(
              scale: _buttonScaleAnimation.value,
              child: Column(
                children: [
                  // Login Button
                  _buildUltraProButton(
                    text: 'Login',
                    isPrimary: true,
                    onPressed: () => _navigateToLogin(),
                    isSmallScreen: isSmallScreen,
                  ),
                  
                  SizedBox(height: isSmallScreen ? 16 : 20),
                  
                  // Register Button
                  _buildUltraProButton(
                    text: 'Create Account',
                    isPrimary: false,
                    onPressed: () => _navigateToRegister(),
                    isSmallScreen: isSmallScreen,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildUltraProButton({
    required String text,
    required bool isPrimary,
    required VoidCallback onPressed,
    required bool isSmallScreen,
  }) {
    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _glowAnimation.value,
          child: Container(
            width: isSmallScreen ? 280 : 320,
            height: isSmallScreen ? 56 : 64,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: isPrimary
                  ? const LinearGradient(
                      colors: [
                        Color(0xFF6366F1),
                        Color(0xFF8B5CF6),
                      ],
                    )
                  : null,
              border: !isPrimary
                  ? Border.all(
                      color: const Color(0xFF6366F1).withOpacity(0.5),
                      width: 2,
                    )
                  : null,
              boxShadow: isPrimary
                  ? [
                      BoxShadow(
                        color: const Color(0xFF6366F1).withOpacity(0.4),
                        blurRadius: 20,
                        spreadRadius: 2,
                        offset: const Offset(0, 8),
                      ),
                    ]
                  : null,
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () {
                  HapticFeedback.mediumImpact();
                  onPressed();
                },
                child: Center(
                  child: Text(
                    text,
                    style: TextStyle(
                      fontSize: isSmallScreen ? 16 : 18,
                      fontWeight: FontWeight.w600,
                      color: isPrimary
                          ? Colors.white
                          : const Color(0xFF6366F1),
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _navigateToLogin() {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const LoginPage(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1.0, 0.0),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeInOutCubic,
            )),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 600),
      ),
    );
  }

  void _navigateToRegister() {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const RegisterPage(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(-1.0, 0.0),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeInOutCubic,
            )),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 600),
      ),
    );
  }
}

// Ultra Pro Welcome Particle Painter
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

// Ultra Particle class for welcome screen
class UltraParticle {
  late double x;
  late double y;
  late double vx;
  late double vy;
  late double size;
  late double opacity;

  UltraParticle() {
    reset();
  }

  void reset() {
    x = math.Random().nextDouble();
    y = math.Random().nextDouble();
    vx = (math.Random().nextDouble() - 0.5) * 0.0004;
    vy = (math.Random().nextDouble() - 0.5) * 0.0004;
    size = math.Random().nextDouble() * 2 + 1;
    opacity = math.Random().nextDouble() * 0.5 + 0.2;
  }

  void update() {
    x += vx;
    y += vy;
    if (x < 0 || x > 1 || y < 0 || y > 1) {
      reset();
    }
  }
}

// Floating Element class for welcome screen
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
    vx = (math.Random().nextDouble() - 0.5) * 0.0003;
    vy = (math.Random().nextDouble() - 0.5) * 0.0003;
    size = math.Random().nextDouble() * 15 + 10;
    opacity = math.Random().nextDouble() * 0.3 + 0.1;
    rotation = math.Random().nextDouble() * 2 * math.pi;
    rotationSpeed = (math.Random().nextDouble() - 0.5) * 0.01;
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

