import 'core/services/mongodb_image_service.dart';

/// Simple test to verify MongoDB connection and create collections
void main() async {
  print('🔍 Testing MongoDB Connection...');
  
  try {
    // Initialize MongoDB service
    await MongoDBImageService.initialize();
    
    // Test connection by getting storage stats
    final stats = await MongoDBImageService.getStorageStats();
    print('✅ MongoDB Connected Successfully!');
    print('📊 Storage Stats: $stats');
    
    // Test image data retrieval (will create placeholder if none exists)
    final testData = await MongoDBImageService.getImageData('test_image_123');
    if (testData != null) {
      print('✅ Image data service working: ${testData.length} bytes');
    }
    
    print('🎉 MongoDB is ready for image storage!');
    
  } catch (e) {
    print('❌ MongoDB connection failed: $e');
    print('💡 Make sure MongoDB is running on localhost:27017');
  }
}
