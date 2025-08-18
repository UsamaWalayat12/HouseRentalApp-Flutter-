import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'firebase_service.dart';
import 'payment_service.dart';
import 'booking_service.dart';

class AnalyticsService {
  static Future<Map<String, dynamic>> getLandlordAnalytics(String landlordId) async {
    try {
      // Get basic analytics from Firebase
      final basicAnalytics = await FirebaseService.getLandlordAnalytics(landlordId);
      
      // Get payment statistics
      final paymentStats = await PaymentService.getPaymentStatistics(landlordId);
      
      // Get booking statistics
      final bookingStats = await BookingService.getBookingStatistics(landlordId);
      
      // Get monthly revenue data
      final monthlyRevenue = await PaymentService.getMonthlyRevenue(landlordId, 6);
      
      // Calculate occupancy rate
      final occupancyRate = bookingStats['confirmedBookings'] > 0
          ? (bookingStats['confirmedBookings'] / bookingStats['totalBookings'] * 100).toStringAsFixed(1)
          : '0';

      // Get recent activities
      final recentActivities = await _getRecentActivities(landlordId);

      // Get top performing properties
      final topProperties = await _getTopPerformingProperties(landlordId);

      return {
        'totalProperties': basicAnalytics['propertiesCount'],
        'activeBookings': bookingStats['confirmedBookings'],
        'totalRevenue': paymentStats['totalRevenue'],
        'totalRevenueChange': '+15.2%', // TODO: Calculate actual change
        'averageBooking': paymentStats['averagePaymentAmount'],
        'averageBookingChange': '+8.5%', // TODO: Calculate actual change
        'occupancyRate': '$occupancyRate%',
        'occupancyRateChange': '+5.2%', // TODO: Calculate actual change
        'totalBookings': bookingStats['totalBookings'],
        'totalBookingsChange': '+12.0%', // TODO: Calculate actual change
        'monthlyRevenue': monthlyRevenue,
        'topPerformingProperties': topProperties,
        'recentActivities': recentActivities,
      };
    } catch (e) {
      throw Exception('Failed to get landlord analytics: ${e.toString()}');
    }
  }

  static Future<List<Map<String, dynamic>>> _getRecentActivities(String landlordId) async {
    try {
      final activitiesQuery = await FirebaseFirestore.instance
          .collection('activities')
          .where('landlordId', isEqualTo: landlordId)
          .orderBy('timestamp', descending: true)
          .limit(5)
          .get();

      return activitiesQuery.docs.map((doc) {
        final data = doc.data();
        return {
          'type': data['type'] ?? 'general',
          'description': data['description'] ?? data['title'] ?? 'Activity',
          'timestamp': data['timestamp']?.toDate()?.toIso8601String() ?? DateTime.now().toIso8601String(),
          'title': data['title'] ?? '',
          'subtitle': data['subtitle'] ?? '',
          'time': _getTimeAgo(data['timestamp']?.toDate() ?? DateTime.now()),
          'icon': _getActivityIcon(data['type'] ?? ''),
          'color': _getActivityColor(data['type'] ?? ''),
        };
      }).toList();
    } catch (e) {
      // Return empty list if activities collection doesn't exist yet
      return [];
    }
  }

  static Future<List<Map<String, dynamic>>> _getTopPerformingProperties(String landlordId) async {
    try {
      final propertiesStream = FirebaseService.getPropertiesByLandlord(landlordId);
      final properties = await propertiesStream.first;
      
      // Sort properties by revenue or rating
      properties.sort((a, b) => (b.rating ?? 0).compareTo(a.rating ?? 0));
      
      return properties.take(3).map((property) {
        return {
          'name': property.title,
          'revenue': (property.price * 0.8), // Return as double, not string
          'occupancy': (property.rating ?? 0) * 20, // Return as double, not string
          'bookings': (property.reviewCount ?? 0), // Using review count as a proxy for bookings
          'rating': property.rating ?? 0.0,
          'imageUrl': property.imageUrls.isNotEmpty ? property.imageUrls.first : null,
        };
      }).toList();
    } catch (e) {
      return [];
    }
  }

  static String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays} days ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hours ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minutes ago';
    } else {
      return 'just now';
    }
  }

  static IconData _getActivityIcon(String type) {
    switch (type.toLowerCase()) {
      case 'booking':
        return Icons.calendar_today;
      case 'payment':
        return Icons.payment;
      case 'review':
        return Icons.star;
      case 'property':
        return Icons.home;
      default:
        return Icons.notifications;
    }
  }

  static Color _getActivityColor(String type) {
    switch (type.toLowerCase()) {
      case 'booking':
        return Colors.blue;
      case 'payment':
        return Colors.green;
      case 'review':
        return Colors.amber;
      case 'property':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }
} 