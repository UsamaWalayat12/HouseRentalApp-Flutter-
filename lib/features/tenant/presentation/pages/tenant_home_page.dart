import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'dart:ui' as ui;
import 'dart:math' as math;
import '../../../../core/theme/app_theme.dart';
import '../../../property/presentation/bloc/property_bloc.dart';
import '../../../property/presentation/widgets/property_card.dart';
import '../../../property/presentation/pages/property_details_page.dart';
import '../../../../shared/models/property_model.dart';
import '../widgets/search_filters_widget.dart';
import '../widgets/map_view_widget.dart';
import '../widgets/saved_searches_widget.dart';
import 'my_bookings_page.dart';
import 'package:rent_a_home/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:rent_a_home/features/tenant/presentation/pages/tenant_chats_page.dart';
import 'rental_management_page.dart';
import '../../../profile/presentation/pages/profile_page.dart';
import 'package:rent_a_home/shared/mixins/animations_mixin.dart';

class TenantHomePage extends StatefulWidget {
  const TenantHomePage({super.key});

  @override
  State<TenantHomePage> createState() => _TenantHomePageState();
}

class _TenantHomePageState extends State<TenantHomePage>
    with TickerProviderStateMixin, LandlordAnimationsMixin {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const MyBookingsPage(),
    const RentalManagementPage(),
    const TenantChatsPage(),
    const ProfilePage(),
  ];

  final List<NavigationItem> _navigationItems = [
    NavigationItem(
      icon: Icons.book_outlined,
      activeIcon: Icons.book,
      label: 'Bookings',
      color: const Color(0xFF1A237E),
    ),
    NavigationItem(
      icon: Icons.home_outlined,
      activeIcon: Icons.home,
      label: 'Rentals',
      color: const Color(0xFF00C853),
    ),
    NavigationItem(
      icon: Icons.chat_bubble_outline,
      activeIcon: Icons.chat_bubble,
      label: 'Chats',
      color: const Color(0xFFFF6F00),
    ),
    NavigationItem(
      icon: Icons.person_outline,
      activeIcon: Icons.person,
      label: 'Profile',
      color: const Color(0xFF9C27B0),
    ),
  ];


  void _onItemTapped(int index) {
    if (_selectedIndex != index) {
      setState(() {
        _selectedIndex = index;
      });
      
      // Animate the transition
      fadeController.reset();
      scaleController.reset();
      fadeController.forward();
      scaleController.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E27),
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topLeft,
            radius: 1.5,
            colors: [
              Color(0xFF1E3A5F), // Dark blue-teal at the top left
              Color(0xFF2A4A6B), // Medium blue in the middle
              Color(0xFF0F1B2E), // Darker navy blue
              Color(0xFF0A0E27), // Very dark navy at the edges
            ],
            stops: [0.0, 0.3, 0.7, 1.0],
          ),
        ),
        child: FadeTransition(
          opacity: fadeAnimation,
          child: ScaleTransition(
            scale: scaleAnimation,
            child: Stack(
              children: [
                _buildAnimatedBackground(),
                Positioned.fill(
                  child: _pages[_selectedIndex],
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(child: _buildBottomNavigationBar()),
      extendBodyBehindAppBar: true,
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      margin: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(35),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00F5FF).withOpacity(0.3),
            blurRadius: 40,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(35),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 30, sigmaY: 30),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF0A0E27),
              border: Border.all(
                color: const Color(0xFF00F5FF).withOpacity(0.3),
                width: 1,
              ),
              borderRadius: BorderRadius.circular(35),
            ),
            child: BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              backgroundColor: Colors.transparent,
              elevation: 0,
              selectedItemColor: Colors.white,
              unselectedItemColor: Colors.white.withOpacity(0.7),
              selectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                shadows: [
                  Shadow(
                    color: Colors.black54,
                    blurRadius: 2,
                    offset: Offset(0, 1),
                  ),
                ],
              ),
              unselectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 11,
                shadows: [
                  Shadow(
                    color: Colors.black45,
                    blurRadius: 1,
                    offset: Offset(0, 1),
                  ),
                ],
              ),
              currentIndex: _selectedIndex,
              onTap: _onItemTapped,
              items: _navigationItems.map((item) => BottomNavigationBarItem(
                icon: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: _selectedIndex == _navigationItems.indexOf(item) ? [
                      BoxShadow(
                        color: const Color(0xFF00F5FF).withOpacity(0.4),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ] : null,
                  ),
                  child: Icon(item.icon),
                ),
                activeIcon: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF00F5FF).withOpacity(0.6),
                        blurRadius: 12,
                        spreadRadius: 3,
                      ),
                    ],
                  ),
                  child: Icon(item.activeIcon),
                ),
                label: item.label,
              )).toList(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedBackground() {
    return AnimatedBuilder(
      animation: fadeController,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.topLeft,
              radius: 1.5,
              colors: [
                Color.lerp(
                  const Color(0xFF00F5FF).withOpacity(0.05),
                  const Color(0xFF7C4DFF).withOpacity(0.05),
                  math.sin(fadeController.value * 2 * math.pi) * 0.5 + 0.5,
                )!,
                const Color(0xFF1E3A5F).withOpacity(0.3),
                const Color(0xFF0F1B2E).withOpacity(0.5),
              ],
            ),
          ),
        );
      },
    );
  }

class NavigationItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final Color color;

  NavigationItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.color,
  });
}

