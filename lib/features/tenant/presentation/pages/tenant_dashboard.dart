import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math' as math;
import 'package:rent_a_home/shared/mixins/animations_mixin.dart';
import 'package:rent_a_home/shared/components/page_layout.dart';

class TenantDashboard extends StatefulWidget {
  const TenantDashboard({super.key});

  @override
  State<TenantDashboard> createState() => _TenantDashboardState();
}

class _TenantDashboardState extends State<TenantDashboard>
    with TickerProviderStateMixin, LandlordAnimationsMixin {

  @override
  void initState() {
    super.initState();
    // Start the glow animation after initialization
    WidgetsBinding.instance.addPostFrameCallback((_) {
      glowController.repeat(reverse: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return LandlordPageLayout(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            _buildNeonHeader(),
            const SizedBox(height: 40),
            _buildQuantumFAB(),
            const SizedBox(height: 30),
            _buildOverviewCards(),
            const SizedBox(height: 30),
            _buildOccupancyChart(),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildNeonHeader() {
    return AnimatedBuilder(
      animation: glowAnimation,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF00F5FF).withOpacity(0.15),
                const Color(0xFF7C4DFF).withOpacity(0.15),
                const Color(0xFF1E3A5F).withOpacity(0.2),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFF00F5FF).withOpacity(glowAnimation.value * 0.8),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF00F5FF).withOpacity(glowAnimation.value * 0.6),
                blurRadius: 30,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Explore Properties!',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      color: Colors.black87,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                    Shadow(
                      color: const Color(0xFF00F5FF).withOpacity(0.8),
                      blurRadius: 12,
                      offset: Offset(0, 0),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Find your next home with ease',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 16,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuantumFAB() {
    return ScaleTransition(
      scale: scaleAnimation,
      child: FloatingActionButton(
        onPressed: () {},
backgroundColor: Colors.black,
        elevation: 0,
        child: AnimatedBuilder(
          animation: glowAnimation,
          builder: (context, child) {
            return Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [Color(0xFF00F5FF), Color(0xFF7C4DFF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00F5FF).withOpacity(glowAnimation.value * 0.7),
                    blurRadius: 25,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: const Icon(
                Icons.add,
                color: Colors.white,
                size: 30,
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildOverviewCards() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Overview',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: const Color(0xFF00F5FF),
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(
                color: const Color(0xFF00F5FF).withOpacity(0.5),
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
              '150+',
              Icons.home_work,
              const Color(0xFF00F5FF),
            ),
            _buildMetricCard(
              'Cities Available',
              '50+',
              Icons.location_city,
              const Color(0xFF7C4DFF),
            ),
            _buildMetricCard(
              'User Ratings',
              '4.8',
              Icons.star,
              const Color(0xFF00FF80),
            ),
            _buildMetricCard(
              'Monthly Listings',
              'New',
              Icons.new_releases,
              const Color(0xFFFF6B9D),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon, Color color) {
    return AnimatedBuilder(
      animation: scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: scaleAnimation.value,
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
                  color: color.withOpacity(0.3),
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

  Widget _buildOccupancyChart() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Occupancy Overview',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: const Color(0xFF00F5FF),
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(
                color: const Color(0xFF00F5FF).withOpacity(0.5),
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
                  const Color(0xFF1E3A5F).withOpacity(0.3),
                  const Color(0xFF2A4A6B).withOpacity(0.2),
                  const Color(0xFF0F1B2E).withOpacity(0.4),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFF00F5FF).withOpacity(0.4),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF00F5FF).withOpacity(0.3),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
          child: PieChart(PieChartData(
            sections: [
              PieChartSectionData(
                color: const Color(0xFF00FF80),
                value: 25,
                title: 'Confirmed',
                radius: 80,
                titleStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              PieChartSectionData(
                color: const Color(0xFF7C4DFF),
                value: 20,
                title: 'Pending',
                radius: 80,
                titleStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              PieChartSectionData(
                color: const Color(0xFFFF6B9D),
                value: 10,
                title: 'Cancelled',
                radius: 80,
                titleStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              PieChartSectionData(
                color: Colors.white.withOpacity(0.3),
                value: 45,
                title: 'Available',
                radius: 80,
                titleStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
            sectionsSpace: 2,
            centerSpaceRadius: 40,
          )),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 16,
          runSpacing: 8,
          children: [
            _buildChartLegend('Confirmed', const Color(0xFF00FF80)),
            _buildChartLegend('Pending', const Color(0xFF7C4DFF)),
            _buildChartLegend('Cancelled', const Color(0xFFFF6B9D)),
            _buildChartLegend('Available', Colors.white.withOpacity(0.3)),
          ],
        ),
      ],
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
}
