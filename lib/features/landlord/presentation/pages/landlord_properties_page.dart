import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../mixins/landlord_animations_mixin.dart';
import '../widgets/landlord_page_layout.dart';
import '../widgets/landlord_design_system.dart';
import '../../../property/presentation/bloc/property_bloc.dart';
import '../../../property/presentation/widgets/property_card.dart';
import '../../../../shared/models/property_model.dart';
import 'add_property_page.dart';
import 'edit_property_page.dart';

class LandlordPropertiesPage extends StatefulWidget {
  const LandlordPropertiesPage({super.key});

  @override
  State<LandlordPropertiesPage> createState() => _LandlordPropertiesPageState();
}

class _LandlordPropertiesPageState extends State<LandlordPropertiesPage>
    with TickerProviderStateMixin, LandlordAnimationsMixin {
  late AnimationController _staggeredListController;
  late Animation<double> _staggeredAnimation;

  @override
void initState() {
    super.initState();
    context.read<PropertyBloc>().add(const LoadProperties());
    initializeLandlordAnimations();
    startLandlordAnimations();
    
    _staggeredListController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _staggeredAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _staggeredListController,
      curve: Curves.easeOutCubic,
    ));
    
    _staggeredListController.forward();
  }

  @override
void dispose() {
    _staggeredListController.dispose();
    disposeLandlordAnimations();
    super.dispose();
  }

  void _loadProperties() {
    context.read<PropertyBloc>().add(const LoadProperties());
  }

  @override
  Widget build(BuildContext context) {
return LandlordPageLayout(
      title: 'My Properties',
      backgroundAnimation: backgroundAnimation,
      fadeAnimation: fadeAnimation,
body: BlocBuilder<PropertyBloc, PropertyState>(
        builder: (context, state) {
          if (state is PropertyLoading) {
            return _buildLoadingState();
          } else if (state is PropertyLoaded) {
            final properties = state.properties;

            if (properties == null || properties.isEmpty) {
              return _buildEmptyState();
            }

            return _buildPropertiesList(properties);
          } else if (state is PropertyError) {
            return _buildErrorState(state.message);
          }

          return const SizedBox.shrink();
        },
),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF00FF80).withOpacity(0.4),
              blurRadius: 25,
              spreadRadius: 3,
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const AddPropertyPage()));
          },
          backgroundColor: Colors.transparent,
          elevation: 0,
          label: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF00FF80),
                  const Color(0xFF00D4FF),
                ],
              ),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.add_home_work,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Add Property',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 4,
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


  Widget _buildLoadingState() {
    return Center(
      child: FadeTransition(
        opacity: fadeAnimation,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Ultra Professional Loading Ring
            Stack(
              alignment: Alignment.center,
              children: [
                // Outer rotating gradient ring
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
                // Inner pulsing core
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        const Color(0xFF00D4FF).withOpacity(0.6),
                        const Color(0xFF00D4FF).withOpacity(0.2),
                        Colors.transparent,
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF00D4FF).withOpacity(0.4),
                        blurRadius: 30,
                        spreadRadius: 10,
                      ),
                    ],
                  ),
                  child: const Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 4,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                ),
                // Central icon
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF00D4FF).withOpacity(0.2),
                  ),
                  child: Icon(
                    Icons.home_work_rounded,
                    color: const Color(0xFF00D4FF),
                    size: 28,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            // Ultra Professional Loading Text
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.5, end: 1.0),
              duration: const Duration(milliseconds: 2000),
              builder: (context, value, child) {
                return Opacity(
                  opacity: value,
                  child: Column(
                    children: [
                      Text(
                        'Loading Properties',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: const Color(0xFF00D4FF),
                          fontWeight: FontWeight.bold,
                          shadows: [
                            Shadow(
                              color: const Color(0xFF00D4FF).withOpacity(0.5),
                              blurRadius: 12,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Preparing your portfolio...',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.white.withOpacity(0.7),
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

  Widget _buildPropertiesList(List<PropertyModel> properties) {
    return RefreshIndicator(
      onRefresh: () async => _loadProperties(),
      color: const Color(0xFF00D4FF),
      child: FadeTransition(
        opacity: fadeAnimation,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: SectionHeader(icon: Icons.home_work, title: 'Your Properties'),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text('${properties.length} items', style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12)),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: properties.length,
                itemBuilder: (context, index) {
                  if (index >= properties.length) return const SizedBox.shrink();
                  final property = properties[index];
                  return AnimatedBuilder(
                    animation: _staggeredListController,
                    builder: (context, child) {
                      final animation = CurvedAnimation(
                        parent: _staggeredListController,
                        curve: Interval(
                          (index * 0.1).clamp(0.0, 1.0),
                          ((index * 0.1) + 0.5).clamp(0.0, 1.0),
                          curve: Curves.easeOutCubic,
                        ),
                      );
                      return FadeTransition(
                        opacity: animation,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0, 0.2),
                            end: Offset.zero,
                          ).animate(animation),
                          child: ScaleTransition(
                            scale: Tween<double>(
                              begin: 0.9,
                              end: 1.0,
                            ).animate(animation),
                            child: _buildPropertyCard(property, index),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

    Widget _buildPropertyCard(PropertyModel property, int index) {
    // Determine premium styling based on property features
    final isPremium = property.price > 2000;
    final accentColor = isPremium ? const Color(0xFF00FF80) : const Color(0xFF00D4FF);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        // Ultra Professional Multi-Layer Gradient
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            accentColor.withOpacity(0.08),
            const Color(0xFF1A1B3A).withOpacity(0.95),
            const Color(0xFF2A2B4A).withOpacity(0.85),
            accentColor.withOpacity(0.05),
          ],
          stops: const [0.0, 0.3, 0.7, 1.0],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: accentColor.withOpacity(0.4),
          width: 2,
        ),
        boxShadow: [
          // Primary glow effect
          BoxShadow(
            color: accentColor.withOpacity(0.2),
            blurRadius: 25,
            spreadRadius: 2,
            offset: const Offset(0, 8),
          ),
          // Secondary depth shadow
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
          // Inner glow simulation
          BoxShadow(
            color: accentColor.withOpacity(0.1),
            blurRadius: 35,
            spreadRadius: -5,
            offset: const Offset(0, 0),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 0.5, sigmaY: 0.5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Property Card with Enhanced Styling
              Stack(
                children: [
                  PropertyCard(property: property),
                  // Premium Badge Overlay
                  if (isPremium)
                    Positioned(
                      top: 16,
                      right: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xFF00FF80),
                              const Color(0xFF00D4FF),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF00FF80).withOpacity(0.4),
                              blurRadius: 12,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.star_rounded,
                              color: Colors.white,
                              size: 14,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'PREMIUM',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
              
              // Ultra Professional Availability Section
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF0A0E27).withOpacity(0.7),
                      const Color(0xFF1A1B3A).withOpacity(0.5),
                    ],
                  ),
                  border: Border(
                    top: BorderSide(
                      color: accentColor.withOpacity(0.2),
                      width: 1.5,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    // Status Icon
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          colors: [
                            (property.isAvailable ? const Color(0xFF00FF80) : const Color(0xFFFF6B9D)).withOpacity(0.3),
                            (property.isAvailable ? const Color(0xFF00FF80) : const Color(0xFFFF6B9D)).withOpacity(0.1),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: (property.isAvailable ? const Color(0xFF00FF80) : const Color(0xFFFF6B9D)).withOpacity(0.4),
                        ),
                      ),
                      child: Icon(
                        property.isAvailable ? Icons.check_circle_outline : Icons.pause_circle_outline,
                        color: property.isAvailable ? const Color(0xFF00FF80) : const Color(0xFFFF6B9D),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Rental Status',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.white.withOpacity(0.6),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            property.isAvailable ? 'Available for Rent' : 'Currently Unavailable',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: property.isAvailable ? const Color(0xFF00FF80) : const Color(0xFFFF6B9D),
                              shadows: [
                                Shadow(
                                  color: (property.isAvailable ? const Color(0xFF00FF80) : const Color(0xFFFF6B9D)).withOpacity(0.3),
                                  blurRadius: 6,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Ultra Professional Toggle Switch
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [
                          BoxShadow(
                            color: accentColor.withOpacity(0.2),
                            blurRadius: 8,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: Transform.scale(
                        scale: 1.1,
                        child: Switch.adaptive(
                          value: property.isAvailable,
                          onChanged: (newValue) {
                            context.read<PropertyBloc>().add(
                                  TogglePropertyAvailability(
                                    propertyId: property.id,
                                    isAvailable: newValue,
                                  ),
                                );
                          },
                          activeColor: const Color(0xFF00FF80),
                          activeTrackColor: const Color(0xFF00FF80).withOpacity(0.3),
                          inactiveThumbColor: Colors.white.withOpacity(0.8),
                          inactiveTrackColor: Colors.white.withOpacity(0.2),
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Ultra Professional Action Buttons
              Container(
                padding: const EdgeInsets.all(24),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildUltraProfessionalActionButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            PageRouteBuilder(
                              pageBuilder: (context, animation, secondaryAnimation) =>
                                  EditPropertyPage(property: property),
                              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                return SlideTransition(
                                  position: Tween<Offset>(
                                    begin: const Offset(1.0, 0.0),
                                    end: Offset.zero,
                                  ).animate(CurvedAnimation(
                                    parent: animation,
                                    curve: Curves.easeOutCubic,
                                  )),
                                  child: FadeTransition(
                                    opacity: animation,
                                    child: child,
                                  ),
                                );
                              },
                            ),
                          );
                        },
                        icon: Icons.edit_outlined,
                        label: 'Edit Property',
                        color: const Color(0xFF5B73FF),
                        isPrimary: true,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildUltraProfessionalActionButton(
                        onPressed: () => _showDeleteDialog(property.id),
                        icon: Icons.delete_outline,
                        label: 'Remove',
                        color: const Color(0xFFFF6B9D),
                        isPrimary: false,
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
  }

  Widget _buildElegantSwitch({
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Transform.scale(
      scale: 0.9,
      child: Switch.adaptive(
        value: value,
        onChanged: onChanged,
        activeColor: const Color(0xFF00D4FF),
        inactiveThumbColor: Colors.white.withOpacity(0.6),
        inactiveTrackColor: Colors.white.withOpacity(0.2),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
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

  Widget _buildEmptyState() {
    return Center(
      child: FadeTransition(
        opacity: fadeAnimation,
        child: SlideTransition(
          position: slideAnimation,
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
                    Icons.home_outlined,
                    size: 64,
                    color: const Color(0xFF00D4FF).withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  'No Properties Yet',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      BoxShadow(
                        color: const Color(0xFF00D4FF).withOpacity(0.5),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  'Add your first property to get started and manage your listings.',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.white.withOpacity(0.8),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                _buildActionButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const AddPropertyPage()));
                  },
                  icon: Icons.add_home_work,
                  label: 'Add New Property',
                  color: const Color(0xFF00FF80),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: FadeTransition(
        opacity: fadeAnimation,
        child: SlideTransition(
          position: slideAnimation,
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
                        const Color(0xFFFF6B9D).withOpacity(0.3),
                        const Color(0xFF9B59B6).withOpacity(0.3),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFF6B9D).withOpacity(0.2),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.error_outline,
                    size: 64,
                    color: const Color(0xFFFF6B9D).withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  'Error Loading Properties',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      BoxShadow(
                        color: const Color(0xFFFF6B9D).withOpacity(0.5),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  message,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.white.withOpacity(0.8),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                _buildActionButton(
                  onPressed: _loadProperties,
                  icon: Icons.refresh,
                  label: 'Retry',
                  color: const Color(0xFF00D4FF),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Ultra Professional Action Button with Advanced Styling
  Widget _buildUltraProfessionalActionButton({
    required VoidCallback onPressed,
    required IconData icon,
    required String label,
    required Color color,
    required bool isPrimary,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          // Primary glow effect
          BoxShadow(
            color: color.withOpacity(isPrimary ? 0.3 : 0.15),
            blurRadius: isPrimary ? 20 : 12,
            spreadRadius: isPrimary ? 2 : 1,
          ),
          // Depth shadow
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
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
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
              mainAxisAlignment: MainAxisAlignment.center,
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
                  label,
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

  void _showDeleteDialog(String propertyId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1A1B3A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(
              color: const Color(0xFFFF6B9D).withOpacity(0.5),
              width: 2,
            ),
          ),
          title: Text(
            'Delete Property',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: const Color(0xFFFF6B9D),
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'Are you sure you want to delete this property? This action cannot be undone.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white.withOpacity(0.8),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF6B9D),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Delete',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: () {
                context.read<PropertyBloc>().add(DeleteProperty(propertyId));
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

}


