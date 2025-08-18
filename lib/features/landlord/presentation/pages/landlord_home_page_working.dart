import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_theme.dart';
import 'landlord_properties_page.dart';
import 'landlord_bookings_page.dart';
import 'landlord_analytics_page.dart';
import '../../../profile/presentation/pages/profile_page.dart';
import 'enhanced_landlord_dashboard.dart';
import 'enhanced_property_management.dart';

class LandlordHomePageWorking extends StatefulWidget {
  const LandlordHomePageWorking({super.key});

  @override
  State<LandlordHomePageWorking> createState() => _LandlordHomePageWorkingState();
}

class _LandlordHomePageWorkingState extends State<LandlordHomePageWorking>
    with TickerProviderStateMixin {
  int _currentIndex = 0;
  final PageController _pageController = PageController();
  
  // Simple Animation Controllers
  late AnimationController _backgroundController;
  late AnimationController _navController;
  
  // Simple Animations
  late Animation<double> _backgroundAnimation;
  late Animation<double> _navAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _backgroundController.dispose();
    _navController.dispose();
    super.dispose();
  }

  void _initializeAnimations() {
    // Simple background animation
    _backgroundController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    );
    _backgroundAnimation = Tween<double>(
      begin: 0.0,
      end: 2 * math.pi,
    ).animate(_backgroundController);
    
    // Simple nav animation
    _navController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _navAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _navController,
      curve: Curves.easeInOut,
    ));

    // Start background animation
    _backgroundController.repeat();
    _navController.forward();
  }

  void _onTabTapped(int index) {
    if (index == _currentIndex) return;
    
    print('🔄 Tab tapped: $index, current: $_currentIndex'); // Debug
    
    setState(() {
      _currentIndex = index;
    });
    
    // Animate to the new page
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    ).then((_) {
      print('✅ Page changed to index: $index'); // Debug
    });
    
    // Haptic feedback
    HapticFeedback.lightImpact();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1A),
      extendBody: true,
      body: AnimatedBuilder(
        animation: _backgroundAnimation,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.topLeft,
                radius: 1.5,
                colors: [
                  Color.lerp(
                    const Color(0xFF1A237E),
                    const Color(0xFF3F51B5),
                    math.sin(_backgroundAnimation.value) * 0.5 + 0.5,
                  )!,
                  const Color(0xFF0A0E27),
                  const Color(0xFF000000),
                ],
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  // Header
                  _buildHeader(),
                  
                  // Main content area with PageView
                  Expanded(
                    child: PageView(
                      controller: _pageController,
                      onPageChanged: (index) {
                        print('📄 Page changed via swipe to: $index'); // Debug
                        setState(() {
                          _currentIndex = index;
                        });
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
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF00D4FF), Color(0xFF5B73FF)],
              ),
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF00D4FF).withOpacity(0.3),
                  blurRadius: 15,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: const Icon(
              Icons.dashboard_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Landlord Dashboard',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Current Page: ${_getPageTitle(_currentIndex)}',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavBar() {
    return AnimatedBuilder(
      animation: _navAnimation,
      builder: (context, child) {
        return Container(
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.white.withOpacity(0.1),
                Colors.white.withOpacity(0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(25),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(25),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                height: 70,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withOpacity(0.1),
                      Colors.white.withOpacity(0.05),
                    ],
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildNavItem(
                      icon: Icons.dashboard_outlined,
                      activeIcon: Icons.dashboard_rounded,
                      label: 'Dashboard',
                      index: 0,
                      color: const Color(0xFF00D4FF),
                    ),
                    _buildNavItem(
                      icon: Icons.home_work_outlined,
                      activeIcon: Icons.home_work_rounded,
                      label: 'Properties',
                      index: 1,
                      color: const Color(0xFF8B5CF6),
                    ),
                    _buildNavItem(
                      icon: Icons.calendar_today_outlined,
                      activeIcon: Icons.calendar_today_rounded,
                      label: 'Bookings',
                      index: 2,
                      color: const Color(0xFF00FF87),
                    ),
                    _buildNavItem(
                      icon: Icons.analytics_outlined,
                      activeIcon: Icons.analytics_rounded,
                      label: 'Analytics',
                      index: 3,
                      color: const Color(0xFFFF6B9D),
                    ),
                    _buildNavItem(
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

  Widget _buildNavItem({
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required int index,
    required Color color,
  }) {
    final isSelected = _currentIndex == index;
    
    return GestureDetector(
      onTap: () => _onTabTapped(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: isSelected ? 40 : 32,
              height: isSelected ? 40 : 32,
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
                          color: color.withOpacity(0.4),
                          blurRadius: 10,
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
                    size: isSelected ? 22 : 18,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 4),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                color: isSelected ? color : Colors.white60,
                fontSize: isSelected ? 11 : 10,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
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

  String _getPageTitle(int index) {
    switch (index) {
      case 0:
        return 'Dashboard';
      case 1:
        return 'Properties';
      case 2:
        return 'Bookings';
      case 3:
        return 'Analytics';
      case 4:
        return 'Profile';
      default:
        return 'Dashboard';
    }
  }
}
