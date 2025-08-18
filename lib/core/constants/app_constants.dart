class AppConstants {
  // Property Types
  static const List<String> propertyTypes = [
    'Apartment',
    'House',
    'Studio',
    'Condo',
    'Townhouse',
    'Loft',
    'Villa',
    'Duplex',
    'Room',
    'Shared Space',
  ];

  // Amenities
  static const List<String> amenities = [
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
    'Security',
    'Elevator',
    'Concierge',
    'Rooftop',
    'Storage',
  ];

  // Property Rules
  static const List<String> propertyRules = [
    'No Smoking',
    'No Pets',
    'No Parties',
    'Quiet Hours 10PM-8AM',
    'No Guests Overnight',
    'Keep Common Areas Clean',
    'Respect Neighbors',
    'No Illegal Activities',
    'Report Maintenance Issues',
    'Follow Building Rules',
  ];

  // Price Periods
  static const List<String> pricePeriods = [
    'daily',
    'weekly',
    'monthly',
    'yearly',
  ];

  // Booking Status
  static const Map<String, String> bookingStatusLabels = {
    'pending': 'Pending',
    'confirmed': 'Confirmed',
    'completed': 'Completed',
    'cancelled': 'Cancelled',
  };

  // Payment Status
  static const Map<String, String> paymentStatusLabels = {
    'pending': 'Pending',
    'completed': 'Completed',
    'failed': 'Failed',
  };

  // Payment Types
  static const Map<String, String> paymentTypeLabels = {
    'rent': 'Rent Payment',
    'deposit': 'Security Deposit',
    'fee': 'Service Fee',
    'refund': 'Refund',
  };

  // Maintenance Categories
  static const List<String> maintenanceCategories = [
    'Plumbing',
    'Electrical',
    'HVAC',
    'Appliance',
    'General',
    'Cleaning',
    'Pest Control',
    'Security',
    'Internet/Cable',
    'Other',
  ];

  // Priority Levels
  static const List<String> priorityLevels = [
    'Low',
    'Medium',
    'High',
    'Urgent',
  ];

  // Verification Types
  static const Map<String, String> verificationTypes = {
    'email': 'Email Verification',
    'phone': 'Phone Verification',
    'identity': 'Identity Verification',
    'income': 'Income Verification',
    'background_check': 'Background Check',
  };

  // Document Types
  static const Map<String, List<String>> documentTypes = {
    'identity': [
      'Driver\'s License',
      'Passport',
      'National ID',
      'State ID',
    ],
    'income': [
      'Pay Stubs (Last 3 months)',
      'Employment Letter',
      'Bank Statements',
      'Tax Returns',
      'W-2 Forms',
    ],
    'additional': [
      'References',
      'Background Check',
      'Credit Report',
      'Previous Rental History',
    ],
  };

  // App Settings
  static const String appName = 'Rent a Home';
  static const String appVersion = '1.0.0';
  static const String supportEmail = 'support@rentahome.com';
  static const String supportPhone = '+1 (555) 123-4567';

  // API Endpoints (for future use)
  static const String baseUrl = 'https://api.rentahome.com';
  static const String apiVersion = 'v1';

  // Image Placeholders
  static const String defaultPropertyImage = 'assets/images/default_property.png';
  static const String defaultUserAvatar = 'assets/images/default_avatar.png';

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  // Validation
  static const int minPasswordLength = 8;
  static const int maxMessageLength = 1000;
  static const int maxFileSize = 10 * 1024 * 1024; // 10MB

  // Date Formats
  static const String dateFormat = 'MMM dd, yyyy';
  static const String timeFormat = 'hh:mm a';
  static const String dateTimeFormat = 'MMM dd, yyyy hh:mm a';

  // Currency
  static const String currencySymbol = '\$';
  static const String currencyCode = 'USD';

  // Map Settings
  static const double defaultLatitude = 37.7749;
  static const double defaultLongitude = -122.4194;
  static const double defaultZoom = 12.0;

  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);

  // Timeouts
  static const Duration apiTimeout = Duration(seconds: 30);
  static const Duration uploadTimeout = Duration(minutes: 5);

  // Cache Settings
  static const Duration cacheExpiry = Duration(hours: 24);
  static const int maxCacheSize = 100;

  // Feature Flags
  static const bool enablePushNotifications = true;
  static const bool enableBiometricAuth = true;
  static const bool enableDarkMode = true;
  static const bool enableOfflineMode = false;

  // Social Media
  static const String facebookUrl = 'https://facebook.com/rentahome';
  static const String twitterUrl = 'https://twitter.com/rentahome';
  static const String instagramUrl = 'https://instagram.com/rentahome';

  // Legal
  static const String privacyPolicyUrl = 'https://rentahome.com/privacy';
  static const String termsOfServiceUrl = 'https://rentahome.com/terms';
  static const String cookiePolicyUrl = 'https://rentahome.com/cookies';
}

