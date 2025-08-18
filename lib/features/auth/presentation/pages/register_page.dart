import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rent_a_home/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:rent_a_home/features/landlord/presentation/pages/landlord_home_page.dart';
import 'package:rent_a_home/features/property/presentation/pages/home_page.dart';
import 'package:rent_a_home/features/auth/presentation/pages/login_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String _selectedRole = 'tenant';

  // Ultra Pro Animation Controllers
  late AnimationController _buttonController;
  late AnimationController _backgroundController;
  late AnimationController _particleController;
  late AnimationController _3dController;
  late AnimationController _formController;
  late AnimationController _floatingController;
  late AnimationController _homeController;
  late AnimationController _glowController;
  late AnimationController _morphController;
  late AnimationController _waveController;

  // Ultra Pro Animations
  late Animation<double> _buttonScaleAnimation;
  late Animation<double> _shimmerAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _particleAnimation;
  late Animation<double> _backgroundAnimation;
  late Animation<double> _3dRotationAnimation;
  late Animation<double> _3dFloatAnimation;
  late Animation<double> _formSlideAnimation;
  late Animation<double> _formFadeAnimation;
  late Animation<double> _floatingAnimation;
  late Animation<double> _waveAnimation;
  late Animation<double> _morphAnimation;
  late Animation<double> _homeFloatAnimation;
  late Animation<double> _homeRotateAnimation;
  late Animation<double> _glowAnimation;
  late Animation<double> _breatheAnimation;
  late Animation<double> _rippleAnimation;
  
  // Ultra Pro Particle Systems
  final List<UltraParticle> ultraParticles = List.generate(100, (_) => UltraParticle());
  final List<FloatingShape> shapes = List.generate(30, (_) => FloatingShape());
  final List<Particle3D> particles3D = List.generate(60, (_) => Particle3D());
  final List<FloatingCube> cubes3D = List.generate(15, (_) => FloatingCube());
  final List<WaveElement> waves = List.generate(10, (_) => WaveElement());
  final List<LightRay> lightRays = List.generate(20, (_) => LightRay());
  final List<FloatingSphere> spheres3D = List.generate(12, (_) => FloatingSphere());

  @override
  void initState() {
    super.initState();
    _initializeUltraProAnimations();
    _startContinuousAnimations();
  }

  void _initializeUltraProAnimations() {
    // Button animations
    _buttonController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    // Background animations
    _backgroundController = AnimationController(
      duration: const Duration(seconds: 35),
      vsync: this,
    );

    // Particle animations
    _particleController = AnimationController(
      duration: const Duration(seconds: 25),
      vsync: this,
    );

    // 3D animations
    _3dController = AnimationController(
      duration: const Duration(seconds: 40),
      vsync: this,
    );

    // Form animations
    _formController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    // Floating animations
    _floatingController = AnimationController(
      duration: const Duration(seconds: 15),
      vsync: this,
    );

    // Home background animations
    _homeController = AnimationController(
      duration: const Duration(seconds: 30),
      vsync: this,
    );

    // Glow animations
    _glowController = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    );

    // Morph animations
    _morphController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    );

    // Wave animations
    _waveController = AnimationController(
      duration: const Duration(seconds: 12),
      vsync: this,
    );

    // Initialize all ultra pro animations
    _buttonScaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.90,
    ).animate(CurvedAnimation(
      parent: _buttonController,
      curve: Curves.easeInOutCubic,
    ));

    _shimmerAnimation = Tween<double>(
      begin: 0.0,
      end: 3.0,
    ).animate(CurvedAnimation(
      parent: _buttonController,
      curve: Curves.easeInOut,
    ));

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _glowController,
      curve: Curves.easeInOut,
    ));

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 2 * math.pi,
    ).animate(CurvedAnimation(
      parent: _3dController,
      curve: Curves.linear,
    ));

    _particleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _particleController,
      curve: Curves.linear,
    ));

    _backgroundAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _backgroundController,
      curve: Curves.linear,
    ));

    _3dRotationAnimation = Tween<double>(
      begin: 0.0,
      end: 6 * math.pi,
    ).animate(CurvedAnimation(
      parent: _3dController,
      curve: Curves.linear,
    ));

    _3dFloatAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _3dController,
      curve: Curves.easeInOut,
    ));

    _formSlideAnimation = Tween<double>(
      begin: 100.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _formController,
      curve: Curves.easeOutBack,
    ));

    _formFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _formController,
      curve: Curves.easeOut,
    ));

    _floatingAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _floatingController,
      curve: Curves.linear,
    ));

    _waveAnimation = Tween<double>(
      begin: 0.0,
      end: 6 * math.pi,
    ).animate(CurvedAnimation(
      parent: _waveController,
      curve: Curves.linear,
    ));

    _morphAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _morphController,
      curve: Curves.easeInOut,
    ));

    _homeFloatAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _homeController,
      curve: Curves.easeInOut,
    ));

    _homeRotateAnimation = Tween<double>(
      begin: 0.0,
      end: 2 * math.pi,
    ).animate(CurvedAnimation(
      parent: _homeController,
      curve: Curves.linear,
    ));

    _glowAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _glowController,
      curve: Curves.easeInOut,
    ));

    _breatheAnimation = Tween<double>(
      begin: 0.90,
      end: 1.10,
    ).animate(CurvedAnimation(
      parent: _glowController,
      curve: Curves.easeInOut,
    ));

    _rippleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _buttonController,
      curve: Curves.easeOut,
    ));
  }

  void _startContinuousAnimations() {
    _backgroundController.repeat();
    _particleController.repeat();
    _3dController.repeat();
    _floatingController.repeat();
    _homeController.repeat();
    _glowController.repeat(reverse: true);
    _morphController.repeat(reverse: true);
    _waveController.repeat();
    
    // Start form animation with stagger
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) _formController.forward();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _buttonController.dispose();
    _backgroundController.dispose();
    _particleController.dispose();
    _3dController.dispose();
    _formController.dispose();
    _floatingController.dispose();
    _homeController.dispose();
    _glowController.dispose();
    _morphController.dispose();
    _waveController.dispose();
    super.dispose();
  }

  void _signUp() {
    _buttonController.forward().then((_) {
      if (mounted) _buttonController.reverse();
    });

    HapticFeedback.heavyImpact();

    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
            SignUpRequested(
              firstName: _nameController.text.trim().split(' ').first,
              lastName: _nameController.text.trim().split(' ').length > 1 ? _nameController.text.trim().split(' ').sublist(1).join(' ') : '',
              email: _emailController.text.trim(),
              password: _passwordController.text,
              role: _selectedRole,
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 600;
    final screenHeight = screenSize.height;
    final screenWidth = screenSize.width;

    return Scaffold(
      body: Container(
        width: screenWidth,
        height: screenHeight,
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topLeft,
            radius: 1.8,
            colors: [
              Color(0xFF0A0E27), // Primary background color as requested
              Color(0xFF1A1B3A),
              Color(0xFF2D1B69),
              Color(0xFF0F0C29),
              Color(0xFF24243e),
            ],
            stops: [0.0, 0.25, 0.5, 0.75, 1.0],
          ),
        ),
        child: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is Authenticated) {
            if (state.user.role == 'landlord') {
              Navigator.of(context).pushAndRemoveUntil(
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) => const LandlordHomePage(),
                  transitionsBuilder: (context, animation, secondaryAnimation, child) {
                    return FadeTransition(opacity: animation, child: child);
                  },
                  transitionDuration: const Duration(milliseconds: 800),
                ),
                (route) => false,
              );
            } else {
              Navigator.of(context).pushAndRemoveUntil(
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) => const HomePage(),
                  transitionsBuilder: (context, animation, secondaryAnimation, child) {
                    return FadeTransition(opacity: animation, child: child);
                  },
                  transitionDuration: const Duration(milliseconds: 800),
                ),
                (route) => false,
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
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Icon(
                          Icons.error_outline,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          state.message,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                backgroundColor: Colors.transparent,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                margin: const EdgeInsets.all(16),
                elevation: 0,
              ),
            );
          }
        },
          child: Stack(
            children: [
              // Ultra Pro 3D Background with Home Image
              _buildUltraPro3DBackground(),
              
              // Animated Home Background
              _buildAnimatedHomeBackground(),
              
              // Ultra Pro Wave Background
              _buildUltraProWaveBackground(),
              
              // Floating 3D Elements
              _buildFloating3DElements(),
              
              // Ultra Pro Particle System
              _buildUltraProParticleSystem(),
              
              // Light Rays Effect
              _buildLightRaysEffect(),
              
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
                          child: Form(
                            key: _formKey,
                            child: _buildMainContent(isSmallScreen),
                          ),
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

  Widget _buildMainContent(bool isSmallScreen) {
    return AnimatedBuilder(
      animation: Listenable.merge([_formSlideAnimation, _formFadeAnimation]),
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _formSlideAnimation.value),
          child: FadeTransition(
            opacity: _formFadeAnimation,
            child: Container(
              padding: EdgeInsets.all(isSmallScreen ? 24.0 : 32.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF1A1B3A).withOpacity(0.85),
                    const Color(0xFF2D1B69).withOpacity(0.65),
                    const Color(0xFF0F0C29).withOpacity(0.75),
                  ],
                ),
                border: Border.all(
                  color: Colors.white.withOpacity(0.15),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0A0E27).withOpacity(0.6),
                    blurRadius: 40,
                    spreadRadius: 8,
                    offset: const Offset(0, 20),
                  ),
                  BoxShadow(
                    color: const Color(0xFF6366F1).withOpacity(0.1),
                    blurRadius: 20,
                    spreadRadius: 2,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildUltraProAnimatedTitle(isSmallScreen),
                  SizedBox(height: isSmallScreen ? 32.0 : 40.0),
                  _buildUltraProTextField(
                    controller: _nameController,
                    label: 'Full Name',
                    icon: Icons.person_outline_rounded,
                    delay: 200,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your full name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20.0),
                  _buildUltraProTextField(
                    controller: _emailController,
                    label: 'Email Address',
                    icon: Icons.email_outlined,
                    delay: 400,
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
                  const SizedBox(height: 20.0),
                  _buildUltraProPasswordField(
                    controller: _passwordController,
                    label: 'Password',
                    obscureText: _obscurePassword,
                    delay: 600,
                    onToggleVisibility: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a password';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20.0),
                  _buildUltraProPasswordField(
                    controller: _confirmPasswordController,
                    label: 'Confirm Password',
                    obscureText: _obscureConfirmPassword,
                    delay: 800,
                    onToggleVisibility: () {
                      setState(() {
                        _obscureConfirmPassword = !_obscureConfirmPassword;
                      });
                    },
                    validator: (value) {
                      if (value != _passwordController.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24.0),
                  _buildUltraProDropdown(delay: 1000),
                  const SizedBox(height: 32.0),
                  BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) {
                      if (state is AuthLoading) {
                        return _buildUltraProLoadingButton(isSmallScreen);
                      }
                      return _buildUltraProSignUpButton(isSmallScreen);
                    },
                  ),
                  SizedBox(height: isSmallScreen ? 24.0 : 32.0),
                  _buildUltraProLoginLink(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildUltraProAnimatedTitle(bool isSmallScreen) {
    return AnimatedBuilder(
      animation: Listenable.merge([_glowAnimation, _breatheAnimation]),
      builder: (context, child) {
        return Transform.scale(
          scale: _breatheAnimation.value,
          child: Column(
            children: [
              ShaderMask(
                shaderCallback: (bounds) => LinearGradient(
                  colors: [
                    const Color(0xFFFFFFFF),
                    Color.lerp(const Color(0xFF6366F1), const Color(0xFF8B5CF6), _glowAnimation.value)!,
                    const Color(0xFF8B5CF6),
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ).createShader(bounds),
                child: Text(
                  'Create Account',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 28 : 34,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.5,
                    shadows: [
                      Shadow(
                        color: const Color(0xFF6366F1).withOpacity(0.5),
                        blurRadius: 25,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Join our premium real estate platform',
                style: TextStyle(
                  fontSize: isSmallScreen ? 16 : 18,
                  color: Colors.white.withOpacity(0.8),
                  fontWeight: FontWeight.w300,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildUltraProTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required int delay,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return AnimatedBuilder(
      animation: _breatheAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _breatheAnimation.value,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF1A1B3A).withOpacity(0.7),
                  const Color(0xFF2D1B69).withOpacity(0.5),
                  const Color(0xFF0F0C29).withOpacity(0.6),
                ],
              ),
              border: Border.all(
                color: Colors.white.withOpacity(0.15),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF6366F1).withOpacity(0.1),
                  blurRadius: 15,
                  spreadRadius: 1,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: TextFormField(
              controller: controller,
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
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                prefixIcon: Icon(
                  icon,
                  color: const Color(0xFF6366F1).withOpacity(0.8),
                  size: 22,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 22,
                ),
                errorStyle: const TextStyle(
                  color: Color(0xFFEF4444),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildUltraProPasswordField({
    required TextEditingController controller,
    required String label,
    required bool obscureText,
    required int delay,
    required VoidCallback onToggleVisibility,
    String? Function(String?)? validator,
  }) {
    return AnimatedBuilder(
      animation: _breatheAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _breatheAnimation.value,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF1A1B3A).withOpacity(0.7),
                  const Color(0xFF2D1B69).withOpacity(0.5),
                  const Color(0xFF0F0C29).withOpacity(0.6),
                ],
              ),
              border: Border.all(
                color: Colors.white.withOpacity(0.15),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF6366F1).withOpacity(0.1),
                  blurRadius: 15,
                  spreadRadius: 1,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: TextFormField(
              controller: controller,
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
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                prefixIcon: Icon(
                  Icons.lock_outline,
                  color: const Color(0xFF6366F1).withOpacity(0.8),
                  size: 22,
                ),
                suffixIcon: IconButton(
                  onPressed: onToggleVisibility,
                  icon: Icon(
                    obscureText ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                    color: const Color(0xFF6366F1).withOpacity(0.8),
                    size: 22,
                  ),
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 22,
                ),
                errorStyle: const TextStyle(
                  color: Color(0xFFEF4444),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildUltraProDropdown({required int delay}) {
    return AnimatedBuilder(
      animation: _breatheAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _breatheAnimation.value,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF1A1B3A).withOpacity(0.7),
                  const Color(0xFF2D1B69).withOpacity(0.5),
                  const Color(0xFF0F0C29).withOpacity(0.6),
                ],
              ),
              border: Border.all(
                color: Colors.white.withOpacity(0.15),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF6366F1).withOpacity(0.1),
                  blurRadius: 15,
                  spreadRadius: 1,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: DropdownButtonFormField<String>(
              value: _selectedRole,
              decoration: InputDecoration(
                labelText: 'Account Type',
                labelStyle: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                prefixIcon: Icon(
                  Icons.account_circle_outlined,
                  color: const Color(0xFF6366F1).withOpacity(0.8),
                  size: 22,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 22,
                ),
              ),
              dropdownColor: const Color(0xFF1A1B3A),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              items: const [
                DropdownMenuItem(
                  value: 'tenant',
                  child: Text('Tenant - Looking for a home'),
                ),
                DropdownMenuItem(
                  value: 'landlord',
                  child: Text('Landlord - Renting out property'),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedRole = value!;
                });
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildUltraProSignUpButton(bool isSmallScreen) {
    return AnimatedBuilder(
      animation: Listenable.merge([_buttonScaleAnimation, _breatheAnimation, _shimmerAnimation]),
      builder: (context, child) {
        return Transform.scale(
          scale: _buttonScaleAnimation.value * _breatheAnimation.value,
          child: Container(
            height: isSmallScreen ? 58 : 66,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
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
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF6366F1).withOpacity(0.5),
                  blurRadius: 25,
                  spreadRadius: 3,
                  offset: const Offset(0, 10),
                ),
                BoxShadow(
                  color: const Color(0xFF8B5CF6).withOpacity(0.3),
                  blurRadius: 15,
                  spreadRadius: 1,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(18),
                onTap: _signUp,
                child: Stack(
                  children: [
                    // Shimmer effect
                    Positioned.fill(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: AnimatedBuilder(
                          animation: _shimmerAnimation,
                          builder: (context, child) {
                            return Transform.translate(
                              offset: Offset(_shimmerAnimation.value * 200 - 100, 0),
                              child: Container(
                                width: 100,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.transparent,
                                      Colors.white.withOpacity(0.3),
                                      Colors.transparent,
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    // Button content
                    Center(
                      child: Text(
                        'Create Account',
                        style: TextStyle(
                          fontSize: isSmallScreen ? 16 : 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: 0.8,
                          shadows: [
                            Shadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 5,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildUltraProLoadingButton(bool isSmallScreen) {
    return Container(
      height: isSmallScreen ? 58 : 66,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: LinearGradient(
          colors: [
            const Color(0xFF6366F1).withOpacity(0.7),
            const Color(0xFF8B5CF6).withOpacity(0.7),
          ],
        ),
      ),
      child: const Center(
        child: SizedBox(
          width: 26,
          height: 26,
          child: CircularProgressIndicator(
            strokeWidth: 3,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ),
      ),
    );
  }

  Widget _buildUltraProLoginLink() {
    return AnimatedBuilder(
      animation: _breatheAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _breatheAnimation.value,
          child: Center(
            child: GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                Navigator.of(context).pushReplacement(
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) => const LoginPage(),
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
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF6366F1).withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: RichText(
                  text: TextSpan(
                    text: "Already have an account? ",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                    ),
                    children: [
                      TextSpan(
                        text: 'Sign In',
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
            ),
          ),
        );
      },
    );
  }

  // Ultra Pro Background Effects
  Widget _buildUltraPro3DBackground() {
    return AnimatedBuilder(
      animation: Listenable.merge([_3dRotationAnimation, _3dFloatAnimation]),
      builder: (context, child) {
        return Positioned.fill(
          child: CustomPaint(
            painter: UltraPro3DBackgroundPainter(
              rotationAngle: _3dRotationAnimation.value,
              floatValue: _3dFloatAnimation.value,
              cubes: cubes3D,
              spheres: spheres3D,
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnimatedHomeBackground() {
    return AnimatedBuilder(
      animation: Listenable.merge([_homeRotateAnimation, _homeFloatAnimation]),
      builder: (context, child) {
        return Positioned.fill(
          child: CustomPaint(
            painter: AnimatedHomePainter(
              rotationAngle: _homeRotateAnimation.value,
              floatValue: _homeFloatAnimation.value,
            ),
          ),
        );
      },
    );
  }

  Widget _buildUltraProWaveBackground() {
    return AnimatedBuilder(
      animation: _waveAnimation,
      builder: (context, child) {
        return Positioned.fill(
          child: CustomPaint(
            painter: UltraProWavePainter(
              waveValue: _waveAnimation.value,
              waves: waves,
            ),
          ),
        );
      },
    );
  }

  Widget _buildFloating3DElements() {
    return AnimatedBuilder(
      animation: Listenable.merge([_floatingAnimation, _morphAnimation]),
      builder: (context, child) {
        return Positioned.fill(
          child: CustomPaint(
            painter: Floating3DElementsPainter(
              floatingValue: _floatingAnimation.value,
              morphValue: _morphAnimation.value,
              shapes: shapes,
            ),
          ),
        );
      },
    );
  }

  Widget _buildUltraProParticleSystem() {
    return AnimatedBuilder(
      animation: _particleAnimation,
      builder: (context, child) {
        return Positioned.fill(
          child: CustomPaint(
            painter: UltraProParticleSystemPainter(
              animationValue: _particleAnimation.value,
              particles: ultraParticles,
              particles3D: particles3D,
            ),
          ),
        );
      },
    );
  }

  Widget _buildLightRaysEffect() {
    return AnimatedBuilder(
      animation: Listenable.merge([_backgroundAnimation, _glowAnimation]),
      builder: (context, child) {
        return Positioned.fill(
          child: CustomPaint(
            painter: LightRaysEffectPainter(
              animationValue: _backgroundAnimation.value,
              glowValue: _glowAnimation.value,
              lightRays: lightRays,
            ),
          ),
        );
      },
    );
  }
}

// Ultra Pro Particle Classes and Painters
class UltraParticle {
  late double x, y, vx, vy, size, opacity, rotation, rotationSpeed;
  late Color color;

  UltraParticle() {
    reset();
  }

  void reset() {
    x = math.Random().nextDouble();
    y = math.Random().nextDouble();
    vx = (math.Random().nextDouble() - 0.5) * 0.0008;
    vy = (math.Random().nextDouble() - 0.5) * 0.0008;
    size = math.Random().nextDouble() * 3 + 1;
    opacity = math.Random().nextDouble() * 0.7 + 0.3;
    rotation = math.Random().nextDouble() * 2 * math.pi;
    rotationSpeed = (math.Random().nextDouble() - 0.5) * 0.02;
    color = Color.fromRGBO(
      99 + math.Random().nextInt(60),
      102 + math.Random().nextInt(60),
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

class FloatingShape {
  late double x, y, vx, vy, size, opacity, rotation, rotationSpeed;
  late Color color;
  late int shapeType;

  FloatingShape() {
    reset();
  }

  void reset() {
    x = math.Random().nextDouble();
    y = math.Random().nextDouble();
    vx = (math.Random().nextDouble() - 0.5) * 0.0006;
    vy = (math.Random().nextDouble() - 0.5) * 0.0006;
    size = math.Random().nextDouble() * 25 + 15;
    opacity = math.Random().nextDouble() * 0.4 + 0.2;
    rotation = math.Random().nextDouble() * 2 * math.pi;
    rotationSpeed = (math.Random().nextDouble() - 0.5) * 0.015;
    shapeType = math.Random().nextInt(4);
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
    if (x < -0.15 || x > 1.15 || y < -0.15 || y > 1.15) {
      reset();
    }
  }
}

class Particle3D {
  late double x, y, z, vx, vy, vz, size, opacity;
  late Color color;

  Particle3D() {
    reset();
  }

  void reset() {
    x = math.Random().nextDouble();
    y = math.Random().nextDouble();
    z = math.Random().nextDouble();
    vx = (math.Random().nextDouble() - 0.5) * 0.001;
    vy = (math.Random().nextDouble() - 0.5) * 0.001;
    vz = (math.Random().nextDouble() - 0.5) * 0.001;
    size = math.Random().nextDouble() * 4 + 2;
    opacity = math.Random().nextDouble() * 0.6 + 0.2;
    color = Color.fromRGBO(
      99 + math.Random().nextInt(50),
      102 + math.Random().nextInt(50),
      241,
      1.0,
    );
  }

  void update() {
    x += vx;
    y += vy;
    z += vz;
    if (x < -0.1 || x > 1.1 || y < -0.1 || y > 1.1 || z < 0 || z > 1) {
      reset();
    }
  }
}

class FloatingCube {
  late double x, y, z, rotX, rotY, rotZ, size, opacity;
  late double vx, vy, vz, rotSpeedX, rotSpeedY, rotSpeedZ;
  late Color color;

  FloatingCube() {
    reset();
  }

  void reset() {
    x = math.Random().nextDouble();
    y = math.Random().nextDouble();
    z = math.Random().nextDouble();
    rotX = math.Random().nextDouble() * 2 * math.pi;
    rotY = math.Random().nextDouble() * 2 * math.pi;
    rotZ = math.Random().nextDouble() * 2 * math.pi;
    vx = (math.Random().nextDouble() - 0.5) * 0.0005;
    vy = (math.Random().nextDouble() - 0.5) * 0.0005;
    vz = (math.Random().nextDouble() - 0.5) * 0.0005;
    rotSpeedX = (math.Random().nextDouble() - 0.5) * 0.02;
    rotSpeedY = (math.Random().nextDouble() - 0.5) * 0.02;
    rotSpeedZ = (math.Random().nextDouble() - 0.5) * 0.02;
    size = math.Random().nextDouble() * 30 + 20;
    opacity = math.Random().nextDouble() * 0.3 + 0.1;
    color = Color.fromRGBO(
      99 + math.Random().nextInt(30),
      102 + math.Random().nextInt(30),
      241,
      1.0,
    );
  }

  void update() {
    x += vx;
    y += vy;
    z += vz;
    rotX += rotSpeedX;
    rotY += rotSpeedY;
    rotZ += rotSpeedZ;
    if (x < -0.2 || x > 1.2 || y < -0.2 || y > 1.2) {
      reset();
    }
  }
}

class WaveElement {
  late double x, y, amplitude, frequency, phase, speed, opacity;
  late Color color;

  WaveElement() {
    reset();
  }

  void reset() {
    x = math.Random().nextDouble();
    y = math.Random().nextDouble();
    amplitude = math.Random().nextDouble() * 50 + 20;
    frequency = math.Random().nextDouble() * 0.02 + 0.01;
    phase = math.Random().nextDouble() * 2 * math.pi;
    speed = math.Random().nextDouble() * 0.0008 + 0.0002;
    opacity = math.Random().nextDouble() * 0.3 + 0.1;
    color = Color.fromRGBO(
      99 + math.Random().nextInt(40),
      102 + math.Random().nextInt(40),
      241,
      1.0,
    );
  }

  void update(double time) {
    phase += speed;
    if (phase > 2 * math.pi) {
      reset();
    }
  }
}

class LightRay {
  late double x, y, angle, length, opacity, speed;
  late Color color;

  LightRay() {
    reset();
  }

  void reset() {
    x = math.Random().nextDouble();
    y = math.Random().nextDouble();
    angle = math.Random().nextDouble() * 2 * math.pi;
    length = math.Random().nextDouble() * 100 + 50;
    opacity = math.Random().nextDouble() * 0.4 + 0.1;
    speed = math.Random().nextDouble() * 0.01 + 0.005;
    color = Color.fromRGBO(
      99 + math.Random().nextInt(50),
      102 + math.Random().nextInt(50),
      241,
      1.0,
    );
  }

  void update() {
    angle += speed;
    if (angle > 2 * math.pi) {
      angle -= 2 * math.pi;
    }
  }
}

class FloatingSphere {
  late double x, y, z, radius, opacity;
  late double vx, vy, vz;
  late Color color;

  FloatingSphere() {
    reset();
  }

  void reset() {
    x = math.Random().nextDouble();
    y = math.Random().nextDouble();
    z = math.Random().nextDouble();
    radius = math.Random().nextDouble() * 15 + 10;
    opacity = math.Random().nextDouble() * 0.4 + 0.2;
    vx = (math.Random().nextDouble() - 0.5) * 0.0004;
    vy = (math.Random().nextDouble() - 0.5) * 0.0004;
    vz = (math.Random().nextDouble() - 0.5) * 0.0004;
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
    z += vz;
    if (x < -0.1 || x > 1.1 || y < -0.1 || y > 1.1) {
      reset();
    }
  }
}

// Ultra Pro Painters
class UltraPro3DBackgroundPainter extends CustomPainter {
  final double rotationAngle;
  final double floatValue;
  final List<FloatingCube> cubes;
  final List<FloatingSphere> spheres;

  UltraPro3DBackgroundPainter({
    required this.rotationAngle,
    required this.floatValue,
    required this.cubes,
    required this.spheres,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final cube in cubes) {
      cube.update();
      _drawCube(canvas, size, cube);
    }

    for (final sphere in spheres) {
      sphere.update();
      _drawSphere(canvas, size, sphere);
    }
  }

  void _drawCube(Canvas canvas, Size size, FloatingCube cube) {
    final paint = Paint()
      ..color = cube.color.withOpacity(cube.opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final x = cube.x * size.width;
    final y = cube.y * size.height;

    canvas.save();
    canvas.translate(x, y);
    canvas.rotate(cube.rotX);

    final rect = Rect.fromCenter(
      center: Offset.zero,
      width: cube.size,
      height: cube.size,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, Radius.circular(cube.size * 0.2)),
      paint,
    );

    canvas.restore();
  }

  void _drawSphere(Canvas canvas, Size size, FloatingSphere sphere) {
    final paint = Paint()
      ..color = sphere.color.withOpacity(sphere.opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final x = sphere.x * size.width;
    final y = sphere.y * size.height;

    canvas.drawCircle(
      Offset(x, y),
      sphere.radius,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class AnimatedHomePainter extends CustomPainter {
  final double rotationAngle;
  final double floatValue;

  AnimatedHomePainter({
    required this.rotationAngle,
    required this.floatValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF6366F1).withOpacity(0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    // Draw animated home shapes
    for (int i = 0; i < 5; i++) {
      final x = (size.width * 0.2 + i * size.width * 0.2) + 
                math.sin(rotationAngle + i * 0.5) * 30;
      final y = (size.height * 0.3 + i * size.height * 0.15) + 
                math.cos(rotationAngle + i * 0.3) * 20;

      _drawHouse(canvas, Offset(x, y), 40 + i * 10, paint);
    }
  }

  void _drawHouse(Canvas canvas, Offset center, double size, Paint paint) {
    // House base
    final baseRect = Rect.fromCenter(
      center: Offset(center.dx, center.dy + size * 0.2),
      width: size,
      height: size * 0.6,
    );
    canvas.drawRect(baseRect, paint);

    // Roof
    final roofPath = Path()
      ..moveTo(center.dx - size * 0.6, center.dy - size * 0.1)
      ..lineTo(center.dx, center.dy - size * 0.5)
      ..lineTo(center.dx + size * 0.6, center.dy - size * 0.1)
      ..close();
    canvas.drawPath(roofPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class UltraProWavePainter extends CustomPainter {
  final double waveValue;
  final List<WaveElement> waves;

  UltraProWavePainter({
    required this.waveValue,
    required this.waves,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final wave in waves) {
      wave.update(waveValue);
      _drawWave(canvas, size, wave);
    }
  }

  void _drawWave(Canvas canvas, Size size, WaveElement wave) {
    final paint = Paint()
      ..color = wave.color.withOpacity(wave.opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final path = Path();
    final startX = wave.x * size.width;
    final startY = wave.y * size.height;

    path.moveTo(startX, startY);

    for (double i = 0; i <= size.width; i += 5) {
      final x = startX + i;
      final y = startY + math.sin(i * wave.frequency + wave.phase) * wave.amplitude;
      path.lineTo(x, y);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class Floating3DElementsPainter extends CustomPainter {
  final double floatingValue;
  final double morphValue;
  final List<FloatingShape> shapes;

  Floating3DElementsPainter({
    required this.floatingValue,
    required this.morphValue,
    required this.shapes,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final shape in shapes) {
      shape.update();
      _drawShape(canvas, size, shape);
    }
  }

  void _drawShape(Canvas canvas, Size size, FloatingShape shape) {
    final paint = Paint()
      ..color = shape.color.withOpacity(shape.opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final x = shape.x * size.width;
    final y = shape.y * size.height;

    canvas.save();
    canvas.translate(x, y);
    canvas.rotate(shape.rotation);

    switch (shape.shapeType) {
      case 0: // Circle
        canvas.drawCircle(Offset.zero, shape.size * 0.5, paint);
        break;
      case 1: // Square
        final rect = Rect.fromCenter(
          center: Offset.zero,
          width: shape.size,
          height: shape.size,
        );
        canvas.drawRect(rect, paint);
        break;
      case 2: // Triangle
        final path = Path()
          ..moveTo(0, -shape.size * 0.5)
          ..lineTo(shape.size * 0.5, shape.size * 0.5)
          ..lineTo(-shape.size * 0.5, shape.size * 0.5)
          ..close();
        canvas.drawPath(path, paint);
        break;
      case 3: // Diamond
        final path = Path()
          ..moveTo(0, -shape.size * 0.5)
          ..lineTo(shape.size * 0.5, 0)
          ..lineTo(0, shape.size * 0.5)
          ..lineTo(-shape.size * 0.5, 0)
          ..close();
        canvas.drawPath(path, paint);
        break;
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class UltraProParticleSystemPainter extends CustomPainter {
  final double animationValue;
  final List<UltraParticle> particles;
  final List<Particle3D> particles3D;

  UltraProParticleSystemPainter({
    required this.animationValue,
    required this.particles,
    required this.particles3D,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Draw 2D particles
    for (final particle in particles) {
      particle.update();
      
      final paint = Paint()
        ..color = particle.color.withOpacity(particle.opacity * 0.6)
        ..style = PaintingStyle.fill;

      final x = particle.x * size.width;
      final y = particle.y * size.height;

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(particle.rotation);
      
      canvas.drawCircle(Offset.zero, particle.size, paint);
      canvas.restore();
    }

    // Draw 3D particles
    for (final particle in particles3D) {
      particle.update();
      
      final paint = Paint()
        ..color = particle.color.withOpacity(particle.opacity * particle.z)
        ..style = PaintingStyle.fill;

      final x = particle.x * size.width;
      final y = particle.y * size.height;
      final scaledSize = particle.size * particle.z;

      canvas.drawCircle(Offset(x, y), scaledSize, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class LightRaysEffectPainter extends CustomPainter {
  final double animationValue;
  final double glowValue;
  final List<LightRay> lightRays;

  LightRaysEffectPainter({
    required this.animationValue,
    required this.glowValue,
    required this.lightRays,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final ray in lightRays) {
      ray.update();
      _drawLightRay(canvas, size, ray);
    }
  }

  void _drawLightRay(Canvas canvas, Size size, LightRay ray) {
    final paint = Paint()
      ..color = ray.color.withOpacity(ray.opacity * glowValue)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final startX = ray.x * size.width;
    final startY = ray.y * size.height;
    final endX = startX + math.cos(ray.angle) * ray.length;
    final endY = startY + math.sin(ray.angle) * ray.length;

    canvas.drawLine(
      Offset(startX, startY),
      Offset(endX, endY),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

