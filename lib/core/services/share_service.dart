import 'package:share_plus/share_plus.dart';
import '../../shared/models/property_model.dart';

class ShareService {
  // Share property details
  static Future<void> shareProperty(PropertyModel property) async {
    try {
      final String shareText = _buildShareText(property);
      
      // Share with title and text
      await Share.share(
        shareText,
        subject: 'Check out this amazing property: ${property.title}',
      );
    } catch (e) {
      print('Error sharing property: $e');
      rethrow;
    }
  }

  // Share property with image
  static Future<void> sharePropertyWithImage(
    PropertyModel property, 
    String? imagePath
  ) async {
    try {
      final String shareText = _buildShareText(property);
      
      if (imagePath != null && imagePath.isNotEmpty) {
        await Share.shareXFiles(
          [XFile(imagePath)],
          text: shareText,
          subject: 'Check out this amazing property: ${property.title}',
        );
      } else {
        await shareProperty(property);
      }
    } catch (e) {
      print('Error sharing property with image: $e');
      // Fallback to text-only sharing
      await shareProperty(property);
    }
  }

  // Build formatted share text
  static String _buildShareText(PropertyModel property) {
    final StringBuffer buffer = StringBuffer();
    
    buffer.writeln('🏠 ${property.title}');
    buffer.writeln();
    buffer.writeln('💰 ${property.priceDisplay}');
    buffer.writeln('📍 ${property.fullAddress}');
    buffer.writeln();
    
    // Property features
    buffer.writeln('🏠 Features:');
    buffer.writeln('• ${property.bedrooms} Bedrooms');
    buffer.writeln('• ${property.bathrooms} Bathrooms');
    
    if (property.area != null && property.area! > 0) {
      buffer.writeln('• ${property.area!.toInt()} sqft');
    }
    
    if (property.rating != null && property.rating! > 0) {
      buffer.writeln('• ⭐ ${property.rating!.toStringAsFixed(1)} rating');
    }
    
    // Amenities
    if (property.amenities.isNotEmpty) {
      buffer.writeln();
      buffer.writeln('✨ Amenities:');
      for (String amenity in property.amenities.take(5)) {
        buffer.writeln('• $amenity');
      }
      if (property.amenities.length > 5) {
        buffer.writeln('• And ${property.amenities.length - 5} more...');
      }
    }
    
    // Description (truncated)
    if (property.description.isNotEmpty) {
      buffer.writeln();
      String description = property.description;
      if (description.length > 150) {
        description = '${description.substring(0, 150)}...';
      }
      buffer.writeln('📝 $description');
    }
    
    buffer.writeln();
    buffer.writeln('📱 Shared via Dream House App');
    
    return buffer.toString();
  }

  // Share property via different platforms
  static Future<void> sharePropertyTo(
    PropertyModel property, 
    SharePlatform platform
  ) async {
    try {
      final String shareText = _buildShareText(property);
      
      switch (platform) {
        case SharePlatform.whatsapp:
          await Share.share(shareText, subject: 'Property Share');
          break;
        case SharePlatform.email:
          await Share.share(
            shareText,
            subject: 'Check out this property: ${property.title}',
          );
          break;
        case SharePlatform.sms:
          await Share.share(shareText);
          break;
        default:
          await shareProperty(property);
      }
    } catch (e) {
      print('Error sharing property to platform: $e');
      // Fallback to general sharing
      await shareProperty(property);
    }
  }
}

enum SharePlatform {
  whatsapp,
  email,
  sms,
  general,
}
