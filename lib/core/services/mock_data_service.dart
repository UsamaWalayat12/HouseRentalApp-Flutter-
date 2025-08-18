import '../../shared/models/property_model.dart';
import '../../shared/models/user_model.dart';

class MockDataService {
  static List<PropertyModel> getMockProperties() {
    final now = DateTime.now();
    return [
      PropertyModel(
        id: '1',
        title: 'Modern Downtown Apartment',
        description: 'Beautiful modern apartment in the heart of downtown with stunning city views. Features include hardwood floors, stainless steel appliances, and floor-to-ceiling windows.',
        type: 'Apartment',
        price: 2500,
        pricePeriod: 'monthly',
        address: '123 Main Street',
        city: 'New York',
        state: 'NY',
        country: 'USA',
        bedrooms: 2,
        bathrooms: 2,
        area: 1200,
        amenities: const ['WiFi', 'Air Conditioning', 'Parking', 'Gym', 'Pool'],
        imageUrls: const [
          'https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?w=800',
          'https://images.unsplash.com/photo-1484154218962-a197022b5858?w=800',
          'https://images.unsplash.com/photo-1502672260266-1c1ef2d93688?w=800',
        ],
        landlordId: 'landlord1',
        landlordName: 'John Smith',
        landlordPhone: '+1 (555) 123-4567',
        landlordEmail: 'john.smith@email.com',
        rating: 4.8,
        reviewCount: 24,
        isAvailable: true,
        createdAt: now.subtract(const Duration(days: 30)),
        updatedAt: now.subtract(const Duration(days: 1)),
      ),
      PropertyModel(
        id: '2',
        title: 'Cozy Suburban House',
        description: 'Charming 3-bedroom house in a quiet suburban neighborhood. Perfect for families with a large backyard, modern kitchen, and attached garage.',
        type: 'House',
        price: 3200,
        pricePeriod: 'monthly',
        address: '456 Oak Avenue',
        city: 'Austin',
        state: 'TX',
        country: 'USA',
        bedrooms: 3,
        bathrooms: 2,
        area: 1800,
        amenities: const ['WiFi', 'Air Conditioning', 'Parking', 'Garden', 'Fireplace'],
        imageUrls: const [
          'https://images.unsplash.com/photo-1570129477492-45c003edd2be?w=800',
          'https://images.unsplash.com/photo-1564013799919-ab600027ffc6?w=800',
          'https://images.unsplash.com/photo-1449844908441-8829872d2607?w=800',
        ],
        landlordId: 'landlord2',
        landlordName: 'Sarah Johnson',
        landlordPhone: '+1 (555) 987-6543',
        landlordEmail: 'sarah.johnson@email.com',
        rating: 4.6,
        reviewCount: 18,
        isAvailable: true,
        createdAt: now.subtract(const Duration(days: 15)),
        updatedAt: now.subtract(const Duration(days: 2)),
      ),
      PropertyModel(
        id: '3',
        title: 'Luxury Penthouse Suite',
        description: 'Stunning penthouse with panoramic city views, private terrace, and premium finishes throughout. Features include marble countertops, smart home technology, and concierge service.',
        type: 'Penthouse',
        price: 5500,
        pricePeriod: 'monthly',
        address: '789 Skyline Drive',
        city: 'Miami',
        state: 'FL',
        country: 'USA',
        bedrooms: 3,
        bathrooms: 3,
        area: 2200,
        amenities: const ['WiFi', 'Air Conditioning', 'Parking', 'Gym', 'Pool', 'Concierge', 'Terrace'],
        imageUrls: const [
          'https://images.unsplash.com/photo-1545324418-cc1a3fa10c00?w=800',
          'https://images.unsplash.com/photo-1560448204-e02f11c3d0e2?w=800',
          'https://images.unsplash.com/photo-1512917774080-9991f1c4c750?w=800',
        ],
        landlordId: 'landlord3',
        landlordName: 'Michael Davis',
        landlordPhone: '+1 (555) 456-7890',
        landlordEmail: 'michael.davis@email.com',
        rating: 4.9,
        reviewCount: 32,
        isAvailable: true,
        createdAt: now.subtract(const Duration(days: 7)),
        updatedAt: now.subtract(const Duration(hours: 12)),
      ),
      PropertyModel(
        id: '4',
        title: 'Beachfront Villa',
        description: 'Spectacular beachfront villa with direct beach access, infinity pool, and breathtaking ocean views. Perfect for vacation rentals with luxury amenities.',
        type: 'Villa',
        price: 8000,
        pricePeriod: 'monthly',
        address: '321 Ocean Boulevard',
        city: 'Malibu',
        state: 'CA',
        country: 'USA',
        bedrooms: 4,
        bathrooms: 4,
        area: 3000,
        amenities: const ['WiFi', 'Air Conditioning', 'Parking', 'Pool', 'Beach Access', 'Hot Tub'],
        imageUrls: const [
          'https://images.unsplash.com/photo-1613490493576-7fde63acd811?w=800',
          'https://images.unsplash.com/photo-1582268611958-ebfd161ef9cf?w=800',
          'https://images.unsplash.com/photo-1571896349842-33c89424de2d?w=800',
        ],
        landlordId: 'landlord4',
        landlordName: 'Emily Wilson',
        landlordPhone: '+1 (555) 321-0987',
        landlordEmail: 'emily.wilson@email.com',
        rating: 4.7,
        reviewCount: 41,
        isAvailable: true,
        createdAt: now.subtract(const Duration(days: 3)),
        updatedAt: now.subtract(const Duration(hours: 6)),
      ),
      PropertyModel(
        id: '5',
        title: 'City Center Loft',
        description: 'Industrial-style loft in the heart of the city with exposed brick walls, high ceilings, and modern amenities. Walking distance to restaurants and entertainment.',
        type: 'Loft',
        price: 2800,
        pricePeriod: 'monthly',
        address: '654 Industrial Way',
        city: 'Chicago',
        state: 'IL',
        country: 'USA',
        bedrooms: 1,
        bathrooms: 1,
        area: 900,
        amenities: const ['WiFi', 'Air Conditioning', 'Parking', 'Gym'],
        imageUrls: const [
          'https://images.unsplash.com/photo-1586023492125-27b2c045efd7?w=800',
          'https://images.unsplash.com/photo-1493809842364-78817add7ffb?w=800',
          'https://images.unsplash.com/photo-1505873242700-f289a29e1e0f?w=800',
        ],
        landlordId: 'landlord5',
        landlordName: 'David Brown',
        landlordPhone: '+1 (555) 654-3210',
        landlordEmail: 'david.brown@email.com',
        rating: 4.4,
        reviewCount: 16,
        isAvailable: true,
        createdAt: now.subtract(const Duration(days: 45)),
        updatedAt: now.subtract(const Duration(days: 5)),
      ),
    ];
  }

  static UserModel getMockUser({String role = 'tenant'}) {
    final now = DateTime.now();
    return UserModel(
      id: 'user123',
      firstName: role == 'landlord' ? 'John' : 'Jane',
      lastName: role == 'landlord' ? 'Landlord' : 'Tenant',
      email: role == 'landlord' ? 'john@landlord.com' : 'jane@tenant.com',
      role: role,
      phone: "+1 (555) 123-4567",
      profileImageUrl: "https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=400",
      createdAt: now.subtract(const Duration(days: 90)),
      updatedAt: now.subtract(const Duration(days: 1)),
    );
  }

  static List<PropertyModel> searchProperties({
    String query = '',
    String? propertyType,
    double? minPrice,
    double? maxPrice,
    int? bedrooms,
    int? bathrooms,
    String? city,
  }) {
    var properties = getMockProperties();

    if (query.isNotEmpty) {
      properties = properties.where((property) {
        return property.title.toLowerCase().contains(query.toLowerCase()) ||
               property.description.toLowerCase().contains(query.toLowerCase()) ||
               property.city.toLowerCase().contains(query.toLowerCase());
      }).toList();
    }

    if (propertyType != null && propertyType.isNotEmpty) {
      properties = properties.where((property) {
        return property.type.toLowerCase() == propertyType.toLowerCase();
      }).toList();
    }

    if (minPrice != null) {
      properties = properties.where((property) {
        return property.price >= minPrice;
      }).toList();
    }

    if (maxPrice != null) {
      properties = properties.where((property) {
        return property.price <= maxPrice;
      }).toList();
    }

    if (bedrooms != null) {
      properties = properties.where((property) {
        return property.bedrooms >= bedrooms;
      }).toList();
    }

    if (bathrooms != null) {
      properties = properties.where((property) {
        return property.bathrooms >= bathrooms;
      }).toList();
    }

    if (city != null && city.isNotEmpty) {
      properties = properties.where((property) {
        return property.city.toLowerCase().contains(city.toLowerCase());
      }).toList();
    }

    return properties;
  }
}

