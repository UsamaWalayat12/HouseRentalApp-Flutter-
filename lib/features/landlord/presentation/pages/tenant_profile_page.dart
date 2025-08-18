import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;

import '../../../../core/theme/app_theme.dart';
import '../../../../shared/models/booking_model.dart';
import '../../../../shared/models/user_model.dart';

class TenantProfilePage extends StatefulWidget {
  final BookingModel? booking;
  final String tenantId;

  const TenantProfilePage({
    super.key,
    this.booking,
    required this.tenantId,
  });

  @override
  State<TenantProfilePage> createState() => _TenantProfilePageState();
}

class _TenantProfilePageState extends State<TenantProfilePage>
    with TickerProviderStateMixin {
  UserModel? _tenant;
  List<BookingModel> _bookingHistory = [];
  bool _isLoading = true;

  late AnimationController _headerAnimationController;
  late Animation<double> _headerFadeAnimation;
  late Animation<Offset> _headerSlideAnimation;
  late AnimationController _contentAnimationController;
  late Animation<double> _contentFadeAnimation;
  late Animation<Offset> _contentSlideAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadTenantProfile();
  }

  void _initializeAnimations() {
    _headerAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _headerFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _headerAnimationController, curve: Curves.easeOut),
    );
    _headerSlideAnimation = Tween<Offset>(begin: const Offset(0, -0.5), end: Offset.zero).animate(
      CurvedAnimation(parent: _headerAnimationController, curve: Curves.easeOutCubic),
    );

    _contentAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _contentFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _contentAnimationController, curve: Curves.easeOut),
    );
    _contentSlideAnimation = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
      CurvedAnimation(parent: _contentAnimationController, curve: Curves.easeOutCubic),
    );
  }

  void _startContentAnimations() {
    _contentAnimationController.forward();
  }

  void _loadTenantProfile() async {
    // TODO: Load tenant profile from backend
    await Future.delayed(const Duration(seconds: 1));

    // Mock data
    setState(() {
      _tenant = UserModel(
        id: widget.booking?.tenantId ?? widget.tenantId ?? 'tenant1',
        email: widget.booking?.tenantEmail ?? 'john.doe@example.com',
        firstName: 'John',
        lastName: 'Doe',
        phone: widget.booking?.tenantPhone ?? '+1234567890',
        role: 'tenant',
        verificationStatus: VerificationStatus.verified,
        rating: 4.8,
        reviewCount: 15,
        createdAt: DateTime.now().subtract(const Duration(days: 365)),
        updatedAt: DateTime.now().subtract(const Duration(days: 30)),
        profile: {
          'occupation': 'Software Engineer',
          'company': 'Tech Corp',
          'emergencyContact': {
            'name': 'Jane Doe',
            'phone': '+1987654321',
            'relationship': 'Sister',
          },
          'preferences': {
            'smokingAllowed': false,
            'petsAllowed': false,
            'quietHours': true,
          },
          'documents': {
            'idVerified': true,
            'incomeVerified': true,
            'backgroundCheck': true,
          },
        },
      );

      _bookingHistory = [
        BookingModel(
          id: '1',
          propertyId: 'prop1',
          propertyTitle: 'Modern Apartment',
          tenantId: _tenant!.id,
          tenantName: _tenant!.fullName,
          tenantEmail: _tenant!.email,
          landlordId: 'landlord1',
          checkInDate: DateTime.now().subtract(const Duration(days: 60)),
          checkOutDate: DateTime.now().subtract(const Duration(days: 30)),
          totalAmount: 2400.0,
          status: BookingStatus.completed,
        ),
        BookingModel(
          id: '2',
          propertyId: 'prop2',
          propertyTitle: 'Luxury Condo',
          tenantId: _tenant!.id,
          tenantName: _tenant!.fullName,
          tenantEmail: _tenant!.email,
          landlordId: 'landlord1',
          checkInDate: DateTime.now().subtract(const Duration(days: 150)),
          checkOutDate: DateTime.now().subtract(const Duration(days: 120)),
          totalAmount: 1800.0,
          status: BookingStatus.completed,
        ),
      ];

      _isLoading = false;
      _headerAnimationController.forward();
      _startContentAnimations();
    });
  }

  @override
  void dispose() {
    _headerAnimationController.dispose();
    _contentAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        body: Center(
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
                'Loading Tenant Profile...', 
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: const Color(0xFF00FFFF),
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ],
          ),
        ),
      );
    }

    if (_tenant == null) {
      return Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: const Text('Tenant Profile', style: TextStyle(color: Colors.white)),
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.person_off_outlined,
                size: 80,
                color: const Color(0xFFFF6B9D).withOpacity(0.7),
              ),
              const SizedBox(height: 24),
              Text(
                'Tenant Not Found',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: const Color(0xFFFF6B9D),
                      fontWeight: FontWeight.w500,
                    ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back),
                label: const Text('Go Back'),
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
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(_tenant!.fullName),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.message),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                _buildNeonSnackBar('Opening chat with ${_tenant!.fullName}', true),
              );
            },
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'block':
                  _blockTenant();
                  break;
                case 'report':
                  _reportTenant();
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'block',
                child: ListTile(
                  leading: Icon(Icons.block),
                  title: Text('Block Tenant'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'report',
                child: ListTile(
                  leading: Icon(Icons.report),
                  title: Text('Report Issue'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfileHeader(),
            const SizedBox(height: 24),
            _buildVerificationSection(),
            const SizedBox(height: 24),
            _buildContactSection(),
            const SizedBox(height: 24),
            _buildPreferencesSection(),
            const SizedBox(height: 24),
            _buildBookingHistorySection(),
            const SizedBox(height: 24),
            _buildReviewsSection(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF00D4FF),
            Color(0xFF5B73FF),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00D4FF).withOpacity(0.4),
            blurRadius: 25,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: Colors.white.withOpacity(0.1),
            child: Text(
              _tenant!.initials,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      _tenant!.fullName,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(
                            color: Colors.black.withOpacity(0.5),
                            blurRadius: 5,
                          ),
                        ],
                      ),
                    ),
                    if (_tenant!.isVerified) ...[
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.verified,
                        color: Color(0xFF00FF80),
                        size: 20,
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 8),
                if (_tenant!.rating != null) ...[
                  Row(
                    children: [
                      const Icon(Icons.star, color: Color(0xFFFFD700), size: 20),
                      const SizedBox(width: 4),
                      Text(
                        '${_tenant!.rating!.toStringAsFixed(1)} (${_tenant!.reviewCount} reviews)',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 4),
                Text(
                  'Member since ${_formatDate(_tenant!.createdAt)}',
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

  Widget _buildSection(String title, IconData icon, Widget content) {
    return Container(
      padding: const EdgeInsets.all(20),
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
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFF00D4FF), size: 28),
              const SizedBox(width: 12),
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
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
            ],
          ),
          const Divider(height: 30, color: Colors.white12),
          content,
        ],
      ),
    );
  }

  Widget _buildVerificationSection() {
    final documents = _tenant!.profile?['documents'] as Map<String, dynamic>?;

    return _buildSection(
      'Verification Status',
      Icons.verified_user,
      Column(
        children: [
          _buildVerificationItem(
            'Identity Verified',
            documents?['idVerified'] ?? false,
          ),
          _buildVerificationItem(
            'Income Verified',
            documents?['incomeVerified'] ?? false,
          ),
          _buildVerificationItem(
            'Background Check',
            documents?['backgroundCheck'] ?? false,
          ),
          _buildVerificationItem(
            'Phone Verified',
            _tenant!.phone != null,
          ),
          _buildVerificationItem(
            'Email Verified',
            _tenant!.verificationStatus == VerificationStatus.verified,
          ),
        ],
      ),
    );
  }

  Widget _buildVerificationItem(String title, bool isVerified) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            isVerified ? Icons.check_circle : Icons.cancel,
            color: isVerified ? const Color(0xFF00FF80) : const Color(0xFFFF6B9D),
            size: 24,
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 16,
            ),
          ),
          const Spacer(),
          if (isVerified)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF00FF80).withOpacity(0.2),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF00FF80).withOpacity(0.5)),
              ),
              child: const Text(
                'Verified',
                style: TextStyle(
                  color: Color(0xFF00FF80),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildContactSection() {
    final profile = _tenant!.profile;
    final emergencyContact = profile?['emergencyContact'] as Map<String, dynamic>?;

    return _buildSection(
      'Contact Information',
      Icons.contact_phone,
      Column(
        children: [
          _buildContactItem('Email', _tenant!.email, Icons.email),
          if (_tenant!.phone != null)
            _buildContactItem('Phone', _tenant!.phone!, Icons.phone),
          if (profile?['occupation'] != null)
            _buildContactItem('Occupation', profile!['occupation'], Icons.work),
          if (profile?['company'] != null)
            _buildContactItem('Company', profile!['company'], Icons.business),
          if (emergencyContact != null) ...[
            const Divider(height: 30, color: Colors.white12),
            Text(
              'Emergency Contact',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            _buildContactItem(
              'Name',
              emergencyContact['name'],
              Icons.person,
            ),
            _buildContactItem(
              'Phone',
              emergencyContact['phone'],
              Icons.phone,
            ),
            _buildContactItem(
              'Relationship',
              emergencyContact['relationship'],
              Icons.family_restroom,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildContactItem(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 22, color: const Color(0xFF00D4FF).withOpacity(0.7)),
          const SizedBox(width: 12),
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.white.withOpacity(0.9),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: Colors.white.withOpacity(0.8)),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreferencesSection() {
    final preferences = _tenant!.profile?['preferences'] as Map<String, dynamic>?;

    return _buildSection(
      'Preferences',
      Icons.settings,
      Column(
        children: [
          _buildPreferenceItem(
            'Non-Smoker',
            !(preferences?['smokingAllowed'] ?? true),
            Icons.smoke_free,
          ),
          _buildPreferenceItem(
            'No Pets',
            !(preferences?['petsAllowed'] ?? true),
            Icons.pets,
          ),
          _buildPreferenceItem(
            'Respects Quiet Hours',
            preferences?['quietHours'] ?? false,
            Icons.volume_off,
          ),
        ],
      ),
    );
  }

  Widget _buildPreferenceItem(String title, bool value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            icon,
            size: 24,
            color: value ? const Color(0xFF00FF80) : const Color(0xFFFF6B9D),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 16,
            ),
          ),
          const Spacer(),
          Icon(
            value ? Icons.check : Icons.close,
            color: value ? const Color(0xFF00FF80) : const Color(0xFFFF6B9D),
            size: 20,
          ),
        ],
      ),
    );
  }

  Widget _buildBookingHistorySection() {
    return _buildSection(
      'Booking History',
      Icons.history,
      _bookingHistory.isEmpty
          ? _buildEmptyState('No booking history available.')
          : Column(
              children: _bookingHistory.map((booking) {
                return _buildBookingHistoryCard(booking);
              }).toList(),
            ),
    );
  }

  Widget _buildBookingHistoryCard(BookingModel booking) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: _getBookingStatusColor(booking.status).withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              _getBookingStatusIcon(booking.status),
              color: _getBookingStatusColor(booking.status),
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Property ${booking.propertyId}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '${_formatDate(booking.checkInDate)} - ${_formatDate(booking.checkOutDate)}',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Total: \$${booking.totalAmount.toStringAsFixed(0)}',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: _getBookingStatusColor(booking.status).withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _getBookingStatusColor(booking.status).withOpacity(0.5)),
            ),
            child: Text(
              booking.statusDisplayName,
              style: TextStyle(
                color: _getBookingStatusColor(booking.status),
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewsSection() {
    return _buildSection(
      'Reviews & Ratings',
      Icons.star,
      Column(
        children: [
          // Mock reviews
          _buildReviewItem(
            'Great tenant, very clean and respectful.',
            5,
            'Property Owner',
            DateTime.now().subtract(const Duration(days: 30)),
          ),
          _buildReviewItem(
            'Excellent communication and followed all house rules.',
            5,
            'Property Manager',
            DateTime.now().subtract(const Duration(days: 120)),
          ),
          _buildReviewItem(
            'Left the property in perfect condition.',
            4,
            'Landlord',
            DateTime.now().subtract(const Duration(days: 200)),
          ),
          _buildEmptyState('No reviews yet.', icon: Icons.rate_review_outlined, showButton: false),
        ],
      ),
    );
  }

  Widget _buildReviewItem(String reviewText, int rating, String reviewer, DateTime date) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.person_outline, color: Colors.white.withOpacity(0.7), size: 20),
              const SizedBox(width: 8),
              Text(
                reviewer,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Row(
                children: List.generate(5, (index) {
                  return Icon(
                    index < rating ? Icons.star : Icons.star_border,
                    color: const Color(0xFFFFD700),
                    size: 18,
                  );
                }),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            reviewText,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 15,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.bottomRight,
            child: Text(
              _formatDate(date),
              style: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return DateFormat('MMM dd, yyyy').format(date);
  }

  Color _getBookingStatusColor(BookingStatus status) {
    switch (status) {
      case BookingStatus.pending:
        return const Color(0xFFFF8000); // Warm Orange
      case BookingStatus.confirmed:
        return const Color(0xFF00FF80); // Emerald Green
      case BookingStatus.accepted:
        return const Color(0xFF00D4FF); // Cyan
      case BookingStatus.completed:
        return Colors.grey; // Grey
      case BookingStatus.checkedIn:
        return const Color(0xFFFFD700); // Gold
      case BookingStatus.checkedOut:
        return const Color(0xFF00D4FF); // Cyan
      case BookingStatus.cancelled:
      case BookingStatus.rejected:
        return const Color(0xFFFF6B9D); // Pink
    }
  }

  IconData _getBookingStatusIcon(BookingStatus status) {
    switch (status) {
      case BookingStatus.pending:
        return Icons.hourglass_empty;
      case BookingStatus.confirmed:
        return Icons.check_circle;
      case BookingStatus.accepted:
        return Icons.check_circle;
      case BookingStatus.checkedIn:
        return Icons.login;
      case BookingStatus.checkedOut:
        return Icons.logout;
      case BookingStatus.completed:
        return Icons.done_all;
      case BookingStatus.cancelled:
      case BookingStatus.rejected:
        return Icons.cancel;
    }
  }

  Widget _buildEmptyState(String message, {IconData icon = Icons.info_outline, bool showButton = true}) {
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
            icon,
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
          if (showButton) ...[
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                // Action for empty state, e.g., navigate to add property
                ScaffoldMessenger.of(context).showSnackBar(
                  _buildNeonSnackBar('Action for empty state triggered!', true),
                );
              },
              icon: const Icon(Icons.add_circle_outline),
              label: const Text('Add New Item'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00D4FF).withOpacity(0.2),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(
                    color: const Color(0xFF00D4FF).withOpacity(0.5),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _blockTenant() {
    ScaffoldMessenger.of(context).showSnackBar(
      _buildNeonSnackBar('Tenant blocked!', true),
    );
    // Implement actual logic to block tenant
  }

  void _reportTenant() {
    ScaffoldMessenger.of(context).showSnackBar(
      _buildNeonSnackBar('Issue reported!', true),
    );
    // Implement actual logic to report tenant
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


