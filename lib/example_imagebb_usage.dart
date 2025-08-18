import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'core/services/image_service.dart';
import 'core/services/imagebb_service.dart';

/// Example class showing how to use ImageBB for image uploads
/// This demonstrates how to switch from Firebase to ImageBB for image storage
class ImageBBUsageExample {
  
  /// Initialize ImageBB as the image storage provider
  static Future<void> initializeImageBB() async {
    // Initialize the Image Service with ImageBB provider
    await ImageService.initialize(provider: ImageStorageProvider.imagebb);
    
    // Check if the service is available
    bool isAvailable = await ImageService.isAvailable();
    if (isAvailable) {
      print('✅ ImageBB service is ready to use!');
      print('🖼️ Provider: ${ImageService.getProviderStatus()}');
    } else {
      print('❌ ImageBB service is not available');
    }
  }
  
  /// Example: Upload property images using ImageBB
  static Future<void> exampleUploadPropertyImages() async {
    try {
      // Initialize ImageBB first
      await initializeImageBB();
      
      // Mock image files (replace with actual XFile objects from image picker)
      List<XFile> imageFiles = []; // Get from ImagePicker in real app
      String propertyId = 'property_123';
      
      print('🏠 Starting property image upload...');
      
      // Upload images using the ImageService (which will use ImageBB)
      List<String> imageUrls = await ImageService.uploadPropertyImages(imageFiles, propertyId);
      
      if (imageUrls.isNotEmpty) {
        print('✅ Successfully uploaded ${imageUrls.length} images!');
        for (int i = 0; i < imageUrls.length; i++) {
          print('📷 Image ${i + 1}: ${imageUrls[i]}');
        }
      } else {
        print('❌ No images were uploaded');
      }
      
    } catch (e) {
      print('❌ Error uploading property images: $e');
    }
  }
  
  /// Example: Upload user avatar using ImageBB
  static Future<void> exampleUploadUserAvatar() async {
    try {
      // Initialize ImageBB first
      await initializeImageBB();
      
      // Mock avatar file (replace with actual XFile from image picker)
      XFile? avatarFile; // Get from ImagePicker in real app
      String userId = 'user_456';
      
      if (avatarFile != null) {
        print('👤 Starting user avatar upload...');
        
        // Upload avatar directly using ImageBBService
        String avatarUrl = await ImageBBService.uploadUserAvatar(avatarFile, userId);
        
        if (avatarUrl.isNotEmpty) {
          print('✅ Successfully uploaded avatar: $avatarUrl');
        } else {
          print('❌ Avatar upload failed');
        }
      }
      
    } catch (e) {
      print('❌ Error uploading user avatar: $e');
    }
  }
  
  /// Example: Check ImageBB service status
  static Future<void> exampleCheckServiceStatus() async {
    try {
      print('🔍 Checking ImageBB service status...');
      
      // Get detailed service status
      Map<String, dynamic> status = await ImageBBService.getServiceStatus();
      
      print('📊 ImageBB Service Status:');
      print('  • Service Name: ${status['serviceName']}');
      print('  • Available: ${status['isAvailable']}');
      print('  • Status: ${status['status']}');
      print('  • API Key: ${status['apiKey']}');
      print('  • Base URL: ${status['baseUrl']}');
      print('  • Last Checked: ${status['lastChecked']}');
      
      if (status['errorMessage'] != null) {
        print('  • Error: ${status['errorMessage']}');
      }
      
    } catch (e) {
      print('❌ Error checking service status: $e');
    }
  }
  
  /// Example: Get ImageBB statistics and features
  static void exampleGetServiceInfo() {
    try {
      print('📈 Getting ImageBB service information...');
      
      // Get upload stats and features
      Map<String, dynamic> stats = ImageBBService.getUploadStats();
      
      print('📊 ImageBB Service Info:');
      print('  • Provider: ${stats['provider']}');
      print('  • API Key: ${stats['apiKey']}');
      print('  • Base URL: ${stats['baseUrl']}');
      
      print('  • Features:');
      for (String feature in stats['features']) {
        print('    ✅ $feature');
      }
      
      print('  • Limitations:');
      for (String limitation in stats['limitations']) {
        print('    ⚠️ $limitation');
      }
      
    } catch (e) {
      print('❌ Error getting service info: $e');
    }
  }
  
  /// Complete example widget showing ImageBB integration
  static Widget buildImageUploadWidget() {
    return Scaffold(
      appBar: AppBar(
        title: Text('ImageBB Upload Example'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Icon(Icons.cloud_upload, size: 48, color: Colors.blue),
                    SizedBox(height: 16),
                    Text(
                      'ImageBB Image Storage',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Using API Key: 978057f1cb3808b692404052ac4c34fd',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () async {
                await initializeImageBB();
              },
              icon: Icon(Icons.settings),
              label: Text('Initialize ImageBB Service'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
            ),
            SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () async {
                await exampleCheckServiceStatus();
              },
              icon: Icon(Icons.info),
              label: Text('Check Service Status'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
            ),
            SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () {
                exampleGetServiceInfo();
              },
              icon: Icon(Icons.analytics),
              label: Text('Get Service Info'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Instructions:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              '1. Initialize ImageBB service first\n'
              '2. Use ImageService.uploadPropertyImages() for property images\n'
              '3. Use ImageBBService.uploadUserAvatar() for user avatars\n'
              '4. Check service status if uploads fail\n'
              '5. Store returned URLs in your database',
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}

/// How to use in your existing code:
/// 
/// 1. Initialize ImageBB service in your main.dart or initialization code:
/// ```dart
/// await ImageService.initialize(provider: ImageStorageProvider.imagebb);
/// ```
/// 
/// 2. Replace Firebase image uploads with:
/// ```dart
/// List<String> imageUrls = await ImageService.uploadPropertyImages(imageFiles, propertyId);
/// ```
/// 
/// 3. For user avatars:
/// ```dart
/// String avatarUrl = await ImageBBService.uploadUserAvatar(avatarFile, userId);
/// ```
/// 
/// 4. Store the returned URLs in your database (Firebase, MongoDB, etc.)
/// 
/// Note: ImageBB doesn't support listing or deleting images via API for free accounts.
/// You need to store image URLs in your database and manage them there.
