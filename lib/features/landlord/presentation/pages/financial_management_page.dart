import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rent_a_home/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:rent_a_home/core/services/payment_service.dart';
import 'package:rent_a_home/core/services/booking_service.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math' as math;
import 'dart:ui' as ui;

class FinancialManagementPage extends StatefulWidget {
  const FinancialManagementPage({super.key});

  @override
  State<FinancialManagementPage> createState() => _FinancialManagementPageState();
}

class _FinancialManagementPageState extends State<FinancialManagementPage>
    with TickerProviderStateMixin {
  bool _isLoading = true;
  Map<String, dynamic>? _financialSummary;
  List<Map<String, dynamic>> _recentTransactions = [];
  List<Map<String, dynamic>> _monthlyRevenue = [];
  List<Map<String, dynamic>> _monthlyExpenses = [];

  // Animation Controllers
  late AnimationController _backgroundController;
  late AnimationController _glowController;
  late AnimationController _pulseController;
  late AnimationController _slideController;
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late AnimationController _chartAnimationController;

  // Animations
  late Animation<double> _backgroundAnimation;
  late Animation<double> _glowAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _chartAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadFinancialData();
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

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _pulseController,
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
    _pulseController.repeat(reverse: true);
    _slideController.forward();
    _fadeController.forward();
    _scaleController.forward();
    _chartAnimationController.forward();
  }

  Future<void> _loadFinancialData() async {
    setState(() => _isLoading = true);
    try {
      final authState = context.read<AuthBloc>().state;
      if (authState is! Authenticated) {
        throw Exception('User not authenticated');
      }
      final landlordId = authState.user.id;

      final paymentStats = await PaymentService.getPaymentStatistics(landlordId);
      final bookingStats = await BookingService.getBookingStatistics(landlordId);
      final monthlyRevenueData = await PaymentService.getMonthlyRevenue(landlordId, 6);
      final monthlyExpenseData = await PaymentService.getMonthlyExpenses(landlordId, 6);
      final recentTransactionsData = await PaymentService.getRecentTransactions(landlordId, 5);

      setState(() {
        _financialSummary = {
          'totalRevenue': paymentStats['totalRevenue'] ?? 0.0,
          'totalExpenses': paymentStats['totalExpenses'] ?? 0.0,
          'netProfit': (paymentStats['totalRevenue'] ?? 0.0) - (paymentStats['totalExpenses'] ?? 0.0),
          'pendingPayments': bookingStats['pendingBookings'] ?? 0,
          'successfulPayments': paymentStats['successfulPayments'] ?? 0,
          'failedPayments': paymentStats['failedPayments'] ?? 0,
        };
        _monthlyRevenue = monthlyRevenueData;
        _monthlyExpenses = monthlyExpenseData;
        _recentTransactions = recentTransactionsData;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _financialSummary = null;
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          _buildNeonSnackBar('Failed to load financial data: ${e.toString()}', false),
        );
      }
    }
  }

  @override
  void dispose() {
    _backgroundController.dispose();
    _glowController.dispose();
    _pulseController.dispose();
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
                : _financialSummary == null
                    ? _buildErrorState()
                    : RefreshIndicator(
                        onRefresh: _loadFinancialData,
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
                                  _buildRevenueExpenseChart(),
                                  const SizedBox(height: 30),
                                  _buildRecentTransactions(),
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
            // Ultra Professional Financial Loading Animation
            Stack(
              alignment: Alignment.center,
              children: [
                // Outer rotating financial ring
                Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: SweepGradient(
                      colors: [
                        const Color(0xFF00FF80).withOpacity(0.1), // Green for profit
                        const Color(0xFF00FF80), // Bright green
                        const Color(0xFF00D4FF), // Cyan
                        const Color(0xFFFF6B9D), // Pink for expenses
                        const Color(0xFF9B59B6), // Purple
                        const Color(0xFF00FF80).withOpacity(0.1),
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
                // Middle pulsing ring with financial theme
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
                            const Color(0xFF00FF80).withOpacity(_glowAnimation.value * 0.6),
                            const Color(0xFF00D4FF).withOpacity(_glowAnimation.value * 0.4),
                            Colors.transparent,
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF00FF80).withOpacity(_glowAnimation.value * 0.5),
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
                // Central financial icon
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        const Color(0xFF00FF80).withOpacity(0.3),
                        const Color(0xFF00FF80).withOpacity(0.1),
                      ],
                    ),
                  ),
                  child: Icon(
                    Icons.account_balance_wallet_rounded,
                    color: const Color(0xFF00FF80),
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
                        'Loading Financial Data',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: const Color(0xFF00FF80),
                          fontWeight: FontWeight.bold,
                          shadows: [
                            Shadow(
                              color: const Color(0xFF00FF80).withOpacity(_glowAnimation.value * 0.5),
                              blurRadius: 12,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Processing your financial insights...',
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
                // Animated Error Icon with Professional Financial Styling
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
                        Icons.account_balance_wallet_outlined,
                        size: 80,
                        color: const Color(0xFFFF6B9D).withOpacity(0.8),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),
                Text(
                  'Financial Data Unavailable',
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
                  'Unable to load your financial overview. Please check your connection and try again.',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                _buildUltraProfessionalButton(
                  'Retry',
                  Icons.refresh_rounded,
                  const Color(0xFFFF6B9D),
                  _loadFinancialData,
                  isPrimary: true,
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
                          'Financial Overview',
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
                          'Manage your property finances',
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

  Widget _buildSummaryCards() {
    final totalRevenue = _financialSummary?['totalRevenue'] ?? 0.0;
    final totalExpenses = _financialSummary?['totalExpenses'] ?? 0.0;
    final netProfit = _financialSummary?['netProfit'] ?? 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Summary',
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
              Icons.arrow_upward,
              const Color(0xFF00FF80),
            ),
            _buildMetricCard(
              'Total Expenses',
              '\$${totalExpenses.toStringAsFixed(2)}',
              Icons.arrow_downward,
              const Color(0xFFFF6B9D),
            ),
            _buildMetricCard(
              'Net Profit',
              '\$${netProfit.toStringAsFixed(2)}',
              Icons.trending_up,
              const Color(0xFF00D4FF),
            ),
            _buildMetricCard(
              'Pending Payments',
              (_financialSummary?['pendingPayments'] ?? 0).toString(),
              Icons.hourglass_empty,
              const Color(0xFF5B73FF),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon, Color color) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
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
          'Monthly Performance',
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
                            return SideTitleWidget(
                              axisSide: meta.axisSide,
                              child: Text(
                                DateFormat('MMM').format(DateTime.parse(_monthlyRevenue[index]['month'])),
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
                        return FlSpot(entry.key.toDouble(), (entry.value['amount'] * _chartAnimation.value));
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
                    LineChartBarData(
                      spots: _monthlyExpenses.asMap().entries.map((entry) {
                        return FlSpot(entry.key.toDouble(), (entry.value['amount'] * _chartAnimation.value));
                      }).toList(),
                      isCurved: true,
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFFFF6B9D),
                          Color(0xFF9B59B6),
                        ],
                      ),
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFFFF6B9D).withOpacity(0.3),
                            const Color(0xFF9B59B6).withOpacity(0.1),
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
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildChartLegend('Revenue', const Color(0xFF00FF80)),
            const SizedBox(width: 20),
            _buildChartLegend('Expenses', const Color(0xFFFF6B9D)),
          ],
        ),
      ],
    );
  }

  double _getMaxYValue() {
    double maxRevenue = _monthlyRevenue.isNotEmpty
        ? _monthlyRevenue.map((e) => e['amount'] as double).reduce(math.max)
        : 0.0;
    double maxExpenses = _monthlyExpenses.isNotEmpty
        ? _monthlyExpenses.map((e) => e['amount'] as double).reduce(math.max)
        : 0.0;
    return (math.max(maxRevenue, maxExpenses) * 1.2).ceilToDouble();
  }

  Widget _buildChartLegend(String title, Color color) {
    return Row(
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

  Widget _buildRecentTransactions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Transactions',
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
        _recentTransactions.isEmpty
            ? _buildEmptyState('No recent transactions.')
            : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _recentTransactions.length,
                itemBuilder: (context, index) {
                  final transaction = _recentTransactions[index];
                  final isCredit = transaction['type'] == 'credit';
                  final icon = isCredit ? Icons.add_circle : Icons.remove_circle;
                  final color = isCredit ? const Color(0xFF00FF80) : const Color(0xFFFF6B9D);
                  final amount = transaction['amount'] ?? 0.0;
                  final description = transaction['description'] ?? 'N/A';
                  final date = transaction['date'] != null
                      ? DateFormat('MMM dd, yyyy').format(transaction['date'].toDate())
                      : 'N/A';

                  return AnimatedBuilder(
                    animation: _scaleAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _scaleAnimation.value,
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
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(
                              color: const Color(0xFF00D4FF).withOpacity(0.3),
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF00D4FF).withOpacity(0.1),
                                blurRadius: 15,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: color.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  icon,
                                  color: color,
                                  size: 28,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      description,
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
                                      date,
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.7),
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                '${isCredit ? '+' : '-'}\$${amount.toStringAsFixed(2)}',
                                style: TextStyle(
                                  color: color,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
      ],
    );
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

  // Ultra Professional Button with Advanced Financial Styling
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


