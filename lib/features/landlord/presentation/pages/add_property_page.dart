import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rent_a_home/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:rent_a_home/features/property/presentation/bloc/property_bloc.dart';
import 'package:rent_a_home/core/services/firebase_service.dart';
import 'package:rent_a_home/core/services/firebase_image_service.dart';
import 'package:rent_a_home/core/services/mongodb_image_service.dart';
import 'package:rent_a_home/core/services/image_service.dart';
import 'package:rent_a_home/core/services/imagebb_service.dart';
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
import '../mixins/landlord_animations_mixin.dart';
import '../widgets/landlord_page_layout.dart';
import '../widgets/landlord_neon_button.dart';

class AddPropertyPage extends StatefulWidget {
  const AddPropertyPage({super.key});

  @override
  State<AddPropertyPage> createState() => _AddPropertyPageState();
}

class _AddPropertyPageState extends State<AddPropertyPage>
    with TickerProviderStateMixin, LandlordAnimationsMixin {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _zipController = TextEditingController();
  final _areaController = TextEditingController();
  final _virtualTourController = TextEditingController();
  final _rulesController = TextEditingController();
  
  String? _selectedPropertyType;
  String _selectedPricePeriod = 'monthly';
  int _bedrooms = 1;
  int _bathrooms = 1;
  List<String> _selectedAmenities = [];
  List<XFile> _selectedImages = [];
  List<String> _imageUrls = [];
  List<File> _selectedDocuments = [];
  bool _isLoading = false;
  bool _isTemplate = false;
  String? _templateName;
  
  // Google Maps
  GoogleMapController? _mapController;
  LatLng? _selectedLocation;
  Set<Marker> _markers = {};
  
  // Image Picker
  final ImagePicker _imagePicker = ImagePicker();
  
  // Calendar for availability
  List<DateTime> _blockedDates = [];
  
  String? _selected3DModel;
  bool _isModelLoading = false;

  Model3D? _selectedPreloadedModel;
  List<Model3D> _availableModels = [];
  String _selectedModelCategory = 'house';

  @override
  void initState() {
    super.initState();
    initializeLandlordAnimations();
    startLandlordAnimations();
  }

  @override
  void dispose() {
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
    disposeLandlordAnimations();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LandlordPageLayout(
      title: '✨ Add New Property',
      backgroundAnimation: backgroundAnimation,
      fadeAnimation: fadeAnimation,
      body: BlocListener<PropertyBloc, PropertyState>(
        listener: (context, state) {
          if (state is PropertyAdded) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                _buildNeonSnackBar('🎉 Property added successfully!', true),
              );
              Navigator.of(context).pop();
            }
          } else if (state is PropertyError) {
            if (mounted) {
              setState(() {
                _isLoading = false;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                _buildNeonSnackBar('❌ Failed to save property: ${state.message}', false),
              );
            }
          }
        },
        child: SlideTransition(
          position: slideAnimation,
          child: ScaleTransition(
            scale: scaleAnimation,
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Hero Header Section
                    _buildHeroSection(),
                    const SizedBox(height: 30),
                    
                    // Form Sections with Ultra Professional Design
                    _buildUltraProfessionalCard('🏡 Basic Information', [
                      _buildUltraTextField(
                        controller: _titleController,
                        label: 'Property Title',
                        hint: 'e.g., Luxury Downtown Apartment',
                        icon: Icons.home_rounded,
                        validator: (value) => value?.isEmpty ?? true ? 'Please enter a property title' : null,
                      ),
                      const SizedBox(height: 20),
                      _buildUltraDropdown(),
                      const SizedBox(height: 20),
                      _buildUltraTextField(
                        controller: _descriptionController,
                        label: 'Property Description',
                        hint: 'Describe what makes your property special...',
                        icon: Icons.description_rounded,
                        maxLines: 4,
                        validator: (value) => value?.isEmpty ?? true ? 'Please enter a description' : null,
                      ),
                    ]),
                    const SizedBox(height: 30),
                    
                    _buildUltraProfessionalCard('📍 Location Details', [
                      _buildUltraTextField(
                        controller: _addressController,
                        label: 'Street Address',
                        hint: '123 Main Street',
                        icon: Icons.location_on_rounded,
                        validator: (value) => value?.isEmpty ?? true ? 'Please enter the street address' : null,
                      ),
                      const SizedBox(height: 20),
                      _buildLocationGrid(),
                    ]),
                    const SizedBox(height: 30),
                    
                    _buildUltraProfessionalCard('💰 Property Specifications', [
                      _buildPricingSection(),
                      const SizedBox(height: 25),
                      _buildSpecificationSliders(),
                      const SizedBox(height: 20),
                      _buildUltraTextField(
                        controller: _areaController,
                        label: 'Total Area (sq ft)',
                        hint: 'e.g., 1200',
                        icon: Icons.square_foot_rounded,
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      ),
                    ]),
                    const SizedBox(height: 30),
                    
                    _buildUltraProfessionalCard('🏖️ Premium Amenities', [
                      _buildUltraAmenities(),
                    ]),
                    const SizedBox(height: 30),
                    
                    _buildUltraProfessionalCard('🌟 Enhanced Features', [
                      _buildUltraTextField(
                        controller: _virtualTourController,
                        label: 'Virtual Tour URL (Optional)',
                        hint: 'https://your-virtual-tour.com',
                        icon: Icons.view_in_ar_rounded,
                        keyboardType: TextInputType.url,
                      ),
                      const SizedBox(height: 20),
                      _buildUltraTextField(
                        controller: _rulesController,
                        label: 'House Rules & Guidelines (Optional)',
                        hint: 'Shared expectations and property guidelines...',
                        icon: Icons.rule_rounded,
                        maxLines: 3,
                      ),
                    ]),
                    const SizedBox(height: 30),
                    
                    _buildUltraProfessionalCard('📸 Property Gallery', [
                      _buildUltraImageUpload(),
                    ]),
                    const SizedBox(height: 40),
                    
                    // Ultra Professional Save Button
                    _buildUltraSaveButton(),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Hero Section
  Widget _buildHeroSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        gradient: LinearGradient(
          colors: [
            AppTheme.landlordPrimary.withOpacity(0.9),
            AppTheme.landlordSecondary.withOpacity(0.9),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.landlordPrimary.withOpacity(0.4),
            blurRadius: 20,
            spreadRadius: 2,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            Icons.add_home_work_rounded,
            color: Colors.white,
            size: 60,
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'List a New Property',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'Fill in the details below to attract the best tenants.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Ultra Professional Card
  Widget _buildUltraProfessionalCard(String title, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF1A1B3A).withOpacity(0.95),
            const Color(0xFF101129).withOpacity(0.9),
          ],
          stops: const [0.0, 1.0],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.landlordPrimary.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.landlordPrimary.withOpacity(0.1),
            blurRadius: 25,
            spreadRadius: 3,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 10,
            spreadRadius: -5,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      color: AppTheme.landlordPrimary.withOpacity(0.7),
                      blurRadius: 15,
                    ),
                  ],
                ),
          ),
          const SizedBox(height: 25),
          ...children,
        ],
      ),
    );
  }

  // Ultra Text Field
  Widget _buildUltraTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    required IconData icon,
    int maxLines = 1,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: AppTheme.landlordPrimary.withOpacity(0.1),
            blurRadius: 20,
            spreadRadius: -5,
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        validator: validator,
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
            color: AppTheme.landlordPrimary,
          ),
          labelStyle: TextStyle(
            color: AppTheme.landlordPrimary.withOpacity(0.8),
          ),
          hintStyle: TextStyle(
            color: Colors.white.withOpacity(0.4),
          ),
          filled: true,
          fillColor: const Color(0xFF101129).withOpacity(0.8),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(
              color: AppTheme.landlordPrimary.withOpacity(0.2),
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(
              color: AppTheme.landlordPrimary.withOpacity(0.2),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(
              color: AppTheme.landlordPrimary,
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
            horizontal: 20,
            vertical: 20,
          ),
        ),
      ),
    );
  }

  // Ultra Dropdown
  Widget _buildUltraDropdown() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: AppTheme.landlordPrimary.withOpacity(0.1),
            blurRadius: 20,
            spreadRadius: -5,
          ),
        ],
      ),
      child: DropdownButtonFormField<String>(
        value: _selectedPropertyType,
        decoration: InputDecoration(
          labelText: 'Property Type',
          prefixIcon: const Icon(
            Icons.home_work_rounded,
            color: AppTheme.landlordPrimary,
          ),
          labelStyle: TextStyle(
            color: AppTheme.landlordPrimary.withOpacity(0.8),
          ),
          filled: true,
          fillColor: const Color(0xFF101129).withOpacity(0.8),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(
              color: AppTheme.landlordPrimary.withOpacity(0.2),
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(
              color: AppTheme.landlordPrimary.withOpacity(0.2),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(
              color: AppTheme.landlordPrimary,
              width: 2,
            ),
          ),
        ),
        dropdownColor: const Color(0xFF1A1B3A),
        style: const TextStyle(
            color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
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
        validator: (value) =>
            value == null ? 'Please select a property type' : null,
      ),
    );
  }

  // Location Grid
  Widget _buildLocationGrid() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildUltraTextField(
                controller: _cityController,
                label: 'City',
                hint: 'e.g., San Francisco',
                icon: Icons.location_city_rounded,
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Please enter the city' : null,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildUltraTextField(
                controller: _stateController,
                label: 'State',
                hint: 'e.g., CA',
                icon: Icons.map_rounded,
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Please enter the state' : null,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildUltraTextField(
          controller: _zipController,
          label: 'ZIP Code',
          hint: 'e.g., 94102',
          icon: Icons.pin_drop_rounded,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          validator: (value) =>
              value?.isEmpty ?? true ? 'Please enter the ZIP code' : null,
        ),
      ],
    );
  }

  // Pricing Section
  Widget _buildPricingSection() {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: _buildUltraTextField(
            controller: _priceController,
            label: 'Rental Price',
            hint: 'e.g., 3000',
            icon: Icons.monetization_on_rounded,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            validator: (value) =>
                value?.isEmpty ?? true ? 'Please enter the price' : null,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 2,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.landlordPrimary.withOpacity(0.1),
                  blurRadius: 20,
                  spreadRadius: -5,
                ),
              ],
            ),
            child: DropdownButtonFormField<String>(
              value: _selectedPricePeriod,
              decoration: InputDecoration(
                labelText: 'Period',
                prefixIcon: const Icon(
                  Icons.schedule_rounded,
                  color: AppTheme.landlordPrimary,
                ),
                labelStyle: TextStyle(
                  color: AppTheme.landlordPrimary.withOpacity(0.8),
                ),
                filled: true,
                fillColor: const Color(0xFF101129).withOpacity(0.8),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide(
                    color: AppTheme.landlordPrimary.withOpacity(0.2),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide(
                    color: AppTheme.landlordPrimary.withOpacity(0.2),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: const BorderSide(
                    color: AppTheme.landlordPrimary,
                    width: 2,
                  ),
                ),
              ),
              dropdownColor: const Color(0xFF1A1B3A),
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500),
              items: ['daily', 'weekly', 'monthly', 'yearly']
                  .map((period) => DropdownMenuItem(
                        value: period,
                        child: Text(
                          period[0].toUpperCase() + period.substring(1),
                          style: const TextStyle(color: Colors.white),
                        ),
                      ))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedPricePeriod = value;
                  });
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  // Specification Sliders
  Widget _buildSpecificationSliders() {
    return Column(
      children: [
        _buildUltraSlider(
          'Bedrooms',
          _bedrooms,
          1,
          10,
          Icons.bed_rounded,
          (value) => setState(() => _bedrooms = value.round()),
        ),
        const SizedBox(height: 16),
        _buildUltraSlider(
          'Bathrooms',
          _bathrooms,
          1,
          10,
          Icons.bathtub_rounded,
          (value) => setState(() => _bathrooms = value.round()),
        ),
      ],
    );
  }

  // Ultra Slider
  Widget _buildUltraSlider(
    String label,
    int value,
    int min,
    int max,
    IconData icon,
    Function(double) onChanged,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF101129).withOpacity(0.8),
            const Color(0xFF1A1B3A).withOpacity(0.6),
          ],
        ),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: AppTheme.landlordPrimary.withOpacity(0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.landlordPrimary.withOpacity(0.1),
            blurRadius: 15,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: AppTheme.landlordPrimary,
                size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      AppTheme.landlordPrimary,
                      AppTheme.landlordSecondary
                    ],
                  ),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.landlordPrimary.withOpacity(0.4),
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
              activeTrackColor: AppTheme.landlordPrimary,
              inactiveTrackColor: AppTheme.landlordPrimary.withOpacity(0.3),
              thumbColor: AppTheme.landlordSecondary,
              overlayColor: AppTheme.landlordPrimary.withOpacity(0.2),
              thumbShape:
                  const RoundSliderThumbShape(enabledThumbRadius: 10),
              overlayShape:
                  const RoundSliderOverlayShape(overlayRadius: 20),
              trackHeight: 4,
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
  }

  // Ultra Amenities
  Widget _buildUltraAmenities() {
    final amenities = [
      {'name': 'WiFi', 'icon': Icons.wifi_rounded},
      {'name': 'Parking', 'icon': Icons.local_parking_rounded},
      {'name': 'Pool', 'icon': Icons.pool_rounded},
      {'name': 'Gym', 'icon': Icons.fitness_center_rounded},
      {'name': 'Pet Friendly', 'icon': Icons.pets_rounded},
      {'name': 'Air Conditioning', 'icon': Icons.ac_unit_rounded},
      {'name': 'Heating', 'icon': Icons.whatshot_rounded},
      {'name': 'Laundry', 'icon': Icons.local_laundry_service_rounded},
      {'name': 'Balcony', 'icon': Icons.balcony_rounded},
      {'name': 'Garden', 'icon': Icons.grass_rounded},
      {'name': 'Security', 'icon': Icons.security_rounded},
      {'name': 'Elevator', 'icon': Icons.elevator_rounded},
    ];

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: amenities.map((amenity) {
        final isSelected = _selectedAmenities.contains(amenity['name']);
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
                      colors: [
                        AppTheme.landlordPrimary,
                        AppTheme.landlordSecondary
                      ],
                    )
                  : LinearGradient(
                      colors: [
                        const Color(0xFF101129).withOpacity(0.8),
                        const Color(0xFF1A1B3A).withOpacity(0.6),
                      ],
                    ),
              borderRadius: BorderRadius.circular(25),
              border: Border.all(
                color: isSelected
                    ? AppTheme.landlordPrimary
                    : AppTheme.landlordPrimary.withOpacity(0.2),
                width: isSelected ? 2 : 1,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: AppTheme.landlordPrimary.withOpacity(0.5),
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
                  color: isSelected
                      ? Colors.white
                      : AppTheme.landlordPrimary,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Text(
                  amenity['name'] as String,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  // Ultra Image Upload
  Widget _buildUltraImageUpload() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: _pickImages,
          child: Container(
            height: 220,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF101129).withOpacity(0.8),
                  const Color(0xFF1A1B3A).withOpacity(0.6),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppTheme.landlordPrimary.withOpacity(0.2),
                width: 2,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.cloud_upload_rounded,
                  color: AppTheme.landlordPrimary,
                  size: 50,
                ),
                const SizedBox(height: 16),
                Text(
                  'Upload Property Images',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'High-quality images attract more tenants',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Images are securely stored on ImageBB',
                  style: TextStyle(
                    color: AppTheme.landlordPrimary.withOpacity(0.7),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (_selectedImages.isNotEmpty) ...[
          const SizedBox(height: 20),
          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _selectedImages.length,
              itemBuilder: (context, index) {
                return Container(
                  margin: const EdgeInsets.only(right: 12),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: FutureBuilder<Widget>(
                          future: _buildImageWidget(_selectedImages[index]),
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              return snapshot.data!;
                            }
                            return Container(
                              width: 120,
                              height: 120,
                              color: const Color(0xFF101129),
                              child: const Center(
                                child: CircularProgressIndicator(
                                  color: AppTheme.landlordPrimary,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      Positioned(
                        top: 6,
                        right: 6,
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedImages.removeAt(index);
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
              },
            ),
          ),
        ],
      ],
    );
  }

  // Ultra Save Button
  Widget _buildUltraSaveButton() {
    return AnimatedBuilder(
      animation: glowAnimation,
      builder: (context, child) {
        return Container(
          width: double.infinity,
          height: 60,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                AppTheme.landlordPrimary,
                AppTheme.landlordSecondary
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: AppTheme.landlordPrimary
                    .withOpacity(0.5 * glowAnimation.value),
                blurRadius: 25,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(30),
              onTap: _isLoading ? null : _saveProperty,
              child: Center(
                child: _isLoading
                    ? const CircularProgressIndicator(
                        color: Colors.white,
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.save_alt_rounded,
                            color: Colors.white,
                            size: 26,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Save & Publish Property',
                            style:
                                Theme.of(context).textTheme.titleLarge?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1.1,
                                    ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _pickImages() async {
    final List<XFile> images = await _imagePicker.pickMultiImage();
    if (images.isNotEmpty) {
      setState(() {
        _selectedImages.addAll(images);
      });
    }
  }

  Future<Widget> _buildImageWidget(XFile imageFile) async {
    if (kIsWeb) {
      // For web, we need to read the bytes and create an Image.memory
      final bytes = await imageFile.readAsBytes();
      return Image.memory(
        bytes,
        width: 120,
        height: 120,
        fit: BoxFit.cover,
      );
    } else {
      // For mobile, we can use Image.file
      return Image.file(
        File(imageFile.path),
        width: 120,
        height: 120,
        fit: BoxFit.cover,
      );
    }
  }

  Future<void> _saveProperty() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Upload images if any
        List<String> imageUrls = [];
        if (_selectedImages.isNotEmpty) {
          // Generate a property ID that will be used for storage
          String propertyId = DateTime.now().millisecondsSinceEpoch.toString();
          
          try {
            print('🏠 Starting image upload process for property: $propertyId');
            print('📱 Selected ${_selectedImages.length} images to upload');
            
            // Initialize ImageBB service
            print('🚀 Initializing ImageBB service...');
            await ImageService.initialize(provider: ImageStorageProvider.imagebb);
            
            // Check if service is available
            bool isAvailable = await ImageService.isAvailable();
            if (!isAvailable) {
              throw Exception('ImageBB service is not available');
            }
            
            print('🖼️ Uploading images to ImageBB...');
            imageUrls = await ImageService.uploadPropertyImages(
              _selectedImages,
              propertyId,
            );
            
            if (imageUrls.isNotEmpty) {
              print('✅ Successfully uploaded ${imageUrls.length} images to ImageBB');
              print('🔗 Image URLs: ${imageUrls.take(3).toList()}...'); // Log first 3 URLs
            } else {
              throw Exception('ImageBB returned empty image list');
            }
          } catch (uploadError) {
            print('❌ ImageBB upload failed: $uploadError');
            
            // Still allow property creation without images but notify user
            imageUrls = [];
            
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                _buildNeonSnackBar(
                  '⚠️ ImageBB upload failed: ${uploadError.toString().substring(0, 50)}... Property will be saved without images.',
                  false,
                ),
              );
            }
          }
        }

        // Create property object
        final property = PropertyModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
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
          country: 'USA', // Adding required country field
          amenities: _selectedAmenities,
          imageUrls: imageUrls,
          virtualTourUrl: _virtualTourController.text.isNotEmpty ? _virtualTourController.text : null,
          landlordId: context.read<AuthBloc>().state is Authenticated ? (context.read<AuthBloc>().state as Authenticated).user.id : '',
          landlordName: context.read<AuthBloc>().state is Authenticated ? (context.read<AuthBloc>().state as Authenticated).user.fullName : '',
          latitude: _selectedLocation?.latitude ?? 0.0,
          longitude: _selectedLocation?.longitude ?? 0.0,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          isAvailable: true,
          reviewCount: 0
        );

        // Add property via bloc
        context.read<PropertyBloc>().add(AddProperty(property: property));
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          _buildNeonSnackBar('Failed to save property: $e', false),
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
      backgroundColor: isSuccess ? AppTheme.landlordPrimary : const Color(0xFFFF6B9D),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      margin: const EdgeInsets.all(16),
      elevation: 10,
      duration: const Duration(seconds: 4),
    );
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
