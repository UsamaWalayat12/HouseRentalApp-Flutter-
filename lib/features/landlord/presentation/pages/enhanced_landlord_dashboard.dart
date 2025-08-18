import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'dart:ui';
import 'dart:math' as math;
import '../widgets/advanced_ui_components.dart';
import '../widgets/landlord_design_system.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../../core/services/analytics_service.dart';
import '../../../../core/services/booking_service.dart';
import '../../../../core/services/payment_service.dart';

class EnhancedLandlordDashboard extends StatefulWidget {
  const EnhancedLandlordDashboard({super.key});

  @override
  State<EnhancedLandlordDashboard> createState() => _EnhancedLandlordDashboardState();
}

class _EnhancedLandlordDashboardState extends State<EnhancedLandlordDashboard>
    with TickerProviderStateMixin {
  Map<String, dynamic>? _dashboardData;
  bool _isLoading = true;
  
  late AnimationController _heroAnimationController;
  late AnimationController _metricsAnimationController;
  late AnimationController _chartAnimationController;
  late AnimationController _floatingAnimationController;
  
  late Animation<double> _heroAnimation;
  late Animation<double> _metricsAnimation;
  late Animation<double> _chartAnimation;
  late Animation<double> _floatingAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadDashboardData();
  }

  void _initializeAnimations() {
    _heroAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _metricsAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _chartAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _floatingAnimationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _heroAnimation = CurvedAnimation(
      parent: _heroAnimationController,
      curve: Curves.easeOutQuart,
    );
    
    _metricsAnimation = CurvedAnimation(
      parent: _metricsAnimationController,
      curve: Curves.easeOutCubic,
    );
    
    _chartAnimation = CurvedAnimation(
      parent: _chartAnimationController,
      curve: Curves.easeOutExpo,
    );
    
    _floatingAnimation = CurvedAnimation(
      parent: _floatingAnimationController,
      curve: Curves.easeInOut,
    );

    // Start floating animation loop
    _floatingAnimationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _heroAnimationController.dispose();
    _metricsAnimationController.dispose();
    _chartAnimationController.dispose();
    _floatingAnimationController.dispose();
    super.dispose();
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

      // Simulate API calls with actual service calls
      final analytics = await AnalyticsService.getLandlordAnalytics(landlordId);
      final bookingStats = await BookingService.getBookingStatistics(landlordId);
      final paymentStats = await PaymentService.getPaymentStatistics(landlordId);

      if (mounted) {
        setState(() {
          _dashboardData = {
            'totalProperties': analytics['propertiesCount'] ?? 12,
            'activeBookings': bookingStats['confirmedBookings'] ?? 8,
            'totalRevenue': paymentStats['totalRevenue'] ?? 15750.0,
            'pendingBookings': bookingStats['pendingBookings'] ?? 3,
            'occupancyRate': 0.85,
            'averageRating': 4.7,
            'monthlyGrowth': 0.15,
            'recentActivities': analytics['recentActivities'] ?? _generateSampleActivities(),
            'revenueData': _generateRevenueData(),
            'occupancyData': _generateOccupancyData(bookingStats),
            'propertyPerformance': _generatePropertyPerformance(),
          };
          _isLoading = false;
        });

        // Start animations sequentially
        _heroAnimationController.forward().then((_) {
          _metricsAnimationController.forward().then((_) {
            _chartAnimationController.forward();
          });
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _dashboardData = null;
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load dashboard: ${e.toString()}'),
            backgroundColor: const Color(0xFFFF6B9D),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
        );
      }
    }
  }

  List<Map<String, dynamic>> _generateSampleActivities() {
    return [
      {
        'type': 'booking',
        'description': 'New booking for Luxury Apartment',
        'timestamp': DateTime.now().subtract(const Duration(hours: 2)).toIso8601String(),
        'amount': 1200,
      },
      {
        'type': 'payment',
        'description': 'Payment received from John Doe',
        'timestamp': DateTime.now().subtract(const Duration(hours: 5)).toIso8601String(),
        'amount': 2500,
      },
      {
        'type': 'property_update',
        'description': 'Property photos updated',
        'timestamp': DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
      },
      {
        'type': 'review',
        'description': 'New 5-star review received',
        'timestamp': DateTime.now().subtract(const Duration(days: 2)).toIso8601String(),
        'rating': 5,
      },
    ];
  }

  List<FlSpot> _generateRevenueData() {
    return [
      const FlSpot(0, 3200),
      const FlSpot(1, 3800),
      const FlSpot(2, 3100),
      const FlSpot(3, 4500),
      const FlSpot(4, 5200),
      const FlSpot(5, 4800),
      const FlSpot(6, 5800),
    ];
  }

  List<Map<String, dynamic>> _generateOccupancyData(Map<String, dynamic> bookingStats) {
    final confirmed = bookingStats['confirmedBookings'] ?? 8;
    final pending = bookingStats['pendingBookings'] ?? 3;
    
    return [
      {'status': 'Occupied', 'value': confirmed, 'color': const Color(0xFF00FF80)},
      {'status': 'Pending', 'value': pending, 'color': const Color(0xFF5B73FF)},
      {'status': 'Maintenance', 'value': 1, 'color': const Color(0xFFFF6B9D)},
      {'status': 'Available', 'value': 3, 'color': Colors.white.withOpacity(0.3)},
    ];
  }

  List<Map<String, dynamic>> _generatePropertyPerformance() {
    return [
      {'name': 'Luxury Apartment A', 'occupancy': 0.95, 'revenue': 4200, 'rating': 4.9},
      {'name': 'Modern Studio B', 'occupancy': 0.87, 'revenue': 2800, 'rating': 4.6},
      {'name': 'Penthouse Suite', 'occupancy': 0.92, 'revenue': 6500, 'rating': 4.8},
      {'name': 'Garden Villa', 'occupancy': 0.78, 'revenue': 3900, 'rating': 4.5},
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E27),
      body: _isLoading
          ? _buildUltraLoadingState()
          : _dashboardData == null
              ? _buildErrorState()
              : _buildDashboardContent(),
      floatingActionButton: _buildFloatingActionMenu(),
    );
  }

  Widget _buildUltraLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              // Outer pulsing ring
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.8, end: 1.2),
                duration: const Duration(seconds: 2),
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: value,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFF00D4FF).withOpacity(0.3),
                          width: 2,
                        ),
                      ),
                    ),
                  );
                },
              ),
              // Inner rotating gradient
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: 2 * math.pi),
                duration: const Duration(seconds: 3),
                builder: (context, value, child) {
                  return Transform.rotate(
                    angle: value,
                    child: Container(
                      width: 80,
                      height: 80,
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
              // Center pulse
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF00D4FF),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF00D4FF).withOpacity(0.5),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.dashboard,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [Color(0xFF00D4FF), Color(0xFF5B73FF)],
            ).createShader(bounds),
            child: const Text(
              'Loading Dashboard...',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: AdvancedUIComponents.glassmorphismCard(
        primaryColor: const Color(0xFFFF6B9D),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 64,
              color: const Color(0xFFFF6B9D),
            ),
            const SizedBox(height: 20),
            const Text(
              'Unable to Load Dashboard',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Please check your connection and try again',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            AdvancedUIComponents.premiumActionButton(
              text: 'Retry',
              icon: Icons.refresh_rounded,
              onPressed: _loadDashboardData,
              primaryColor: const Color(0xFFFF6B9D),
              width: 120,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardContent() {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: _buildHeroSection(),
        ),
        SliverPadding(
          padding: const EdgeInsets.all(20),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              _buildMetricsSection(),
              const SizedBox(height: 30),
              _buildChartsSection(),
              const SizedBox(height: 30),
              _buildPropertyPerformanceSection(),
              const SizedBox(height: 30),
              _buildRecentActivitiesSection(),
              const SizedBox(height: 100), // Space for floating action button
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildHeroSection() {
    final now = DateTime.now();
    final timeOfDay = now.hour < 12 ? 'Morning' : now.hour < 17 ? 'Afternoon' : 'Evening';
    final totalRevenue = _dashboardData?['totalRevenue'] ?? 0.0;
    final monthlyGrowth = _dashboardData?['monthlyGrowth'] ?? 0.0;
    
    return FadeTransition(
      opacity: _heroAnimation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.5),
          end: Offset.zero,
        ).animate(_heroAnimation),
        child: Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.topCenter,
              radius: 2.0,
              colors: [
                const Color(0xFF00D4FF).withOpacity(0.3),
                const Color(0xFF0A0E27).withOpacity(0.8),
                const Color(0xFF000000),
              ],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header greeting
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ShaderMask(
                              shaderCallback: (bounds) => const LinearGradient(
                                colors: [Color(0xFF00D4FF), Color(0xFF5B73FF)],
                              ).createShader(bounds),
                              child: Text(
                                'Good $timeOfDay,',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Landlord Dashboard',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ],
                        ),
                      ),
                      AnimatedBuilder(
                        animation: _floatingAnimation,
                        builder: (context, child) {
                          return Transform.translate(
                            offset: Offset(0, -10 * _floatingAnimation.value),
                            child: Container(
                              padding: const EdgeInsets.all(12),
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
                                    spreadRadius: 5,
                                  ),
                                ],
                              ),
                              child: Icon(
                                timeOfDay == 'Morning' 
                                  ? Icons.wb_sunny_rounded 
                                  : timeOfDay == 'Afternoon' 
                                    ? Icons.wb_sunny_outlined 
                                    : Icons.nightlight_round,
                                color: const Color(0xFF00D4FF),
                                size: 24,
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  
                  // Revenue highlight card (GlassCard)
                  const SizedBox(height: 8),
                  GlassCard(
                    accent: const Color(0xFF00FF80),
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
                                    const Color(0xFF00FF80).withOpacity(0.3),
                                    const Color(0xFF00FF80).withOpacity(0.1),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.trending_up_rounded,
                                color: Color(0xFF00FF80),
                                size: 24,
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: const Color(0xFF00FF80).withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: const Color(0xFF00FF80).withOpacity(0.3),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.arrow_upward,
                                    size: 12,
                                    color: Color(0xFF00FF80),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '+${(monthlyGrowth * 100).toInt()}%',
                                    style: const TextStyle(
                                      color: Color(0xFF00FF80),
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Total Revenue',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            '\$${NumberFormat('#,##0.00').format(totalRevenue)}',
                            style: const TextStyle(
                              color: Color(0xFF00FF80),
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              shadows: [
                                Shadow(
                                  color: Color(0xFF00FF80),
                                  blurRadius: 10,
                                ),
                              ],
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'This month',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.6),
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
        ),
      ),
    );
  }

  Widget _buildMetricsSection() {
    final totalProperties = _dashboardData?['totalProperties'] ?? 0;
    final activeBookings = _dashboardData?['activeBookings'] ?? 0;
    final occupancyRate = _dashboardData?['occupancyRate'] ?? 0.0;
    final averageRating = _dashboardData?['averageRating'] ?? 0.0;

    return FadeTransition(
      opacity: _metricsAnimation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.3),
          end: Offset.zero,
        ).animate(_metricsAnimation),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionHeader(icon: Icons.dashboard_customize, title: 'Key Metrics'),
            const SizedBox(height: 16),
            ResponsiveGrid(
              children: [
                _metricCard(
                  color: LandlordTokens.primary,
                  icon: Icons.home_work_rounded,
                  title: 'Properties',
                  value: totalProperties.toString(),
                  subtitle: 'Total managed',
                  change: '+2',
                  positive: true,
                ),
                _metricCard(
                  color: LandlordTokens.secondary,
                  icon: Icons.event_available_rounded,
                  title: 'Active Bookings',
                  value: activeBookings.toString(),
                  subtitle: 'This month',
                  change: '+12%',
                  positive: true,
                ),
                _metricCard(
                  color: LandlordTokens.success,
                  icon: Icons.pie_chart_rounded,
                  title: 'Occupancy Rate',
                  value: '${(occupancyRate * 100).toInt()}%',
                  subtitle: 'Current rate',
                  change: '+5%',
                  positive: true,
                ),
                _metricCard(
                  color: const Color(0xFFFFD700),
                  icon: Icons.star_rounded,
                  title: 'Avg. Rating',
                  value: averageRating.toStringAsFixed(1),
                  subtitle: 'Guest reviews',
                  change: '+0.3',
                  positive: true,
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
      opacity: _chartAnimation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.3),
          end: Offset.zero,
        ).animate(_chartAnimation),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: _buildRevenueChart(),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: _buildOccupancyChart(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRevenueChart() {
    final revenueData = _dashboardData?['revenueData'] ?? <FlSpot>[];
    
    return GlassCard(
      accent: const Color(0xFF00FF80),
      height: 300,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Revenue Trend',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF00FF80).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.trending_up,
                  color: Color(0xFF00FF80),
                  size: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
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
                        final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul'];
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
                      interval: 2000,
                      getTitlesWidget: (double value, TitleMeta meta) {
                        return Text(
                          '\$${(value / 1000).toInt()}k',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.6),
                            fontSize: 10,
                          ),
                        );
                      },
                      reservedSize: 40,
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: 6,
                minY: 0,
                maxY: 7000,
                lineBarsData: [
                  LineChartBarData(
                    spots: revenueData,
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

  Widget _buildOccupancyChart() {
    final occupancyData = _dashboardData?['occupancyData'] ?? [];
    
    return GlassCard(
      accent: const Color(0xFF5B73FF),
      height: 300,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Occupancy',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF5B73FF).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.pie_chart,
                  color: Color(0xFF5B73FF),
                  size: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: occupancyData.isNotEmpty 
              ? PieChart(
                  PieChartData(
                    sections: occupancyData.map<PieChartSectionData>((data) {
                      return PieChartSectionData(
                        color: data['color'],
                        value: data['value'].toDouble(),
                        title: data['value'] > 0 ? '${data['value']}' : '',
                        radius: 60,
                        titleStyle: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      );
                    }).toList(),
                    sectionsSpace: 2,
                    centerSpaceRadius: 30,
                  ),
                )
              : Center(
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
            spacing: 8,
            runSpacing: 4,
            children: occupancyData.map<Widget>((data) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: data['color'],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    data['status'],
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 10,
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildPropertyPerformanceSection() {
    final propertyPerformance = _dashboardData?['propertyPerformance'] ?? [];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(icon: Icons.analytics_outlined, title: 'Property Performance'),
        const SizedBox(height: 20),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: propertyPerformance.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final property = propertyPerformance[index];
            return AdvancedUIComponents.glassmorphismCard(
              primaryColor: const Color(0xFF00D4FF),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          property['name'],
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.star, color: Color(0xFFFFD700), size: 16),
                            const SizedBox(width: 4),
                            Text(
                              '${property['rating']}',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Text(
                              '\$${property['revenue']}',
                              style: const TextStyle(
                                color: Color(0xFF00FF80),
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        AdvancedUIComponents.neonProgressIndicator(
                          progress: property['occupancy'],
                          color: const Color(0xFF00D4FF),
                          label: 'Occupancy',
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        colors: [
                          const Color(0xFF00D4FF).withOpacity(0.3),
                          const Color(0xFF00D4FF).withOpacity(0.1),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.home_work,
                      color: Color(0xFF00D4FF),
                      size: 24,
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

  Widget _buildRecentActivitiesSection() {
    final recentActivities = _dashboardData?['recentActivities'] ?? [];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          icon: Icons.history,
          title: 'Recent Activities',
          trailing: TextButton(
            onPressed: () {},
            child: const Text('View All', style: TextStyle(color: LandlordTokens.primary, fontWeight: FontWeight.w600)),
          ),
        ),
        const SizedBox(height: 20),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: math.min(recentActivities.length, 5),
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final activity = recentActivities[index];
            final color = _getActivityColor(activity['type']);
            
            return AdvancedUIComponents.glassmorphismCard(
              primaryColor: color,
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
                      _getActivityIcon(activity['type']),
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
                        ),
                        const SizedBox(height: 4),
                        Text(
                          activity['timestamp'] != null
                              ? _formatTime(DateTime.parse(activity['timestamp']))
                              : 'Unknown time',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.6),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (activity['amount'] != null)
                    Text(
                      '\$${activity['amount']}',
                      style: TextStyle(
                        color: color,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
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

  Widget _buildFloatingActionMenu() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedBuilder(
          animation: _floatingAnimation,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, -5 * _floatingAnimation.value),
              child: AdvancedUIComponents.neonFloatingActionButton(
                onPressed: () {
                  // Add property functionality
                },
                icon: Icons.add_home_work,
                color: const Color(0xFF00D4FF),
              ),
            );
          },
        ),
      ],
    );
  }

  Color _getActivityColor(String? type) {
    switch (type) {
      case 'booking':
        return const Color(0xFF00D4FF);
      case 'payment':
        return const Color(0xFF00FF80);
      case 'property_update':
        return const Color(0xFF5B73FF);
      case 'review':
        return const Color(0xFFFFD700);
      default:
        return const Color(0xFF00D4FF);
    }
  }

  IconData _getActivityIcon(String? type) {
    switch (type) {
      case 'booking':
        return Icons.calendar_today;
      case 'payment':
        return Icons.attach_money;
      case 'property_update':
        return Icons.home_work;
      case 'review':
        return Icons.star;
      default:
        return Icons.info_outline;
    }
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
  Widget _metricCard({required Color color, required IconData icon, required String title, required String value, required String subtitle, String? change, bool positive = true}) {
    return GlassCard(
      accent: color,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: RadialGradient(colors: [color.withOpacity(0.3), color.withOpacity(0.1)]),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const Spacer(),
              if (change != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: (positive ? LandlordTokens.success : LandlordTokens.danger).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: (positive ? LandlordTokens.success : LandlordTokens.danger).withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(positive ? Icons.trending_up : Icons.trending_down, size: 14, color: positive ? LandlordTokens.success : LandlordTokens.danger),
                      const SizedBox(width: 4),
                      Text(change, style: TextStyle(color: positive ? LandlordTokens.success : LandlordTokens.danger, fontSize: 12, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(value, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: color, fontSize: 28, fontWeight: FontWeight.bold, shadows: [Shadow(color: color.withOpacity(0.4), blurRadius: 8)])),
          ),
          const SizedBox(height: 6),
          Text(title, style: LandlordTokens.subtitle),
          const SizedBox(height: 4),
          Text(subtitle, style: LandlordTokens.muted(12)),
        ],
      ),
    );
  }
}
