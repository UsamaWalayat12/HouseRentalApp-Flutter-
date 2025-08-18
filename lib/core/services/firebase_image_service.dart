import 'dart:typed_data';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_collection_service.dart';

class FirebaseImageService {
  static final FirebaseStorage _storage = FirebaseStorage.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _imagesFolder = 'property_images';

  /// Upload multiple property images using collection-based service
  static Future<List<String>> uploadPropertyImages(List<XFile> imageFiles, String propertyId) async {
    try {
      print('🔥 Starting Firebase property image upload for property: $propertyId');
      print('📤 Uploading ${imageFiles.length} images...');
      
      // Use the collection service for better organization
      List<String> imageUrls = await FirebaseCollectionService.uploadImagesToCollection(
        collectionName: FirebaseCollectionService.PROPERTY_IMAGES,
        imageFiles: imageFiles,
        documentId: propertyId,
        metadata: {
          'propertyId': propertyId,
          'uploadType': 'property_main_images',
          'uploadedBy': 'flutter_app',
        },
      );
      
      print('✅ Successfully uploaded ${imageUrls.length} property images to Firebase Storage');
      return imageUrls;
    } catch (e) {
      print('❌ Error uploading property images to Firebase: $e');
      
      // Fallback to legacy upload method
      print('🔄 Trying fallback upload method...');
      return await _legacyUploadPropertyImages(imageFiles, propertyId);
    }
  }
  
  /// Legacy upload method as fallback
  static Future<List<String>> _legacyUploadPropertyImages(List<XFile> imageFiles, String propertyId) async {
    List<String> imageUrls = [];
    
    try {
      for (int i = 0; i < imageFiles.length; i++) {
        String imageUrl = await _uploadSingleImage(imageFiles[i], propertyId, i);
        if (imageUrl.isNotEmpty) {
          imageUrls.add(imageUrl);
        }
      }
      
      print('✅ Legacy upload: Successfully uploaded ${imageUrls.length} images to Firebase Storage');
      return imageUrls;
    } catch (e) {
      print('❌ Legacy upload: Error uploading images to Firebase: $e');
      return [];
    }
  }

  /// Upload a single image to Firebase Storage
  static Future<String> _uploadSingleImage(XFile imageFile, String propertyId, int index) async {
    try {
      // Create unique filename
      String fileName = '${propertyId}_img_${index}_${DateTime.now().millisecondsSinceEpoch}.${imageFile.name.split('.').last}';
      String filePath = '$_imagesFolder/$propertyId/$fileName';

      // Create reference to Firebase Storage location
      Reference storageRef = _storage.ref().child(filePath);

      // Get file data
      Uint8List imageData;
      if (kIsWeb) {
        imageData = await imageFile.readAsBytes();
      } else {
        File file = File(imageFile.path);
        imageData = await file.readAsBytes();
      }

      // Set metadata
      SettableMetadata metadata = SettableMetadata(
        contentType: _getMimeType(imageFile.name.split('.').last),
        customMetadata: {
          'propertyId': propertyId,
          'originalName': imageFile.name,
          'uploadedAt': DateTime.now().toIso8601String(),
          'index': index.toString(),
        },
      );

      // Upload file
      TaskSnapshot uploadTask = await storageRef.putData(imageData, metadata);
      
      // Get download URL
      String downloadURL = await uploadTask.ref.getDownloadURL();
      
      print('✅ Image uploaded successfully: $fileName');
      return downloadURL;
      
    } catch (e) {
      print('❌ Error uploading single image: $e');
      return '';
    }
  }

  /// Get all image URLs for a property using collection service
  static Future<List<String>> getPropertyImageUrls(String propertyId) async {
    try {
      print('🔍 Fetching images for property: $propertyId');
      
      // Try collection service first
      List<String> imageUrls = await FirebaseCollectionService.getImagesFromCollection(
        collectionName: FirebaseCollectionService.PROPERTY_IMAGES,
        documentId: propertyId,
      );
      
      if (imageUrls.isNotEmpty) {
        print('✅ Collection service: Retrieved ${imageUrls.length} image URLs for property: $propertyId');
        return imageUrls;
      }
      
      // Fallback to legacy method
      print('🔄 Collection service returned empty, trying legacy method...');
      return await _legacyGetPropertyImageUrls(propertyId);
    } catch (e) {
      print('❌ Error retrieving property images: $e');
      // Fallback to legacy method
      return await _legacyGetPropertyImageUrls(propertyId);
    }
  }
  
  /// Legacy method to get property images
  static Future<List<String>> _legacyGetPropertyImageUrls(String propertyId) async {
    try {
      ListResult result = await _storage.ref().child('$_imagesFolder/$propertyId').listAll();
      
      List<String> imageUrls = [];
      for (Reference ref in result.items) {
        String url = await ref.getDownloadURL();
        imageUrls.add(url);
      }
      
      // Sort by upload time (filename contains timestamp)
      imageUrls.sort();
      
      print('✅ Legacy method: Retrieved ${imageUrls.length} image URLs for property: $propertyId');
      return imageUrls;
    } catch (e) {
      print('❌ Legacy method: Error retrieving property images: $e');
      return [];
    }
  }

  /// Delete all images for a property
  static Future<bool> deletePropertyImages(String propertyId) async {
    try {
      ListResult result = await _storage.ref().child('$_imagesFolder/$propertyId').listAll();
      
      for (Reference ref in result.items) {
        await ref.delete();
      }
      
      print('✅ Deleted ${result.items.length} images for property: $propertyId');
      return true;
    } catch (e) {
      print('❌ Error deleting property images: $e');
      return false;
    }
  }

  /// Delete a specific image by URL
  static Future<bool> deleteImageByUrl(String imageUrl) async {
    try {
      Reference ref = _storage.refFromURL(imageUrl);
      await ref.delete();
      
      print('✅ Deleted image: ${ref.name}');
      return true;
    } catch (e) {
      print('❌ Error deleting image: $e');
      return false;
    }
  }

  /// Get storage statistics
  static Future<Map<String, dynamic>> getStorageStats(String propertyId) async {
    try {
      ListResult result = await _storage.ref().child('$_imagesFolder/$propertyId').listAll();
      
      int totalImages = result.items.length;
      int totalSize = 0;
      
      for (Reference ref in result.items) {
        FullMetadata metadata = await ref.getMetadata();
        totalSize += metadata.size ?? 0;
      }
      
      return {
        'totalImages': totalImages,
        'totalSizeBytes': totalSize,
        'totalSizeMB': (totalSize / (1024 * 1024)).toStringAsFixed(2),
        'averageSizeBytes': totalImages > 0 ? (totalSize / totalImages).round() : 0,
        'averageSizeKB': totalImages > 0 ? ((totalSize / totalImages) / 1024).toStringAsFixed(2) : '0.00',
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
      case 'gif':
        return 'image/gif';
      default:
        return 'image/jpeg';
    }
  }

  /// Upload images from XFile list (generic method)
  static Future<List<String>> uploadImagesFromXFiles(List<XFile> imageFiles) async {
    try {
      String tempId = DateTime.now().millisecondsSinceEpoch.toString();
      return await uploadPropertyImages(imageFiles, tempId);
    } catch (e) {
      print('❌ Error uploading images from XFiles: $e');
      return [];
    }
  }
  
  /// Get Firebase Storage statistics for monitoring
  static Future<Map<String, dynamic>> getFirebaseStorageStats() async {
    try {
      return await FirebaseCollectionService.getCollectionStats(FirebaseCollectionService.PROPERTY_IMAGES);
    } catch (e) {
      print('❌ Error getting Firebase Storage stats: $e');
      return {'error': e.toString()};
    }
  }
  
  /// Initialize Firebase Storage collections
  static Future<void> initializeStorageCollections() async {
    try {
      print('🔧 Initializing Firebase Storage collections...');
      await FirebaseCollectionService.initializeCollections();
      print('✅ Firebase Storage collections initialized');
    } catch (e) {
      print('❌ Error initializing Firebase Storage collections: $e');
    }
  }

  /// Check if Firebase Storage is available and properly configured
  static Future<bool> isAvailable() async {
    try {
      print('🔍 Checking Firebase Storage availability...');
      
      // Use the collection service availability check
      bool collectionServiceAvailable = await FirebaseCollectionService.isAvailable();
      
      if (collectionServiceAvailable) {
        print('✅ Firebase Storage is available and collection service is ready');
        return true;
      }
      
      // Fallback to basic availability check
      final root = _storage.ref();
      await root.list(ListOptions(maxResults: 1));
      
      print('✅ Firebase Storage is available (basic check)');
      return true;
    } catch (e) {
      print('❌ Firebase Storage not available: $e');
      
      // Check for specific error types
      String errorString = e.toString().toLowerCase();
      if (errorString.contains('cors')) {
        print('🚨 CORS Error detected. Please run setup_image_storage.ps1 to fix CORS configuration.');
      } else if (errorString.contains('permission') || errorString.contains('unauthorized')) {
        print('🚨 Permission Error detected. Please check Firebase Storage security rules.');
      } else if (errorString.contains('network') || errorString.contains('connection')) {
        print('🚨 Network Error detected. Please check your internet connection.');
      } else {
        print('🚨 Unknown Firebase Storage error. Please check Firebase console.');
      }
      
      return false;
    }
  }
  
  /// Get detailed status information for debugging
  static Future<Map<String, dynamic>> getDetailedStatus() async {
    Map<String, dynamic> status = {
      'isAvailable': false,
      'collections': {},
      'errorMessage': null,
      'lastChecked': DateTime.now().toIso8601String(),
    };
    
    try {
      // Check basic availability
      status['isAvailable'] = await isAvailable();
      
      if (status['isAvailable']) {
        // Get collection statistics
        status['collections'] = {
          'property_images': await FirebaseCollectionService.getCollectionStats(FirebaseCollectionService.PROPERTY_IMAGES),
          'user_avatars': await FirebaseCollectionService.getCollectionStats(FirebaseCollectionService.USER_AVATARS),
          'property_documents': await FirebaseCollectionService.getCollectionStats(FirebaseCollectionService.PROPERTY_DOCUMENTS),
          'gallery_images': await FirebaseCollectionService.getCollectionStats(FirebaseCollectionService.GALLERY_IMAGES),
        };
      }
    } catch (e) {
      status['errorMessage'] = e.toString();
      print('❌ Error getting detailed Firebase Storage status: $e');
    }
    
    return status;
  }
}
