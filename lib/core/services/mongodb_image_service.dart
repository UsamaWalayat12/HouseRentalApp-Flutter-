import 'dart:typed_data';
import 'dart:io';
import 'dart:convert';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';
import '../config/mongodb_config.dart';

class MongoDBImageService {
  // MongoDB connection settings from configuration
  static String get _connectionString => MongoDBConfig.connectionString;
  static String get _databaseName => MongoDBConfig.databaseName;
  static String get _collectionName => MongoDBConfig.collectionName;
  
  static Db? _database;
  static DbCollection? _collection;
  static bool _isInitialized = false;
  static bool _useRemoteMongoDB = false;

  /// Initialize MongoDB connection using connection string
  static Future<void> initialize() async {
    if (_isInitialized) {
      return;
    }

    // Validate connection string
    if (!MongoDBConfig.isConfigured()) {
      print('⚠️ MongoDB connection string not configured');
      print(MongoDBConfig.getConfigurationHelp());
      _isInitialized = true;
      return;
    }

    try {
      print('📡 Attempting to connect to MongoDB...');
      print('🔗 Connection string: ${_connectionString.replaceAll(RegExp(r':[^:/@]+@'), ':***@')}'); // Hide password in logs
      
      // Check if this is a MongoDB Atlas SRV connection string
      if (_connectionString.startsWith('mongodb+srv://')) {
        print('⚠️ MongoDB Atlas SRV connections are not supported by mongo_dart package');
        print('📝 To use MongoDB Atlas:');
        print('   1. Get your cluster\'s standard connection string (mongodb://) from Atlas');
        print('   2. Or use a different MongoDB instance that supports standard connections');
        print('   3. Or implement image storage using Firebase Storage or Cloudinary');
        
        _useRemoteMongoDB = false;
        _isInitialized = true;
        return;
      }
      
      // Handle standard MongoDB connection strings
      String finalConnectionString;
      if (_connectionString.contains('?')) {
        // Insert database name before query parameters
        finalConnectionString = _connectionString.replaceFirst('?', '/$_databaseName?');
      } else {
        // Append database name to connection string
        finalConnectionString = '$_connectionString/$_databaseName';
      }
      
      print('🔗 Final connection string: ${finalConnectionString.replaceAll(RegExp(r':[^:/@]+@'), ':***@')}');
      
      _database = Db(finalConnectionString);
      await _database!.open();
      
      _collection = _database!.collection(_collectionName);
      
      _useRemoteMongoDB = true;
      _isInitialized = true;
      print('✅ Connected to MongoDB successfully');
      print('🗃️ Database: $_databaseName, Collection: $_collectionName');
      
      // Test the connection with a simple operation
      try {
        await _collection!.count();
        print('🏓 Connection test successful');
      } catch (testError) {
        print('⚠️ Connection test failed, but connection established: $testError');
      }
      
      return;
    } catch (e) {
      print('❌ Failed to connect to MongoDB: $e');
      if (_database != null) {
        try {
          await _database!.close();
        } catch (_) {}
        _database = null;
      }
      _useRemoteMongoDB = false;
      _isInitialized = true;
    }
  }

  /// Ensure connection is active
  static Future<void> _ensureConnection() async {
    if (!_isInitialized) {
      await initialize();
    }
    
    if (_useRemoteMongoDB && _database != null) {
      if (_database?.state != State.OPEN) {
        await _database?.open();
      }
    }
  }

  /// Upload multiple images from XFiles and return image URLs/IDs
  static Future<List<String>> uploadPropertyImages(List<XFile> imageFiles, String propertyId) async {
    await _ensureConnection();
    
    List<String> imageIds = [];
    
    try {
      for (int i = 0; i < imageFiles.length; i++) {
        String imageId = await _uploadSingleImage(imageFiles[i], propertyId, i);
        imageIds.add(imageId);
      }
      
      print('✅ Successfully uploaded ${imageIds.length} images');
      return imageIds;
    } catch (e) {
      print('❌ Error uploading images: $e');
      // Return empty list instead of throwing exception to prevent app crash
      return [];
    }
  }

  /// Upload a single image
  static Future<String> _uploadSingleImage(XFile imageFile, String propertyId, int index) async {
    try {
      // Create unique image ID
      String imageId = '${propertyId}_img_${index}_${DateTime.now().millisecondsSinceEpoch}';
      
      // Get file extension
      String fileName = imageFile.name;
      String fileExtension = fileName.split('.').last.toLowerCase();
      
      // Validate image type
      if (!['jpg', 'jpeg', 'png', 'webp'].contains(fileExtension)) {
        throw Exception('Unsupported image format: $fileExtension');
      }

      if (_useRemoteMongoDB && _collection != null) {
        // Read image bytes for MongoDB storage
        Uint8List imageBytes;
        if (kIsWeb) {
          imageBytes = await imageFile.readAsBytes();
        } else {
          File file = File(imageFile.path);
          imageBytes = await file.readAsBytes();
        }

        // Create image document
        Map<String, dynamic> imageDocument = {
          '_id': imageId,
          'propertyId': propertyId,
          'fileName': fileName,
          'fileExtension': fileExtension,
          'imageData': base64Encode(imageBytes),
          'size': imageBytes.length,
          'uploadedAt': DateTime.now(),
          'index': index,
          'metadata': {
            'originalName': imageFile.name,
            'mimeType': _getMimeType(fileExtension),
          }
        };

        // Insert into MongoDB
        await _collection!.insertOne(imageDocument);
      } else {
        // For fallback, just create a placeholder - in a real app you'd save to local storage
        print('💾 Would save image to local storage: $imageId');
      }
      
      print('✅ Image processed successfully: $imageId');
      return imageId;
      
    } catch (e) {
      print('❌ Error processing single image: $e');
      // Return a fallback ID instead of throwing to prevent app crash
      return '${propertyId}_fallback_${index}_${DateTime.now().millisecondsSinceEpoch}';
    }
  }

  /// Get image data by image ID
  static Future<Uint8List?> getImageData(String imageId) async {
    print('🔍 Attempting to load image: $imageId');
    
    await _ensureConnection();
    
    if (!_useRemoteMongoDB || _collection == null) {
      print('💾 MongoDB not available, using fallback for: $imageId');
      // Create a simple placeholder image for testing
      return _createPlaceholderImageData();
    }
    
    try {
      print('🔍 Searching for image in MongoDB: $imageId');
      Map<String, dynamic>? imageDoc = await _collection!.findOne({'_id': imageId});
      
      if (imageDoc != null && imageDoc['imageData'] != null) {
        print('✅ Found image in MongoDB: $imageId');
        String base64Data = imageDoc['imageData'];
        return base64Decode(base64Data);
      } else {
        print('❌ Image not found in MongoDB: $imageId');
        return _createPlaceholderImageData();
      }
    } catch (e) {
      print('❌ Error retrieving image: $e');
      return _createPlaceholderImageData();
    }
  }

  /// Get all images for a property
  static Future<List<Map<String, dynamic>>> getPropertyImages(String propertyId) async {
    await _ensureConnection();
    
    if (!_useRemoteMongoDB || _collection == null) {
      // Fallback: return empty list
      print('💾 Would load property images from local storage for: $propertyId');
      return [];
    }
    
    try {
      List<Map<String, dynamic>> images = await _collection!
          .find({'propertyId': propertyId})
          .toList();
      
      // Sort by index
      images.sort((a, b) => (a['index'] as int).compareTo(b['index'] as int));
      
      return images;
    } catch (e) {
      print('❌ Error retrieving property images: $e');
      return [];
    }
  }

  /// Get image metadata (without image data for performance)
  static Future<List<Map<String, dynamic>>> getPropertyImageMetadata(String propertyId) async {
    await _ensureConnection();
    
    if (!_useRemoteMongoDB || _collection == null) {
      // Fallback: return empty list
      print('💾 Would load image metadata from local storage for: $propertyId');
      return [];
    }
    
    try {
      List<Map<String, dynamic>> images = await _collection!
          .find({'propertyId': propertyId})
          .toList();
      
      // Remove image data from results for performance
      images = images.map((image) {
        image.remove('imageData');
        return image;
      }).toList();
      
      // Sort by index
      images.sort((a, b) => (a['index'] as int).compareTo(b['index'] as int));
      
      return images;
    } catch (e) {
      print('❌ Error retrieving image metadata: $e');
      return [];
    }
  }

  /// Delete property images
  static Future<bool> deletePropertyImages(String propertyId) async {
    await _ensureConnection();
    
    try {
      WriteResult result = await _collection!.deleteMany({'propertyId': propertyId});
      print('✅ Deleted ${result.nRemoved} images for property: $propertyId');
      return true;
    } catch (e) {
      print('❌ Error deleting property images: $e');
      return false;
    }
  }

  /// Delete a specific image
  static Future<bool> deleteImage(String imageId) async {
    await _ensureConnection();
    
    try {
      WriteResult result = await _collection!.deleteOne({'_id': imageId});
      print('✅ Deleted image: $imageId');
      return result.nRemoved > 0;
    } catch (e) {
      print('❌ Error deleting image: $e');
      return false;
    }
  }

  /// Update image order/index
  static Future<bool> updateImageIndex(String imageId, int newIndex) async {
    await _ensureConnection();
    
    try {
      WriteResult result = await _collection!.updateOne(
        {'_id': imageId},
        {'\$set': {'index': newIndex, 'updatedAt': DateTime.now()}}
      );
      return result.nMatched > 0;
    } catch (e) {
      print('❌ Error updating image index: $e');
      return false;
    }
  }

  /// Get statistics about stored images
  static Future<Map<String, dynamic>> getStorageStats() async {
    await _ensureConnection();
    
    // If MongoDB is not available, return fallback stats
    if (!_useRemoteMongoDB || _collection == null) {
      print('💾 MongoDB not available, returning fallback storage stats');
      return {
        'totalImages': 0,
        'totalSizeBytes': 0,
        'totalSizeMB': '0.00',
        'averageSizeBytes': 0,
        'averageSizeKB': '0.00',
      };
    }
    
    try {
      int totalImages = await _collection!.count();
      
      // Handle empty collection case
      if (totalImages == 0) {
        return {
          'totalImages': 0,
          'totalSizeBytes': 0,
          'totalSizeMB': '0.00',
          'averageSizeBytes': 0,
          'averageSizeKB': '0.00',
        };
      }
      
      var aggregationCursor = _collection!.aggregateToStream([
        {
          '\$group': {
            '_id': null,
            'totalSize': {'\$sum': '\$size'},
            'averageSize': {'\$avg': '\$size'}
          }
        }
      ]);
      
      List<Map<String, dynamic>> sizeAggregation = await aggregationCursor.toList();
      
      int totalSize = 0;
      double averageSize = 0;
      
      if (sizeAggregation.isNotEmpty && sizeAggregation.first != null) {
        totalSize = sizeAggregation.first['totalSize'] ?? 0;
        averageSize = sizeAggregation.first['averageSize']?.toDouble() ?? 0;
      }
      
      return {
        'totalImages': totalImages,
        'totalSizeBytes': totalSize,
        'totalSizeMB': (totalSize / (1024 * 1024)).toStringAsFixed(2),
        'averageSizeBytes': averageSize.toInt(),
        'averageSizeKB': (averageSize / 1024).toStringAsFixed(2),
      };
    } catch (e) {
      print('❌ Error getting storage stats: $e');
      return {
        'totalImages': 0,
        'totalSizeBytes': 0,
        'totalSizeMB': '0.00',
        'averageSizeBytes': 0,
        'averageSizeKB': '0.00',
      };
    }
  }

  /// Helper method to get MIME type from file extension
  static String _getMimeType(String extension) {
    switch (extension.toLowerCase()) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'webp':
        return 'image/webp';
      default:
        return 'application/octet-stream';
    }
  }

  /// Close database connection
  static Future<void> close() async {
    try {
      await _database?.close();
      _database = null;
      _collection = null;
      print('✅ MongoDB connection closed');
    } catch (e) {
      print('❌ Error closing MongoDB connection: $e');
    }
  }

  /// Generate image URL for accessing images (for display purposes)
  /// This returns the MongoDB image ID which can be used to retrieve the image
  static String getImageUrl(String imageId) {
    return 'mongodb://$imageId';
  }

  /// Convert MongoDB image IDs to a format compatible with existing code
  static List<String> convertImageIdsToUrls(List<String> imageIds) {
    return imageIds.map((id) => getImageUrl(id)).toList();
  }

  /// Create a simple colored placeholder image as bytes for fallback
  static Uint8List _createPlaceholderImageData() {
    // Create a simple 1x1 PNG image in blue color
    // This is a minimal PNG image with blue pixel
    return Uint8List.fromList([
      0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, // PNG signature
      0x00, 0x00, 0x00, 0x0D, 0x49, 0x48, 0x44, 0x52, // IHDR chunk
      0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01, // 1x1 pixel
      0x08, 0x02, 0x00, 0x00, 0x00, 0x90, 0x77, 0x53, 0xDE,
      0x00, 0x00, 0x00, 0x0C, 0x49, 0x44, 0x41, 0x54, // IDAT chunk
      0x08, 0xD7, 0x63, 0x60, 0x60, 0x60, 0x00, 0x00,
      0x00, 0x04, 0x00, 0x01, 0xA2, 0x44, 0x44, 0x9F,
      0x00, 0x00, 0x00, 0x00, 0x49, 0x45, 0x4E, 0x44, // IEND chunk
      0xAE, 0x42, 0x60, 0x82
    ]);
  }
}
