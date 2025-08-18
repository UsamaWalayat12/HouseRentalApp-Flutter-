import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:rent_a_home/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:rent_a_home/features/landlord/presentation/pages/landlord_home_page.dart';
import 'package:rent_a_home/features/property/presentation/pages/home_page.dart';
import 'package:rent_a_home/features/auth/presentation/pages/register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  
  // Focus nodes to detect which field is active
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
  }

  
  void _showErrorDialog(BuildContext context, String message) {
    Navigator.of(context, rootNavigator: true).popUntil((route) => route.isFirst);
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1B3A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.error_outline, color: Colors.red, size: 24),
            ),
            const SizedBox(width: 12),
            const Text(
              'Login Error',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        content: Text(
          message,
          style: const TextStyle(
            fontSize: 16,
            height: 1.5,
            color: Colors.white70,
          ),
        ),
        actions: [
          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                context.read<AuthBloc>().add(AuthCheckRequested());
              },
              child: const Text(
                'OK',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  void _login() {
    if (_formKey.currentState!.validate()) {
      HapticFeedback.mediumImpact();

      context.read<AuthBloc>().add(
            LoginRequested(
              email: _emailController.text.trim(),
              password: _passwordController.text.trim(),
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 600;
    final authState = context.watch<AuthBloc>().state;

    // Show error dialog if there's an error
    if (authState is AuthError) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showErrorDialog(context, authState.message);
      });
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFF6366F1),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(
              Icons.arrow_back,
              color: Color(0xFF6366F1),
              size: 22,
            ),
            padding: EdgeInsets.zero,
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0A0E27), // Primary background color as requested
              Color(0xFF1A1B3A),
              Color(0xFF2D1B69),
              Color(0xFF0F0C29),
            ],
            stops: [0.0, 0.3, 0.7, 1.0],
          ),
        ),
        child: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is Authenticated) {
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
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: const LinearGradient(
                        colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.error_outline, 
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            state.message,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  backgroundColor: Colors.transparent,
                  behavior: SnackBarBehavior.floating,
                  margin: EdgeInsets.only(
                    bottom: MediaQuery.of(context).size.height - 150,
                    left: 20,
                    right: 20,
                  ),
                  elevation: 0,
                ),
              );
            }
          },
          child: Stack(
            children: [
              
              // Main Content with Enhanced Overflow Protection
              SafeArea(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: EdgeInsets.symmetric(
                        horizontal: isSmallScreen ? 24.0 : constraints.maxWidth * 0.25,
                        vertical: 24.0,
                      ),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight - 48.0,
                          maxWidth: isSmallScreen ? double.infinity : 500,
                        ),
                        child: IntrinsicHeight(
                          child: _buildLoginCard(context, isSmallScreen),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildLoginCard(BuildContext context, bool isSmallScreen) {
    return Center(
      child: Container(
        constraints: BoxConstraints(
          maxWidth: isSmallScreen ? double.infinity : 450,
        ),
        padding: EdgeInsets.all(isSmallScreen ? 24.0 : 32.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF1A1B3A).withOpacity(0.8),
              const Color(0xFF2D1B69).withOpacity(0.6),
              const Color(0xFF0F0C29).withOpacity(0.7),
            ],
          ),
          border: Border.all(
            color: Colors.white.withOpacity(0.1),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0A0E27).withOpacity(0.5),
              blurRadius: 30,
              spreadRadius: 5,
              offset: const Offset(0, 15),
            ),
          ],
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Title
              _buildTitle(isSmallScreen),
              
              SizedBox(height: isSmallScreen ? 32 : 40),
              
              // Email Field
              _buildUltraProTextField(
                controller: _emailController,
                focusNode: _emailFocusNode,
                label: 'Email Address',
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 20),
              
              // Password Field
              _buildUltraProPasswordField(
                controller: _passwordController,
                focusNode: _passwordFocusNode,
                label: 'Password',
                obscureText: _obscurePassword,
                onToggleVisibility: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  return null;
                },
              ),
              
              SizedBox(height: isSmallScreen ? 32 : 40),
              
              // Login Button
              BlocBuilder<AuthBloc, AuthState>(
                builder: (context, state) {
                  if (state is AuthLoading) {
                    return _buildLoadingButton(isSmallScreen);
                  }
                  return _buildLoginButton(isSmallScreen);
                },
              ),
              
              SizedBox(height: isSmallScreen ? 24 : 32),
              
              // Register Link
              _buildRegisterLink(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTitle(bool isSmallScreen) {
    return Column(
      children: [
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [
              Color(0xFFFFFFFF),
              Color(0xFF6366F1),
              Color(0xFF8B5CF6),
            ],
          ).createShader(bounds),
          child: Text(
            'Welcome Back',
            style: TextStyle(
              fontSize: isSmallScreen ? 28 : 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 1.2,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Sign in to your account',
          style: TextStyle(
            fontSize: isSmallScreen ? 16 : 18,
            color: Colors.white.withOpacity(0.7),
            fontWeight: FontWeight.w300,
          ),
        ),
      ],
    );
  }

  Widget _buildUltraProTextField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [
            const Color(0xFF1A1B3A).withOpacity(0.6),
            const Color(0xFF2D1B69).withOpacity(0.4),
          ],
        ),
        border: Border.all(
          color: focusNode.hasFocus 
              ? const Color(0xFF6366F1).withOpacity(0.8)
              : Colors.white.withOpacity(0.1),
          width: 2,
        ),
        boxShadow: focusNode.hasFocus
            ? [
                BoxShadow(
                  color: const Color(0xFF6366F1).withOpacity(0.3),
                  blurRadius: 15,
                  spreadRadius: 2,
                ),
              ]
            : null,
      ),
      child: TextFormField(
        controller: controller,
        focusNode: focusNode,
        keyboardType: keyboardType,
        validator: validator,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: focusNode.hasFocus 
                ? const Color(0xFF6366F1)
                : Colors.white.withOpacity(0.6),
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
          prefixIcon: Icon(
            icon,
            color: focusNode.hasFocus 
                ? const Color(0xFF6366F1)
                : Colors.white.withOpacity(0.6),
            size: 22,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 20,
          ),
          errorStyle: const TextStyle(
            color: Color(0xFFEF4444),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildUltraProPasswordField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String label,
    required bool obscureText,
    required VoidCallback onToggleVisibility,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [
            const Color(0xFF1A1B3A).withOpacity(0.6),
            const Color(0xFF2D1B69).withOpacity(0.4),
          ],
        ),
        border: Border.all(
          color: focusNode.hasFocus 
              ? const Color(0xFF6366F1).withOpacity(0.8)
              : Colors.white.withOpacity(0.1),
          width: 2,
        ),
        boxShadow: focusNode.hasFocus
            ? [
                BoxShadow(
                  color: const Color(0xFF6366F1).withOpacity(0.3),
                  blurRadius: 15,
                  spreadRadius: 2,
                ),
              ]
            : null,
      ),
      child: TextFormField(
        controller: controller,
        focusNode: focusNode,
        obscureText: obscureText,
        validator: validator,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: focusNode.hasFocus 
                ? const Color(0xFF6366F1)
                : Colors.white.withOpacity(0.6),
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
          prefixIcon: Icon(
            Icons.lock_outline,
            color: focusNode.hasFocus 
                ? const Color(0xFF6366F1)
                : Colors.white.withOpacity(0.6),
            size: 22,
          ),
          suffixIcon: IconButton(
            onPressed: onToggleVisibility,
            icon: Icon(
              obscureText ? Icons.visibility_outlined : Icons.visibility_off_outlined,
              color: focusNode.hasFocus 
                  ? const Color(0xFF6366F1)
                  : Colors.white.withOpacity(0.6),
              size: 22,
            ),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 20,
          ),
          errorStyle: const TextStyle(
            color: Color(0xFFEF4444),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildLoginButton(bool isSmallScreen) {
    return Container(
      height: isSmallScreen ? 56 : 64,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          colors: [
            Color(0xFF6366F1),
            Color(0xFF8B5CF6),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6366F1).withOpacity(0.4),
            blurRadius: 20,
            spreadRadius: 2,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: _login,
          child: Center(
            child: Text(
              'Sign In',
              style: TextStyle(
                fontSize: isSmallScreen ? 16 : 18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingButton(bool isSmallScreen) {
    return Container(
      height: isSmallScreen ? 56 : 64,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [
            const Color(0xFF6366F1).withOpacity(0.7),
            const Color(0xFF8B5CF6).withOpacity(0.7),
          ],
        ),
      ),
      child: const Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 3,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ),
      ),
    );
  }

  Widget _buildRegisterLink() {
    return Center(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          Navigator.of(context).push(
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) => const RegisterPage(),
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
        },
        child: RichText(
          text: TextSpan(
            text: "Don't have an account? ",
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 16,
              fontWeight: FontWeight.w400,
            ),
            children: [
              TextSpan(
                text: 'Sign Up',
                style: TextStyle(
                  color: const Color(0xFF6366F1),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  decoration: TextDecoration.underline,
                  decorationColor: const Color(0xFF6366F1),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Ultra Pro Login Particle Painter
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

// Ultra Particle class for login screen
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
    vx = (math.Random().nextDouble() - 0.5) * 0.0005;
    vy = (math.Random().nextDouble() - 0.5) * 0.0005;
    size = math.Random().nextDouble() * 2.5 + 1;
    opacity = math.Random().nextDouble() * 0.6 + 0.2;
  }

  void update() {
    x += vx;
    y += vy;
    if (x < 0 || x > 1 || y < 0 || y > 1) {
      reset();
    }
  }
}

// Floating Element class for login screen
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

// Interactive 3D Human Painter (placeholder - would need actual implementation)
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
    final paint = Paint()
      ..color = const Color(0xFF6366F1).withOpacity(0.6)
      ..style = PaintingStyle.fill;

    // Simple human figure representation
    final center = Offset(size.width / 2, size.height / 2);
    
    // Head
    canvas.drawCircle(
      Offset(center.dx, center.dy - 40),
      20,
      paint,
    );
    
    // Body
    canvas.drawRect(
      Rect.fromCenter(
        center: center,
        width: 30,
        height: 60,
      ),
      paint,
    );
    
    // Arms (pointing gesture based on focus)
    if (currentFocus != 'none') {
      final armPaint = Paint()
        ..color = const Color(0xFF8B5CF6).withOpacity(0.8)
        ..strokeWidth = 8
        ..strokeCap = StrokeCap.round;
      
      canvas.drawLine(
        Offset(center.dx - 15, center.dy - 10),
        Offset(center.dx - 40, center.dy - 20 + pointingIntensity * 10),
        armPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Cozy Modern Home 3D Painter (placeholder - would need actual implementation)
class CozyModernHome3DPainter extends CustomPainter {
  final double rotationAngle;

  CozyModernHome3DPainter({
    required this.rotationAngle,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF6366F1).withOpacity(0.7)
      ..style = PaintingStyle.fill;

    final center = Offset(size.width / 2, size.height / 2);
    
    // Simple house representation
    // Base
    canvas.drawRect(
      Rect.fromCenter(
        center: Offset(center.dx, center.dy + 20),
        width: 80,
        height: 60,
      ),
      paint,
    );
    
    // Roof
    final roofPath = Path()
      ..moveTo(center.dx - 50, center.dy - 10)
      ..lineTo(center.dx, center.dy - 40)
      ..lineTo(center.dx + 50, center.dy - 10)
      ..close();
    
    canvas.drawPath(roofPath, paint);
    
    // Door
    final doorPaint = Paint()
      ..color = const Color(0xFF8B5CF6).withOpacity(0.8)
      ..style = PaintingStyle.fill;
    
    canvas.drawRect(
      Rect.fromCenter(
        center: Offset(center.dx, center.dy + 30),
        width: 20,
        height: 30,
      ),
      doorPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

