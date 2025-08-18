# ImageBB Integration for Flutter App

## Overview

This document explains how to use the ImageBB API integration in your Flutter rent-a-home application. ImageBB provides free image hosting services and is a great alternative to Firebase Storage for image uploads.

## API Key Configuration

Your ImageBB API key is already configured in the system:
```
API Key: 978057f1cb3808b692404052ac4c34fd
```

This key is hardcoded in the `ImageBBService` class for your convenience.

## Files Created/Modified

### New Files
1. **`lib/core/services/imagebb_service.dart`** - Main ImageBB service implementation
2. **`lib/example_imagebb_usage.dart`** - Example usage and demonstration code
3. **`IMAGEBB_INTEGRATION.md`** - This documentation file

### Modified Files
1. **`lib/core/services/image_service.dart`** - Updated to include ImageBB as a provider option

## How to Use ImageBB

### 1. Initialize the Service

In your main.dart or app initialization code:

```dart
import 'core/services/image_service.dart';

// Initialize ImageBB as the image storage provider
await ImageService.initialize(provider: ImageStorageProvider.imagebb);

// Check if service is available
bool isAvailable = await ImageService.isAvailable();
if (isAvailable) {
  print('✅ ImageBB service ready!');
} else {
  print('❌ ImageBB service not available');
}
```

### 2. Upload Property Images

```dart
// Upload multiple property images
List<XFile> imageFiles = []; // Get from ImagePicker
String propertyId = 'property_123';

List<String> imageUrls = await ImageService.uploadPropertyImages(imageFiles, propertyId);

// Store the URLs in your database
for (String url in imageUrls) {
  print('Image URL: $url');
  // Save to Firebase/MongoDB/your database
}
```

### 3. Upload User Avatar

```dart
import 'core/services/imagebb_service.dart';

XFile avatarFile; // Get from ImagePicker
String userId = 'user_456';

String avatarUrl = await ImageBBService.uploadUserAvatar(avatarFile, userId);
if (avatarUrl.isNotEmpty) {
  print('Avatar uploaded: $avatarUrl');
  // Save URL to user profile in database
}
```

### 4. Upload Document Images

```dart
List<XFile> documentFiles = []; // Get from file picker
String userId = 'user_789';
String documentType = 'identity'; // or 'income', etc.

List<String> documentUrls = await ImageBBService.uploadDocumentImages(
  documentFiles, 
  userId, 
  documentType
);
```

## Service Status and Monitoring

### Check Service Status

```dart
Map<String, dynamic> status = await ImageBBService.getServiceStatus();
print('Service Available: ${status['isAvailable']}');
print('Last Checked: ${status['lastChecked']}');
```

### Get Service Information

```dart
Map<String, dynamic> info = ImageBBService.getUploadStats();
print('Provider: ${info['provider']}');
print('Features: ${info['features']}');
print('Limitations: ${info['limitations']}');
```

## ImageBB Features and Limitations

### ✅ Features
- Free image hosting
- No expiration (with account)
- Direct image URLs
- HTTPS support
- API-based uploads
- Supports JPG, PNG, BMP, GIF, TIF, WEBP formats
- Max file size: 32MB per image

### ⚠️ Limitations
- Rate limited (check ImageBB terms)
- No built-in analytics
- **Cannot delete images via API** (free accounts)
- **Cannot list images by folder via API**
- Must store URLs in your database for management

## Database Integration

Since ImageBB doesn't support listing or deleting images via API, you must store image URLs in your database:

### Firebase Firestore Example
```dart
// Save property images to Firestore
await FirebaseFirestore.instance
    .collection('properties')
    .doc(propertyId)
    .set({
  'images': imageUrls, // List of ImageBB URLs
  'updatedAt': FieldValue.serverTimestamp(),
}, SetOptions(merge: true));
```

### MongoDB Example
```dart
// Save to MongoDB
await propertyCollection.updateOne(
  where.eq('_id', ObjectId.fromHexString(propertyId)),
  modify.set('images', imageUrls).set('updatedAt', DateTime.now()),
);
```

## Switching from Firebase to ImageBB

### Replace Firebase Storage Calls

**Before (Firebase):**
```dart
// Old Firebase code
await FirebaseImageService.uploadPropertyImages(imageFiles, propertyId);
```

**After (ImageBB):**
```dart
// New ImageBB code
await ImageService.initialize(provider: ImageStorageProvider.imagebb);
await ImageService.uploadPropertyImages(imageFiles, propertyId);
```

### Update Your Property Model

Make sure your property model stores image URLs:

```dart
class Property {
  final String id;
  final List<String> imageUrls; // Store ImageBB URLs here
  final String title;
  // ... other fields
  
  Property({
    required this.id,
    required this.imageUrls,
    required this.title,
  });
}
```

## Error Handling

Always wrap ImageBB calls in try-catch blocks:

```dart
try {
  List<String> urls = await ImageService.uploadPropertyImages(imageFiles, propertyId);
  // Handle success
} catch (e) {
  print('Upload failed: $e');
  // Show user-friendly error message
  // Maybe fallback to local storage or retry
}
```

## Integration with Existing Pages

### Property Add/Edit Pages

Update your property upload logic:

```dart
// In your add_property_page.dart or edit_property_page.dart
Future<void> _uploadImages() async {
  try {
    // Initialize ImageBB
    await ImageService.initialize(provider: ImageStorageProvider.imagebb);
    
    // Upload images
    List<String> imageUrls = await ImageService.uploadPropertyImages(
      _selectedImages, 
      _propertyId
    );
    
    // Save to your database
    await _savePropertyToDatabase(imageUrls);
    
  } catch (e) {
    // Handle error
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Failed to upload images: $e')),
    );
  }
}
```

### Profile Pages

Update avatar upload in profile pages:

```dart
// In your edit_profile_page.dart
Future<void> _uploadAvatar() async {
  if (_selectedAvatar != null) {
    try {
      String avatarUrl = await ImageBBService.uploadUserAvatar(
        _selectedAvatar!, 
        _currentUserId
      );
      
      // Update user profile in database
      await _updateUserProfile(avatarUrl);
      
    } catch (e) {
      // Handle error
      print('Avatar upload failed: $e');
    }
  }
}
```

## Testing the Integration

Use the provided example code to test:

```dart
// Run these examples to test the integration
await ImageBBUsageExample.initializeImageBB();
await ImageBBUsageExample.exampleCheckServiceStatus();
ImageBBUsageExample.exampleGetServiceInfo();
```

## Troubleshooting

### Common Issues

1. **Upload fails with network error**
   - Check internet connection
   - Verify API key is correct
   - Check ImageBB service status

2. **Images not displaying**
   - Verify URLs are stored correctly in database
   - Check if URLs are accessible in browser
   - Ensure proper CORS configuration if using web

3. **Rate limiting issues**
   - Implement retry logic with exponential backoff
   - Consider upgrading ImageBB account for higher limits
   - Batch uploads with delays between requests

### Debug Information

Enable debug logging to troubleshoot:

```dart
// The service already includes detailed logging
// Check your Flutter console for detailed upload progress
```

## Security Considerations

- API key is hardcoded for your convenience, but consider moving to environment variables for production
- Always validate file types and sizes before upload
- Implement proper user authentication before allowing uploads
- Consider implementing upload quotas per user

## Migration Guide

If migrating from Firebase Storage:

1. Initialize ImageBB service in your app
2. Update all image upload calls to use `ImageService`
3. Modify your database schema to store image URLs
4. Update your UI to load images from URLs instead of Firebase
5. Test thoroughly before deploying

## Support

For ImageBB API documentation and support:
- API Documentation: https://api.imgbb.com/
- ImageBB Website: https://imgbb.com/
- Terms of Service: https://imgbb.com/terms

---

**Note**: This integration is now ready to use in your Flutter app. The API key provided should work immediately for testing and development. For production use, consider creating your own ImageBB account for better control and monitoring.
