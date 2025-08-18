import 'dart:io';
import 'core/services/mongodb_image_service.dart';

/// Simple debug script to test MongoDB connectivity and image functionality
void main() async {
  print('🔍 Starting MongoDB Image Service Debug Test');
  
  // Test 1: Initialize MongoDB service
  print('\n📡 Test 1: Initializing MongoDB Image Service...');
  try {
    await MongoDBImageService.initialize();
    print('✅ MongoDB Image Service initialized successfully');
  } catch (e) {
    print('❌ MongoDB Image Service initialization failed: $e');
  }
  
  // Test 2: Test image data retrieval
  print('\n💾 Test 2: Testing image data retrieval...');
  try {
    // Try to get a test image (this will create a placeholder if not found)
    final testImageData = await MongoDBImageService.getImageData('test_image_id');
    
    if (testImageData != null) {
      print('✅ Successfully retrieved image data: ${testImageData.length} bytes');
    } else {
      print('❌ No image data returned');
    }
  } catch (e) {
    print('❌ Error retrieving image data: $e');
  }
  
  // Test 3: Get storage statistics
  print('\n📊 Test 3: Getting storage statistics...');
  try {
    final stats = await MongoDBImageService.getStorageStats();
    print('✅ Storage stats: $stats');
  } catch (e) {
    print('❌ Error getting storage stats: $e');
  }
  
  print('\n🏁 Debug test completed');
  exit(0);
}
