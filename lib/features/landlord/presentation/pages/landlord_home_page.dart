import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:flutter/physics.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/services/analytics_service.dart';
import '../../../../core/services/booking_service.dart';
import '../../../../core/services/payment_service.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../mixins/landlord_animations_mixin.dart';
import '../../../../core/services/data_seeder.dart';
import '../widgets/landlord_page_layout.dart';
import '../widgets/custom_painters.dart';
import 'landlord_properties_page.dart';
import 'landlord_bookings_page.dart';
import 'landlord_analytics_page.dart';
import '../../../profile/presentation/pages/profile_page.dart';
import 'add_property_page.dart';
import 'tenant_management_page.dart';
import 'enhanced_landlord_dashboard.dart';
import 'enhanced_property_management.dart';

class LandlordHomePage extends StatefulWidget {
  const LandlordHomePage({super.key});

  @override
  State<LandlordHomePage> createState() => _LandlordHomePageState();
}

class _LandlordHomePageState extends State<LandlordHomePage>
    with TickerProviderStateMixin, LandlordAnimationsMixin {
  int _currentIndex = 0;
  final PageController _pageController = PageController();
  
  // Advanced Animation Controllers for Figma-level design
  late AnimationController _floatingParticlesController;
  late AnimationController _navigationSlideController;
  late AnimationController _backgroundPulseController;
  late AnimationController _tabIndicatorController;
  late AnimationController _morphingController;
  
  // Advanced Animations
  late Animation<double> _floatingParticlesAnimation;
  late Animation<double> _navigationSlideAnimation;
  late Animation<double> _backgroundPulseAnimation;
  late Animation<double> _tabIndicatorAnimation;
  late Animation<double> _morphingAnimation;
  
  // Particle System
  final List<Particle> _particles = [];
  
  // Tab Selection State
  bool _isAnimating = false;

@override
  void initState() {
    super.initState();
    initializeLandlordAnimations();
    startLandlordAnimations();
    _initializeAdvancedAnimations();
    _initializeParticleSystem();
  }

  @override
  void dispose() {
    _pageController.dispose();
    disposeLandlordAnimations();
    _disposeAdvancedAnimations();
    super.dispose();
  }

  void _onTabTapped(int index) {
    if (index == _currentIndex) return; // Remove the _isAnimating check
    
    print('🔄 Tab tapped: $index, current: $_currentIndex'); // Debug
    
    setState(() {
      _currentIndex = index; // Update immediately for UI consistency
    });
    
    // Simple page transition without blocking animation
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    ).then((_) {
      print('✅ Page animation completed for index: $index'); // Debug
    });
    
    // Haptic feedback
    HapticFeedback.lightImpact();
  }

@override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final bottomPadding = mediaQuery.padding.bottom;
    final screenHeight = mediaQuery.size.height;
    
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1A),
      body: SafeArea(
        bottom: false, // We'll handle bottom spacing manually
        child: AnimatedBuilder(
          animation: Listenable.merge([
            _floatingParticlesController,
            _backgroundPulseController,
            _morphingController,
          ]),
          builder: (context, child) {
            return SizedBox(
              height: screenHeight,
              child: Stack(
                children: [
                  // Advanced animated background with particles
                  Positioned.fill(
                    child: _buildFigmaLevelBackground(),
                  ),
                  
                  // Floating particles system
                  Positioned.fill(
                    child: _buildFloatingParticles(),
                  ),
                  
                  // Main content with morphing transitions - constrained height
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    bottom: 96 + bottomPadding, // Reserve a bit more space for nav bar + system bottom padding
                    child: _buildMorphingPageView(),
                  ),
                  
                  // Floating action overlay (Figma-style)
                  _buildFloatingActionOverlay(),
                  
                  // Bottom navigation bar positioned at bottom with proper constraints
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    height: 96 + bottomPadding, // Increased height for nav bar + system padding
                    child: _buildFigmaLevelBottomNavBar(),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // Advanced Animation Initialization
  void _initializeAdvancedAnimations() {
    // Floating particles animation
    _floatingParticlesController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    );
    _floatingParticlesAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _floatingParticlesController,
      curve: Curves.linear,
    ));
    
    // Navigation slide animation
    _navigationSlideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _navigationSlideAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _navigationSlideController,
      curve: Curves.elasticOut,
    ));
    
    // Background pulse animation
    _backgroundPulseController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );
    _backgroundPulseAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _backgroundPulseController,
      curve: Curves.easeInOut,
    ));
    
    // Tab indicator animation
    _tabIndicatorController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _tabIndicatorAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _tabIndicatorController,
      curve: Curves.easeInOutBack,
    ));
    
    // Morphing animation
    _morphingController = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    );
    _morphingAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _morphingController,
      curve: Curves.easeInOut,
    ));
    
    // Start continuous animations
    _floatingParticlesController.repeat();
    _backgroundPulseController.repeat(reverse: true);
    _morphingController.repeat(reverse: true);
  }
  
  void _initializeParticleSystem() {
    final random = math.Random();
    for (int i = 0; i < 25; i++) {
      _particles.add(Particle(
        x: random.nextDouble(),
        y: random.nextDouble(),
        size: random.nextDouble() * 4 + 2,
        speed: random.nextDouble() * 0.02 + 0.01,
        color: _getParticleColor(random),
        opacity: random.nextDouble() * 0.5 + 0.1,
      ));
    }
  }
  
  Color _getParticleColor(math.Random random) {
    final colors = [
      const Color(0xFF00D4FF),
      const Color(0xFF5B73FF),
      const Color(0xFF00FF80),
      const Color(0xFFFF6B9D),
      const Color(0xFF9B59B6),
      const Color(0xFFFFB800),
    ];
    return colors[random.nextInt(colors.length)];
  }
  
  void _disposeAdvancedAnimations() {
    _floatingParticlesController.dispose();
    _navigationSlideController.dispose();
    _backgroundPulseController.dispose();
    _tabIndicatorController.dispose();
    _morphingController.dispose();
  }

  Widget _buildBeautifulBottomNavBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 25,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: const Color(0xFF00D4FF).withOpacity(0.1),
            blurRadius: 40,
            spreadRadius: 5,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            height: 75,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withOpacity(0.15),
                  Colors.white.withOpacity(0.05),
                ],
              ),
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
                width: 1.5,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildBeautifulNavItem(
                  icon: Icons.dashboard_outlined,
                  activeIcon: Icons.dashboard_rounded,
                  label: 'Dashboard',
                  index: 0,
                  color: const Color(0xFF00D4FF),
                ),
                _buildBeautifulNavItem(
                  icon: Icons.home_work_outlined,
                  activeIcon: Icons.home_work_rounded,
                  label: 'Properties',
                  index: 1,
                  color: const Color(0xFF8B5CF6),
                ),
                _buildBeautifulNavItem(
                  icon: Icons.calendar_today_outlined,
                  activeIcon: Icons.calendar_today_rounded,
                  label: 'Bookings',
                  index: 2,
                  color: const Color(0xFF00FF87),
                ),
                _buildBeautifulNavItem(
                  icon: Icons.analytics_outlined,
                  activeIcon: Icons.analytics_rounded,
                  label: 'Analytics',
                  index: 3,
                  color: const Color(0xFFFF6B9D),
                ),
                _buildBeautifulNavItem(
                  icon: Icons.person_outline,
                  activeIcon: Icons.person_rounded,
                  label: 'Profile',
                  index: 4,
                  color: const Color(0xFFFFB800),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBeautifulNavItem({
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required int index,
    required Color color,
  }) {
    final isSelected = _currentIndex == index;
    
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        _onTabTapped(index);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOutCubic,
              width: 50,
              height: 32,
              decoration: BoxDecoration(
                gradient: isSelected
                    ? LinearGradient(
                        colors: [color, color.withOpacity(0.7)],
                      )
                    : null,
                borderRadius: BorderRadius.circular(20),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: color.withOpacity(0.3),
                          blurRadius: 15,
                          spreadRadius: 2,
                        ),
                      ]
                    : [],
              ),
              child: Center(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    isSelected ? activeIcon : icon,
                    key: ValueKey(isSelected),
                    color: isSelected ? Colors.white : Colors.white60,
                    size: isSelected ? 22 : 20,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 4),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 300),
              style: TextStyle(
                color: isSelected ? color : Colors.white60,
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                letterSpacing: 0.3,
              ),
              child: Text(
                label,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Methods moved from _LandlordDashboardState to _LandlordHomePageState
  Widget _buildFigmaLevelBackground() {
    return AnimatedBuilder(
      animation: _backgroundPulseAnimation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(
                -0.8 + (_backgroundPulseAnimation.value * 0.4),
                -0.6 + (_backgroundPulseAnimation.value * 0.3),
              ),
              radius: 2.5 + (_backgroundPulseAnimation.value * 0.5),
              colors: [
                Color.lerp(
                  const Color(0xFF1E40AF),
                  const Color(0xFF3B82F6),
                  _backgroundPulseAnimation.value,
                )!.withOpacity(0.5 + _backgroundPulseAnimation.value * 0.2),
                Color.lerp(
                  const Color(0xFF312E81),
                  const Color(0xFF6366F1),
                  _backgroundPulseAnimation.value,
                )!.withOpacity(0.4),
                Color.lerp(
                  const Color(0xFF0F172A),
                  const Color(0xFF1E293B),
                  _backgroundPulseAnimation.value,
                )!.withOpacity(0.9),
                const Color(0xFF000000),
              ],
              stops: const [0.0, 0.3, 0.7, 1.0],
            ),
          ),
          child: Stack(
            children: [
              _buildMeshGradientOverlay(),
              _buildDynamicLightRays(),
              _buildNoiseTextureOverlay(),
            ],
          ),
        );
      },
    );
  }
  
  Widget _buildMeshGradientOverlay() {
    return AnimatedBuilder(
      animation: _morphingAnimation,
      builder: (context, child) {
        return CustomPaint(
          painter: MeshGradientPainter(
            animationValue: _morphingAnimation.value,
            colors: [
              const Color(0xFF00D4FF).withOpacity(0.15),
              const Color(0xFF5B73FF).withOpacity(0.10),
              const Color(0xFF00FF80).withOpacity(0.08),
              const Color(0xFFFF6B9D).withOpacity(0.12),
            ],
          ),
          size: Size.infinite,
        );
      },
    );
  }
  
  Widget _buildDynamicLightRays() {
    return AnimatedBuilder(
      animation: _floatingParticlesAnimation,
      builder: (context, child) {
        return CustomPaint(
          painter: LightRaysPainter(
            animationValue: _floatingParticlesAnimation.value,
            rayCount: 8,
            rayColors: [
              const Color(0xFF00D4FF).withOpacity(0.1),
              const Color(0xFF5B73FF).withOpacity(0.08),
              const Color(0xFF00FF80).withOpacity(0.05),
            ],
          ),
          size: Size.infinite,
        );
      },
    );
  }
  
  Widget _buildNoiseTextureOverlay() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.transparent,
            Colors.white.withOpacity(0.02),
            Colors.transparent,
            Colors.white.withOpacity(0.01),
          ],
        ),
      ),
    );
  }
  
  Widget _buildFloatingParticles() {
    return AnimatedBuilder(
      animation: _floatingParticlesAnimation,
      builder: (context, child) {
        return CustomPaint(
          painter: ParticleSystemPainter(
            particles: _particles,
            animationValue: _floatingParticlesAnimation.value,
          ),
          size: Size.infinite,
        );
      },
    );
  }
  
  Widget _buildMorphingPageView() {
    return AnimatedBuilder(
      animation: _tabIndicatorAnimation,
      builder: (context, child) {
        return LayoutBuilder(
          builder: (context, constraints) {
            return Container(
              margin: EdgeInsets.all(_tabIndicatorAnimation.value * 8),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(_tabIndicatorAnimation.value * 20),
                child: SizedBox(
                  width: constraints.maxWidth,
                  height: constraints.maxHeight, // Use available height
                  child: PageView(
                    controller: _pageController,
                    onPageChanged: (index) {
                      if (!_isAnimating) {
                        setState(() {
                          _currentIndex = index;
                        });
                      }
                    },
                    children: const [
                      EnhancedLandlordDashboard(),
                      EnhancedPropertyManagement(),
                      LandlordBookingsPage(),
                      LandlordAnalyticsPage(),
                      ProfilePage(),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
  
  Widget _buildFloatingActionOverlay() {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 20,
      right: 20,
      child: AnimatedBuilder(
        animation: _navigationSlideAnimation,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(
              _navigationSlideAnimation.value * 50 - 50,
              0,
            ),
            child: Transform.scale(
              scale: 0.8 + (_navigationSlideAnimation.value * 0.2),
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFF00D4FF).withOpacity(0.8),
                      const Color(0xFF5B73FF).withOpacity(0.6),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF00D4FF).withOpacity(0.4),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(30),
                    onTap: () {
                      HapticFeedback.mediumImpact();
                      _showQuickActionPanel();
                    },
                    child: const Center(
                      child: Icon(
                        Icons.notifications_active_outlined,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
  
  void _showQuickActionPanel() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _buildQuickActionPanel(),
    );
  }
  
  Widget _buildQuickActionPanel() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF1A1B3A).withOpacity(0.95),
            const Color(0xFF0A0E27).withOpacity(0.98),
          ],
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        border: Border.all(
          color: const Color(0xFF00D4FF).withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Quick Actions',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      children: [
                        _buildQuickActionItem(
                          'Add Property',
                          Icons.add_home,
                          const Color(0xFF00FF80),
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AddPropertyPage(),
                            ),
                          ),
                        ),
                        _buildQuickActionItem(
                          'View Analytics',
                          Icons.analytics,
                          const Color(0xFF5B73FF),
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const LandlordAnalyticsPage(),
                            ),
                          ),
                        ),
                        _buildQuickActionItem(
                          'Messages',
                          Icons.message,
                          const Color(0xFFFF6B9D),
                          () {},
                        ),
                        _buildQuickActionItem(
                          'Settings',
                          Icons.settings,
                          const Color(0xFFFFB800),
                          () {},
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildQuickActionItem(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withOpacity(0.15),
            color.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.3),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: color,
                size: 32,
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildFigmaLevelBottomNavBar() {
    // Note: The outer layout already reserves `bottomPadding` space in build(),
    // so we avoid wrapping this with an additional SafeArea to prevent height
    // reduction that can cause overflow of the inner Column.
    return AnimatedBuilder(
      animation: Listenable.merge([
        _navigationSlideAnimation,
        _tabIndicatorAnimation,
      ]),
      builder: (context, child) {
        return Container(
          margin: const EdgeInsets.fromLTRB(12, 0, 12, 12.0),
          height: 82,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(32),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(0.18),
                Colors.white.withOpacity(0.08),
                Colors.white.withOpacity(0.12),
              ],
            ),
            border: Border.all(
              color: Colors.white.withOpacity(0.15),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.4),
                blurRadius: 30,
                offset: const Offset(0, 15),
                spreadRadius: 5,
              ),
              BoxShadow(
                color: const Color(0xFF00D4FF).withOpacity(0.15),
                blurRadius: 50,
                spreadRadius: 10,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(32),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white.withOpacity(0.1),
                      Colors.white.withOpacity(0.05),
                    ],
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildFigmaNavItem(
                      icon: Icons.dashboard_outlined,
                      activeIcon: Icons.dashboard_rounded,
                      label: 'Dashboard',
                      index: 0,
                      color: const Color(0xFF00D4FF),
                    ),
                    _buildFigmaNavItem(
                      icon: Icons.home_work_outlined,
                      activeIcon: Icons.home_work_rounded,
                      label: 'Properties',
                      index: 1,
                      color: const Color(0xFF8B5CF6),
                    ),
                    _buildFigmaNavItem(
                      icon: Icons.calendar_today_outlined,
                      activeIcon: Icons.calendar_today_rounded,
                      label: 'Bookings',
                      index: 2,
                      color: const Color(0xFF00FF87),
                    ),
                    _buildFigmaNavItem(
                      icon: Icons.analytics_outlined,
                      activeIcon: Icons.analytics_rounded,
                      label: 'Analytics',
                      index: 3,
                      color: const Color(0xFFFF6B9D),
                    ),
                    _buildFigmaNavItem(
                      icon: Icons.person_outline,
                      activeIcon: Icons.person_rounded,
                      label: 'Profile',
                      index: 4,
                      color: const Color(0xFFFFB800),
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
  
  Widget _buildFigmaNavItem({
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required int index,
    required Color color,
  }) {
    final isSelected = _currentIndex == index;
    
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        _onTabTapped(index);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 350),
                  width: isSelected ? 56 : 40,
                  height: isSelected ? 40 : 30,
                  decoration: BoxDecoration(
                    gradient: isSelected
                        ? RadialGradient(
                            colors: [
                              color.withOpacity(0.4),
                              color.withOpacity(0.1),
                              Colors.transparent,
                            ],
                          )
                        : null,
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: color.withOpacity(0.5),
                              blurRadius: 25,
                              spreadRadius: 3,
                            ),
                          ]
                        : [],
                  ),
                ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: isSelected ? 50 : 36,
                  height: isSelected ? 36 : 28,
                  decoration: BoxDecoration(
                    gradient: isSelected
                        ? LinearGradient(
                            colors: [
                              color.withOpacity(0.3),
                              color.withOpacity(0.15),
                            ],
                          )
                        : null,
                    borderRadius: BorderRadius.circular(20),
                    border: isSelected
                        ? Border.all(
                            color: color.withOpacity(0.4),
                            width: 1.5,
                          )
                        : null,
                  ),
                  child: Center(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      child: Icon(
                        isSelected ? activeIcon : icon,
                        key: ValueKey(isSelected),
                        color: isSelected ? Colors.white : Colors.white60,
                        size: isSelected ? 26 : 22,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 300),
              style: TextStyle(
                color: isSelected ? color : Colors.white60,
                fontSize: isSelected ? 12 : 10,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                letterSpacing: 0.5,
              ),
              child: Text(
                label,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LandlordDashboard extends StatefulWidget {
  const _LandlordDashboard();

  @override
  State<_LandlordDashboard> createState() => _LandlordDashboardState();
}

class _LandlordDashboardState extends State<_LandlordDashboard> {
  Map<String, dynamic>? _dashboardData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _generateSampleData() async {
    try {
      final authState = context.read<AuthBloc>().state;
      if (authState is! Authenticated) {
        throw Exception('User not authenticated');
      }
      final landlordId = authState.user.id;

      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00D4FF)),
          ),
        ),
      );

      await DataSeeder.seedSampleData(landlordId);
      
      // Close loading dialog
      if (mounted) Navigator.of(context).pop();
      
      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          _buildNeonSnackBar('✅ Sample data generated successfully!', true),
        );
      }

      // Reload dashboard data
      await _loadDashboardData();
    } catch (e) {
      // Close loading dialog if still open
      if (mounted) Navigator.of(context).pop();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          _buildNeonSnackBar('❌ Failed to generate sample data: ${e.toString()}', false),
        );
      }
    }
  }

  Future<void> _loadDashboardData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    
    try {
      final authState = context.read<AuthBloc>().state;
      if (authState is! Authenticated) {
        throw Exception('User not authenticated');
      }
      final landlordId = authState.user.id;

      final analytics = await AnalyticsService.getLandlordAnalytics(landlordId);
      final bookingStats = await BookingService.getBookingStatistics(landlordId);
      final paymentStats = await PaymentService.getPaymentStatistics(landlordId);

      if (mounted) {
        setState(() {
          _dashboardData = {
            'totalProperties': analytics['propertiesCount'] ?? 0,
            'activeBookings': bookingStats['confirmedBookings'] ?? 0,
            'totalRevenue': paymentStats['totalRevenue'] ?? 0.0,
            'pendingBookings': bookingStats['pendingBookings'] ?? 0,
            'recentActivities': analytics['recentActivities'] ?? [],
            'occupancyData': _generateOccupancyData(bookingStats),
          };
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _dashboardData = null;
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          _buildNeonSnackBar('Failed to load dashboard data: ${e.toString()}', false),
        );
      }
    }
  }

  List<Map<String, dynamic>> _generateOccupancyData(Map<String, dynamic> bookingStats) {
    final totalBookings = bookingStats['totalBookings'] ?? 0;
    final confirmedBookings = bookingStats['confirmedBookings'] ?? 0;
    final pendingBookings = bookingStats['pendingBookings'] ?? 0;
    final cancelledBookings = bookingStats['cancelledBookings'] ?? 0;

    return [
      {'status': 'Confirmed', 'value': confirmedBookings, 'color': const Color(0xFF00FF80)},
      {'status': 'Pending', 'value': pendingBookings, 'color': const Color(0xFF5B73FF)},
      {'status': 'Cancelled', 'value': cancelledBookings, 'color': const Color(0xFFFF6B9D)},
      {'status': 'Available', 'value': totalBookings - confirmedBookings - pendingBookings - cancelledBookings, 'color': Colors.white.withOpacity(0.3)},
    ];
  }


  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.topCenter,
          radius: 2.0,
          colors: [
            Color(0xFF0A0E27),
            Color(0xFF050818),
            Color(0xFF000510),
          ],
        ),
      ),
      child: RefreshIndicator(
        onRefresh: _loadDashboardData,
        color: const Color(0xFF00D4FF),
        backgroundColor: const Color(0xFF1A1B3A),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: _isLoading
              ? _buildUltraProfessionalLoadingState()
              : _dashboardData == null
                  ? _buildUltraProfessionalErrorState()
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),
                        _buildUltraProfessionalHeader(),
                        const SizedBox(height: 30),
                        _buildUltraProfessionalQuickStats(),
                        const SizedBox(height: 30),
                        _buildUltraProfessionalQuickActions(),
                        const SizedBox(height: 30),
                        _buildUltraProfessionalMetricsGrid(),
                        const SizedBox(height: 30),
                        Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: _buildUltraProfessionalOccupancyChart(),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              flex: 2,
                              child: _buildUltraProfessionalRevenueChart(),
                            ),
                          ],
                        ),
                        const SizedBox(height: 30),
                        _buildUltraProfessionalRecentActivities(),
                        const SizedBox(height: 40),
                      ],
                    ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              gradient: const SweepGradient(
                colors: [Color(0xFF00FFFF), Color(0xFF0080FF), Color(0xFF8000FF)],
              ),
              borderRadius: BorderRadius.circular(50),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF00FFFF).withOpacity(0.5),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Loading Dashboard Data...', 
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: const Color(0xFF00FFFF),
                  fontWeight: FontWeight.w500,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.dashboard_outlined,
            size: 80,
            color: const Color(0xFFFF6B9D).withOpacity(0.7),
          ),
          const SizedBox(height: 24),
          Text(
            'Failed to Load Dashboard Data',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: const Color(0xFFFF6B9D),
                  fontWeight: FontWeight.w500,
                ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: _loadDashboardData,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF6B9D).withOpacity(0.2),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(
                      color: const Color(0xFFFF6B9D).withOpacity(0.5),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton.icon(
                onPressed: _generateSampleData,
                icon: const Icon(Icons.data_saver_on),
                label: const Text('Generate Sample Data'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00D4FF).withOpacity(0.2),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(
                      color: const Color(0xFF00D4FF).withOpacity(0.5),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNeonHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF00D4FF).withOpacity(0.2),
            const Color(0xFF5B73FF).withOpacity(0.2),
            const Color(0xFF9B59B6).withOpacity(0.2),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF00D4FF).withOpacity(0.7),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00D4FF).withOpacity(0.3),
            blurRadius: 30,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome, Landlord!',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              shadows: [
                Shadow(
                  color: const Color(0xFF00D4FF).withOpacity(0.5),
                  blurRadius: 10,
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Manage your properties with ease',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: const Color(0xFF00D4FF),
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(
                color: const Color(0xFF00D4FF).withOpacity(0.5),
                blurRadius: 10,
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 20,
          mainAxisSpacing: 20,
          children: [
            _buildActionButton(
              'Add Property',
              Icons.add_home_work,
              const Color(0xFF00FF80),
              () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AddPropertyPage())),
            ),
            _buildActionButton(
              'View Bookings',
              Icons.calendar_today,
              const Color(0xFF00D4FF),
              () => Navigator.push(context, MaterialPageRoute(builder: (context) => const LandlordBookingsPage())),
            ),
            _buildActionButton(
              'View Analytics',
              Icons.analytics,
              const Color(0xFF5B73FF),
              () => Navigator.push(context, MaterialPageRoute(builder: (context) => const LandlordAnalyticsPage())),
            ),
            _buildActionButton(
              'Manage Tenants',
              Icons.people,
              const Color(0xFFFF6B9D),
              () => Navigator.push(context, MaterialPageRoute(builder: (context) => const TenantManagementPage())),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton(String title, IconData icon, Color color, VoidCallback onPressed) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    color.withOpacity(0.2),
                    color.withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: color.withOpacity(0.3),
                ),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.1),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    icon,
                    color: color,
                    size: 40,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    title,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          color: color.withOpacity(0.5),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildOverviewCards() {
    final totalProperties = _dashboardData?['totalProperties'] ?? 0;
    final activeBookings = _dashboardData?['activeBookings'] ?? 0;
    final totalRevenue = _dashboardData?['totalRevenue'] ?? 0.0;
    final pendingBookings = _dashboardData?['pendingBookings'] ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Overview',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: const Color(0xFF00D4FF),
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(
                color: const Color(0xFF00D4FF).withOpacity(0.5),
                blurRadius: 10,
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 20,
          mainAxisSpacing: 20,
          children: [
            _buildMetricCard(
              'Total Properties',
              totalProperties.toString(),
              Icons.home_work,
              const Color(0xFF00D4FF),
            ),
            _buildMetricCard(
              'Active Bookings',
              activeBookings.toString(),
              Icons.calendar_today,
              const Color(0xFF5B73FF),
            ),
            _buildMetricCard(
              'Total Revenue',
              '\$${totalRevenue.toStringAsFixed(2)}',
              Icons.attach_money,
              const Color(0xFF00FF80),
            ),
            _buildMetricCard(
              'Pending Bookings',
              pendingBookings.toString(),
              Icons.hourglass_empty,
              const Color(0xFFFF6B9D),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon, Color color) {
    return Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  color.withOpacity(0.2),
                  color.withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: color.withOpacity(0.3),
              ),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.1),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(
                  icon,
                  color: color,
                  size: 36,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      value,
                      style: TextStyle(
                        color: color,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(
                            color: color.withOpacity(0.5),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
    );
  }

  Widget _buildOccupancyChart() {
    final occupancyData = _dashboardData?['occupancyData'] ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Occupancy Overview',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: const Color(0xFF00D4FF),
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(
                color: const Color(0xFF00D4FF).withOpacity(0.5),
                blurRadius: 10,
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Container(
          height: 250,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF1A1B3A).withOpacity(0.8),
                const Color(0xFF2A2B4A).withOpacity(0.6),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFF00D4FF).withOpacity(0.3),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF00D4FF).withOpacity(0.1),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: PieChart(
            PieChartData(
              sections: occupancyData.map<PieChartSectionData>((data) {
                return PieChartSectionData(
                  color: data['color'],
                  value: data['value'].toDouble(),
                  title: data['value'] > 0 ? '${data['value']}' : '',
                  radius: 80,
                  titleStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  badgeWidget: data['value'] > 0 ? _buildBadge(data['status']) : null,
                  badgePositionPercentageOffset: 1.2,
                );
              }).toList(),
              sectionsSpace: 2,
              centerSpaceRadius: 40,
              pieTouchData: PieTouchData(enabled: true),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 16,
          runSpacing: 8,
          children: occupancyData.map<Widget>((data) {
            return _buildChartLegend(data['status'], data['color']);
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.white.withOpacity(0.8),
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildChartLegend(String title, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildRecentActivities() {
    final recentActivities = _dashboardData?['recentActivities'] ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Activities',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: const Color(0xFF00D4FF),
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(
                color: const Color(0xFF00D4FF).withOpacity(0.5),
                blurRadius: 10,
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        recentActivities.isEmpty
            ? _buildEmptyState('No recent activities.')
            : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: recentActivities.length,
                itemBuilder: (context, index) {
                  final activity = recentActivities[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 15),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          const Color(0xFF1A1B3A).withOpacity(0.8),
                          const Color(0xFF2A2B4A).withOpacity(0.6),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFF00D4FF).withOpacity(0.3),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF00D4FF).withOpacity(0.1),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFF5B73FF).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            _getActivityIcon(activity['type']),
                            color: const Color(0xFF5B73FF),
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                activity['description'] ?? 'N/A',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                activity['timestamp'] != null
                                    ? DateFormat('MMM dd, yyyy HH:mm').format(DateTime.parse(activity['timestamp']))
                                    : 'N/A',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.7),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
      ],
    );
  }

  IconData _getActivityIcon(String type) {
    switch (type) {
      case 'booking':
        return Icons.calendar_today;
      case 'payment':
        return Icons.attach_money;
      case 'property_update':
        return Icons.home_work;
      default:
        return Icons.info_outline;
    }
  }

  Widget _buildEmptyState(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF1A1B3A).withOpacity(0.8),
            const Color(0xFF2A2B4A).withOpacity(0.6),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF00D4FF).withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00D4FF).withOpacity(0.1),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            Icons.info_outline,
            color: const Color(0xFF00D4FF).withOpacity(0.7),
            size: 48,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }


  SnackBar _buildNeonSnackBar(String message, bool isSuccess) {
    return SnackBar(
      content: Text(
        message,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: isSuccess ? const Color(0xFF00D4FF) : const Color(0xFFFF6B9D),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      margin: const EdgeInsets.all(16),
    );
  }

  // Ultra Professional Dashboard Components
  Widget _buildUltraProfessionalLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              // Outer rotating ring
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFF00D4FF).withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: 2 * math.pi),
                  duration: const Duration(seconds: 3),
                  builder: (context, value, child) {
                    return Transform.rotate(
                      angle: value,
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: SweepGradient(
                            colors: [
                              const Color(0xFF00D4FF).withOpacity(0.1),
                              const Color(0xFF00D4FF),
                              const Color(0xFF5B73FF),
                              const Color(0xFF00D4FF).withOpacity(0.1),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              // Inner pulsing circle
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFF00D4FF).withOpacity(0.5),
                      const Color(0xFF00D4FF).withOpacity(0.1),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF00D4FF).withOpacity(0.5),
                      blurRadius: 30,
                      spreadRadius: 10,
                    ),
                  ],
                ),
                child: const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    strokeWidth: 3,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.5, end: 1.0),
            duration: const Duration(milliseconds: 1500),
            builder: (context, value, child) {
              return Opacity(
                opacity: value,
                child: Text(
                  'Initializing Dashboard...',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: const Color(0xFF00D4FF),
                    fontWeight: FontWeight.w600,
                    shadows: [
                      Shadow(
                        color: const Color(0xFF00D4FF).withOpacity(0.5),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildUltraProfessionalErrorState() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(32),
        margin: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFFFF6B9D).withOpacity(0.15),
              const Color(0xFF1A1B3A).withOpacity(0.8),
              const Color(0xFFFF6B9D).withOpacity(0.15),
            ],
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: const Color(0xFFFF6B9D).withOpacity(0.5),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFF6B9D).withOpacity(0.3),
              blurRadius: 25,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFFF6B9D).withOpacity(0.2),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFF6B9D).withOpacity(0.3),
                    blurRadius: 20,
                  ),
                ],
              ),
              child: Icon(
                Icons.warning_amber_rounded,
                size: 60,
                color: const Color(0xFFFF6B9D),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Dashboard Unavailable',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                shadows: [
                  Shadow(
                    color: const Color(0xFFFF6B9D).withOpacity(0.5),
                    blurRadius: 10,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Unable to load your dashboard data. Please try again or generate sample data to get started.',
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildUltraProfessionalButton(
                  'Retry',
                  Icons.refresh_rounded,
                  const Color(0xFF00D4FF),
                  _loadDashboardData,
                ),
                const SizedBox(width: 16),
                _buildUltraProfessionalButton(
                  'Generate Data',
                  Icons.auto_fix_high,
                  const Color(0xFF00FF80),
                  _generateSampleData,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUltraProfessionalButton(
    String text,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 15,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onPressed,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color.withOpacity(0.8), color.withOpacity(0.6)],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: color.withOpacity(0.5),
                width: 1.5,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Text(
                  text,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUltraProfessionalHeader() {
    final now = DateTime.now();
    final timeOfDay = now.hour < 12 ? 'Morning' : now.hour < 17 ? 'Afternoon' : 'Evening';
    
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF00D4FF).withOpacity(0.2),
            const Color(0xFF5B73FF).withOpacity(0.2),
            const Color(0xFF9B59B6).withOpacity(0.2),
            const Color(0xFF00D4FF).withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFF00D4FF).withOpacity(0.4),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00D4FF).withOpacity(0.25),
            blurRadius: 30,
            spreadRadius: 5,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Good $timeOfDay, Landlord!',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        color: const Color(0xFF00D4FF).withOpacity(0.5),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Your properties are performing excellently today',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormat('EEEE, MMMM dd, yyyy').format(now),
                  style: TextStyle(
                    color: const Color(0xFF00D4FF).withOpacity(0.9),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  const Color(0xFF00D4FF).withOpacity(0.3),
                  const Color(0xFF00D4FF).withOpacity(0.1),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF00D4FF).withOpacity(0.3),
                  blurRadius: 20,
                ),
              ],
            ),
            child: Icon(
              timeOfDay == 'Morning' ? Icons.wb_sunny_rounded :
              timeOfDay == 'Afternoon' ? Icons.wb_sunny_outlined : Icons.nightlight_round,
              color: const Color(0xFF00D4FF),
              size: 32,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUltraProfessionalQuickStats() {
    final totalProperties = _dashboardData?['totalProperties'] ?? 0;
    final activeBookings = _dashboardData?['activeBookings'] ?? 0;
    final totalRevenue = _dashboardData?['totalRevenue'] ?? 0.0;
    final pendingBookings = _dashboardData?['pendingBookings'] ?? 0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF1A1B3A).withOpacity(0.9),
            const Color(0xFF2A2B4A).withOpacity(0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF00D4FF).withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00D4FF).withOpacity(0.15),
            blurRadius: 25,
            spreadRadius: 3,
          ),
        ],
      ),
      child: Row(
        children: [
          _buildQuickStatItem(
            'Properties',
            totalProperties.toString(),
            Icons.home_work_rounded,
            const Color(0xFF00D4FF),
          ),
          const SizedBox(width: 1),
          _buildStatDivider(),
          const SizedBox(width: 1),
          _buildQuickStatItem(
            'Active',
            activeBookings.toString(),
            Icons.event_available,
            const Color(0xFF00FF80),
          ),
          const SizedBox(width: 1),
          _buildStatDivider(),
          const SizedBox(width: 1),
          _buildQuickStatItem(
            'Revenue',
            '\$${(totalRevenue / 1000).toStringAsFixed(1)}k',
            Icons.trending_up,
            const Color(0xFF5B73FF),
          ),
          const SizedBox(width: 1),
          _buildStatDivider(),
          const SizedBox(width: 1),
          _buildQuickStatItem(
            'Pending',
            pendingBookings.toString(),
            Icons.schedule,
            const Color(0xFFFF6B9D),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStatItem(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: RadialGradient(
                colors: [
                  color.withOpacity(0.3),
                  color.withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              shadows: [
                Shadow(
                  color: color.withOpacity(0.5),
                  blurRadius: 8,
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildStatDivider() {
    return Container(
      height: 50,
      width: 1.5,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            const Color(0xFF00D4FF).withOpacity(0.3),
            Colors.transparent,
          ],
        ),
      ),
    );
  }

  Widget _buildUltraProfessionalQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.flash_on,
              color: const Color(0xFF00D4FF),
              size: 24,
            ),
            const SizedBox(width: 12),
            Text(
              'Quick Actions',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: const Color(0xFF00D4FF),
                fontWeight: FontWeight.bold,
                shadows: [
                  Shadow(
                    color: const Color(0xFF00D4FF).withOpacity(0.5),
                    blurRadius: 10,
                  ),
                ],
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF00D4FF).withOpacity(0.2),
                    const Color(0xFF5B73FF).withOpacity(0.2),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF00D4FF).withOpacity(0.3),
                ),
              ),
              child: Text(
                '4 Actions',
                style: TextStyle(
                  color: const Color(0xFF00D4FF),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.3,
          children: [
            _buildUltraProfessionalActionCard(
              'Add Property',
              'Create new listing',
              Icons.add_home_work,
              const Color(0xFF00FF80),
              () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AddPropertyPage())),
            ),
            _buildUltraProfessionalActionCard(
              'View Bookings',
              'Manage reservations',
              Icons.calendar_view_month,
              const Color(0xFF00D4FF),
              () => Navigator.push(context, MaterialPageRoute(builder: (context) => const LandlordBookingsPage())),
            ),
            _buildUltraProfessionalActionCard(
              'Analytics',
              'Performance insights',
              Icons.analytics,
              const Color(0xFF5B73FF),
              () => Navigator.push(context, MaterialPageRoute(builder: (context) => const LandlordAnalyticsPage())),
            ),
            _buildUltraProfessionalActionCard(
              'Tenants',
              'Manage relationships',
              Icons.people,
              const Color(0xFFFF6B9D),
              () => Navigator.push(context, MaterialPageRoute(builder: (context) => const TenantManagementPage())),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildUltraProfessionalActionCard(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.15),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onPressed,
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  color.withOpacity(0.15),
                  const Color(0xFF1A1B3A).withOpacity(0.8),
                  color.withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: color.withOpacity(0.3),
                width: 1.5,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          colors: [
                            color.withOpacity(0.3),
                            color.withOpacity(0.1),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        icon,
                        color: color,
                        size: 24,
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.white.withOpacity(0.5),
                      size: 16,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        color: color.withOpacity(0.3),
                        blurRadius: 5,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUltraProfessionalMetricsGrid() {
    final totalProperties = _dashboardData?['totalProperties'] ?? 0;
    final activeBookings = _dashboardData?['activeBookings'] ?? 0;
    final totalRevenue = _dashboardData?['totalRevenue'] ?? 0.0;
    final pendingBookings = _dashboardData?['pendingBookings'] ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.dashboard_customize,
              color: const Color(0xFF00D4FF),
              size: 24,
            ),
            const SizedBox(width: 12),
            Text(
              'Performance Metrics',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: const Color(0xFF00D4FF),
                fontWeight: FontWeight.bold,
                shadows: [
                  Shadow(
                    color: const Color(0xFF00D4FF).withOpacity(0.5),
                    blurRadius: 10,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.4,
          children: [
            _buildUltraProfessionalMetricCard(
              'Total Properties',
              totalProperties.toString(),
              '+12%',
              Icons.home_work,
              const Color(0xFF00D4FF),
              isPositive: true,
            ),
            _buildUltraProfessionalMetricCard(
              'Active Bookings',
              activeBookings.toString(),
              '+8%',
              Icons.event_available,
              const Color(0xFF5B73FF),
              isPositive: true,
            ),
            _buildUltraProfessionalMetricCard(
              'Monthly Revenue',
              '\$${totalRevenue.toStringAsFixed(0)}',
              '+15%',
              Icons.trending_up,
              const Color(0xFF00FF80),
              isPositive: true,
            ),
            _buildUltraProfessionalMetricCard(
              'Pending Reviews',
              pendingBookings.toString(),
              '-3%',
              Icons.rate_review,
              const Color(0xFFFF6B9D),
              isPositive: false,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildUltraProfessionalMetricCard(
    String title,
    String value,
    String change,
    IconData icon,
    Color color,
    {required bool isPositive}
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withOpacity(0.15),
            const Color(0xFF1A1B3A).withOpacity(0.9),
            color.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 20,
            spreadRadius: 3,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    colors: [
                      color.withOpacity(0.3),
                      color.withOpacity(0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 20,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isPositive 
                    ? const Color(0xFF00FF80).withOpacity(0.2)
                    : const Color(0xFFFF6B9D).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isPositive 
                      ? const Color(0xFF00FF80).withOpacity(0.3)
                      : const Color(0xFFFF6B9D).withOpacity(0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isPositive ? Icons.trending_up : Icons.trending_down,
                      size: 12,
                      color: isPositive 
                        ? const Color(0xFF00FF80)
                        : const Color(0xFFFF6B9D),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      change,
                      style: TextStyle(
                        color: isPositive 
                          ? const Color(0xFF00FF80)
                          : const Color(0xFFFF6B9D),
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              shadows: [
                Shadow(
                  color: color.withOpacity(0.5),
                  blurRadius: 8,
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUltraProfessionalOccupancyChart() {
    final occupancyData = _dashboardData?['occupancyData'] ?? [];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF1A1B3A).withOpacity(0.9),
            const Color(0xFF2A2B4A).withOpacity(0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF00D4FF).withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00D4FF).withOpacity(0.15),
            blurRadius: 25,
            spreadRadius: 3,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Occupancy Overview',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFF00D4FF).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.pie_chart,
                  color: const Color(0xFF00D4FF),
                  size: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: occupancyData.isNotEmpty ? PieChart(
              PieChartData(
                sections: occupancyData.map<PieChartSectionData>((data) {
                  return PieChartSectionData(
                    color: data['color'],
                    value: data['value'].toDouble(),
                    title: data['value'] > 0 ? '${data['value']}' : '',
                    radius: 70,
                    titleStyle: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  );
                }).toList(),
                sectionsSpace: 2,
                centerSpaceRadius: 30,
                pieTouchData: PieTouchData(
                  touchCallback: (FlTouchEvent event, pieTouchResponse) {},
                  enabled: true,
                ),
              ),
            ) : Center(
              child: Text(
                'No data available',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: occupancyData.map<Widget>((data) {
              return _buildLegendItem(data['status'], data['color']);
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String title, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          title,
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildUltraProfessionalRevenueChart() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF1A1B3A).withOpacity(0.9),
            const Color(0xFF2A2B4A).withOpacity(0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF00FF80).withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00FF80).withOpacity(0.15),
            blurRadius: 25,
            spreadRadius: 3,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Revenue Trend',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFF00FF80).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.trending_up,
                  color: const Color(0xFF00FF80),
                  size: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 1000,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Colors.white.withOpacity(0.1),
                      strokeWidth: 1,
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: 1,
                      getTitlesWidget: (double value, TitleMeta meta) {
                        const style = TextStyle(
                          color: Colors.white54,
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        );
                        Widget text;
                        switch (value.toInt()) {
                          case 0:
                            text = const Text('Jan', style: style);
                            break;
                          case 1:
                            text = const Text('Feb', style: style);
                            break;
                          case 2:
                            text = const Text('Mar', style: style);
                            break;
                          case 3:
                            text = const Text('Apr', style: style);
                            break;
                          case 4:
                            text = const Text('May', style: style);
                            break;
                          case 5:
                            text = const Text('Jun', style: style);
                            break;
                          default:
                            text = const Text('', style: style);
                            break;
                        }
                        return SideTitleWidget(
                          axisSide: meta.axisSide,
                          child: text,
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 2000,
                      getTitlesWidget: (double value, TitleMeta meta) {
                        return Text(
                          '\$${(value / 1000).toInt()}k',
                          style: const TextStyle(
                            color: Colors.white54,
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                        );
                      },
                      reservedSize: 42,
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: 5,
                minY: 0,
                maxY: 6000,
                lineBarsData: [
                  LineChartBarData(
                    spots: [
                      const FlSpot(0, 3000),
                      const FlSpot(1, 3500),
                      const FlSpot(2, 2800),
                      const FlSpot(3, 4200),
                      const FlSpot(4, 4800),
                      const FlSpot(5, 5200),
                    ],
                    isCurved: true,
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF00FF80),
                        Color(0xFF00D4FF),
                      ],
                    ),
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 4,
                          color: const Color(0xFF00FF80),
                          strokeWidth: 2,
                          strokeColor: Colors.white,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          const Color(0xFF00FF80).withOpacity(0.3),
                          const Color(0xFF00FF80).withOpacity(0.1),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUltraProfessionalRecentActivities() {
    final recentActivities = _dashboardData?['recentActivities'] ?? [];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF1A1B3A).withOpacity(0.9),
            const Color(0xFF2A2B4A).withOpacity(0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF00D4FF).withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00D4FF).withOpacity(0.15),
            blurRadius: 25,
            spreadRadius: 3,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.history,
                color: const Color(0xFF00D4FF),
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Recent Activities',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () {},
                child: Text(
                  'View All',
                  style: TextStyle(
                    color: const Color(0xFF00D4FF),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          recentActivities.isEmpty
              ? _buildUltraProfessionalEmptyState()
              : ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: math.min(recentActivities.length, 5),
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final activity = recentActivities[index];
                    return _buildUltraProfessionalActivityItem(activity);
                  },
                ),
        ],
      ),
    );
  }

  Widget _buildUltraProfessionalActivityItem(Map<String, dynamic> activity) {
    final activityType = activity['type'] ?? 'unknown';
    final color = _getActivityColor(activityType);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withOpacity(0.1),
            Colors.transparent,
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: RadialGradient(
                colors: [
                  color.withOpacity(0.3),
                  color.withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              _getActivityIcon(activityType),
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity['description'] ?? 'Activity occurred',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  activity['timestamp'] != null
                      ? _formatActivityTime(DateTime.parse(activity['timestamp']))
                      : 'Unknown time',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              activityType.toUpperCase(),
              style: TextStyle(
                color: color,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getActivityColor(String type) {
    switch (type) {
      case 'booking':
        return const Color(0xFF00FF80);
      case 'payment':
        return const Color(0xFF5B73FF);
      case 'property_update':
        return const Color(0xFF00D4FF);
      default:
        return const Color(0xFFFF6B9D);
    }
  }

  String _formatActivityTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  Widget _buildUltraProfessionalEmptyState() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF00D4FF).withOpacity(0.1),
            Colors.transparent,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF00D4FF).withOpacity(0.2),
          style: BorderStyle.solid,
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF00D4FF).withOpacity(0.1),
            ),
            child: Icon(
              Icons.timeline,
              color: const Color(0xFF00D4FF).withOpacity(0.7),
              size: 32,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No Recent Activity',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your activity will appear here as you manage your properties',
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// FIGMA-LEVEL CUSTOM PAINTERS

class Particle {
  double x;
  double y;
  final double size;
  final double speed;
  final Color color;
  final double opacity;
  double angle;
  
  Particle({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.color,
    required this.opacity,
    this.angle = 0.0,
  });
  
  void update(double deltaTime) {
    x += speed * math.cos(angle) * deltaTime * 100;
    y += speed * math.sin(angle) * deltaTime * 100;
    angle += 0.01;
    
    // Wrap around screen
    if (x > 1.1) x = -0.1;
    if (x < -0.1) x = 1.1;
    if (y > 1.1) y = -0.1;
    if (y < -0.1) y = 1.1;
  }
}

class ParticleSystemPainter extends CustomPainter {
  final List<Particle> particles;
  final double animationValue;
  
  ParticleSystemPainter({
    required this.particles,
    required this.animationValue,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    for (final particle in particles) {
      particle.update(0.016); // 60fps
      
      final paint = Paint()
        ..color = particle.color.withOpacity(particle.opacity * (0.3 + 0.7 * math.sin(animationValue * math.pi * 2)))
        ..style = PaintingStyle.fill;
      
      final center = Offset(
        particle.x * size.width,
        particle.y * size.height,
      );
      
      // Draw particle with glow effect
      final glowPaint = Paint()
        ..color = particle.color.withOpacity(particle.opacity * 0.1)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
      
      canvas.drawCircle(center, particle.size * 3, glowPaint);
      canvas.drawCircle(center, particle.size, paint);
    }
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class MeshGradientPainter extends CustomPainter {
  final double animationValue;
  final List<Color> colors;
  
  MeshGradientPainter({
    required this.animationValue,
    required this.colors,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    
    // Create multiple gradients at different positions
    for (int i = 0; i < colors.length; i++) {
      final gradient = RadialGradient(
        center: Alignment(
          -1 + (i / colors.length * 2) + math.sin(animationValue * math.pi + i) * 0.3,
          -1 + (i / colors.length * 2) + math.cos(animationValue * math.pi + i) * 0.3,
        ),
        radius: 0.8 + math.sin(animationValue * math.pi * 2 + i) * 0.3,
        colors: [colors[i], Colors.transparent],
        stops: const [0.0, 1.0],
      );
      
      final paint = Paint()..shader = gradient.createShader(rect);
      canvas.drawRect(rect, paint);
    }
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

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
    final center = Offset(size.width / 2, size.height / 2);
    
    for (int i = 0; i < rayCount; i++) {
      final angle = (i / rayCount * math.pi * 2) + (animationValue * math.pi * 2);
      final rayLength = size.width * 0.8;
      
      final gradient = LinearGradient(
        begin: Alignment.center,
        end: Alignment.centerRight,
        colors: [
          rayColors[i % rayColors.length],
          Colors.transparent,
        ],
      );
      
      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(angle);
      
      final rect = Rect.fromLTWH(-rayLength/2, -2, rayLength, 4);
      final paint = Paint()..shader = gradient.createShader(rect);
      
      canvas.drawRect(rect, paint);
      canvas.restore();
    }
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
