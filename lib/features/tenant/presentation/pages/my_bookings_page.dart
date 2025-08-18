import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rent_a_home/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:rent_a_home/shared/models/booking_model.dart';
import '../../../../core/theme/app_theme.dart';
import '../widgets/booking_card_widget.dart';
import 'tenant_chat_page.dart';

class MyBookingsPage extends StatefulWidget {
  const MyBookingsPage({super.key});

  @override
  State<MyBookingsPage> createState() => _MyBookingsPageState();
}

class _MyBookingsPageState extends State<MyBookingsPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? _currentUserId;
  bool _isLoading = true;
  List<BookingModel> _bookings = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));
    
    _getCurrentUser();
    _fadeController.forward();
    _slideController.forward();
  }

  void _getCurrentUser() {
    final authState = context.read<AuthBloc>().state;
    if (authState is Authenticated) {
      setState(() {
        _currentUserId = authState.user.id;
      });
      _loadBookings();
    }
  }

  Future<void> _loadBookings() async {
    if (_currentUserId == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final snapshot = await _firestore
          .collection('bookings')
          .where('tenantId', isEqualTo: _currentUserId)
          .get();

      if (mounted) {
        setState(() {
          _bookings = snapshot.docs
              .map((doc) => BookingModel.fromFirestore(doc))
              .toList()
            ..sort((a, b) => (b.bookingDate ?? DateTime.now())
                .compareTo(a.bookingDate ?? DateTime.now()));
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading bookings: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(child: Text('Error loading bookings: $e')),
              ],
            ),
            backgroundColor: Colors.red[600],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: _loadBookings,
        ),
      ),
    );
      }
    }
  }

  List<BookingModel> _filterBookings(List<BookingModel> bookings, int tabIndex) {
    switch (tabIndex) {
      case 0: // Active
        return bookings.where((b) => 
          b.status == BookingStatus.accepted).toList();
      case 1: // Pending
        return bookings.where((b) => 
          b.status == BookingStatus.pending).toList();
      case 2: // Past
        return bookings.where((b) => 
          b.status == BookingStatus.completed || 
          b.status == BookingStatus.cancelled ||
          b.status == BookingStatus.rejected).toList();
      default:
        return [];
    }
  }

  void _navigateToChat(BookingModel booking) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => TenantChatPage(
          landlordId: booking.landlordId,
          landlordName: booking.tenantName,
          bookingId: booking.id ?? '',
          propertyTitle: booking.propertyTitle,
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOut;
          var tween = Tween(begin: begin, end: end).chain(
            CurveTween(curve: curve),
          );
          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E27),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'My Bookings',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            shadows: [
              Shadow(
                color: AppTheme.landlordPrimary.withOpacity(0.5),
                blurRadius: 10,
              ),
            ],
          ),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppTheme.landlordSurface.withOpacity(0.8),
                  AppTheme.landlordSurfaceVariant.withOpacity(0.6),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppTheme.landlordPrimary.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                  color: AppTheme.landlordPrimary,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.landlordSurface.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              indicatorPadding: const EdgeInsets.all(4),
              labelColor: Colors.white,
              unselectedLabelColor: Colors.grey[600],
              labelStyle: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
              unselectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
              tabs: [
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.home, size: 16),
                      const SizedBox(width: 4),
                      const Text('Active'),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.schedule, size: 16),
                      const SizedBox(width: 4),
                      const Text('Pending'),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.history, size: 16),
                      const SizedBox(width: 4),
                      const Text('Past'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: _isLoading
          ? _buildLoadingState()
          : FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildBookingsList(_filterBookings(_bookings, 0), 0),
                    _buildBookingsList(_filterBookings(_bookings, 1), 1),
                    _buildBookingsList(_filterBookings(_bookings, 2), 2),
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
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1A237E)),
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Loading your bookings...',
            style: TextStyle(
              color: const Color(0xFFFFFFFF),
              fontSize: 16,
              fontWeight: FontWeight.w500,
              shadows: [
                Shadow(
                  color: Colors.black.withOpacity(0.5),
                  blurRadius: 2,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingsList(List<BookingModel> bookings, int tabIndex) {
    if (bookings.isEmpty) {
      return _buildEmptyState(tabIndex);
    }

    return RefreshIndicator(
      onRefresh: _loadBookings,
      color: const Color(0xFF1A237E),
      backgroundColor: Colors.white,
      child: ListView.builder(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(16),
        itemCount: bookings.length,
        itemBuilder: (context, index) {
          final booking = bookings[index];
          return AnimatedContainer(
            duration: Duration(milliseconds: 300 + (index * 100)),
            curve: Curves.easeOutBack,
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
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
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () {
                    if (booking.status == BookingStatus.accepted) {
                      _navigateToChat(booking);
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header with status
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                booking.propertyTitle,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            _buildStatusBadge(booking.status),
                          ],
                        ),
                        const SizedBox(height: 16),
                        
                        // Booking details
                        Row(
                          children: [
                            Expanded(
                              child: _buildDetailItem(
                                icon: Icons.calendar_today,
                                label: 'Check-in',
                                value: _formatDate(booking.checkInDate),
                                color: const Color(0xFF00C853),
                              ),
                            ),
                            Expanded(
                              child: _buildDetailItem(
                                icon: Icons.calendar_today_outlined,
                                label: 'Check-out',
                                value: _formatDate(booking.checkOutDate),
                                color: const Color(0xFFFF6F00),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        
                        Row(
                          children: [
                            Expanded(
                              child: _buildDetailItem(
                                icon: Icons.people,
                                label: 'Guests',
                                value: '${booking.guests ?? 1}',
                                color: const Color(0xFF1A237E),
                              ),
                            ),
                            Expanded(
                              child: _buildDetailItem(
                                icon: Icons.attach_money,
                                label: 'Total',
                                value: '\$${booking.totalAmount.toStringAsFixed(0)}',
                                color: const Color(0xFF00C853),
                              ),
                            ),
                          ],
                        ),
                        
                        if (booking.status == BookingStatus.accepted) ...[
                          const SizedBox(height: 16),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  const Color(0xFF1A237E).withOpacity(0.1),
                                  const Color(0xFF1A237E).withOpacity(0.05),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color(0xFF1A237E).withOpacity(0.2),
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.chat_bubble,
                                  color: Color(0xFF1A237E),
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  'Tap to chat with landlord',
                                  style: TextStyle(
                                    color: Color(0xFF1A237E),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const Spacer(),
                                const Icon(
                                  Icons.arrow_forward_ios,
                                  color: Color(0xFF1A237E),
                                  size: 16,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
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

  Widget _buildDetailItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.7),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(BookingStatus status) {
    Color color;
    String text;
    IconData icon;
    
    switch (status) {
      case BookingStatus.pending:
        color = const Color(0xFFFF6F00);
        text = 'Pending';
        icon = Icons.schedule;
        break;
      case BookingStatus.accepted:
        color = const Color(0xFF00C853);
        text = 'Active';
        icon = Icons.check_circle;
        break;
      case BookingStatus.completed:
        color = const Color(0xFF1A237E);
        text = 'Completed';
        icon = Icons.done_all;
        break;
      case BookingStatus.cancelled:
        color = Colors.red[600]!;
        text = 'Cancelled';
        icon = Icons.cancel;
        break;
      case BookingStatus.rejected:
        color = Colors.red[600]!;
        text = 'Rejected';
        icon = Icons.close;
        break;
      case BookingStatus.confirmed:
        color = const Color(0xFF00C853);
        text = 'Confirmed';
        icon = Icons.check_circle;
        break;
      case BookingStatus.checkedIn:
        color = const Color(0xFF00C853);
        text = 'Checked In';
        icon = Icons.login;
        break;
      case BookingStatus.checkedOut:
        color = const Color(0xFF1A237E);
        text = 'Checked Out';
        icon = Icons.logout;
        break;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(int tabIndex) {
    String title;
    String subtitle;
    IconData icon;
    Color color;
    
    switch (tabIndex) {
      case 0:
        title = 'No Active Bookings';
        subtitle = 'Your confirmed bookings will appear here';
        icon = Icons.home_outlined;
        color = const Color(0xFF00C853);
        break;
      case 1:
        title = 'No Pending Bookings';
        subtitle = 'Your booking requests will appear here';
        icon = Icons.schedule;
        color = const Color(0xFFFF6F00);
        break;
      case 2:
        title = 'No Past Bookings';
        subtitle = 'Your booking history will appear here';
        icon = Icons.history;
        color = const Color(0xFF1A237E);
        break;
      default:
        title = 'No Bookings';
        subtitle = 'Your bookings will appear here';
        icon = Icons.book_outlined;
        color = Colors.grey[400]!;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 64,
              color: color,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: const Color(0xFFFFFFFF),
              shadows: [
                Shadow(
                  color: Colors.black.withOpacity(0.5),
                  blurRadius: 2,
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(
              color: const Color(0xFFE0E0E0),
              fontSize: 16,
              shadows: [
                Shadow(
                  color: Colors.black.withOpacity(0.5),
                  blurRadius: 2,
                ),
              ],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return '${date.day}/${date.month}/${date.year}';
  }
}

