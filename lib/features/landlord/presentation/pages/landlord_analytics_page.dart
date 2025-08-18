import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:math' as math;
import '../../../../core/services/analytics_service.dart';
import '../../../../core/services/booking_service.dart';
import '../../../../core/services/payment_service.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../../../core/services/data_seeder.dart';

class LandlordAnalyticsPage extends StatefulWidget {
  const LandlordAnalyticsPage({super.key});

  @override
  State<LandlordAnalyticsPage> createState() => _LandlordAnalyticsPageState();
}

class _LandlordAnalyticsPageState extends State<LandlordAnalyticsPage>
    with TickerProviderStateMixin {
  Map<String, dynamic>? _analyticsData;
  bool _isLoading = true;
  String _selectedPeriod = 'month';
  List<Map<String, dynamic>> _monthlyRevenue = [];
  List<Map<String, dynamic>> _recentActivities = [];
  List<Map<String, dynamic>> _topProperties = [];

  // Animation Controllers
  late AnimationController _backgroundController;
  late AnimationController _glowController;
  late AnimationController _slideController;
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late AnimationController _chartAnimationController;

  // Animations
  late Animation<double> _backgroundAnimation;
  late Animation<double> _glowAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _chartAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadAnalyticsData();
    _startAnimations();
  }

  void _initializeAnimations() {
    _backgroundController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    );
    _backgroundAnimation = Tween<double>(
      begin: 0.0,
      end: 2 * math.pi,
    ).animate(_backgroundController);

    _glowController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _glowAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _glowController,
      curve: Curves.easeInOut,
    ));

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    ));

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeOutBack,
    ));

    _chartAnimationController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    _chartAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _chartAnimationController,
      curve: Curves.easeOutQuad,
    ));
  }

  void _startAnimations() {
    _backgroundController.repeat();
    _glowController.repeat(reverse: true);
    _slideController.forward();
    _fadeController.forward();
    _scaleController.forward();
    _chartAnimationController.forward();
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

      // Reload analytics data
      await _loadAnalyticsData();
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

  Future<void> _loadAnalyticsData() async {
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
      final monthlyRevenueData = await PaymentService.getMonthlyRevenue(landlordId, 6);

      setState(() {
        _analyticsData = {
          'totalRevenue': paymentStats['totalRevenue'] ?? 0.0,
          'totalProperties': analytics['propertiesCount'] ?? 0,
          'activeBookings': bookingStats['confirmedBookings'] ?? 0,
          'occupancyRate': ((bookingStats['confirmedBookings'] ?? 0) / (bookingStats['totalBookings'] ?? 1) * 100).toStringAsFixed(1) + '%',
          'pendingBookings': bookingStats['pendingBookings'] ?? 0,
          'completedBookings': bookingStats['completedBookings'] ?? 0,
          'averageBookingValue': bookingStats['averageBookingValue'] ?? 0.0,
          'successRate': paymentStats['successRate'] ?? 0.0,
        };
        _monthlyRevenue = monthlyRevenueData;
        _recentActivities = analytics['recentActivities'] ?? [];
        _topProperties = analytics['topPerformingProperties'] ?? [];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _analyticsData = null;
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          _buildNeonSnackBar('Failed to load analytics: ${e.toString()}', false),
        );
      }
    }
  }

  @override
  void dispose() {
    _backgroundController.dispose();
    _glowController.dispose();
    _slideController.dispose();
    _fadeController.dispose();
    _scaleController.dispose();
    _chartAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E27),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          _buildAnimatedBackground(),
          SafeArea(
            child: _isLoading
                ? _buildLoadingState()
                : _analyticsData == null
                    ? _buildErrorState()
                    : RefreshIndicator(
                        onRefresh: _loadAnalyticsData,
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.all(20),
                          child: SlideTransition(
                            position: _slideAnimation,
                            child: ScaleTransition(
                              scale: _scaleAnimation,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 20),
                                  _buildNeonHeader(),
                                  const SizedBox(height: 40),
                                  _buildSummaryCards(),
                                  const SizedBox(height: 30),
                                  _buildTimePeriodSelector(),
                                  const SizedBox(height: 30),
                                  _buildRevenueExpenseChart(),
                                  const SizedBox(height: 30),
                                  _buildTopPropertiesSection(),
                                  const SizedBox(height: 30),
                                  _buildRecentActivitiesSection(),
                                  const SizedBox(height: 40),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedBackground() {
    return AnimatedBuilder(
      animation: _backgroundAnimation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.topLeft,
              radius: 1.5,
              colors: [
                Color.lerp(
                  const Color(0xFF1A1B3A),
                  const Color(0xFF2A2B4A),
                  math.sin(_backgroundAnimation.value) * 0.5 + 0.5,
                )!,
                const Color(0xFF0A0E27),
                const Color(0xFF000000),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Ultra Professional Analytics Loading Animation
            Stack(
              alignment: Alignment.center,
              children: [
                // Outer rotating analytics ring
                Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: SweepGradient(
                      colors: [
                        const Color(0xFF00D4FF).withOpacity(0.1),
                        const Color(0xFF00D4FF),
                        const Color(0xFF5B73FF),
                        const Color(0xFF9B59B6),
                        const Color(0xFF00FF80),
                        const Color(0xFF00D4FF).withOpacity(0.1),
                      ],
                    ),
                  ),
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: 2 * math.pi),
                    duration: const Duration(seconds: 3),
                    builder: (context, value, child) {
                      return Transform.rotate(
                        angle: value,
                        child: Container(
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                // Middle pulsing ring
                AnimatedBuilder(
                  animation: _glowAnimation,
                  builder: (context, child) {
                    return Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            const Color(0xFF00D4FF).withOpacity(_glowAnimation.value * 0.6),
                            const Color(0xFF5B73FF).withOpacity(_glowAnimation.value * 0.4),
                            Colors.transparent,
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF00D4FF).withOpacity(_glowAnimation.value * 0.5),
                            blurRadius: 25,
                            spreadRadius: 8,
                          ),
                        ],
                      ),
                      child: const Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ),
                    );
                  },
                ),
                // Central analytics icon
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        const Color(0xFF00D4FF).withOpacity(0.3),
                        const Color(0xFF00D4FF).withOpacity(0.1),
                      ],
                    ),
                  ),
                  child: Icon(
                    Icons.analytics_rounded,
                    color: const Color(0xFF00D4FF),
                    size: 28,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            // Ultra Professional Loading Text
            AnimatedBuilder(
              animation: _glowAnimation,
              builder: (context, child) {
                return Opacity(
                  opacity: 0.7 + (_glowAnimation.value * 0.3),
                  child: Column(
                    children: [
                      Text(
                        'Loading Analytics',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: const Color(0xFF00D4FF),
                          fontWeight: FontWeight.bold,
                          shadows: [
                            Shadow(
                              color: const Color(0xFF00D4FF).withOpacity(_glowAnimation.value * 0.5),
                              blurRadius: 12,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Processing your performance data...',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFFFF6B9D).withOpacity(0.15),
                  const Color(0xFF9B59B6).withOpacity(0.15),
                  const Color(0xFF1A1B3A).withOpacity(0.8),
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
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Animated Error Icon with Professional Styling
                AnimatedBuilder(
                  animation: _glowAnimation,
                  builder: (context, child) {
                    return Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            const Color(0xFFFF6B9D).withOpacity(_glowAnimation.value * 0.3),
                            Colors.transparent,
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFF6B9D).withOpacity(_glowAnimation.value * 0.4),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.analytics_outlined,
                        size: 80,
                        color: const Color(0xFFFF6B9D).withOpacity(0.8),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),
                Text(
                  'Analytics Unavailable',
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
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  'Unable to load analytics data. Try refreshing or generate sample data to get started.',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                Column(
                  children: [
                    _buildUltraProfessionalButton(
                      'Retry',
                      Icons.refresh_rounded,
                      const Color(0xFFFF6B9D),
                      _loadAnalyticsData,
                      isPrimary: true,
                    ),
                    const SizedBox(height: 16),
                    _buildUltraProfessionalButton(
                      'Generate Sample Data',
                      Icons.auto_fix_high,
                      const Color(0xFF00D4FF),
                      _generateSampleData,
                      isPrimary: false,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNeonHeader() {
    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
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
              color: const Color(0xFF00D4FF).withOpacity(_glowAnimation.value),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF00D4FF).withOpacity(_glowAnimation.value * 0.5),
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
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF00D4FF), Color(0xFF5B73FF)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF00D4FF).withOpacity(0.5),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Analytics Dashboard',
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
                          'Gain insights into your property performance',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTimePeriodSelector() {
    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF00FFFF).withOpacity(0.25),
                const Color(0xFF8000FF).withOpacity(0.15),
                const Color(0xFF1A1B3A).withOpacity(0.8),
              ],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: const Color(0xFF00FFFF).withOpacity(_glowAnimation.value * 0.8),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF00FFFF).withOpacity(_glowAnimation.value * 0.3),
                blurRadius: 25,
                spreadRadius: 5,
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            children: [
              // Header with animated icon
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        colors: [
                          const Color(0xFF00FFFF).withOpacity(0.3),
                          Colors.transparent,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.date_range_rounded,
                      color: const Color(0xFF00FFFF),
                      size: 24,
                      shadows: [
                        Shadow(
                          color: const Color(0xFF00FFFF).withOpacity(0.5),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Time Period',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          color: const Color(0xFF00FFFF).withOpacity(0.5),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Button Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(child: _buildUltraProfessionalTimeButton('Week', _selectedPeriod == 'week')),
                  const SizedBox(width: 8),
                  Expanded(child: _buildUltraProfessionalTimeButton('Month', _selectedPeriod == 'month')),
                  const SizedBox(width: 8),
                  Expanded(child: _buildUltraProfessionalTimeButton('Quarter', _selectedPeriod == 'quarter')),
                  const SizedBox(width: 8),
                  Expanded(child: _buildUltraProfessionalTimeButton('Year', _selectedPeriod == 'year')),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildUltraProfessionalTimeButton(String text, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPeriod = text.toLowerCase();
          _loadAnalyticsData(); // Reload data based on new period
        });
      },
      child: AnimatedBuilder(
        animation: _glowAnimation,
        builder: (context, child) {
          return Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            decoration: BoxDecoration(
              gradient: isSelected
                  ? LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        const Color(0xFF00FFFF).withOpacity(0.9),
                        const Color(0xFF0080FF).withOpacity(0.8),
                        const Color(0xFF5B73FF).withOpacity(0.7),
                      ],
                    )
                  : LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        const Color(0xFF00FFFF).withOpacity(0.15),
                        const Color(0xFF0080FF).withOpacity(0.10),
                        Colors.transparent,
                      ],
                    ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected
                    ? const Color(0xFF00FFFF).withOpacity(_glowAnimation.value)
                    : const Color(0xFF00FFFF).withOpacity(0.4),
                width: isSelected ? 2 : 1,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: const Color(0xFF00FFFF).withOpacity(_glowAnimation.value * 0.5),
                        blurRadius: 15,
                        spreadRadius: 3,
                      ),
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : [
                      BoxShadow(
                        color: const Color(0xFF00FFFF).withOpacity(0.1),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                    ],
            ),
            child: Center(
              child: Text(
                text,
                style: TextStyle(
                  color: isSelected ? Colors.white : const Color(0xFF00FFFF),
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                  fontSize: 13,
                  shadows: isSelected
                      ? [
                          Shadow(
                            color: Colors.black.withOpacity(0.5),
                            blurRadius: 4,
                          ),
                          Shadow(
                            color: const Color(0xFF00FFFF).withOpacity(0.3),
                            blurRadius: 8,
                          ),
                        ]
                      : [
                          Shadow(
                            color: const Color(0xFF00FFFF).withOpacity(0.3),
                            blurRadius: 6,
                          ),
                        ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummaryCards() {
    final totalRevenue = _analyticsData?['totalRevenue'] ?? 0.0;
    final totalProperties = _analyticsData?['totalProperties'] ?? 0;
    final activeBookings = _analyticsData?['activeBookings'] ?? 0;
    final occupancyRate = _analyticsData?['occupancyRate'] ?? '0%';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Key Metrics',
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
              'Total Revenue',
              '\$${totalRevenue.toStringAsFixed(2)}',
              Icons.attach_money,
              const Color(0xFF00FF80),
            ),
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
              'Occupancy Rate',
              occupancyRate,
              Icons.trending_up,
              const Color(0xFFFF6B9D),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon, Color color) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: AnimatedBuilder(
            animation: _glowAnimation,
            builder: (context, child) {
              return Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      color.withOpacity(0.25),
                      color.withOpacity(0.15),
                      const Color(0xFF1A1B3A).withOpacity(0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: color.withOpacity(_glowAnimation.value * 0.6 + 0.2),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(_glowAnimation.value * 0.3),
                      blurRadius: 25,
                      spreadRadius: 5,
                    ),
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                    // Inner shadow for depth
                    BoxShadow(
                      color: Colors.white.withOpacity(0.05),
                      blurRadius: 10,
                      spreadRadius: -2,
                      offset: const Offset(-2, -2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Enhanced icon with professional styling
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          colors: [
                            color.withOpacity(0.3),
                            Colors.transparent,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: color.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: Icon(
                        icon,
                        color: color,
                        size: 32,
                        shadows: [
                          Shadow(
                            color: color.withOpacity(_glowAnimation.value * 0.5),
                            blurRadius: 12,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Enhanced text section
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                            shadows: [
                              Shadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Professional value display with enhanced styling
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Text(
                            value,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              letterSpacing: -0.5,
                              shadows: [
                                Shadow(
                                  color: color.withOpacity(_glowAnimation.value * 0.8),
                                  blurRadius: 15,
                                ),
                                Shadow(
                                  color: Colors.black.withOpacity(0.5),
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                          ),
                        ),
                        // Progress indicator bar
                        Container(
                          margin: const EdgeInsets.only(top: 8),
                          height: 3,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(2),
                            gradient: LinearGradient(
                              colors: [
                                color.withOpacity(0.8),
                                color.withOpacity(0.4),
                                Colors.transparent,
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: color.withOpacity(_glowAnimation.value * 0.4),
                                blurRadius: 6,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildRevenueExpenseChart() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Monthly Revenue',
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
        AnimatedBuilder(
          animation: _chartAnimation,
          builder: (context, child) {
            return Container(
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
              child: LineChart(
                LineChartData(
                  minX: 0,
                  maxX: (_monthlyRevenue.length - 1).toDouble(),
                  minY: 0,
                  maxY: _getMaxYValue(),
                  titlesData: FlTitlesData(
                    show: true,
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index >= 0 && index < _monthlyRevenue.length) {
                            final monthData = _monthlyRevenue[index]['month'];
                            final dateTime = monthData is DateTime ? monthData : DateTime.now();
                            return SideTitleWidget(
                              axisSide: meta.axisSide,
                              child: Text(
                                DateFormat('MMM').format(dateTime),
                                style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 10),
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
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return SideTitleWidget(
                            axisSide: meta.axisSide,
                            child: Text(
                              '\$${value.toInt()}',
                              style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 10),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: true,
                    horizontalInterval: _getMaxYValue() / 5,
                    verticalInterval: 1,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: Colors.white.withOpacity(0.1),
                        strokeWidth: 1,
                      );
                    },
                    getDrawingVerticalLine: (value) {
                      return FlLine(
                        color: Colors.white.withOpacity(0.1),
                        strokeWidth: 1,
                      );
                    },
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: _monthlyRevenue.asMap().entries.map((entry) {
                        final revenue = (entry.value['revenue'] as double?) ?? 0.0;
                        return FlSpot(entry.key.toDouble(), (revenue * _chartAnimation.value));
                      }).toList(),
                      isCurved: true,
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF00FF80),
                          Color(0xFF00D4FF),
                        ],
                      ),
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFF00FF80).withOpacity(0.3),
                            const Color(0xFF00D4FF).withOpacity(0.1),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  double _getMaxYValue() {
    if (_monthlyRevenue.isEmpty) return 100.0;
    
    double maxRevenue = _monthlyRevenue
        .map((e) => (e['revenue'] as double?) ?? 0.0)
        .reduce(math.max);
    
    // Ensure we have a minimum value for the chart
    if (maxRevenue <= 0) return 100.0;
    
    return (maxRevenue * 1.2).ceilToDouble();
  }

  Widget _buildTopPropertiesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Top Performing Properties',
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
        _topProperties.isEmpty
            ? _buildEmptyState('No top performing properties yet.')
            : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _topProperties.length,
                itemBuilder: (context, index) {
                  final property = _topProperties[index];
                  return FadeTransition(
                    opacity: _fadeAnimation,
                    child: ScaleTransition(
                      scale: _scaleAnimation,
                      child: Container(
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
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                image: DecorationImage(
                                  image: NetworkImage(property['imageUrl'] ?? 'https://via.placeholder.com/150'),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    property['name'] ?? 'N/A',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Revenue: \$${(property['revenue'] ?? 0.0).toStringAsFixed(2)}',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.7),
                                      fontSize: 14,
                                    ),
                                  ),
                                  Text(
                                    'Bookings: ${property['bookings'] ?? 0}',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.7),
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              Icons.star,
                              color: const Color(0xFFFFD700),
                              size: 24,
                            ),
                            Text(
                              '${property['rating'] ?? 'N/A'}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
      ],
    );
  }

  Widget _buildRecentActivitiesSection() {
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
        _recentActivities.isEmpty
            ? _buildEmptyState('No recent activities.')
            : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _recentActivities.length,
                itemBuilder: (context, index) {
                  final activity = _recentActivities[index];
                  return FadeTransition(
                    opacity: _fadeAnimation,
                    child: ScaleTransition(
                      scale: _scaleAnimation,
                      child: Container(
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
                      ),
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

  // Ultra Professional Button with Advanced Styling
  Widget _buildUltraProfessionalButton(
    String text,
    IconData icon,
    Color color,
    VoidCallback onPressed,
    {required bool isPrimary}
  ) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(isPrimary ? 0.3 : 0.15),
            blurRadius: isPrimary ? 20 : 12,
            spreadRadius: isPrimary ? 2 : 1,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onPressed,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isPrimary
                    ? [
                        color.withOpacity(0.8),
                        color.withOpacity(0.6),
                        color.withOpacity(0.4),
                      ]
                    : [
                        color.withOpacity(0.2),
                        color.withOpacity(0.15),
                        color.withOpacity(0.1),
                      ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: color.withOpacity(isPrimary ? 0.6 : 0.4),
                width: isPrimary ? 2 : 1.5,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      colors: [
                        Colors.white.withOpacity(isPrimary ? 0.3 : 0.2),
                        Colors.transparent,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    size: 18,
                    color: isPrimary ? Colors.white : color,
                    shadows: isPrimary
                        ? [
                            Shadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 4,
                            ),
                          ]
                        : [],
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  text,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: isPrimary ? Colors.white : color,
                    fontWeight: FontWeight.bold,
                    shadows: isPrimary
                        ? [
                            Shadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 4,
                            ),
                          ]
                        : [
                            Shadow(
                              color: color.withOpacity(0.3),
                              blurRadius: 6,
                            ),
                          ],
                  ),
                ),
              ],
            ),
          ),
        ),
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
}


