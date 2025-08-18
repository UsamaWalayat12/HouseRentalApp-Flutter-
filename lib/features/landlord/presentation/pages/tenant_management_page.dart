import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;
import 'dart:ui' as ui;

import '../../../../core/theme/app_theme.dart';
import '../../../../shared/models/booking_model.dart';
import '../../../../shared/models/user_model.dart';
import 'tenant_profile_page.dart';
import 'chat_page.dart';

class TenantManagementPage extends StatefulWidget {
  const TenantManagementPage({super.key});

  @override
  State<TenantManagementPage> createState() => _TenantManagementPageState();
}

class _TenantManagementPageState extends State<TenantManagementPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  
  // Ultra Professional Animation Controllers
  late AnimationController _backgroundController;
  late AnimationController _glowController;
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _scaleController;
  late AnimationController _cardAnimationController;
  
  // Ultra Professional Animations
  late Animation<double> _backgroundAnimation;
  late Animation<double> _glowAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _cardAnimation;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _initializeAnimations();
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

    _cardAnimationController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    _cardAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _cardAnimationController,
      curve: Curves.easeOutQuad,
    ));
  }

  void _startAnimations() {
    _backgroundController.repeat();
    _glowController.repeat(reverse: true);
    _slideController.forward();
    _fadeController.forward();
    _scaleController.forward();
    _cardAnimationController.forward();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _backgroundController.dispose();
    _glowController.dispose();
    _slideController.dispose();
    _fadeController.dispose();
    _scaleController.dispose();
    _cardAnimationController.dispose();
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
            child: Column(
              children: [
                _buildNeonHeader(),
                const SizedBox(height: 20),
                _buildUltraProfessionalTabBar(),
                const SizedBox(height: 20),
                Expanded(
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: ScaleTransition(
                      scale: _scaleAnimation,
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          _buildApplicationsTab(),
                          _buildCurrentTenantsTab(),
                          _buildMessagesTab(),
                        ],
                      ),
                    ),
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
          margin: const EdgeInsets.all(20),
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
          child: Row(
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
                      'Tenant Management',
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
                      'Manage applications and tenant relationships',
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
        );
      },
    );
  }

  Widget _buildUltraProfessionalTabBar() {
    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFF1A1B3A).withOpacity(0.8),
                const Color(0xFF2A2B4A).withOpacity(0.6),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFF00D4FF).withOpacity(_glowAnimation.value * 0.5 + 0.2),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF00D4FF).withOpacity(_glowAnimation.value * 0.2),
                blurRadius: 20,
                spreadRadius: 3,
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: TabBar(
            controller: _tabController,
            indicatorSize: TabBarIndicatorSize.tab,
            indicator: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF00D4FF),
                  Color(0xFF5B73FF),
                ],
              ),
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF00D4FF).withOpacity(0.4),
                  blurRadius: 15,
                  spreadRadius: 2,
                ),
              ],
            ),
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white.withOpacity(0.6),
            labelStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
            unselectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.normal,
              fontSize: 12,
            ),
            tabs: [
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.assignment, size: 16),
                    const SizedBox(width: 6),
                    Text('Applications'),
                  ],
                ),
              ),
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.people, size: 16),
                    const SizedBox(width: 6),
                    Text('Tenants'),
                  ],
                ),
              ),
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.message, size: 16),
                    const SizedBox(width: 6),
                    Text('Messages'),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }


  Widget _buildApplicationsTab() {
    final applications = _getMockApplications();

    if (applications.isEmpty) {
      return _buildEmptyState(
        icon: Icons.assignment_outlined,
        title: 'No Applications Yet',
        subtitle: 'New tenant applications will appear here.',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: applications.length,
      itemBuilder: (context, index) {
        final application = applications[index];
        return _buildApplicationCard(application, index);
      },
    );
  }

  Widget _buildApplicationCard(BookingModel application, int index) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutCubic,
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
        borderRadius: BorderRadius.circular(16),
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
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _viewTenantProfile(application.tenantId),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: const Color(0xFF00D4FF).withOpacity(0.2),
                        child: Text(
                          application.tenantName.isNotEmpty ? application.tenantName[0].toUpperCase() : 'T',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: const Color(0xFF00D4FF),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              application.tenantName,
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              application.propertyTitle,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.white.withOpacity(0.7),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: _getStatusColor(application.status).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: _getStatusColor(application.status).withOpacity(0.5)),
                        ),
                        child: Text(
                          application.statusDisplay,
                          style: TextStyle(
                            color: _getStatusColor(application.status),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildInfoRow(Icons.calendar_today, application.dateRange),
                  const SizedBox(height: 8),
                  _buildInfoRow(Icons.attach_money, '\$${application.totalAmount.toStringAsFixed(0)}'),
                  if (application.specialRequests != null && application.specialRequests!.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    _buildSpecialRequests(application.specialRequests!),
                  ],
                  if (application.status == BookingStatus.pending) ...[
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: _buildActionButton(
                            onPressed: () => _viewTenantProfile(application.tenantId),
                            icon: Icons.person,
                            label: 'Profile',
                            color: const Color(0xFF00D4FF),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildActionButton(
                            onPressed: () => _rejectApplication(application.id),
                            icon: Icons.close,
                            label: 'Reject',
                            color: const Color(0xFFFF6B9D),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildActionButton(
                            onPressed: () => _acceptApplication(application.id),
                            icon: Icons.check,
                            label: 'Accept',
                            color: const Color(0xFF00FF80),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.white.withOpacity(0.7)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white.withOpacity(0.9),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildSpecialRequests(String requests) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Special Requests:',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            requests,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.white.withOpacity(0.7),
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentTenantsTab() {
    final tenants = _getMockCurrentTenants();

    if (tenants.isEmpty) {
      return _buildEmptyState(
        icon: Icons.people_outline,
        title: 'No Current Tenants',
        subtitle: 'Active tenants will appear here.',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: tenants.length,
      itemBuilder: (context, index) {
        final tenant = tenants[index];
        return _buildTenantCard(tenant, index);
      },
    );
  }

  Widget _buildTenantCard(UserModel tenant, int index) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutCubic,
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
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF5B73FF).withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF5B73FF).withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _viewTenantProfile(tenant.tenantId),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: const Color(0xFF5B73FF).withOpacity(0.2),
                    child: Text(
                      tenant.tenantName.isNotEmpty ? tenant.tenantName[0].toUpperCase() : 'T',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: const Color(0xFF5B73FF),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tenant.tenantName,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          tenant.propertyTitle,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.white.withOpacity(0.7),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        _buildInfoRow(Icons.calendar_today, tenant.dateRange),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      switch (value) {
                        case 'profile':
                          _viewTenantProfile(tenant.tenantId);
                          break;
                        case 'message':
                          _openChat(tenant.tenantId, tenant.tenantName);
                          break;
                        case 'rate':
                          _rateTenant(tenant.tenantId);
                          break;
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'profile',
                        child: _buildPopupMenuItemContent(Icons.person, 'View Profile'),
                      ),
                      PopupMenuItem(
                        value: 'message',
                        child: _buildPopupMenuItemContent(Icons.message, 'Send Message'),
                      ),
                      PopupMenuItem(
                        value: 'rate',
                        child: _buildPopupMenuItemContent(Icons.star, 'Rate Tenant'),
                      ),
                    ],
                    color: const Color(0xFF1A1B3A),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    icon: Icon(Icons.more_vert, color: Colors.white.withOpacity(0.7)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPopupMenuItemContent(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: Colors.white.withOpacity(0.8)),
        const SizedBox(width: 10),
        Text(text, style: TextStyle(color: Colors.white.withOpacity(0.9))),
      ],
    );
  }

  Widget _buildMessagesTab() {
    final conversations = _getMockConversations();

    if (conversations.isEmpty) {
      return _buildEmptyState(
        icon: Icons.message_outlined,
        title: 'No Messages Yet',
        subtitle: 'Conversations with tenants will appear here.',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: conversations.length,
      itemBuilder: (context, index) {
        final conversation = conversations[index];
        return _buildConversationCard(conversation, index);
      },
    );
  }

  Widget _buildConversationCard(Map<String, dynamic> conversation, int index) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutCubic,
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
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFFF6B9D).withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF6B9D).withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _openChat(
              conversation['tenantId'],
              conversation['tenantName'],
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: const Color(0xFFFF6B9D).withOpacity(0.2),
                        child: Text(
                          (conversation['tenantName'] as String).isNotEmpty ? (conversation['tenantName'] as String)[0].toUpperCase() : 'T',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: const Color(0xFFFF6B9D),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (conversation['unreadCount'] > 0)
                        Positioned(
                          right: 0,
                          top: 0,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: const Color(0xFF00D4FF),
                              shape: BoxShape.circle,
                              border: Border.all(color: const Color(0xFF0A0E27), width: 2),
                            ),
                            child: Text(
                              conversation['unreadCount'].toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          conversation['tenantName'],
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          conversation['propertyTitle'],
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.white.withOpacity(0.7),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          conversation['lastMessage'],
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: Colors.white.withOpacity(0.9)),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    conversation['time'],
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.white.withOpacity(0.6),
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

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF00D4FF).withOpacity(0.3),
                    const Color(0xFF5B73FF).withOpacity(0.3),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00D4FF).withOpacity(0.2),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Icon(
                icon,
                size: 64,
                color: const Color(0xFF00D4FF).withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              title,
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
            const SizedBox(height: 16),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.white.withOpacity(0.8),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(BookingStatus status) {
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

  Widget _buildActionButton({
    required VoidCallback onPressed,
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withOpacity(0.2),
            color.withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 18,
                  color: color,
                ),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                    shadows: [
                      BoxShadow(
                        color: color.withOpacity(0.5),
                        blurRadius: 5,
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

  List<BookingModel> _getMockApplications() {
    return [
      BookingModel(
        id: '1',
        propertyId: 'prop1',
        propertyTitle: 'Modern Downtown Apartment',
        tenantId: 'tenant1',
        tenantName: 'John Smith',
        tenantEmail: 'john@example.com',
        tenantPhone: '+1234567890',
        landlordId: 'landlord1',
        checkInDate: DateTime.now().add(const Duration(days: 7)),
        checkOutDate: DateTime.now().add(const Duration(days: 37)),
        totalAmount: 2400,
        status: BookingStatus.pending,
        specialRequests: 'Need parking space for 2 cars. Pet-friendly accommodation required.',
      ),
      BookingModel(
        id: '2',
        propertyId: 'prop2',
        propertyTitle: 'Cozy Suburban House',
        tenantId: 'tenant2',
        tenantName: 'Sarah Johnson',
        tenantEmail: 'sarah@example.com',
        landlordId: 'landlord1',
        checkInDate: DateTime.now().add(const Duration(days: 14)),
        checkOutDate: DateTime.now().add(const Duration(days: 44)),
        totalAmount: 3200,
        status: BookingStatus.pending,
      ),
      BookingModel(
        id: '3',
        propertyId: 'prop3',
        propertyTitle: 'Spacious Family Home',
        tenantId: 'tenant3',
        tenantName: 'Michael Brown',
        tenantEmail: 'michael@example.com',
        landlordId: 'landlord1',
        checkInDate: DateTime.now().add(const Duration(days: 21)),
        checkOutDate: DateTime.now().add(const Duration(days: 51)),
        totalAmount: 4500,
        status: BookingStatus.confirmed,
      ),
    ];
  }

  List<UserModel> _getMockCurrentTenants() {
    return [
      UserModel(
        id: 'tenant3',
        email: 'michael@example.com',
        firstName: 'Michael',
        lastName: 'Brown',
        role: 'tenant',
      ),
      UserModel(
        id: 'tenant4',
        email: 'emily@example.com',
        firstName: 'Emily',
        lastName: 'Davis',
        role: 'tenant',
      ),
    ];
  }

  List<Map<String, dynamic>> _getMockConversations() {
    return [
      {
        'tenantId': 'tenant1',
        'tenantName': 'John Smith',
        'propertyTitle': 'Modern Downtown Apartment',
        'lastMessage': 'Hi, is the parking space available?',
        'time': '10:30 AM',
        'unreadCount': 2,
      },
      {
        'tenantId': 'tenant3',
        'tenantName': 'Michael Brown',
        'propertyTitle': 'Spacious Family Home',
        'lastMessage': 'Thanks for confirming the booking!',
        'time': 'Yesterday',
        'unreadCount': 0,
      },
      {
        'tenantId': 'tenant4',
        'tenantName': 'Emily Davis',
        'propertyTitle': 'Luxury Penthouse',
        'lastMessage': 'When can I view the property?',
        'time': '2 days ago',
        'unreadCount': 1,
      },
    ];
  }

  void _viewTenantProfile(String tenantId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TenantProfilePage(tenantId: tenantId),
      ),
    );
  }

  void _openChat(String tenantId, String tenantName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatPage(tenantId: tenantId, tenantName: tenantName),
      ),
    );
  }

  void _acceptApplication(String? applicationId) {
    if (applicationId == null) return;
    ScaffoldMessenger.of(context).showSnackBar(
      _buildNeonSnackBar('Application $applicationId accepted!', true),
    );
    // Implement actual logic to accept application
  }

  void _rejectApplication(String? applicationId) {
    if (applicationId == null) return;
    ScaffoldMessenger.of(context).showSnackBar(
      _buildNeonSnackBar('Application $applicationId rejected!', false),
    );
    // Implement actual logic to reject application
  }

  void _rateTenant(String tenantId) {
    ScaffoldMessenger.of(context).showSnackBar(
      _buildNeonSnackBar('Rating tenant $tenantId...', true),
    );
    // Implement actual logic to rate tenant
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


