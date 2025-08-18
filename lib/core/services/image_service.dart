import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'firebase_image_service.dart';
import 'firebase_collection_service.dart';
import 'imagebb_service.dart';

enum ImageStorageProvider { firebase, cloudinary, imagebb, none }

class ImageService {
  static ImageStorageProvider _currentProvider = ImageStorageProvider.none; // Temporarily disabled Firebase until enabled
  
  // Cloudinary configuration (update with your actual values)
  static const String _cloudinaryCloudName = 'your_cloud_name';
  static const String _cloudinaryUploadPreset = 'your_upload_preset';
  static CloudinaryPublic? _cloudinary;

  /// Initialize the image service with preferred provider
  static Future<void> initialize({ImageStorageProvider provider = ImageStorageProvider.none}) async {
    _currentProvider = provider;
    
    if (_currentProvider == ImageStorageProvider.cloudinary) {
      _cloudinary = CloudinaryPublic(_cloudinaryCloudName, _cloudinaryUploadPreset);
    }
    
    print('🖼️ Image Service initialized with provider: ${_currentProvider.toString()}');
  }

  /// Upload multiple images and return URLs/IDs
  static Future<List<String>> uploadPropertyImages(List<XFile> imageFiles, String propertyId) async {
    switch (_currentProvider) {
      case ImageStorageProvider.firebase:
        try {
          return await FirebaseImageService.uploadPropertyImages(imageFiles, propertyId);
        } catch (e) {
          print('❌ Firebase upload failed, falling back to placeholder URLs: $e');
          return _generatePlaceholderUrls(imageFiles, propertyId);
        }
        
      case ImageStorageProvider.cloudinary:
        try {
          return await _uploadToCloudinary(imageFiles, propertyId);
        } catch (e) {
          print('❌ Cloudinary upload failed, falling back to placeholder URLs: $e');
          return _generatePlaceholderUrls(imageFiles, propertyId);
        }
        
      case ImageStorageProvider.imagebb:
        try {
          return await ImageBBService.uploadPropertyImages(imageFiles, propertyId);
        } catch (e) {
          print('❌ ImageBB upload failed, falling back to placeholder URLs: $e');
          return _generatePlaceholderUrls(imageFiles, propertyId);
        }
        
      case ImageStorageProvider.none:
      default:
        print('💾 No image storage provider configured, using placeholder URLs');
        return _generatePlaceholderUrls(imageFiles, propertyId);
    }
  }

  /// Get all image URLs for a property
  static Future<List<String>> getPropertyImageUrls(String propertyId) async {
    switch (_currentProvider) {
      case ImageStorageProvider.firebase:
        try {
          return await FirebaseImageService.getPropertyImageUrls(propertyId);
        } catch (e) {
          print('❌ Firebase fetch failed: $e');
          return [];
        }
        
      case ImageStorageProvider.cloudinary:
        // Cloudinary doesn't have a direct way to list images by folder
        // You would need to store URLs in your database
        print('📝 Cloudinary image listing requires database storage of URLs');
        return [];
        
      case ImageStorageProvider.imagebb:
        // ImageBB doesn't have a direct way to list images by folder
        // You would need to store URLs in your database
        print('📝 ImageBB image listing requires database storage of URLs');
        return [];
        
      case ImageStorageProvider.none:
      default:
        return [];
    }
  }

  /// Delete all images for a property
  static Future<bool> deletePropertyImages(String propertyId) async {
    switch (_currentProvider) {
      case ImageStorageProvider.firebase:
        return await FirebaseImageService.deletePropertyImages(propertyId);
        
      case ImageStorageProvider.cloudinary:
        print('📝 Cloudinary image deletion requires individual image public IDs');
        return false;
        
      case ImageStorageProvider.imagebb:
        print('📝 ImageBB image deletion is not supported via API for free accounts');
        return false;
        
      case ImageStorageProvider.none:
      default:
        return true;
    }
  }

  /// Get storage statistics
  static Future<Map<String, dynamic>> getStorageStats([String? propertyId]) async {
    switch (_currentProvider) {
      case ImageStorageProvider.firebase:
        if (propertyId != null) {
          return await FirebaseImageService.getStorageStats(propertyId);
        } else {
          // Get stats for all properties - simplified version
          return {
            'totalImages': 0,
            'totalSizeBytes': 0,
            'totalSizeMB': '0.00',
            'averageSizeBytes': 0,
            'averageSizeKB': '0.00',
          };
        }
        
      case ImageStorageProvider.imagebb:
        return ImageBBService.getUploadStats();
        
      case ImageStorageProvider.cloudinary:
      case ImageStorageProvider.none:
      default:
        return {
          'totalImages': 0,
          'totalSizeBytes': 0,
          'totalSizeMB': '0.00',
          'averageSizeBytes': 0,
          'averageSizeKB': '0.00',
        };
    }
  }

  /// Check if the current provider is available
  static Future<bool> isAvailable() async {
    switch (_currentProvider) {
      case ImageStorageProvider.firebase:
        try {
          bool available = await FirebaseImageService.isAvailable();
          if (!available) {
            print('🚨 Firebase Storage not available. This might be due to:');
            print('   • CORS configuration issues');
            print('   • Firebase Storage security rules');
            print('   • Network connectivity problems');
            print('   📖 See FIREBASE_CORS_FIX.md for solutions');
          }
          return available;
        } catch (e) {
          print('❌ Firebase Storage check failed: $e');
          return false;
        }
        
      case ImageStorageProvider.cloudinary:
        bool available = _cloudinary != null;
        if (!available) {
          print('❌ Cloudinary not configured. Update constants in image_service.dart');
        }
        return available;
        
      case ImageStorageProvider.imagebb:
        try {
          bool available = await ImageBBService.isAvailable();
          if (!available) {
            print('❌ ImageBB service not available. Check API key and network connection.');
          }
          return available;
        } catch (e) {
          print('❌ ImageBB service check failed: $e');
          return false;
        }
        
      case ImageStorageProvider.none:
      default:
        print('ℹ️ No image storage provider configured');
        return false;
    }
  }

  /// Get current provider status
  static String getProviderStatus() {
    switch (_currentProvider) {
      case ImageStorageProvider.firebase:
        return '🔥 Firebase Storage';
      case ImageStorageProvider.cloudinary:
        return '☁️ Cloudinary';
      case ImageStorageProvider.imagebb:
        return '🖼️ ImageBB';
      case ImageStorageProvider.none:
        return '❌ No Provider Configured';
    }
  }

  /// Upload images to Cloudinary
  static Future<List<String>> _uploadToCloudinary(List<XFile> imageFiles, String propertyId) async {
    if (_cloudinary == null) {
      throw Exception('Cloudinary not initialized');
    }

    List<String> imageUrls = [];
    
    for (int i = 0; i < imageFiles.length; i++) {
      try {
        Uint8List imageData = await imageFiles[i].readAsBytes();
        
        CloudinaryResponse response = await _cloudinary!.uploadFile(
          CloudinaryFile.fromBytesData(
            imageData,
            identifier: '${propertyId}_img_$i',
            folder: 'property_images/$propertyId',
          ),
        );
        
        if (response.secureUrl != null) {
          imageUrls.add(response.secureUrl!);
          print('✅ Uploaded to Cloudinary: ${response.publicId}');
        }
      } catch (e) {
        print('❌ Error uploading image $i to Cloudinary: $e');
      }
    }
    
    return imageUrls;
  }

  /// Generate placeholder URLs for fallback
  static List<String> _generatePlaceholderUrls(List<XFile> imageFiles, String propertyId) {
    return imageFiles.asMap().entries.map((entry) {
      int index = entry.key;
      return 'placeholder://${propertyId}_img_${index}_${DateTime.now().millisecondsSinceEpoch}';
    }).toList();
  }

  // === NEW COLLECTION-BASED METHODS ===

  /// Upload property images to Firebase Collections
  static Future<List<String>> uploadPropertyImagesToCollection(
      List<XFile> imageFiles, String propertyId) async {
    return await FirebaseCollectionService.uploadImagesToCollection(
      collectionName: FirebaseCollectionService.PROPERTY_IMAGES,
      imageFiles: imageFiles,
      documentId: propertyId,
      metadata: {
        'propertyId': propertyId,
        'uploadedBy': 'ImageService',
        'category': 'property',
      },
    );
  }

  /// Get property images from Firebase Collection
  static Future<List<String>> getPropertyImagesFromCollection(String propertyId) async {
    return await FirebaseCollectionService.getImagesFromCollection(
      collectionName: FirebaseCollectionService.PROPERTY_IMAGES,
      documentId: propertyId,
    );
  }

  /// Upload user avatar to Firebase Collections
  static Future<List<String>> uploadUserAvatar(List<XFile> imageFiles, String userId) async {
    return await FirebaseCollectionService.uploadImagesToCollection(
      collectionName: FirebaseCollectionService.USER_AVATARS,
      imageFiles: imageFiles,
      documentId: userId,
      metadata: {
        'userId': userId,
        'uploadedBy': 'ImageService',
        'category': 'avatar',
      },
    );
  }

  /// Get user avatar from Firebase Collection
  static Future<List<String>> getUserAvatar(String userId) async {
    return await FirebaseCollectionService.getImagesFromCollection(
      collectionName: FirebaseCollectionService.USER_AVATARS,
      documentId: userId,
    );
  }

  /// Upload property documents to Firebase Collections
  static Future<List<String>> uploadPropertyDocuments(
      List<XFile> documentFiles, String propertyId) async {
    return await FirebaseCollectionService.uploadImagesToCollection(
      collectionName: FirebaseCollectionService.PROPERTY_DOCUMENTS,
      imageFiles: documentFiles,
      documentId: propertyId,
      metadata: {
        'propertyId': propertyId,
        'uploadedBy': 'ImageService',
        'category': 'document',
      },
    );
  }

  /// Get property documents from Firebase Collection
  static Future<List<String>> getPropertyDocuments(String propertyId) async {
    return await FirebaseCollectionService.getImagesFromCollection(
      collectionName: FirebaseCollectionService.PROPERTY_DOCUMENTS,
      documentId: propertyId,
    );
  }

  /// Upload gallery images to Firebase Collections
  static Future<List<String>> uploadGalleryImages(
      List<XFile> imageFiles, String galleryId) async {
    return await FirebaseCollectionService.uploadImagesToCollection(
      collectionName: FirebaseCollectionService.GALLERY_IMAGES,
      imageFiles: imageFiles,
      documentId: galleryId,
      metadata: {
        'galleryId': galleryId,
        'uploadedBy': 'ImageService',
        'category': 'gallery',
      },
    );
  }

  /// Get gallery images from Firebase Collection
  static Future<List<String>> getGalleryImages(String galleryId) async {
    return await FirebaseCollectionService.getImagesFromCollection(
      collectionName: FirebaseCollectionService.GALLERY_IMAGES,
      documentId: galleryId,
    );
  }

  /// Delete images from any collection
  static Future<bool> deleteImagesFromCollection(String collectionName, String documentId) async {
    return await FirebaseCollectionService.deleteImagesFromCollection(
      collectionName: collectionName,
      documentId: documentId,
    );
  }

  /// Get collection statistics
  static Future<Map<String, dynamic>> getCollectionStats(String collectionName) async {
    return await FirebaseCollectionService.getCollectionStats(collectionName);
  }

  /// List all available collections
  static Future<List<String>> listAllCollections() async {
    return await FirebaseCollectionService.listCollections();
  }

  /// Search images across all collections
  static Future<List<Map<String, dynamic>>> searchAllImages(String searchTerm) async {
    return await FirebaseCollectionService.searchImages(searchTerm);
  }

  /// Initialize Firebase Collections
  static Future<void> initializeFirebaseCollections() async {
    await FirebaseCollectionService.initializeCollections();
  }

  /// Check if Firebase Collection service is available
  static Future<bool> isFirebaseCollectionAvailable() async {
    return await FirebaseCollectionService.isAvailable();
  }
}
