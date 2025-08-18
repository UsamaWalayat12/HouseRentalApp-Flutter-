import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:ui';
import 'dart:math' as math;
import '../widgets/advanced_ui_components.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../../core/services/property_service.dart';
import 'add_property_page.dart';

class EnhancedPropertyManagement extends StatefulWidget {
  const EnhancedPropertyManagement({super.key});

  @override
  State<EnhancedPropertyManagement> createState() => _EnhancedPropertyManagementState();
}

class _EnhancedPropertyManagementState extends State<EnhancedPropertyManagement>
    with TickerProviderStateMixin {
  bool _isLoading = true;
  List<Map<String, dynamic>> _properties = [];
  String _selectedFilter = 'All';
  final TextEditingController _searchController = TextEditingController();

  late AnimationController _listAnimationController;
  late AnimationController _filterAnimationController;
  late Animation<double> _listAnimation;
  late Animation<double> _filterAnimation;

  final List<String> _filterOptions = ['All', 'Available', 'Occupied', 'Maintenance', 'Under Review'];
  final List<Color> _filterColors = [
    const Color(0xFF00D4FF),
    const Color(0xFF00FF80),
    const Color(0xFF5B73FF),
    const Color(0xFFFF6B9D),
    const Color(0xFFFFD700),
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadProperties();
  }

  void _initializeAnimations() {
    _listAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _filterAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _listAnimation = CurvedAnimation(
      parent: _listAnimationController,
      curve: Curves.easeOutQuart,
    );

    _filterAnimation = CurvedAnimation(
      parent: _filterAnimationController,
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void dispose() {
    _listAnimationController.dispose();
    _filterAnimationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadProperties() async {
    setState(() => _isLoading = true);

    try {
      final authState = context.read<AuthBloc>().state;
      if (authState is! Authenticated) {
        throw Exception('User not authenticated');
      }

      // Simulate loading with sample data
      await Future.delayed(const Duration(milliseconds: 1500));

      if (mounted) {
        setState(() {
          _properties = _generateSampleProperties();
          _isLoading = false;
        });

        // Start animations
        _filterAnimationController.forward().then((_) {
          _listAnimationController.forward();
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load properties: ${e.toString()}'),
            backgroundColor: const Color(0xFFFF6B9D),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  List<Map<String, dynamic>> _generateSampleProperties() {
    return [
      {
        'id': '1',
        'title': 'Luxury Downtown Apartment',
        'address': '123 Main Street, Downtown',
        'type': 'Apartment',
        'bedrooms': 2,
        'bathrooms': 2,
        'price': 2500.0,
        'status': 'Available',
        'rating': 4.8,
        'reviews': 24,
        'images': ['https://via.placeholder.com/300x200'],
        'occupancyRate': 0.92,
        'lastBooked': '2024-01-15',
        'amenities': ['WiFi', 'Parking', 'Gym', 'Pool'],
        'revenue': 7500.0,
        'expenses': 1200.0,
      },
      {
        'id': '2',
        'title': 'Modern Studio Loft',
        'address': '456 Oak Avenue, Midtown',
        'type': 'Studio',
        'bedrooms': 1,
        'bathrooms': 1,
        'price': 1800.0,
        'status': 'Occupied',
        'rating': 4.6,
        'reviews': 18,
        'images': ['https://via.placeholder.com/300x200'],
        'occupancyRate': 0.95,
        'lastBooked': '2024-01-20',
        'amenities': ['WiFi', 'Laundry', 'Security'],
        'revenue': 5400.0,
        'expenses': 800.0,
      },
      {
        'id': '3',
        'title': 'Spacious Family House',
        'address': '789 Elm Street, Suburbs',
        'type': 'House',
        'bedrooms': 4,
        'bathrooms': 3,
        'price': 3200.0,
        'status': 'Maintenance',
        'rating': 4.9,
        'reviews': 31,
        'images': ['https://via.placeholder.com/300x200'],
        'occupancyRate': 0.88,
        'lastBooked': '2024-01-10',
        'amenities': ['WiFi', 'Parking', 'Garden', 'Garage'],
        'revenue': 9600.0,
        'expenses': 1800.0,
      },
      {
        'id': '4',
        'title': 'Cozy Suburban Condo',
        'address': '321 Pine Road, Westside',
        'type': 'Condo',
        'bedrooms': 3,
        'bathrooms': 2,
        'price': 2200.0,
        'status': 'Under Review',
        'rating': 4.5,
        'reviews': 12,
        'images': ['https://via.placeholder.com/300x200'],
        'occupancyRate': 0.78,
        'lastBooked': '2024-01-05',
        'amenities': ['WiFi', 'Parking', 'Balcony'],
        'revenue': 6600.0,
        'expenses': 1000.0,
      },
    ];
  }

  List<Map<String, dynamic>> get _filteredProperties {
    var filtered = _properties.where((property) {
      final matchesFilter = _selectedFilter == 'All' || property['status'] == _selectedFilter;
      final matchesSearch = _searchController.text.isEmpty ||
          property['title'].toLowerCase().contains(_searchController.text.toLowerCase()) ||
          property['address'].toLowerCase().contains(_searchController.text.toLowerCase());
      return matchesFilter && matchesSearch;
    }).toList();

    return filtered;
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Available':
        return const Color(0xFF00FF80);
      case 'Occupied':
        return const Color(0xFF5B73FF);
      case 'Maintenance':
        return const Color(0xFFFF6B9D);
      case 'Under Review':
        return const Color(0xFFFFD700);
      default:
        return const Color(0xFF00D4FF);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E27),
      body: _isLoading ? _buildLoadingState() : _buildContent(),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: 2 * math.pi),
                duration: const Duration(seconds: 2),
                builder: (context, value, child) {
                  return Transform.rotate(
                    angle: value,
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: SweepGradient(
                          colors: [
                            const Color(0xFF00D4FF).withOpacity(0.1),
                            const Color(0xFF00D4FF),
                            const Color(0xFF5B73FF),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF0A0E27),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF00D4FF).withOpacity(0.3),
                      blurRadius: 20,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.home_work_rounded,
                  color: Color(0xFF00D4FF),
                  size: 30,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [Color(0xFF00D4FF), Color(0xFF5B73FF)],
            ).createShader(bounds),
            child: const Text(
              'Loading Properties...',
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

  Widget _buildContent() {
    return SafeArea(
      child: Column(
        children: [
          _buildHeader(),
          _buildSearchAndFilter(),
          _buildPropertiesGrid(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: RadialGradient(
                colors: [
                  const Color(0xFF00D4FF).withOpacity(0.3),
                  const Color(0xFF00D4FF).withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFF00D4FF).withOpacity(0.3),
              ),
            ),
            child: const Icon(
              Icons.home_work_rounded,
              color: Color(0xFF00D4FF),
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Property Management',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${_properties.length} properties',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          AdvancedUIComponents.animatedBadge(
            badgeText: _properties.where((p) => p['status'] == 'Available').length.toString(),
            badgeColor: const Color(0xFF00FF80),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF00FF80).withOpacity(0.2),
                    const Color(0xFF00FF80).withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.check_circle_outline,
                color: Color(0xFF00FF80),
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilter() {
    return FadeTransition(
      opacity: _filterAnimation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, -0.3),
          end: Offset.zero,
        ).animate(_filterAnimation),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              // Search bar
              AdvancedUIComponents.premiumSearchBar(
                controller: _searchController,
                hintText: 'Search properties...',
                onChanged: (value) => setState(() {}),
                accentColor: const Color(0xFF00D4FF),
              ),
              const SizedBox(height: 16),
              
              // Filter chips
              SizedBox(
                height: 50,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: _filterOptions.length,
                  itemBuilder: (context, index) {
                    final filter = _filterOptions[index];
                    final color = _filterColors[index];
                    final isSelected = _selectedFilter == filter;
                    
                    return Container(
                      margin: const EdgeInsets.only(right: 12),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(25),
                          onTap: () {
                            setState(() {
                              _selectedFilter = filter;
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            decoration: BoxDecoration(
                              gradient: isSelected
                                  ? LinearGradient(colors: [color, color.withOpacity(0.8)])
                                  : null,
                              color: isSelected ? null : Colors.white.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(25),
                              border: Border.all(
                                color: isSelected ? color : Colors.white.withOpacity(0.2),
                                width: 1.5,
                              ),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: color.withOpacity(0.3),
                                        blurRadius: 12,
                                        spreadRadius: 2,
                                      ),
                                    ]
                                  : [],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _getFilterIcon(filter),
                                  size: 16,
                                  color: isSelected ? Colors.white : color,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  filter,
                                  style: TextStyle(
                                    color: isSelected ? Colors.white : color,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getFilterIcon(String filter) {
    switch (filter) {
      case 'All':
        return Icons.grid_view;
      case 'Available':
        return Icons.check_circle;
      case 'Occupied':
        return Icons.people;
      case 'Maintenance':
        return Icons.build;
      case 'Under Review':
        return Icons.rate_review;
      default:
        return Icons.circle;
    }
  }

  Widget _buildPropertiesGrid() {
    final filteredProperties = _filteredProperties;
    
    return Expanded(
      child: FadeTransition(
        opacity: _listAnimation,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.3),
            end: Offset.zero,
          ).animate(_listAnimation),
          child: filteredProperties.isEmpty
              ? _buildEmptyState()
              : GridView.builder(
                  padding: const EdgeInsets.all(20),
                  physics: const BouncingScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 1,
                    childAspectRatio: 1.2,
                    mainAxisSpacing: 20,
                  ),
                  itemCount: filteredProperties.length,
                  itemBuilder: (context, index) {
                    final property = filteredProperties[index];
                    return TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration: Duration(milliseconds: 600 + (index * 100)),
                      curve: Curves.easeOutCubic,
                      builder: (context, value, child) {
                        return Transform.scale(
                          scale: 0.8 + (0.2 * value),
                          child: Opacity(
                            opacity: value,
                            child: _buildPropertyCard(property),
                          ),
                        );
                      },
                    );
                  },
                ),
        ),
      ),
    );
  }

  Widget _buildPropertyCard(Map<String, dynamic> property) {
    final statusColor = _getStatusColor(property['status']);
    final revenue = property['revenue'] as double;
    final expenses = property['expenses'] as double;
    final profit = revenue - expenses;
    final profitMargin = revenue > 0 ? (profit / revenue) : 0.0;
    
    return AdvancedUIComponents.glassmorphismCard(
      primaryColor: statusColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Property header with status
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      property['title'],
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          color: Colors.white.withOpacity(0.6),
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            property['address'],
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.6),
                              fontSize: 12,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: statusColor.withOpacity(0.3),
                  ),
                ),
                child: Text(
                  property['status'],
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Property details row
          Row(
            children: [
              _buildPropertyDetail(
                icon: Icons.bed_outlined,
                value: '${property['bedrooms']}',
                label: 'Bed',
              ),
              const SizedBox(width: 20),
              _buildPropertyDetail(
                icon: Icons.bathtub_outlined,
                value: '${property['bathrooms']}',
                label: 'Bath',
              ),
              const SizedBox(width: 20),
              _buildPropertyDetail(
                icon: Icons.square_foot,
                value: property['type'],
                label: 'Type',
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Performance metrics
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Performance',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    AdvancedUIComponents.neonProgressIndicator(
                      progress: property['occupancyRate'],
                      color: statusColor,
                      height: 6,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '\$${property['price'].toStringAsFixed(0)}',
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'per month',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Rating and revenue
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFD700).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.star_rounded,
                      color: Color(0xFFFFD700),
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${property['rating']} (${property['reviews']})',
                      style: const TextStyle(
                        color: Color(0xFFFFD700),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '\$${profit.toStringAsFixed(0)}',
                    style: TextStyle(
                      color: profit >= 0 ? const Color(0xFF00FF80) : const Color(0xFFFF6B9D),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Profit',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Action buttons
          Row(
            children: [
              Expanded(
                child: AdvancedUIComponents.premiumActionButton(
                  text: 'View Details',
                  icon: Icons.visibility_outlined,
                  onPressed: () {
                    // Navigate to property details
                  },
                  primaryColor: statusColor.withOpacity(0.8),
                  secondaryColor: statusColor,
                  height: 40,
                ),
              ),
              const SizedBox(width: 12),
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.2),
                  ),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      // Show more options
                    },
                    child: const Icon(
                      Icons.more_vert,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPropertyDetail({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          color: Colors.white.withOpacity(0.8),
          size: 20,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.6),
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: AdvancedUIComponents.glassmorphismCard(
        primaryColor: const Color(0xFF5B73FF),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 64,
              color: const Color(0xFF5B73FF),
            ),
            const SizedBox(height: 20),
            const Text(
              'No Properties Found',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Try adjusting your search or filter criteria',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            AdvancedUIComponents.premiumActionButton(
              text: 'Clear Filters',
              icon: Icons.clear_all_rounded,
              onPressed: () {
                setState(() {
                  _selectedFilter = 'All';
                  _searchController.clear();
                });
              },
              primaryColor: const Color(0xFF5B73FF),
              width: 140,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return AdvancedUIComponents.neonFloatingActionButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AddPropertyPage()),
        );
      },
      icon: Icons.add_home_work,
      color: const Color(0xFF00D4FF),
    );
  }
}
