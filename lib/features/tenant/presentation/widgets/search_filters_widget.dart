import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';

class SearchFiltersWidget extends StatefulWidget {
  final String? selectedPropertyType;
  final double? minPrice;
  final double? maxPrice;
  final int? bedrooms;
  final int? bathrooms;
  final List<String> selectedAmenities;
  final double? minRating;
  final DateTimeRange? availabilityDates;
  final Function(String?, double?, double?, int?, int?, List<String>, double?, DateTimeRange?) onApply;
  final VoidCallback onClear;

  const SearchFiltersWidget({
    super.key,
    this.selectedPropertyType,
    this.minPrice,
    this.maxPrice,
    this.bedrooms,
    this.bathrooms,
    required this.selectedAmenities,
    this.minRating,
    this.availabilityDates,
    required this.onApply,
    required this.onClear,
  });

  @override
  State<SearchFiltersWidget> createState() => _SearchFiltersWidgetState();
}

class _SearchFiltersWidgetState extends State<SearchFiltersWidget> {
  String? _selectedPropertyType;
  double _minPrice = 0;
  double _maxPrice = 5000;
  int? _bedrooms;
  int? _bathrooms;
  List<String> _selectedAmenities = [];
  double _minRating = 0;
  DateTimeRange? _availabilityDates;

  final List<String> _availableAmenities = [
    'Wi-Fi',
    'Air Conditioning',
    'Heating',
    'Parking',
    'Pet Friendly',
    'Gym',
    'Pool',
    'Laundry',
    'Dishwasher',
    'Balcony',
    'Garden',
    'Furnished',
    'Kitchen',
    'TV',
    'Workspace',
  ];

  @override
  void initState() {
    super.initState();
    _selectedPropertyType = widget.selectedPropertyType;
    _minPrice = widget.minPrice ?? 0;
    _maxPrice = widget.maxPrice ?? 5000;
    _bedrooms = widget.bedrooms;
    _bathrooms = widget.bathrooms;
    _selectedAmenities = List.from(widget.selectedAmenities);
    _minRating = widget.minRating ?? 0;
    _availabilityDates = widget.availabilityDates;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Advanced Filters',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: [
                  TextButton(
                    onPressed: () {
                      widget.onClear();
                      Navigator.of(context).pop();
                    },
                    child: const Text('Clear All'),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Property Type
                  _buildSectionTitle('Property Type'),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: AppConstants.propertyTypes.map((type) {
                      return FilterChip(
                        label: Text(type),
                        selected: _selectedPropertyType == type,
                        onSelected: (selected) {
                          setState(() {
                            _selectedPropertyType = selected ? type : null;
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                  
                  // Price Range
                  _buildSectionTitle('Price Range'),
                  const SizedBox(height: 12),
                  RangeSlider(
                    values: RangeValues(_minPrice, _maxPrice),
                    min: 0,
                    max: 5000,
                    divisions: 100,
                    labels: RangeLabels(
                      '\$${_minPrice.toInt()}',
                      '\$${_maxPrice.toInt()}',
                    ),
                    onChanged: (values) {
                      setState(() {
                        _minPrice = values.start;
                        _maxPrice = values.end;
                      });
                    },
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('\$${_minPrice.toInt()}'),
                      Text('\$${_maxPrice.toInt()}'),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // Bedrooms & Bathrooms
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionTitle('Bedrooms'),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 8,
                              children: [0, 1, 2, 3, 4, 5].map((count) {
                                return FilterChip(
                                  label: Text(count == 0 ? 'Studio' : '$count+'),
                                  selected: _bedrooms == count,
                                  onSelected: (selected) {
                                    setState(() {
                                      _bedrooms = selected ? count : null;
                                    });
                                  },
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionTitle('Bathrooms'),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 8,
                              children: [1, 2, 3, 4].map((count) {
                                return FilterChip(
                                  label: Text('$count+'),
                                  selected: _bathrooms == count,
                                  onSelected: (selected) {
                                    setState(() {
                                      _bathrooms = selected ? count : null;
                                    });
                                  },
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // Amenities
                  _buildSectionTitle('Amenities'),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _availableAmenities.map((amenity) {
                      return FilterChip(
                        label: Text(amenity),
                        selected: _selectedAmenities.contains(amenity),
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _selectedAmenities.add(amenity);
                            } else {
                              _selectedAmenities.remove(amenity);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                  
                  // Minimum Rating
                  _buildSectionTitle('Minimum Rating'),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Slider(
                          value: _minRating,
                          min: 0,
                          max: 5,
                          divisions: 10,
                          label: _minRating == 0 ? 'Any' : '${_minRating.toStringAsFixed(1)}+',
                          onChanged: (value) {
                            setState(() {
                              _minRating = value;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Row(
                        children: [
                          Icon(Icons.star, color: Colors.amber[600], size: 20),
                          const SizedBox(width: 4),
                          Text(
                            _minRating == 0 ? 'Any' : '${_minRating.toStringAsFixed(1)}+',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // Availability Dates
                  _buildSectionTitle('Availability Dates'),
                  const SizedBox(height: 12),
                  InkWell(
                    onTap: _selectAvailabilityDates,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _availabilityDates != null
                                  ? '${_formatDate(_availabilityDates!.start)} - ${_formatDate(_availabilityDates!.end)}'
                                  : 'Select availability dates',
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          ),
                          if (_availabilityDates != null)
                            IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                setState(() {
                                  _availabilityDates = null;
                                });
                              },
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
          
          // Apply Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                widget.onApply(
                  _selectedPropertyType,
                  _minPrice > 0 ? _minPrice : null,
                  _maxPrice < 5000 ? _maxPrice : null,
                  _bedrooms,
                  _bathrooms,
                  _selectedAmenities,
                  _minRating > 0 ? _minRating : null,
                  _availabilityDates,
                );
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Apply Filters'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w600,
      ),
    );
  }

  void _selectAvailabilityDates() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDateRange: _availabilityDates,
    );

    if (picked != null) {
      setState(() {
        _availabilityDates = picked;
      });
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

