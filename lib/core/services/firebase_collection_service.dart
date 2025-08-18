import 'dart:typed_data';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Enhanced Firebase Storage service with collection-based image management
class FirebaseCollectionService {
  static final FirebaseStorage _storage = FirebaseStorage.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Collection names for different types of images
  static const String PROPERTY_IMAGES = 'property_images';
  static const String USER_AVATARS = 'user_avatars';
  static const String PROPERTY_DOCUMENTS = 'property_documents';
  static const String GALLERY_IMAGES = 'gallery_images';

  /// Upload multiple images to a specific collection
  static Future<List<String>> uploadImagesToCollection({
    required String collectionName,
    required List<XFile> imageFiles,
    required String documentId,
    Map<String, dynamic>? metadata,
  }) async {
    List<String> uploadedUrls = [];
    
    try {
      for (int i = 0; i < imageFiles.length; i++) {
        String downloadUrl = await _uploadSingleImageToCollection(
          collectionName: collectionName,
          imageFile: imageFiles[i],
          documentId: documentId,
          imageIndex: i,
          metadata: metadata,
        );
        
        if (downloadUrl.isNotEmpty) {
          uploadedUrls.add(downloadUrl);
        }
      }

      // Save image URLs to Firestore collection
      await _saveImageUrlsToFirestore(
        collectionName: collectionName,
        documentId: documentId,
        imageUrls: uploadedUrls,
        metadata: metadata,
      );

      print('✅ Successfully uploaded ${uploadedUrls.length} images to collection: $collectionName');
      return uploadedUrls;
    } catch (e) {
      print('❌ Error uploading images to collection $collectionName: $e');
      return [];
    }
  }

  /// Upload a single image to Firebase Storage collection
  static Future<String> _uploadSingleImageToCollection({
    required String collectionName,
    required XFile imageFile,
    required String documentId,
    required int imageIndex,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      // Create unique filename with timestamp
      String fileExtension = imageFile.name.split('.').last.toLowerCase();
      String fileName = '${documentId}_${imageIndex}_${DateTime.now().millisecondsSinceEpoch}.$fileExtension';
      String storagePath = '$collectionName/$documentId/$fileName';

      // Create Firebase Storage reference
      Reference storageRef = _storage.ref().child(storagePath);

      // Get file data
      Uint8List imageData;
      if (kIsWeb) {
        imageData = await imageFile.readAsBytes();
      } else {
        File file = File(imageFile.path);
        imageData = await file.readAsBytes();
      }

      // Create metadata
      SettableMetadata storageMetadata = SettableMetadata(
        contentType: _getMimeType(fileExtension),
        customMetadata: {
          'collection': collectionName,
          'documentId': documentId,
          'originalName': imageFile.name,
          'uploadedAt': DateTime.now().toIso8601String(),
          'imageIndex': imageIndex.toString(),
          'fileSize': imageData.length.toString(),
          ...?metadata?.map((key, value) => MapEntry(key, value.toString())),
        },
      );

      // Upload file
      TaskSnapshot uploadTask = await storageRef.putData(imageData, storageMetadata);
      
      // Get download URL
      String downloadURL = await uploadTask.ref.getDownloadURL();
      
      print('✅ Image uploaded to collection: $storagePath');
      return downloadURL;
      
    } catch (e) {
      print('❌ Error uploading image to collection: $e');
      return '';
    }
  }

  /// Save image URLs to Firestore for easy retrieval
  static Future<void> _saveImageUrlsToFirestore({
    required String collectionName,
    required String documentId,
    required List<String> imageUrls,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      await _firestore
          .collection('${collectionName}_metadata')
          .doc(documentId)
          .set({
        'imageUrls': imageUrls,
        'imageCount': imageUrls.length,
        'lastUpdated': FieldValue.serverTimestamp(),
        'collectionName': collectionName,
        'documentId': documentId,
        ...?metadata,
      }, SetOptions(merge: true));

      print('✅ Saved ${imageUrls.length} image URLs to Firestore collection: ${collectionName}_metadata');
    } catch (e) {
      print('❌ Error saving image URLs to Firestore: $e');
    }
  }

  /// Get all images from a collection for a specific document
  static Future<List<String>> getImagesFromCollection({
    required String collectionName,
    required String documentId,
  }) async {
    try {
      // First try to get from Firestore metadata
      DocumentSnapshot doc = await _firestore
          .collection('${collectionName}_metadata')
          .doc(documentId)
          .get();

      if (doc.exists && doc.data() != null) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        List<dynamic> imageUrls = data['imageUrls'] ?? [];
        List<String> urls = imageUrls.cast<String>();
        print('✅ Retrieved ${urls.length} images from Firestore for $documentId');
        return urls;
      }

      // Fallback: Get from Firebase Storage directly
      return await _getImagesFromStorageDirectory(collectionName, documentId);
    } catch (e) {
      print('❌ Error getting images from collection $collectionName: $e');
      return [];
    }
  }

  /// Get images directly from Firebase Storage directory
  static Future<List<String>> _getImagesFromStorageDirectory(
      String collectionName, String documentId) async {
    try {
      ListResult result = await _storage.ref().child('$collectionName/$documentId').listAll();
      
      List<String> imageUrls = [];
      for (Reference ref in result.items) {
        String url = await ref.getDownloadURL();
        imageUrls.add(url);
      }
      
      imageUrls.sort(); // Sort by filename (which includes timestamp)
      print('✅ Retrieved ${imageUrls.length} images from Storage for $documentId');
      return imageUrls;
    } catch (e) {
      print('❌ Error getting images from storage directory: $e');
      return [];
    }
  }

  /// Delete all images from a collection for a specific document
  static Future<bool> deleteImagesFromCollection({
    required String collectionName,
    required String documentId,
  }) async {
    try {
      // Delete from Firebase Storage
      ListResult result = await _storage.ref().child('$collectionName/$documentId').listAll();
      
      for (Reference ref in result.items) {
        await ref.delete();
      }
      
      // Delete metadata from Firestore
      await _firestore
          .collection('${collectionName}_metadata')
          .doc(documentId)
          .delete();
      
      print('✅ Deleted ${result.items.length} images from collection: $collectionName/$documentId');
      return true;
    } catch (e) {
      print('❌ Error deleting images from collection: $e');
      return false;
    }
  }

  /// Get collection statistics
  static Future<Map<String, dynamic>> getCollectionStats(String collectionName) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('${collectionName}_metadata')
          .get();

      int totalDocuments = snapshot.docs.length;
      int totalImages = 0;
      int totalSize = 0;

      for (QueryDocumentSnapshot doc in snapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        totalImages += (data['imageCount'] as int? ?? 0);
      }

      // Get storage size (approximate)
      ListResult result = await _storage.ref().child(collectionName).listAll();
      for (Reference ref in result.items) {
        try {
          FullMetadata metadata = await ref.getMetadata();
          totalSize += metadata.size ?? 0;
        } catch (e) {
          // Skip if can't get metadata
        }
      }

      return {
        'collectionName': collectionName,
        'totalDocuments': totalDocuments,
        'totalImages': totalImages,
        'totalSizeBytes': totalSize,
        'totalSizeMB': (totalSize / (1024 * 1024)).toStringAsFixed(2),
        'averageImagesPerDocument': totalDocuments > 0 ? (totalImages / totalDocuments).toStringAsFixed(1) : '0',
      };
    } catch (e) {
      print('❌ Error getting collection stats: $e');
      return {
        'collectionName': collectionName,
        'totalDocuments': 0,
        'totalImages': 0,
        'totalSizeBytes': 0,
        'totalSizeMB': '0.00',
        'averageImagesPerDocument': '0',
        'error': e.toString(),
      };
    }
  }

  /// List all available collections
  static Future<List<String>> listCollections() async {
    try {
      ListResult result = await _storage.ref().listAll();
      List<String> collections = result.prefixes.map((ref) => ref.name).toList();
      print('✅ Available collections: $collections');
      return collections;
    } catch (e) {
      print('❌ Error listing collections: $e');
      return [];
    }
  }

  /// Search images across collections
  static Future<List<Map<String, dynamic>>> searchImages(String searchTerm) async {
    try {
      List<Map<String, dynamic>> results = [];
      
      // Search in all metadata collections
      List<String> collections = [
        '${PROPERTY_IMAGES}_metadata',
        '${USER_AVATARS}_metadata',
        '${PROPERTY_DOCUMENTS}_metadata',
        '${GALLERY_IMAGES}_metadata',
      ];

      for (String collection in collections) {
        try {
          QuerySnapshot snapshot = await _firestore
              .collection(collection)
              .where('documentId', isGreaterThanOrEqualTo: searchTerm)
              .where('documentId', isLessThan: searchTerm + '\uf8ff')
              .limit(10)
              .get();

          for (QueryDocumentSnapshot doc in snapshot.docs) {
            Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
            results.add({
              'collection': collection.replaceAll('_metadata', ''),
              'documentId': data['documentId'],
              'imageUrls': data['imageUrls'],
              'imageCount': data['imageCount'],
              'lastUpdated': data['lastUpdated'],
            });
          }
        } catch (e) {
          // Skip collection if error
        }
      }

      return results;
    } catch (e) {
      print('❌ Error searching images: $e');
      return [];
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
      case 'bmp':
        return 'image/bmp';
      case 'tiff':
      case 'tif':
        return 'image/tiff';
      default:
        return 'image/jpeg';
    }
  }

  /// Check if Firebase Storage is available
  static Future<bool> isAvailable() async {
    try {
      await _storage.ref().list(ListOptions(maxResults: 1));
      return true;
    } catch (e) {
      print('❌ Firebase Storage not available: $e');
      return false;
    }
  }

  /// Initialize collections (create default folders)
  static Future<void> initializeCollections() async {
    try {
      List<String> collections = [
        PROPERTY_IMAGES,
        USER_AVATARS,
        PROPERTY_DOCUMENTS,
        GALLERY_IMAGES,
      ];

      for (String collection in collections) {
        // Create a placeholder file to initialize the folder
        Reference ref = _storage.ref().child('$collection/.keep');
        await ref.putString('This folder is for $collection');
        print('✅ Initialized collection: $collection');
      }
    } catch (e) {
      print('❌ Error initializing collections: $e');
    }
  }
}
