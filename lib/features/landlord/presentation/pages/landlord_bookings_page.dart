import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../widgets/landlord_design_system.dart';
import '../../../../features/auth/presentation/bloc/auth_bloc.dart';
import '../bloc/landlord_booking_bloc.dart';
import '../../../../shared/models/booking_model.dart';
import 'chat_page.dart';
import 'dart:math' as math;

class LandlordBookingsPage extends StatefulWidget {
  const LandlordBookingsPage({super.key});

  @override
  State<LandlordBookingsPage> createState() => _LandlordBookingsPageState();
}

class _LandlordBookingsPageState extends State<LandlordBookingsPage>
    with TickerProviderStateMixin {
  late TabController _tabController;

  // Animation Controllers
  late AnimationController _backgroundController;
  late AnimationController _glowController;
  late AnimationController _slideController;
  late AnimationController _fadeController;
  late AnimationController _scaleController;

  // Animations
  late Animation<double> _backgroundAnimation;
  late Animation<double> _glowAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);

    _initializeAnimations();
    _startAnimations();

    // Fetch initial bookings after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchBookingsForStatus('pending');
    });

    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        final status = _getStatusFromIndex(_tabController.index);
        _fetchBookingsForStatus(status);
      }
    });
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
  }

  void _startAnimations() {
    _backgroundController.repeat();
    _glowController.repeat(reverse: true);
    _slideController.forward();
    _fadeController.forward();
    _scaleController.forward();
  }

  void _fetchBookingsForStatus(String status) {
    final authState = context.read<AuthBloc>().state;
    if (authState is Authenticated) {
      print('Fetching bookings for landlord: ${authState.user.id} with status: $status');
      context.read<LandlordBookingBloc>().add(LoadBookings(authState.user.id, status));
    } else {
      print('User not authenticated');
    }
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
            child: Column(
              children: [
                _buildNeonHeader(),
                _buildAnimatedTabBar(),
                Expanded(
                  child: BlocConsumer<LandlordBookingBloc, LandlordBookingState>(
                    listener: (context, state) {
                      if (state is LandlordBookingError) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          _buildNeonSnackBar(state.message, false),
                        );
                      }
                    },
                    builder: (context, state) {
                      print('Current booking state: $state');
                      return TabBarView(
                        controller: _tabController,
                        children: [
                          _buildBookingView(state, 'pending'),
                          _buildBookingView(state, 'accepted'),
                          _buildBookingView(state, 'completed'),
                          _buildBookingView(state, 'cancelled'),
                        ],
                      );
                    },
                  ),
                ),
              ],
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
                          'Bookings',
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
                          'Manage your property bookings',
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

  Widget _buildAnimatedTabBar() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(15),
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
          child: TabBar(
            controller: _tabController,
            indicatorSize: TabBarIndicatorSize.tab,
            indicator: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF00D4FF), Color(0xFF5B73FF)],
              ),
              borderRadius: BorderRadius.circular(15),
            ),
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white.withOpacity(0.7),
            labelStyle: const TextStyle(fontWeight: FontWeight.bold),
            unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal),
            tabs: const [
              Tab(text: 'Pending'),
              Tab(text: 'Accepted'),
              Tab(text: 'Completed'),
              Tab(text: 'Cancelled'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBookingView(LandlordBookingState state, String statusFilter) {
    if (state is LandlordBookingLoading) {
      return Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Ultra Professional Loading Animation
              Stack(
                alignment: Alignment.center,
                children: [
                  // Outer rotating ring with dynamic colors
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: SweepGradient(
                        colors: [
                          const Color(0xFF00D4FF).withOpacity(0.1),
                          const Color(0xFF00D4FF),
                          const Color(0xFF5B73FF),
                          const Color(0xFF00FF80),
                          const Color(0xFF00D4FF).withOpacity(0.1),
                        ],
                      ),
                    ),
                    child: TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: 2 * math.pi),
                      duration: const Duration(seconds: 2),
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
                  // Inner pulsing core
                  AnimatedBuilder(
                    animation: _glowAnimation,
                    builder: (context, child) {
                      return Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              const Color(0xFF00D4FF).withOpacity(_glowAnimation.value * 0.8),
                              const Color(0xFF00D4FF).withOpacity(_glowAnimation.value * 0.3),
                              Colors.transparent,
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF00D4FF).withOpacity(_glowAnimation.value * 0.6),
                              blurRadius: 30,
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
                  // Central booking icon
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF00D4FF).withOpacity(0.2),
                    ),
                    child: Icon(
                      Icons.calendar_month_rounded,
                      color: const Color(0xFF00D4FF),
                      size: 24,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              // Ultra Professional Loading Text
              AnimatedBuilder(
                animation: _glowAnimation,
                builder: (context, child) {
                  return Opacity(
                    opacity: 0.7 + (_glowAnimation.value * 0.3),
                    child: Column(
                      children: [
                        Text(
                          'Loading Bookings',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: const Color(0xFF00D4FF),
                            fontWeight: FontWeight.bold,
                            shadows: [
                              Shadow(
                                color: const Color(0xFF00D4FF).withOpacity(_glowAnimation.value * 0.5),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Fetching your ${_getStatusFromIndex(_tabController.index)} bookings...',
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

    if (state is LandlordBookingError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: const Color(0xFFFF6B9D).withOpacity(0.7),
            ),
            const SizedBox(height: 16),
            Text(
              'Error: ${state.message}',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: const Color(0xFFFF6B9D),
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                _fetchBookingsForStatus(statusFilter);
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF6B9D).withOpacity(0.2),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(
                    color: const Color(0xFFFF6B9D).withOpacity(0.5),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (state is LandlordBookingLoaded) {
      final filteredBookings = state.bookings.where(
              (booking) => booking.status.toString().split('.').last.toLowerCase() == statusFilter.toLowerCase()
      ).toList();

      if (filteredBookings.isEmpty) {
        return Center(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Ultra Professional Empty State Container
                  Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          const Color(0xFF00D4FF).withOpacity(0.15),
                          const Color(0xFF5B73FF).withOpacity(0.15),
                          const Color(0xFF1A1B3A).withOpacity(0.8),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: const Color(0xFF00D4FF).withOpacity(0.3),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF00D4FF).withOpacity(0.2),
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
                        // Animated Icon with Glow
                        AnimatedBuilder(
                          animation: _glowAnimation,
                          builder: (context, child) {
                            return Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: RadialGradient(
                                  colors: [
                                    const Color(0xFF00D4FF).withOpacity(_glowAnimation.value * 0.3),
                                    Colors.transparent,
                                  ],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF00D4FF).withOpacity(_glowAnimation.value * 0.4),
                                    blurRadius: 20,
                                    spreadRadius: 5,
                                  ),
                                ],
                              ),
                              child: Icon(
                                _getEmptyStateIcon(statusFilter),
                                size: 64,
                                color: const Color(0xFF00D4FF).withOpacity(0.8),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'No ${statusFilter.toUpperCase()} Bookings',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            shadows: [
                              Shadow(
                                color: const Color(0xFF00D4FF).withOpacity(0.5),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _getEmptyStateMessage(statusFilter),
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }

      return _buildBookingsList(filteredBookings);
    }

    return const Center(
      child: Text(
        'Select a tab to view bookings',
        style: TextStyle(color: Colors.white54),
      ),
    );
  }

  Widget _buildBookingsList(List<BookingModel> bookings) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: bookings.length,
      itemBuilder: (context, index) {
        final booking = bookings[index];
        final accent = _getStatusColor(booking.status);
        return FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: GlassCard(
              margin: const EdgeInsets.only(bottom: 15),
              padding: const EdgeInsets.all(16),
              accent: accent,
              radius: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          booking.propertyTitle,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            shadows: [
                              Shadow(
                                color: const Color(0xFF00D4FF).withOpacity(0.5),
                                blurRadius: 5,
                              ),
                            ],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: _getStatusColor(booking.status).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                            color: _getStatusColor(booking.status).withOpacity(0.5),
                          ),
                        ),
                        child: Text(
                          _getStatusText(booking.status),
                          style: TextStyle(
                            color: accent,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _buildInfoRow(Icons.person, booking.tenantName, Colors.white.withOpacity(0.7)),
                  const SizedBox(height: 4),
                  _buildInfoRow(
                    Icons.calendar_today,
                    '${DateFormat('MMM d, yyyy').format(booking.checkInDate)} - ${DateFormat('MMM d, yyyy').format(booking.checkOutDate)}',
                    Colors.white.withOpacity(0.7),
                  ),
                  const SizedBox(height: 8),
                  _buildInfoRow(
                    Icons.attach_money,
                    NumberFormat.simpleCurrency(name: 'USD').format(booking.totalAmount),
                    const Color(0xFF00FF80),
                    isBold: true,
                  ),
                  if (booking.status == BookingStatus.pending) ...[
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildNeonButton(
                            'Reject',
                            () => _showRejectDialog(context, booking.id ?? ''),
                            const Color(0xFFFF6B9D),
                            isOutlined: true,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildNeonButton(
                            'Accept',
                            () => _confirmBooking(booking.id ?? ''),
                            const Color(0xFF00FF80),
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (booking.status == BookingStatus.accepted) ...[
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: _buildNeonButton(
                        'Chat with Tenant',
                        () => _navigateToChat(booking),
                        const Color(0xFF00D4FF),
                        icon: Icons.chat,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(IconData icon, String text, Color color, {bool isBold = false}) {
    return Row(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 14,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildNeonButton(String text, VoidCallback onPressed, Color color, {IconData? icon, bool isOutlined = false}) {
    return GestureDetector(
      onTap: onPressed,
      child: AnimatedBuilder(
        animation: _glowAnimation,
        builder: (context, child) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              gradient: isOutlined
                  ? null
                  : LinearGradient(
                colors: [color.withOpacity(0.8), color.withOpacity(0.6)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              color: isOutlined ? Colors.transparent : null,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: color.withOpacity(_glowAnimation.value),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(_glowAnimation.value * 0.3),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  Icon(icon, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                ],
                Text(
                  text,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _confirmBooking(String bookingId) {
    context.read<LandlordBookingBloc>().add(UpdateBookingStatus(bookingId, 'accepted'));
    ScaffoldMessenger.of(context).showSnackBar(
      _buildNeonSnackBar('Booking accepted successfully!', true),
    );
  }

  void _showRejectDialog(BuildContext context, String bookingId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1B3A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Reject Booking',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: const Color(0xFFFF6B9D),
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Are you sure you want to reject this booking?',
          style: TextStyle(color: Colors.white.withOpacity(0.8)),
        ),
        actions: [
          _buildNeonButton(
            'Cancel',
            () => Navigator.of(context).pop(),
            const Color(0xFF5B73FF),
            isOutlined: true,
          ),
          _buildNeonButton(
            'Reject',
            () {
              context.read<LandlordBookingBloc>().add(UpdateBookingStatus(bookingId, 'rejected'));
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                _buildNeonSnackBar('Booking rejected', false),
              );
            },
            const Color(0xFFFF6B9D),
          ),
        ],
      ),
    );
  }

  void _navigateToChat(BookingModel booking) {
    Navigator.push(
      context,
      MaterialPageRoute(
builder: (context) => ChatPage(
          tenantId: booking.tenantId,
          tenantName: booking.tenantName,
        ),
      ),
    );
  }

  String _getStatusFromIndex(int index) {
    switch (index) {
      case 0:
        return 'pending';
      case 1:
        return 'accepted';
      case 2:
        return 'completed';
      case 3:
        return 'cancelled';
      default:
        return 'pending';
    }
  }

  Color _getStatusColor(BookingStatus status) {
    switch (status) {
      case BookingStatus.pending:
        return const Color(0xFF5B73FF); // Blue
      case BookingStatus.accepted:
        return const Color(0xFF00FF80); // Green
      case BookingStatus.rejected:
        return const Color(0xFFFF6B9D); // Pink
      case BookingStatus.completed:
        return const Color(0xFF00D4FF); // Cyan
      case BookingStatus.cancelled:
        return const Color(0xFF9B59B6); // Purple
      case BookingStatus.confirmed:
        return const Color(0xFF00FF80); // Green (same as accepted)
      case BookingStatus.checkedIn:
        return const Color(0xFFFFD700); // Gold
      case BookingStatus.checkedOut:
        return const Color(0xFF00D4FF); // Cyan (same as completed)
    }
  }

  String _getStatusText(BookingStatus status) {
    return status.toString().split('.').last.toUpperCase();
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

  // Helper methods for Ultra Professional Empty States
  IconData _getEmptyStateIcon(String statusFilter) {
    switch (statusFilter.toLowerCase()) {
      case 'pending':
        return Icons.pending_actions;
      case 'accepted':
        return Icons.check_circle_outline;
      case 'completed':
        return Icons.verified;
      case 'cancelled':
        return Icons.cancel_outlined;
      default:
        return Icons.event_note;
    }
  }

  String _getEmptyStateMessage(String statusFilter) {
    switch (statusFilter.toLowerCase()) {
      case 'pending':
        return 'No pending bookings at this time.\nNew booking requests will appear here.';
      case 'accepted':
        return 'No accepted bookings currently.\nConfirmed bookings will be shown here.';
      case 'completed':
        return 'No completed bookings yet.\nFinished stays will be listed here.';
      case 'cancelled':
        return 'No cancelled bookings found.\nCancelled reservations will appear here.';
      default:
        return 'No bookings available in this category.';
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _backgroundController.dispose();
    _glowController.dispose();
    _slideController.dispose();
    _fadeController.dispose();
    _scaleController.dispose();
    super.dispose();
  }
}


