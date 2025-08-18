import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:ui';
import 'dart:math' as math;
import '../widgets/advanced_ui_components.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../../core/services/analytics_service.dart';
import '../../../../core/services/booking_service.dart';
import '../../../../core/services/payment_service.dart';

class NewBeautifulLandlordDashboard extends StatefulWidget {
  const NewBeautifulLandlordDashboard({super.key});

  @override
  State<NewBeautifulLandlordDashboard> createState() => _NewBeautifulLandlordDashboardState();
}

class _NewBeautifulLandlordDashboardState extends State<NewBeautifulLandlordDashboard>
    with TickerProviderStateMixin {
  
  Map<String, dynamic>? _dashboardData;
  bool _isLoading = true;
  String _selectedTimeRange = 'This Month';
  
  // Animation Controllers
  late AnimationController _headerAnimationController;
  late AnimationController _statsAnimationController;
  late AnimationController _cardsAnimationController;
  late AnimationController _chartsAnimationController;
  late AnimationController _backgroundController;
  
  // Animations
  late Animation<double> _headerSlideAnimation;
  late Animation<double> _headerFadeAnimation;
  late Animation<double> _statsAnimation;
  late Animation<double> _cardsAnimation;
  late Animation<double> _chartsAnimation;
  late Animation<double> _backgroundAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadDashboardData();
  }

  void _initializeAnimations() {
    // Header animations
    _headerAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // Stats animations
    _statsAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    // Cards animations  
    _cardsAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    // Charts animations
    _chartsAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1800),
      vsync: this,
    );

    // Background animation (continuous)
    _backgroundController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    );

    // Create animations
    _headerSlideAnimation = Tween<double>(
      begin: -100.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _headerAnimationController,
      curve: Curves.elasticOut,
    ));

    _headerFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _headerAnimationController,
      curve: Curves.easeInOut,
    ));

    _statsAnimation = CurvedAnimation(
      parent: _statsAnimationController,
      curve: Curves.bounceOut,
    );

    _cardsAnimation = CurvedAnimation(
      parent: _cardsAnimationController,
      curve: Curves.elasticOut,
    );

    _chartsAnimation = CurvedAnimation(
      parent: _chartsAnimationController,
      curve: Curves.easeOutExpo,
    );

    _backgroundAnimation = CurvedAnimation(
      parent: _backgroundController,
      curve: Curves.linear,
    );

    // Start background animation loop
    _backgroundController.repeat();
  }

  @override
  void dispose() {
    _headerAnimationController.dispose();
    _statsAnimationController.dispose();
    _cardsAnimationController.dispose();
    _chartsAnimationController.dispose();
    _backgroundController.dispose();
    super.dispose();
  }

  Future<void> _loadDashboardData() async {
    if (!mounted) return;
    
    setState(() => _isLoading = true);
    
    try {
      // Simulate loading with beautiful animation
      await Future.delayed(const Duration(seconds: 2));
      
      // Generate mock data
      setState(() {
        _dashboardData = {
          'totalRevenue': 248750.00,
          'monthlyGrowth': 0.23,
          'totalProperties': 18,
          'activeBookings': 42,
          'occupancyRate': 0.87,
          'averageRating': 4.8,
          'pendingPayments': 12500.00,
          'maintenanceRequests': 3,
          'revenueGrowth': [
            FlSpot(0, 42000),
            FlSpot(1, 45000),
            FlSpot(2, 38000),
            FlSpot(3, 52000),
            FlSpot(4, 61000),
            FlSpot(5, 58000),
            FlSpot(6, 67000),
            FlSpot(7, 72000),
            FlSpot(8, 69000),
            FlSpot(9, 78000),
            FlSpot(10, 84000),
            FlSpot(11, 89000),
          ],
          'topProperties': [
            {'name': 'Skyline Penthouse', 'revenue': 12500, 'rating': 4.9, 'occupancy': 0.95},
            {'name': 'Garden Villa Estate', 'revenue': 8900, 'rating': 4.8, 'occupancy': 0.92},
            {'name': 'Modern Loft Complex', 'revenue': 7600, 'rating': 4.7, 'occupancy': 0.88},
            {'name': 'Beachfront Apartment', 'revenue': 6800, 'rating': 4.6, 'occupancy': 0.85},
          ],
          'recentActivities': [
            {
              'type': 'payment_received',
              'title': 'Payment Received',
              'description': 'John Smith - Skyline Penthouse',
              'amount': 3200.00,
              'time': '2 hours ago',
              'icon': Icons.payments_rounded,
              'color': const Color(0xFF00FF87),
            },
            {
              'type': 'new_booking',
              'title': 'New Booking',
              'description': 'Sarah Johnson - Garden Villa',
              'amount': 2800.00,
              'time': '5 hours ago',
              'icon': Icons.event_available_rounded,
              'color': const Color(0xFF00D4FF),
            },
            {
              'type': 'property_inquiry',
              'title': 'Property Inquiry',
              'description': 'Michael Davis - Beachfront Apt',
              'time': '1 day ago',
              'icon': Icons.help_outline_rounded,
              'color': const Color(0xFFFFB800),
            },
            {
              'type': 'maintenance_completed',
              'title': 'Maintenance Completed',
              'description': 'AC Repair - Modern Loft Complex',
              'time': '2 days ago',
              'icon': Icons.build_rounded,
              'color': const Color(0xFF8B5CF6),
            },
          ]
        };
        _isLoading = false;
      });

      // Start animations in sequence
      _headerAnimationController.forward().then((_) {
        _statsAnimationController.forward().then((_) {
          _cardsAnimationController.forward().then((_) {
            _chartsAnimationController.forward();
          });
        });
      });

    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1A), // Rich dark background
      body: _isLoading ? _buildLoadingState() : _buildDashboard(),
      extendBodyBehindAppBar: true,
    );
  }

  Widget _buildLoadingState() {
    return Stack(
      children: [
        // Animated background
        AnimatedBuilder(
          animation: _backgroundAnimation,
          builder: (context, child) {
            return Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.topLeft,
                  radius: 2.0 + (_backgroundAnimation.value * 0.5),
                  colors: [
                    const Color(0xFF1E3A8A).withOpacity(0.3),
                    const Color(0xFF0F172A).withOpacity(0.8),
                    const Color(0xFF000000),
                  ],
                ),
              ),
            );
          },
        ),
        
        // Loading animation
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Main loading circle
              Stack(
                alignment: Alignment.center,
                children: [
                  // Outer rotating ring
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: 2 * math.pi),
                    duration: const Duration(seconds: 3),
                    builder: (context, value, child) {
                      return Transform.rotate(
                        angle: value,
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: SweepGradient(
                              colors: [
                                Colors.transparent,
                                const Color(0xFF00D4FF).withOpacity(0.3),
                                const Color(0xFF00FF87),
                                const Color(0xFF8B5CF6).withOpacity(0.3),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  
                  // Inner pulsing circle
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.8, end: 1.2),
                    duration: const Duration(seconds: 2),
                    builder: (context, value, child) {
                      return Transform.scale(
                        scale: value,
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                const Color(0xFF00D4FF),
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
                        ),
                      );
                    },
                  ),
                  
                  // Center icon
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.1),
                      border: Border.all(
                        color: const Color(0xFF00D4FF),
                        width: 2,
                      ),
                    ),
                    child: const Icon(
                      Icons.dashboard_rounded,
                      color: Color(0xFF00D4FF),
                      size: 20,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 40),
              
              // Loading text with shimmer effect
              ShaderMask(
                shaderCallback: (bounds) => LinearGradient(
                  colors: [
                    Colors.white.withOpacity(0.3),
                    Colors.white,
                    Colors.white.withOpacity(0.3),
                  ],
                  stops: const [0.0, 0.5, 1.0],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ).createShader(bounds),
                child: const Text(
                  'Loading Dashboard...',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              
              const SizedBox(height: 12),
              
              Text(
                'Preparing your analytics',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.6),
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDashboard() {
    return Stack(
      children: [
        // Animated background
        _buildAnimatedBackground(),
        
        // Main content
        SafeArea(
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Custom header
              SliverToBoxAdapter(
                child: _buildHeader(),
              ),
              
              // Revenue overview card
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: _buildRevenueOverviewCard(),
                ),
              ),
              
              // Quick stats
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _buildQuickStats(),
                ),
              ),
              
              // Charts section
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: _buildChartsSection(),
                ),
              ),
              
              // Top properties
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: _buildTopPropertiesSection(),
                ),
              ),
              
              // Recent activities
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: _buildRecentActivitiesSection(),
                ),
              ),
              
              // Bottom padding
              const SliverToBoxAdapter(
                child: SizedBox(height: 100),
              ),
            ],
          ),
        ),
        
        // Floating action menu
        _buildFloatingActionMenu(),
      ],
    );
  }

  Widget _buildAnimatedBackground() {
    return AnimatedBuilder(
      animation: _backgroundAnimation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(
                -0.8 + (_backgroundAnimation.value * 0.3),
                -0.6 + (_backgroundAnimation.value * 0.2),
              ),
              radius: 1.5,
              colors: [
                const Color(0xFF1E40AF).withOpacity(0.4),
                const Color(0xFF312E81).withOpacity(0.3),
                const Color(0xFF0F172A).withOpacity(0.9),
                const Color(0xFF000000),
              ],
              stops: const [0.0, 0.3, 0.7, 1.0],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    final user = 'Alex Thompson'; // You can get this from auth state
    final greeting = _getGreeting();
    
    return AnimatedBuilder(
      animation: _headerAnimationController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _headerSlideAnimation.value),
          child: Opacity(
            opacity: _headerFadeAnimation.value,
            child: Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      // Profile section
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ShaderMask(
                              shaderCallback: (bounds) => const LinearGradient(
                                colors: [Color(0xFF00D4FF), Color(0xFF00FF87)],
                              ).createShader(bounds),
                              child: Text(
                                '$greeting,',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              user,
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    const Color(0xFF00FF87).withOpacity(0.2),
                                    const Color(0xFF00D4FF).withOpacity(0.2),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: const Color(0xFF00FF87).withOpacity(0.3),
                                ),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.verified_user_rounded,
                                    size: 14,
                                    color: Color(0xFF00FF87),
                                  ),
                                  SizedBox(width: 6),
                                  Text(
                                    'Premium Host',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF00FF87),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // Profile picture and actions
                      Column(
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Color(0xFF00D4FF),
                                  Color(0xFF00FF87),
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF00D4FF).withOpacity(0.3),
                                  blurRadius: 20,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.person_rounded,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              _buildActionButton(
                                icon: Icons.notifications_outlined,
                                onTap: () {},
                              ),
                              const SizedBox(width: 8),
                              _buildActionButton(
                                icon: Icons.settings_outlined,
                                onTap: () {},
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.white.withOpacity(0.1),
          ),
        ),
        child: Icon(
          icon,
          color: Colors.white.withOpacity(0.8),
          size: 20,
        ),
      ),
    );
  }

  Widget _buildRevenueOverviewCard() {
    final totalRevenue = _dashboardData?['totalRevenue'] ?? 0.0;
    final monthlyGrowth = _dashboardData?['monthlyGrowth'] ?? 0.0;
    final pendingPayments = _dashboardData?['pendingPayments'] ?? 0.0;
    
    return FadeTransition(
      opacity: _statsAnimation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.5),
          end: Offset.zero,
        ).animate(_statsAnimation),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
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
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF00FF87).withOpacity(0.1),
                blurRadius: 30,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF00FF87),
                          Color(0xFF00D4FF),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF00FF87).withOpacity(0.3),
                          blurRadius: 15,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.account_balance_wallet_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00FF87).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFF00FF87).withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.trending_up_rounded,
                          size: 16,
                          color: Color(0xFF00FF87),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '+${(monthlyGrowth * 100).toInt()}%',
                          style: const TextStyle(
                            color: Color(0xFF00FF87),
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              const Text(
                'Total Revenue',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              
              const SizedBox(height: 8),
              
              ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [Color(0xFF00FF87), Color(0xFF00D4FF)],
                ).createShader(bounds),
                child: Text(
                  '\$${_formatNumber(totalRevenue)}',
                  style: const TextStyle(
                    fontSize: 42,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              
              const SizedBox(height: 8),
              
              Text(
                'This month • \$${_formatNumber(pendingPayments)} pending',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickStats() {
    final stats = [
      {
        'title': 'Properties',
        'value': _dashboardData?['totalProperties']?.toString() ?? '0',
        'subtitle': 'Active listings',
        'icon': Icons.home_work_rounded,
        'color': const Color(0xFF00D4FF),
        'change': '+2 this week',
      },
      {
        'title': 'Bookings',
        'value': _dashboardData?['activeBookings']?.toString() ?? '0',
        'subtitle': 'This month',
        'icon': Icons.event_available_rounded,
        'color': const Color(0xFF8B5CF6),
        'change': '+15% vs last month',
      },
      {
        'title': 'Occupancy',
        'value': '${((_dashboardData?['occupancyRate'] ?? 0.0) * 100).toInt()}%',
        'subtitle': 'Current rate',
        'icon': Icons.pie_chart_rounded,
        'color': const Color(0xFFFFB800),
        'change': '+3% this month',
      },
      {
        'title': 'Rating',
        'value': (_dashboardData?['averageRating'] ?? 0.0).toStringAsFixed(1),
        'subtitle': 'Avg guest rating',
        'icon': Icons.star_rounded,
        'color': const Color(0xFFFF6B9D),
        'change': '+0.2 improved',
      },
    ];
    
    return AnimatedBuilder(
      animation: _statsAnimationController,
      builder: (context, child) {
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.1,
          ),
          itemCount: stats.length,
          itemBuilder: (context, index) {
            final stat = stats[index];
            final animation = Tween<double>(
              begin: 0.0,
              end: 1.0,
            ).animate(CurvedAnimation(
              parent: _statsAnimationController,
              curve: Interval(
                index * 0.1,
                0.6 + (index * 0.1),
                curve: Curves.elasticOut,
              ),
            ));
            
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.5),
                  end: Offset.zero,
                ).animate(animation),
                child: _buildStatCard(stat),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildStatCard(Map<String, dynamic> stat) {
    return GestureDetector(
      onTap: () => HapticFeedback.lightImpact(),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withOpacity(0.1),
              Colors.white.withOpacity(0.05),
            ],
          ),
          border: Border.all(
            color: (stat['color'] as Color).withOpacity(0.2),
          ),
          boxShadow: [
            BoxShadow(
              color: (stat['color'] as Color).withOpacity(0.1),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: (stat['color'] as Color).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    stat['icon'],
                    color: stat['color'],
                    size: 24,
                  ),
                ),
                const Spacer(),
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: stat['color'],
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: (stat['color'] as Color).withOpacity(0.5),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            Text(
              stat['title'],
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            
            const SizedBox(height: 4),
            
            Text(
              stat['value'],
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 4),
            
            Text(
              stat['subtitle'],
              style: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: 12,
              ),
            ),
            
            const Spacer(),
            
            Row(
              children: [
                Icon(
                  Icons.trending_up_rounded,
                  size: 12,
                  color: stat['color'],
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    stat['change'],
                    style: TextStyle(
                      color: stat['color'],
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartsSection() {
    return FadeTransition(
      opacity: _chartsAnimation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.3),
          end: Offset.zero,
        ).animate(_chartsAnimation),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(0.1),
                Colors.white.withOpacity(0.05),
              ],
            ),
            border: Border.all(
              color: Colors.white.withOpacity(0.1),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text(
                    'Revenue Analytics',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  _buildTimeRangeSelector(),
                ],
              ),
              
              const SizedBox(height: 24),
              
              SizedBox(
                height: 300,
                child: _buildRevenueChart(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimeRangeSelector() {
    final options = ['This Week', 'This Month', 'This Year'];
    
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: options.map((option) {
          final isSelected = option == _selectedTimeRange;
          return GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() => _selectedTimeRange = option);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                gradient: isSelected
                    ? const LinearGradient(
                        colors: [Color(0xFF00D4FF), Color(0xFF00FF87)],
                      )
                    : null,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                option,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.white60,
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildRevenueChart() {
    final revenueData = _dashboardData?['revenueGrowth'] ?? <FlSpot>[];
    
    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          drawHorizontalLine: true,
          horizontalInterval: 20000,
          getDrawingHorizontalLine: (value) => FlLine(
            color: Colors.white.withOpacity(0.1),
            strokeWidth: 1,
          ),
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
              getTitlesWidget: (value, meta) {
                const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                              'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
                if (value.toInt() < months.length) {
                  return Text(
                    months[value.toInt()],
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 10,
                    ),
                  );
                }
                return const Text('');
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 20000,
              reservedSize: 50,
              getTitlesWidget: (value, meta) {
                return Text(
                  '\$${(value / 1000).toInt()}k',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 10,
                  ),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        minX: 0,
        maxX: 11,
        minY: 0,
        maxY: 100000,
        lineBarsData: [
          LineChartBarData(
            spots: revenueData,
            isCurved: true,
            gradient: const LinearGradient(
              colors: [
                Color(0xFF00FF87),
                Color(0xFF00D4FF),
              ],
            ),
            barWidth: 4,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 6,
                  color: const Color(0xFF00FF87),
                  strokeWidth: 3,
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
                  const Color(0xFF00FF87).withOpacity(0.2),
                  const Color(0xFF00D4FF).withOpacity(0.1),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopPropertiesSection() {
    final topProperties = _dashboardData?['topProperties'] ?? [];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF8B5CF6), Color(0xFFEC4899)],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.trending_up_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Top Performing Properties',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 20),
        
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: topProperties.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final property = topProperties[index];
            return _buildPropertyCard(property, index);
          },
        ),
      ],
    );
  }

  Widget _buildPropertyCard(Map<String, dynamic> property, int index) {
    final colors = [
      const Color(0xFF00FF87),
      const Color(0xFF00D4FF),
      const Color(0xFF8B5CF6),
      const Color(0xFFFF6B9D),
    ];
    final color = colors[index % colors.length];
    
    return GestureDetector(
      onTap: () => HapticFeedback.lightImpact(),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withOpacity(0.1),
              Colors.white.withOpacity(0.05),
            ],
          ),
          border: Border.all(
            color: color.withOpacity(0.2),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.home_work_rounded,
                    color: color,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    property['name'],
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: color.withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    '#${index + 1}',
                    style: TextStyle(
                      color: color,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Monthly Revenue',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.6),
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '\$${_formatNumber(property['revenue'])}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Rating',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.6),
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            color: Color(0xFFFFD700),
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            property['rating'].toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Occupancy',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.6),
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${(property['occupancy'] * 100).toInt()}%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Occupancy progress bar
            Container(
              height: 4,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(2),
                color: Colors.white.withOpacity(0.1),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: property['occupancy'],
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(2),
                    gradient: LinearGradient(
                      colors: [color, color.withOpacity(0.6)],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivitiesSection() {
    final activities = _dashboardData?['recentActivities'] ?? [];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFFB800), Color(0xFFFF6B9D)],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.history_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Recent Activities',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            TextButton(
              onPressed: () => HapticFeedback.lightImpact(),
              child: const Text(
                'View All',
                style: TextStyle(
                  color: Color(0xFF00D4FF),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 20),
        
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: activities.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final activity = activities[index];
            return _buildActivityCard(activity);
          },
        ),
      ],
    );
  }

  Widget _buildActivityCard(Map<String, dynamic> activity) {
    return GestureDetector(
      onTap: () => HapticFeedback.lightImpact(),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withOpacity(0.08),
              Colors.white.withOpacity(0.04),
            ],
          ),
          border: Border.all(
            color: (activity['color'] as Color).withOpacity(0.2),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: (activity['color'] as Color).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                activity['icon'],
                color: activity['color'],
                size: 20,
              ),
            ),
            
            const SizedBox(width: 16),
            
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    activity['title'],
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    activity['description'],
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    activity['time'],
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.4),
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
            
            if (activity['amount'] != null) ...[
              const SizedBox(width: 12),
              Text(
                '\$${_formatNumber(activity['amount'])}',
                style: TextStyle(
                  color: activity['color'],
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingActionMenu() {
    return Positioned(
      bottom: 30,
      right: 20,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildFloatingActionButton(
            icon: Icons.add_home_work_rounded,
            color: const Color(0xFF00D4FF),
            onPressed: () {
              HapticFeedback.mediumImpact();
              // Navigate to add property
            },
          ),
          const SizedBox(height: 12),
          _buildFloatingActionButton(
            icon: Icons.analytics_rounded,
            color: const Color(0xFF8B5CF6),
            onPressed: () {
              HapticFeedback.mediumImpact();
              // Navigate to analytics
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color,
              color.withOpacity(0.8),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: 28,
        ),
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  String _formatNumber(num number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }
}
