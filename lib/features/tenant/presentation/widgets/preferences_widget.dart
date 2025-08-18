import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';

class PreferencesWidget extends StatefulWidget {
  final Map<String, dynamic> preferences;
  final Function(Map<String, dynamic>) onPreferencesChanged;

  const PreferencesWidget({
    super.key,
    required this.preferences,
    required this.onPreferencesChanged,
  });

  @override
  State<PreferencesWidget> createState() => _PreferencesWidgetState();
}

class _PreferencesWidgetState extends State<PreferencesWidget> {
  late Map<String, dynamic> _preferences;

  final List<String> _availableLocations = [
    'Downtown',
    'Midtown',
    'Uptown',
    'Suburbs',
    'Waterfront',
    'University District',
    'Business District',
    'Historic District',
  ];

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
    _preferences = Map.from(widget.preferences);
  }

  void _updatePreferences() {
    widget.onPreferencesChanged(_preferences);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Search Preferences',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Set your preferences to get personalized property recommendations.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 24),
        
        // Budget Range
        _buildBudgetSection(),
        const SizedBox(height: 24),
        
        // Preferred Locations
        _buildLocationSection(),
        const SizedBox(height: 24),
        
        // Property Types
        _buildPropertyTypeSection(),
        const SizedBox(height: 24),
        
        // Amenities
        _buildAmenitiesSection(),
        const SizedBox(height: 24),
        
        // Move-in Date
        _buildMoveInDateSection(),
        const SizedBox(height: 24),
        
        // Lease Duration
        _buildLeaseDurationSection(),
        const SizedBox(height: 24),
        
        // Lifestyle Preferences
        _buildLifestyleSection(),
        const SizedBox(height: 24),
        
        // Notification Preferences
        _buildNotificationSection(),
        const SizedBox(height: 24),
        
        // Save Button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _savePreferences,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text('Save Preferences'),
          ),
        ),
      ],
    );
  }

  Widget _buildBudgetSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Budget Range',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            RangeSlider(
              values: RangeValues(
                _preferences['budget_min']?.toDouble() ?? 500.0,
                _preferences['budget_max']?.toDouble() ?? 2000.0,
              ),
              min: 0,
              max: 5000,
              divisions: 100,
              labels: RangeLabels(
                '\$${(_preferences['budget_min']?.toInt() ?? 500)}',
                '\$${(_preferences['budget_max']?.toInt() ?? 2000)}',
              ),
              onChanged: (values) {
                setState(() {
                  _preferences['budget_min'] = values.start;
                  _preferences['budget_max'] = values.end;
                });
                _updatePreferences();
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('\$${(_preferences['budget_min']?.toInt() ?? 500)}'),
                Text('\$${(_preferences['budget_max']?.toInt() ?? 2000)}'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationSection() {
    final selectedLocations = List<String>.from(_preferences['preferred_locations'] ?? []);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Preferred Locations',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _availableLocations.map((location) {
                final isSelected = selectedLocations.contains(location);
                return FilterChip(
                  label: Text(location),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        selectedLocations.add(location);
                      } else {
                        selectedLocations.remove(location);
                      }
                      _preferences['preferred_locations'] = selectedLocations;
                    });
                    _updatePreferences();
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPropertyTypeSection() {
    final selectedTypes = List<String>.from(_preferences['property_types'] ?? []);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Property Types',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: AppConstants.propertyTypes.map((type) {
                final isSelected = selectedTypes.contains(type);
                return FilterChip(
                  label: Text(type),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        selectedTypes.add(type);
                      } else {
                        selectedTypes.remove(type);
                      }
                      _preferences['property_types'] = selectedTypes;
                    });
                    _updatePreferences();
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAmenitiesSection() {
    final selectedAmenities = List<String>.from(_preferences['amenities'] ?? []);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Preferred Amenities',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _availableAmenities.map((amenity) {
                final isSelected = selectedAmenities.contains(amenity);
                return FilterChip(
                  label: Text(amenity),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        selectedAmenities.add(amenity);
                      } else {
                        selectedAmenities.remove(amenity);
                      }
                      _preferences['amenities'] = selectedAmenities;
                    });
                    _updatePreferences();
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMoveInDateSection() {
    final moveInDate = _preferences['move_in_date'] as DateTime?;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Preferred Move-in Date',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: _selectMoveInDate,
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
                        moveInDate != null
                            ? _formatDate(moveInDate)
                            : 'Select move-in date',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ),
                    if (moveInDate != null)
                      IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _preferences['move_in_date'] = null;
                          });
                          _updatePreferences();
                        },
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeaseDurationSection() {
    final leaseDuration = _preferences['lease_duration'] as int? ?? 12;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Preferred Lease Duration',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Slider(
                    value: leaseDuration.toDouble(),
                    min: 1,
                    max: 24,
                    divisions: 23,
                    label: '$leaseDuration months',
                    onChanged: (value) {
                      setState(() {
                        _preferences['lease_duration'] = value.toInt();
                      });
                      _updatePreferences();
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  '$leaseDuration months',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLifestyleSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Lifestyle Preferences',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Pet-friendly properties'),
              subtitle: const Text('I have or plan to have pets'),
              value: _preferences['pets'] ?? false,
              onChanged: (value) {
                setState(() {
                  _preferences['pets'] = value;
                });
                _updatePreferences();
              },
            ),
            SwitchListTile(
              title: const Text('Smoking allowed'),
              subtitle: const Text('I smoke or need smoking-allowed properties'),
              value: _preferences['smoking'] ?? false,
              onChanged: (value) {
                setState(() {
                  _preferences['smoking'] = value;
                });
                _updatePreferences();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationSection() {
    final notifications = Map<String, bool>.from(_preferences['notifications'] ?? {});
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Notification Preferences',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('New Properties'),
              subtitle: const Text('Get notified about new properties matching your criteria'),
              value: notifications['new_properties'] ?? true,
              onChanged: (value) {
                setState(() {
                  notifications['new_properties'] = value;
                  _preferences['notifications'] = notifications;
                });
                _updatePreferences();
              },
            ),
            SwitchListTile(
              title: const Text('Price Drops'),
              subtitle: const Text('Get notified when property prices drop'),
              value: notifications['price_drops'] ?? true,
              onChanged: (value) {
                setState(() {
                  notifications['price_drops'] = value;
                  _preferences['notifications'] = notifications;
                });
                _updatePreferences();
              },
            ),
            SwitchListTile(
              title: const Text('Saved Searches'),
              subtitle: const Text('Get updates for your saved searches'),
              value: notifications['saved_searches'] ?? true,
              onChanged: (value) {
                setState(() {
                  notifications['saved_searches'] = value;
                  _preferences['notifications'] = notifications;
                });
                _updatePreferences();
              },
            ),
            SwitchListTile(
              title: const Text('Booking Updates'),
              subtitle: const Text('Get notified about booking status changes'),
              value: notifications['booking_updates'] ?? true,
              onChanged: (value) {
                setState(() {
                  notifications['booking_updates'] = value;
                  _preferences['notifications'] = notifications;
                });
                _updatePreferences();
              },
            ),
            SwitchListTile(
              title: const Text('Messages'),
              subtitle: const Text('Get notified about new messages'),
              value: notifications['messages'] ?? true,
              onChanged: (value) {
                setState(() {
                  notifications['messages'] = value;
                  _preferences['notifications'] = notifications;
                });
                _updatePreferences();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _selectMoveInDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _preferences['move_in_date'] ?? DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() {
        _preferences['move_in_date'] = picked;
      });
      _updatePreferences();
    }
  }

  void _savePreferences() async {
    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );
    
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));
    
    // Close loading
    Navigator.of(context).pop();
    
    // Show success
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Preferences saved successfully!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}

