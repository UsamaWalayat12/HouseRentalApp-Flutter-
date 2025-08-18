import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rent_a_home/features/property/presentation/bloc/property_bloc.dart';
import 'package:rent_a_home/core/services/firebase_service.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';
import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/models/property_model.dart';
import '../../../../core/services/model_service.dart';
import '../../../../core/services/imagebb_service.dart';
import '../../../../core/services/image_service.dart';
import '../mixins/landlord_animations_mixin.dart';
import '../widgets/landlord_page_layout.dart';
import '../widgets/landlord_neon_button.dart';

class EditPropertyPage extends StatefulWidget {
  final PropertyModel property;

  const EditPropertyPage({super.key, required this.property});

  @override
  State<EditPropertyPage> createState() => _EditPropertyPageState();
}

class _EditPropertyPageState extends State<EditPropertyPage>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _priceController;
  late TextEditingController _addressController;
  late TextEditingController _cityController;
  late TextEditingController _stateController;
  late TextEditingController _zipController;
  late TextEditingController _areaController;
  late TextEditingController _virtualTourController;
  late TextEditingController _rulesController;
  late TextEditingController _imageUrlController;

  late String? _selectedPropertyType;
  late String _selectedPricePeriod;
  late int _bedrooms;
  late int _bathrooms;
  late List<String> _selectedAmenities;
  List<XFile> _newSelectedImages = [];
  late List<String> _existingImageUrls;
  List<File> _selectedDocuments = [];
  bool _isLoading = false;

  // Google Maps
  GoogleMapController? _mapController;
  LatLng? _selectedLocation;
  Set<Marker> _markers = {};

  // Image Picker
  final ImagePicker _imagePicker = ImagePicker();

  // Animation Controllers
  late AnimationController _floatingController;
  late AnimationController _glowController;
  late AnimationController _rotationController;
  late AnimationController _pulseController;
  late AnimationController _slideController;
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late AnimationController _morphController;
  late AnimationController _particleController;

  // Animations
  late Animation<double> _floatingAnimation;
  late Animation<double> _glowAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _morphAnimation;
  late Animation<double> _particleAnimation;

  // Add new controllers for 3D animations
  late AnimationController _modelRotationController;
  late AnimationController _modelScaleController;
  late AnimationController _modelFloatController;
  late Animation<double> _modelRotationAnimation;
  late Animation<double> _modelScaleAnimation;
  late Animation<double> _modelFloatAnimation;

  String? _selected3DModel;
  bool _isModelLoading = false;

  Model3D? _selectedPreloadedModel;
  List<Model3D> _availableModels = [];
  String _selectedModelCategory = 'house';

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _initializeAnimations();
    _initialize3DAnimations();
    _loadModels();
    _startAnimations();
    _populateFields();
  }

  void _initializeControllers() {
    _titleController = TextEditingController();
    _descriptionController = TextEditingController();
    _priceController = TextEditingController();
    _addressController = TextEditingController();
    _cityController = TextEditingController();
    _stateController = TextEditingController();
    _zipController = TextEditingController();
    _areaController = TextEditingController();
    _virtualTourController = TextEditingController();
    _rulesController = TextEditingController();
    _imageUrlController = TextEditingController();
  }

  void _populateFields() {
    final property = widget.property;
    _titleController.text = property.title;
    _descriptionController.text = property.description;
    _priceController.text = property.price.toString();
    _addressController.text = property.address;
    _cityController.text = property.city;
    _stateController.text = property.state;
    _zipController.text = property.country; // Using country instead of zipCode
    _areaController.text = property.area?.toString() ?? '0';
    _virtualTourController.text = property.virtualTourUrl ?? '';
    _rulesController.text = property.additionalInfo?['rules'] ?? '';

    _selectedPropertyType = property.type; // Using type instead of propertyType
    _selectedPricePeriod = property.pricePeriod;
    _bedrooms = property.bedrooms;
    _bathrooms = property.bathrooms;
    _selectedAmenities = List.from(property.amenities);
    _existingImageUrls = List.from(property.imageUrls); // Using imageUrls instead of images
    _selectedLocation = LatLng(property.latitude ?? 0.0, property.longitude ?? 0.0);
    _markers.add(Marker(
      markerId: const MarkerId('propertyLocation'),
      position: _selectedLocation!,
    ));
  }

  void _initializeAnimations() {
    // Floating animation for background elements
    _floatingController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );
    _floatingAnimation = Tween<double>(
      begin: -15,
      end: 15,
    ).animate(CurvedAnimation(
      parent: _floatingController,
      curve: Curves.easeInOutSine,
    ));

    // Glow animation for neon effects
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

    // Rotation animation for 3D elements
    _rotationController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    );
    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 2 * math.pi,
    ).animate(CurvedAnimation(
      parent: _rotationController,
      curve: Curves.linear,
    ));

    // Pulse animation for interactive elements
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

    // Slide animation for form entry
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

    // Fade animation
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

    // Scale animation
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

    // Morph animation
    _morphController = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    );
    _morphAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _morphController,
      curve: Curves.easeInOut,
    ));

    // Particle animation
    _particleController = AnimationController(
      duration: const Duration(seconds: 12),
      vsync: this,
    );
    _particleAnimation = Tween<double>(
      begin: 0.0,
      end: 2 * math.pi,
    ).animate(_particleController);
  }

  void _initialize3DAnimations() {
    // Model rotation animation
    _modelRotationController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    );
    _modelRotationAnimation = Tween<double>(
      begin: 0,
      end: 2 * math.pi,
    ).animate(CurvedAnimation(
      parent: _modelRotationController,
      curve: Curves.linear,
    ));

    // Model scale animation
    _modelScaleController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _modelScaleAnimation = Tween<double>(
      begin: 0.95,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _modelScaleController,
      curve: Curves.easeInOut,
    ));

    // Model floating animation
    _modelFloatController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _modelFloatAnimation = Tween<double>(
      begin: -10,
      end: 10,
    ).animate(CurvedAnimation(
      parent: _modelFloatController,
      curve: Curves.easeInOut,
    ));
  }

  void _startAnimations() {
    _floatingController.repeat(reverse: true);
    _glowController.repeat(reverse: true);
    _rotationController.repeat();
    _pulseController.repeat(reverse: true);
    _slideController.forward();
    _fadeController.forward();
    _scaleController.forward();
    _morphController.repeat(reverse: true);
    _particleController.repeat();
    _modelRotationController.repeat();
    _modelScaleController.repeat(reverse: true);
    _modelFloatController.repeat(reverse: true);
  }

  void _loadModels() {
    setState(() {
      _availableModels = ModelService.getModelsByCategory(_selectedModelCategory);
    });
  }

  @override
  void dispose() {
    _floatingController.dispose();
    _glowController.dispose();
    _rotationController.dispose();
    _pulseController.dispose();
    _slideController.dispose();
    _fadeController.dispose();
    _scaleController.dispose();
    _morphController.dispose();
    _particleController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _zipController.dispose();
    _areaController.dispose();
    _virtualTourController.dispose();
    _rulesController.dispose();
    _imageUrlController.dispose();
    _modelRotationController.dispose();
    _modelScaleController.dispose();
    _modelFloatController.dispose();
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
          _buildFloatingElements(),
          _buildParticleField(),
          SafeArea(
            child: BlocListener<PropertyBloc, PropertyState>(
              listener: (context, state) {
                if (state is PropertyUpdated) {
                  if (mounted) {
                    setState(() {
                      _isLoading = false;
                    });
                    print('✅ Property updated successfully! Updated imageUrls: $_existingImageUrls');
                    ScaffoldMessenger.of(context).showSnackBar(
                      _buildNeonSnackBar('Property updated successfully!', true),
                    );
                    // Wait a moment for the state to propagate, then navigate back
                    Future.delayed(const Duration(milliseconds: 500), () {
                      if (mounted) {
                        Navigator.of(context).pop(true); // Return true to indicate success
                      }
                    });
                  }
                } else if (state is PropertyError) {
                  if (mounted) {
                    setState(() {
                      _isLoading = false;
                    });
                    print('❌ Property update failed: ${state.message}');
                    ScaffoldMessenger.of(context).showSnackBar(
                      _buildNeonSnackBar('Failed to update property: ${state.message}', false),
                    );
                  }
                } else if (state is PropertyLoading) {
                  print('🔄 Property is loading...');
                }
              },
              child: Form(
                key: _formKey,
                child: FadeTransition(
                  opacity: _fadeAnimation,
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
                            _buildNeonCard('Basic Information', [
                              _buildNeonTextField(
                                controller: _titleController,
                                label: 'Property Title',
                                hint: 'e.g., Modern Downtown Apartment',
                                icon: Icons.home,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter a property title';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 20),
                              _buildNeonDropdown(),
                              const SizedBox(height: 20),
                              _buildNeonTextField(
                                controller: _descriptionController,
                                label: 'Description',
                                hint: 'Describe your property...',
                                icon: Icons.description,
                                maxLines: 4,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter a description';
                                  }
                                  return null;
                                },
                              ),
                            ]),
                            const SizedBox(height: 30),
                            _buildNeonCard('Location', [
                              _buildNeonTextField(
                                controller: _addressController,
                                label: 'Street Address',
                                icon: Icons.location_on,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter the street address';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 20),
                              _buildLocationRow(),
                            ]),
                            const SizedBox(height: 30),
                            _buildNeonCard('Property Details', [
                              _buildPriceRow(),
                              const SizedBox(height: 20),
                              _buildNeonSliders(),
                              const SizedBox(height: 20),
                              _buildNeonTextField(
                                controller: _areaController,
                                label: 'Area (sq ft)',
                                icon: Icons.square_foot,
                                keyboardType: TextInputType.number,
                                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                              ),
                            ]),
                            const SizedBox(height: 30),
                            _buildNeonCard('Amenities', [
                              _buildNeonAmenities(),
                            ]),
                            const SizedBox(height: 30),
                            _buildNeonCard('Additional Features', [
                              _buildNeonTextField(
                                controller: _virtualTourController,
                                label: 'Virtual Tour URL (Optional)',
                                hint: 'https://example.com/virtual-tour',
                                icon: Icons.view_in_ar,
                                keyboardType: TextInputType.url,
                              ),
                              const SizedBox(height: 20),
                              _buildNeonTextField(
                                controller: _rulesController,
                                label: 'House Rules (Optional)',
                                hint: 'No smoking, No pets, Quiet hours after 10 PM...',
                                icon: Icons.rule,
                                maxLines: 3,
                              ),
                            ]),
                            const SizedBox(height: 30),
                            _buildNeonCard('Images', [
                              _buildNeonImageUpload(),
                            ]),
                            const SizedBox(height: 40),
                            _buildNeonSaveButton(),
                            const SizedBox(height: 40),
                          ],
                        ),
                      ),
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
    return Container(
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.topLeft,
          radius: 1.5,
          colors: [
            Color(0xFF1A1B3A),
            Color(0xFF0A0E27),
            Color(0xFF000000),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingElements() {
    return AnimatedBuilder(
      animation: _floatingAnimation,
      builder: (context, child) {
        return Stack(
          children: [
            // Floating cube
            Positioned(
              top: 100 + _floatingAnimation.value,
              left: 50,
              child: AnimatedBuilder(
                animation: _rotationAnimation,
                builder: (context, child) {
                  return Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()
                      ..setEntry(3, 2, 0.001)
                      ..rotateX(_rotationAnimation.value * 0.3)
                      ..rotateY(_rotationAnimation.value * 0.5),
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF00D4FF), Color(0xFF5B73FF)],
                        ),
                        borderRadius: BorderRadius.circular(6),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF00D4FF).withOpacity(0.5),
                            blurRadius: 20,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            // Floating triangle
            Positioned(
              top: 200 - _floatingAnimation.value,
              right: 60,
              child: AnimatedBuilder(
                animation: _rotationAnimation,
                builder: (context, child) {
                  return Transform.rotate(
                    angle: _rotationAnimation.value,
                    child: CustomPaint(
                      size: const Size(25, 25),
                      painter: NeonTrianglePainter(),
                    ),
                  );
                },
              ),
            ),
            // Floating circles
            Positioned(
              top: 300 + _floatingAnimation.value * 0.5,
              left: 30,
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF6B9D), Color(0xFF9B59B6)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFF6B9D).withOpacity(0.5),
                      blurRadius: 15,
                      spreadRadius: 2,
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildParticleField() {
    return AnimatedBuilder(
      animation: _particleAnimation,
      builder: (context, child) {
        return Stack(
          children: List.generate(20, (index) {
            final offset = Offset(
              (index * 50.0) + (math.sin(_particleAnimation.value + index) * 100),
              (index * 80.0) + (math.cos(_particleAnimation.value + index) * 60),
            );
            return Positioned(
              left: offset.dx,
              top: offset.dy,
              child: Container(
                width: 2 + (index % 3),
                height: 2 + (index % 3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: [
                    const Color(0xFF00D4FF),
                    const Color(0xFF5B73FF),
                    const Color(0xFFFF6B9D),
                    const Color(0xFF9B59B6),
                  ][index % 4].withOpacity(0.7),
                  boxShadow: [
                    BoxShadow(
                      color: [
                        const Color(0xFF00D4FF),
                        const Color(0xFF5B73FF),
                        const Color(0xFFFF6B9D),
                        const Color(0xFF9B59B6),
                      ][index % 4].withOpacity(0.5),
                      blurRadius: 10,
                    ),
                  ],
                ),
              ),
            );
          }),
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
                          'Edit Property',
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
                          'Update your property listing',
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

  Widget _buildNeonCard(String title, List<Widget> children) {
    return Container(
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
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
                ...children,
              ],
            ),
        );
  }

  Widget _buildNeonTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    required IconData icon,
    int maxLines = 1,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
    Function(String)? onSubmitted,
  }) {
    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF00D4FF).withOpacity(_glowAnimation.value * 0.2),
                blurRadius: 15,
                spreadRadius: 2,
              ),
            ],
          ),
          child: TextFormField(
            controller: controller,
            maxLines: maxLines,
            keyboardType: keyboardType,
            inputFormatters: inputFormatters,
            validator: validator,
            onFieldSubmitted: onSubmitted,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              labelText: label,
              hintText: hint,
              prefixIcon: Icon(
                icon,
                color: const Color(0xFF00D4FF),
              ),
              labelStyle: TextStyle(
                color: const Color(0xFF00D4FF).withOpacity(0.8),
              ),
              hintStyle: TextStyle(
                color: Colors.white.withOpacity(0.5),
              ),
              filled: true,
              fillColor: const Color(0xFF2A2D47).withOpacity(0.9),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(
                  color: const Color(0xFF00D4FF).withOpacity(0.3),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(
                  color: const Color(0xFF00D4FF).withOpacity(0.5),
                  width: 1.5,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: const BorderSide(
                  color: Color(0xFF00D4FF),
                  width: 2,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: const BorderSide(
                  color: Color(0xFFFF6B9D),
                  width: 2,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildNeonDropdown() {
    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF00D4FF).withOpacity(_glowAnimation.value * 0.2),
                blurRadius: 15,
                spreadRadius: 2,
              ),
            ],
          ),
          child: DropdownButtonFormField<String>(
            value: _selectedPropertyType,
            decoration: InputDecoration(
              labelText: 'Property Type',
              prefixIcon: const Icon(
                Icons.home_work,
                color: Color(0xFF00D4FF),
              ),
              labelStyle: TextStyle(
                color: const Color(0xFF00D4FF).withOpacity(0.8),
              ),
              filled: true,
              fillColor: const Color(0xFF2A2D47).withOpacity(0.9),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(
                  color: const Color(0xFF00D4FF).withOpacity(0.3),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(
                  color: const Color(0xFF00D4FF).withOpacity(0.5),
                  width: 1.5,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: const BorderSide(
                  color: Color(0xFF00D4FF),
                  width: 2,
                ),
              ),
            ),
            dropdownColor: const Color(0xFF1A1B3A),
            style: const TextStyle(color: Colors.white),
            items: ['Apartment', 'House', 'Condo', 'Studio', 'Villa']
                .map((type) => DropdownMenuItem(
                      value: type,
                      child: Text(
                        type,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ))
                .toList(),
            onChanged: (value) {
              setState(() {
                _selectedPropertyType = value;
              });
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please select a property type';
              }
              return null;
            },
          ),
        );
      },
    );
  }

  Widget _buildLocationRow() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildNeonTextField(
                controller: _cityController,
                label: 'City',
                icon: Icons.location_city,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the city';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildNeonTextField(
                controller: _stateController,
                label: 'State',
                icon: Icons.map,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the state';
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildNeonTextField(
          controller: _zipController,
          label: 'ZIP Code',
          icon: Icons.pin_drop,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter the ZIP code';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildPriceRow() {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: _buildNeonTextField(
            controller: _priceController,
            label: 'Price',
            icon: Icons.attach_money,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter the price';
              }
              return null;
            },
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: AnimatedBuilder(
            animation: _glowAnimation,
            builder: (context, child) {
              return Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF00D4FF).withOpacity(_glowAnimation.value * 0.2),
                      blurRadius: 15,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: DropdownButtonFormField<String>(
                  value: _selectedPricePeriod,
                  decoration: InputDecoration(
                    labelText: 'Period',
                    prefixIcon: const Icon(
                      Icons.schedule,
                      color: Color(0xFF00D4FF),
                    ),
                    labelStyle: TextStyle(
                      color: const Color(0xFF00D4FF).withOpacity(0.8),
                    ),
                    filled: true,
                    fillColor: const Color(0xFF2A2D47).withOpacity(0.9),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(
                        color: const Color(0xFF00D4FF).withOpacity(0.3),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(
                        color: const Color(0xFF00D4FF).withOpacity(0.5),
                        width: 1.5,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: const BorderSide(
                        color: Color(0xFF00D4FF),
                        width: 2,
                      ),
                    ),
                  ),
                  dropdownColor: const Color(0xFF1A1B3A),
                  style: const TextStyle(color: Colors.white),
                  items: ['daily', 'weekly', 'monthly', 'yearly']
                      .map((period) => DropdownMenuItem(
                            value: period,
                            child: Text(
                              period.toUpperCase(),
                              style: const TextStyle(color: Colors.white),
                            ),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedPricePeriod = value!;
                    });
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildNeonSliders() {
    return Column(
      children: [
        _buildNeonSlider(
          'Bedrooms',
          _bedrooms,
          1,
          10,
          Icons.bed,
          (value) => setState(() => _bedrooms = value.round()),
        ),
        const SizedBox(height: 20),
        _buildNeonSlider(
          'Bathrooms',
          _bathrooms,
          1,
          10,
          Icons.bathtub,
          (value) => setState(() => _bathrooms = value.round()),
        ),
      ],
    );
  }

  Widget _buildNeonSlider(
    String label,
    int value,
    int min,
    int max,
    IconData icon,
    Function(double) onChanged,
  ) {
    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFF1A1B3A).withOpacity(0.6),
                const Color(0xFF2A2B4A).withOpacity(0.4),
              ],
            ),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: const Color(0xFF00D4FF).withOpacity(0.3),
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF00D4FF).withOpacity(_glowAnimation.value * 0.2),
                blurRadius: 15,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    icon,
                    color: const Color(0xFF00D4FF),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      label,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF00D4FF), Color(0xFF5B73FF)],
                      ),
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF00D4FF).withOpacity(0.5),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: Text(
                      value.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: const Color(0xFF00D4FF),
                  inactiveTrackColor: const Color(0xFF00D4FF).withOpacity(0.3),
                  thumbColor: const Color(0xFF00D4FF),
                  overlayColor: const Color(0xFF00D4FF).withOpacity(0.2),
                  thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
                  overlayShape: const RoundSliderOverlayShape(overlayRadius: 18),
                ),
                child: Slider(
                  value: value.toDouble(),
                  min: min.toDouble(),
                  max: max.toDouble(),
                  divisions: max - min,
                  onChanged: onChanged,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNeonAmenities() {
    final amenities = [
      {'name': 'WiFi', 'icon': Icons.wifi},
      {'name': 'Parking', 'icon': Icons.local_parking},
      {'name': 'Pool', 'icon': Icons.pool},
      {'name': 'Gym', 'icon': Icons.fitness_center},
      {'name': 'Pet Friendly', 'icon': Icons.pets},
      {'name': 'Air Conditioning', 'icon': Icons.ac_unit},
      {'name': 'Heating', 'icon': Icons.whatshot},
      {'name': 'Laundry', 'icon': Icons.local_laundry_service},
      {'name': 'Balcony', 'icon': Icons.balcony},
      {'name': 'Garden', 'icon': Icons.grass},
      {'name': 'Security', 'icon': Icons.security},
      {'name': 'Elevator', 'icon': Icons.elevator},
    ];

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: amenities.map((amenity) {
        final isSelected = _selectedAmenities.contains(amenity['name']);
        return AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            return GestureDetector(
              onTap: () {
                setState(() {
                  if (isSelected) {
                    _selectedAmenities.remove(amenity['name']);
                  } else {
                    _selectedAmenities.add(amenity['name'] as String);
                  }
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  gradient: isSelected
                      ? const LinearGradient(
                          colors: [Color(0xFF00D4FF), Color(0xFF5B73FF)],
                        )
                      : LinearGradient(
                          colors: [
                            const Color(0xFF1A1B3A).withOpacity(0.6),
                            const Color(0xFF2A2B4A).withOpacity(0.4),
                          ],
                        ),
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF00D4FF)
                        : const Color(0xFF00D4FF).withOpacity(0.3),
                    width: isSelected ? 2 : 1,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: const Color(0xFF00D4FF).withOpacity(0.5),
                            blurRadius: 15,
                            spreadRadius: 2,
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      amenity['icon'] as IconData,
                      color: isSelected ? Colors.white : const Color(0xFF00D4FF),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      amenity['name'] as String,
                      style: TextStyle(
                        color: isSelected ? Colors.white : const Color(0xFF00D4FF),
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }).toList(),
    );
  }

  Widget _buildNeonImageUpload() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Add Image URL Input
        Row(
          children: [
            Expanded(
              child: _buildNeonTextField(
                controller: _imageUrlController,
                label: 'Image URL',
                hint: 'https://example.com/image.jpg',
                icon: Icons.link,
                onSubmitted: (value) => _addImageUrl(),
              ),
            ),
            const SizedBox(width: 12),
            Container(
              height: 56,
              child: ElevatedButton(
                onPressed: _addImageUrl,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00D4FF),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: const Icon(Icons.add),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: AnimatedBuilder(
                animation: _glowAnimation,
                builder: (context, child) {
                  return GestureDetector(
                    onTap: _pickImages,
                    child: Container(
                      height: 120,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFF1A1B3A).withOpacity(0.6),
                            const Color(0xFF2A2B4A).withOpacity(0.4),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                          color: const Color(0xFF00D4FF).withOpacity(0.3),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF00D4FF).withOpacity(_glowAnimation.value * 0.2),
                            blurRadius: 15,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.cloud_upload,
                            color: const Color(0xFF00D4FF),
                            size: 32,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Upload Files',
                            style: TextStyle(
                              color: const Color(0xFF00D4FF),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Container(
                height: 120,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF1A1B3A).withOpacity(0.6),
                      const Color(0xFF2A2B4A).withOpacity(0.4),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: const Color(0xFF9B59B6).withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.link,
                      color: const Color(0xFF9B59B6),
                      size: 32,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Use Image URLs',
                      style: TextStyle(
                        color: const Color(0xFF9B59B6),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Recommended',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        if (_existingImageUrls.isNotEmpty || _newSelectedImages.isNotEmpty) ...[
          const SizedBox(height: 20),
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _existingImageUrls.length + _newSelectedImages.length,
              itemBuilder: (context, index) {
                if (index < _existingImageUrls.length) {
                  // Existing image
                  return Container(
                    margin: const EdgeInsets.only(right: 12),
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            _existingImageUrls[index],
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1A1B3A).withOpacity(0.6),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Center(
                                  child: CircularProgressIndicator(
                                    color: Color(0xFF00D4FF),
                                    strokeWidth: 2,
                                  ),
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1A1B3A).withOpacity(0.6),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: const Color(0xFFFF6B9D).withOpacity(0.5),
                                  ),
                                ),
                                child: const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.broken_image,
                                      color: Color(0xFFFF6B9D),
                                      size: 32,
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      'Failed to load',
                                      style: TextStyle(
                                        color: Color(0xFFFF6B9D),
                                        fontSize: 8,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                        Positioned(
                          top: 4,
                          right: 4,
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _existingImageUrls.removeAt(index);
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Color(0xFFFF6B9D),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                } else {
                  // New image
                  final newImageIndex = index - _existingImageUrls.length;
                  return Container(
                    margin: const EdgeInsets.only(right: 12),
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: FutureBuilder<Widget>(
                            future: _buildImageWidget(_newSelectedImages[newImageIndex]),
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                return snapshot.data!;
                              }
                              return const Center(
                                child: CircularProgressIndicator(
                                  color: Color(0xFF00D4FF),
                                ),
                              );
                            },
                          ),
                        ),
                        Positioned(
                          top: 4,
                          right: 4,
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _newSelectedImages.removeAt(newImageIndex);
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Color(0xFFFF6B9D),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }
              },
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildNeonSaveButton() {
    return Container(
            width: double.infinity,
            height: 60,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF00D4FF), Color(0xFF5B73FF)],
              ),
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF00D4FF).withOpacity(0.5),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(30),
                onTap: _isLoading ? null : _updateProperty,
                child: Center(
                  child: _isLoading
                      ? const CircularProgressIndicator(
                          color: Colors.white,
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.save,
                              color: Colors.white,
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Update Property',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
        );
  }

  void _addImageUrl() {
    final url = _imageUrlController.text.trim();
    if (url.isNotEmpty && _isValidImageUrl(url)) {
      setState(() {
        _existingImageUrls.add(url);
        _imageUrlController.clear(); // Clear the field after adding
      });
      ScaffoldMessenger.of(context).showSnackBar(
        _buildNeonSnackBar('Image URL added successfully!', true),
      );
    } else if (url.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        _buildNeonSnackBar('Please enter a valid image URL', false),
      );
    }
  }

  Future<void> _pickImages() async {
    final List<XFile> images = await _imagePicker.pickMultiImage();
    if (images.isNotEmpty) {
      setState(() {
        _newSelectedImages.addAll(images);
      });
    }
  }

  Future<Widget> _buildImageWidget(XFile imageFile) async {
    if (kIsWeb) {
      // For web, we need to read the bytes and create an Image.memory
      final bytes = await imageFile.readAsBytes();
      return Image.memory(
        bytes,
        width: 100,
        height: 100,
        fit: BoxFit.cover,
      );
    } else {
      // For mobile, we can use Image.file
      return Image.file(
        File(imageFile.path),
        width: 100,
        height: 100,
        fit: BoxFit.cover,
      );
    }
  }

  Future<void> _updateProperty() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Upload new images to Cloudinary
        List<String> newImageUrls = [];
        
        if (_newSelectedImages.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            _buildNeonSnackBar('Uploading images to ImgBB...', true),
          );
          
          newImageUrls = await ImageBBService.uploadPropertyImages(
            _newSelectedImages,
            widget.property.id,
          );
          
          print('=== IMGBB UPLOAD RESULTS ===');
          print('Uploaded ${newImageUrls.length} images');
          print('URLs: $newImageUrls');
          print('============================');
        }

        // Combine existing URLs with newly uploaded URLs
        final allImageUrls = [..._existingImageUrls, ...newImageUrls];
        
        // Debug print to check URLs
        print('=== PROPERTY UPDATE DEBUG ===');
        print('Original property imageUrls: ${widget.property.imageUrls}');
        print('Current _existingImageUrls: $_existingImageUrls');
        print('New uploaded URLs: $newImageUrls');
        print('Final allImageUrls to save: $allImageUrls');
        print('Property ID: ${widget.property.id}');
        print('===============================');

        // Create updated property object
        final updatedProperty = widget.property.copyWith(
          title: _titleController.text,
          description: _descriptionController.text,
          price: double.tryParse(_priceController.text) ?? 0.0,
          pricePeriod: _selectedPricePeriod,
          type: _selectedPropertyType ?? 'Apartment',
          bedrooms: _bedrooms,
          bathrooms: _bathrooms,
          area: double.tryParse(_areaController.text) ?? 0.0,
          address: _addressController.text,
          city: _cityController.text,
          state: _stateController.text,
          country: _zipController.text,
          amenities: _selectedAmenities,
          imageUrls: allImageUrls,
          virtualTourUrl: _virtualTourController.text.isNotEmpty ? _virtualTourController.text : null,
          additionalInfo: {
            'rules': _rulesController.text.isNotEmpty ? _rulesController.text : null,
          },
          latitude: _selectedLocation?.latitude ?? 0.0,
          longitude: _selectedLocation?.longitude ?? 0.0,
          landlordId: widget.property.landlordId,
          landlordName: widget.property.landlordName,
          isAvailable: widget.property.isAvailable,
          createdAt: widget.property.createdAt,
          updatedAt: DateTime.now(),
          reviewCount: widget.property.reviewCount
        );

        // Update property via bloc
        context.read<PropertyBloc>().add(UpdateProperty(property: updatedProperty));
        
        // Update our local state with the new image URLs to show immediate feedback
        print('🔄 Updating local state with new images...');
        setState(() {
          _existingImageUrls = List.from(allImageUrls);
          _newSelectedImages.clear();
        });
        print('✅ Local state updated. _existingImageUrls now: $_existingImageUrls');
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          _buildNeonSnackBar('Failed to update property: $e', false),
        );
      }
    }
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

  bool _isValidImageUrl(String url) {
    // Basic URL validation
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      return false;
    }
    
    // Check if URL ends with common image extensions
    final imageExtensions = ['.jpg', '.jpeg', '.png', '.gif', '.webp', '.bmp'];
    final lowerUrl = url.toLowerCase();
    
    return imageExtensions.any((ext) => lowerUrl.contains(ext)) || 
           lowerUrl.contains('imgur.com') || 
           lowerUrl.contains('unsplash.com') ||
           lowerUrl.contains('pexels.com') ||
           lowerUrl.contains('images') ||
           lowerUrl.contains('photo');
  }
}

class NeonTrianglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF00D4FF)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..moveTo(size.width / 2, 0)
      ..lineTo(0, size.height)
      ..lineTo(size.width, size.height)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

