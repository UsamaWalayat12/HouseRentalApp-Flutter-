import 'dart:typed_data';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;

class ImageBBService {
  // ImageBB API configuration
  static const String _baseUrl = 'https://api.imgbb.com/1/upload';
  static const String _apiKey = '978057f1cb3808b692404052ac4c34fd';
  
  /// Upload a single image to ImageBB
  static Future<String> uploadSingleImage(XFile imageFile, {String? imageName}) async {
    try {
      print('🖼️ Starting ImageBB upload for: ${imageFile.name}');
      
      // Read image data
      Uint8List imageData = await imageFile.readAsBytes();
      
      print('📊 Original image size: ${(imageData.length / 1024).toStringAsFixed(2)}KB');
      
      // Check if image needs compression (if > 5MB, compress it)
      if (imageData.length > 5 * 1024 * 1024) {
        print('🗜️ Image is large (${(imageData.length / (1024 * 1024)).toStringAsFixed(2)}MB), compressing...');
        imageData = await _compressImage(imageData, imageFile.name);
        print('✅ Image compressed to: ${(imageData.length / 1024).toStringAsFixed(2)}KB');
      }
      
      // Check image size (max 32MB after compression)
      if (imageData.length > 32 * 1024 * 1024) {
        throw Exception('Image size exceeds 32MB limit even after compression. Size: ${(imageData.length / (1024 * 1024)).toStringAsFixed(2)}MB');
      }
      
      // Validate image format by checking file extension
      String fileName = imageFile.name.toLowerCase();
      List<String> supportedFormats = ['.jpg', '.jpeg', '.png', '.gif', '.bmp', '.webp', '.tif', '.tiff'];
      bool isValidFormat = supportedFormats.any((ext) => fileName.endsWith(ext));
      
      if (!isValidFormat) {
        throw Exception('Unsupported image format. File: ${imageFile.name}. Supported: JPG, PNG, GIF, BMP, WEBP, TIF');
      }
      
      print('📊 Image validation passed - Final Size: ${(imageData.length / 1024).toStringAsFixed(2)}KB, Format: Valid');
      
      // Convert to base64
      String base64Image = base64Encode(imageData);
      
      // Use regular POST request instead of MultipartRequest for better compatibility
      var uri = Uri.parse(_baseUrl);
      
      // Prepare form data
      Map<String, String> formData = {
        'key': _apiKey,
        'image': base64Image,
      };
      
      // Add optional image name (sanitize the name)
      if (imageName != null && imageName.isNotEmpty) {
        // Remove special characters and spaces from name
        String sanitizedName = imageName.replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_');
        if (sanitizedName.length > 50) {
          sanitizedName = sanitizedName.substring(0, 50);
        }
        formData['name'] = sanitizedName;
      } else {
        // Generate a unique name
        String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
        String baseName = fileName.split('.').first.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_');
        formData['name'] = 'img_${timestamp}_$baseName';
      }
      
      print('🚀 Sending request to ImageBB with image name: ${formData['name']}');
      print('📦 Base64 payload size: ${(base64Image.length / 1024).toStringAsFixed(2)}KB');
      
      // Calculate dynamic timeout based on image size (minimum 30s, +10s per MB)
      int timeoutSeconds = 30 + ((imageData.length / (1024 * 1024)) * 10).ceil();
      if (timeoutSeconds > 180) timeoutSeconds = 180; // Max 3 minutes
      
      print('⏱️ Using timeout: ${timeoutSeconds}s for this upload');
      
      // Send the request with dynamic timeout
      var response = await http.post(
        uri,
        body: formData,
      ).timeout(
        Duration(seconds: timeoutSeconds),
        onTimeout: () {
          throw Exception('Upload timeout after ${timeoutSeconds} seconds. Try compressing the image further or check your internet connection.');
        },
      );
      
      print('📡 ImageBB response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        Map<String, dynamic> jsonResponse = json.decode(response.body);
        
        if (jsonResponse['success'] == true) {
          String imageUrl = jsonResponse['data']['url'];
          String displayUrl = jsonResponse['data']['display_url'] ?? imageUrl;
          print('✅ ImageBB upload successful: $displayUrl');
          return displayUrl; // Use display_url for better compatibility
        } else {
          String errorMessage = 'Unknown error';
          if (jsonResponse.containsKey('error') && jsonResponse['error'] != null) {
            if (jsonResponse['error'] is Map && jsonResponse['error']['message'] != null) {
              errorMessage = jsonResponse['error']['message'];
            } else if (jsonResponse['error'] is String) {
              errorMessage = jsonResponse['error'];
            }
          }
          throw Exception('ImageBB API error: $errorMessage');
        }
      } else {
        String errorDetails = response.body.isNotEmpty ? response.body : 'No response body';
        print('❌ HTTP Error Details: $errorDetails');
        
        // Handle specific error codes
        switch (response.statusCode) {
          case 400:
            throw Exception('Bad Request (400): Invalid image data or parameters. Check image format and size.');
          case 401:
            throw Exception('Unauthorized (401): Invalid API key.');
          case 413:
            throw Exception('Payload Too Large (413): Image exceeds size limit.');
          case 429:
            throw Exception('Too Many Requests (429): Rate limit exceeded. Please wait and try again.');
          case 500:
            throw Exception('Internal Server Error (500): ImageBB service is temporarily unavailable.');
          default:
            throw Exception('HTTP Error: ${response.statusCode} - $errorDetails');
        }
      }
      
    } catch (e) {
      print('❌ ImageBB upload failed: $e');
      rethrow; // Use rethrow instead of throw e to preserve stack trace
    }
  }
  
  /// Upload multiple images to ImageBB
  static Future<List<String>> uploadMultipleImages(
    List<XFile> imageFiles, 
    String propertyId
  ) async {
    List<String> imageUrls = [];
    
    print('🖼️ Starting ImageBB upload for ${imageFiles.length} images (Property: $propertyId)');
    
    for (int i = 0; i < imageFiles.length; i++) {
      try {
        // Generate unique name for each image
        String imageName = '${propertyId}_img_${i + 1}_${DateTime.now().millisecondsSinceEpoch}';
        
        String imageUrl = await uploadSingleImage(imageFiles[i], imageName: imageName);
        if (imageUrl.isNotEmpty) {
          imageUrls.add(imageUrl);
          print('✅ Uploaded image ${i + 1}/${imageFiles.length}: $imageName');
        }
      } catch (e) {
        print('❌ Failed to upload image ${i + 1}/${imageFiles.length}: $e');
        // Continue with other images even if one fails
      }
    }
    
    print('✅ ImageBB upload completed: ${imageUrls.length}/${imageFiles.length} images uploaded successfully');
    return imageUrls;
  }
  
  /// Upload property images with proper naming convention
  static Future<List<String>> uploadPropertyImages(
    List<XFile> imageFiles, 
    String propertyId
  ) async {
    try {
      print('🏠 Uploading property images to ImageBB for property: $propertyId');
      return await uploadMultipleImages(imageFiles, propertyId);
    } catch (e) {
      print('❌ Error uploading property images to ImageBB: $e');
      return [];
    }
  }
  
  /// Upload user avatar to ImageBB
  static Future<String> uploadUserAvatar(XFile imageFile, String userId) async {
    try {
      print('👤 Uploading user avatar to ImageBB for user: $userId');
      String imageName = 'avatar_${userId}_${DateTime.now().millisecondsSinceEpoch}';
      return await uploadSingleImage(imageFile, imageName: imageName);
    } catch (e) {
      print('❌ Error uploading user avatar to ImageBB: $e');
      return '';
    }
  }
  
  /// Upload document images to ImageBB
  static Future<List<String>> uploadDocumentImages(
    List<XFile> documentFiles, 
    String userId, 
    String documentType
  ) async {
    List<String> documentUrls = [];
    
    print('📄 Uploading document images to ImageBB for user: $userId');
    
    for (int i = 0; i < documentFiles.length; i++) {
      try {
        String imageName = 'doc_${documentType}_${userId}_${i + 1}_${DateTime.now().millisecondsSinceEpoch}';
        
        String imageUrl = await uploadSingleImage(documentFiles[i], imageName: imageName);
        if (imageUrl.isNotEmpty) {
          documentUrls.add(imageUrl);
          print('✅ Uploaded document ${i + 1}/${documentFiles.length}: $imageName');
        }
      } catch (e) {
        print('❌ Failed to upload document ${i + 1}/${documentFiles.length}: $e');
      }
    }
    
    print('✅ Document upload completed: ${documentUrls.length}/${documentFiles.length} documents uploaded');
    return documentUrls;
  }
  
  /// Check if ImageBB service is available
  static Future<bool> isAvailable() async {
    try {
      print('🔍 Checking ImageBB service availability...');
      
      // Test with a minimal request to check if API key is valid
      var uri = Uri.parse(_baseUrl);
      var response = await http.post(
        uri,
        body: {
          'key': _apiKey,
        },
      ).timeout(const Duration(seconds: 10));
      
      // Even if it fails, if we get a proper response structure, the service is available
      if (response.statusCode == 400) {
        Map<String, dynamic> jsonResponse = json.decode(response.body);
        if (jsonResponse.containsKey('error')) {
          print('✅ ImageBB service is available (API key valid)');
          return true;
        }
      }
      
      print('❌ ImageBB service availability check failed');
      return false;
    } catch (e) {
      print('❌ ImageBB service not available: $e');
      return false;
    }
  }
  
  /// Get service status information
  static Future<Map<String, dynamic>> getServiceStatus() async {
    Map<String, dynamic> status = {
      'serviceName': 'ImageBB',
      'isAvailable': false,
      'apiKey': _apiKey.substring(0, 8) + '...',
      'baseUrl': _baseUrl,
      'lastChecked': DateTime.now().toIso8601String(),
      'errorMessage': null,
    };
    
    try {
      status['isAvailable'] = await isAvailable();
      
      if (status['isAvailable']) {
        status['status'] = 'Active';
      } else {
        status['status'] = 'Inactive';
      }
    } catch (e) {
      status['errorMessage'] = e.toString();
      status['status'] = 'Error';
    }
    
    return status;
  }
  
  /// Get upload statistics (placeholder - ImageBB doesn't provide analytics)
  static Map<String, dynamic> getUploadStats() {
    return {
      'provider': 'ImageBB',
      'apiKey': _apiKey.substring(0, 8) + '...',
      'baseUrl': _baseUrl,
      'features': [
        'Free image hosting',
        'No expiration (with account)',
        'Direct image URLs',
        'HTTPS support',
        'API-based uploads',
      ],
      'limitations': [
        'Max file size: 32MB',
        'Supported formats: JPG, PNG, BMP, GIF, TIF, WEBP',
        'Rate limited (check ImageBB terms)',
        'No built-in analytics',
      ],
    };
  }
  
  /// Delete image (Note: ImageBB doesn't provide delete API for free accounts)
  static Future<bool> deleteImage(String imageUrl) async {
    print('⚠️ ImageBB does not support image deletion through API for free accounts');
    print('ℹ️ You need to manually delete images from your ImageBB dashboard');
    print('🔗 ImageBB Dashboard: https://imgbb.com/');
    return false;
  }
  
  /// Batch delete (placeholder)
  static Future<bool> deleteMultipleImages(List<String> imageUrls) async {
    print('⚠️ ImageBB does not support batch image deletion through API for free accounts');
    print('ℹ️ You need to manually delete images from your ImageBB dashboard');
    return false;
  }
  
  /// Helper function to compress large images using proper image processing
  static Future<Uint8List> _compressImage(Uint8List imageData, String fileName) async {
    try {
      print('🗅️ Starting proper image compression...');
      
      // Decode the image
      img.Image? image = img.decodeImage(imageData);
      if (image == null) {
        print('⚠️ Could not decode image, returning original');
        return imageData;
      }
      
      print('🖼️ Original image: ${image.width}x${image.height} pixels');
      
      // Calculate compression strategy based on file size and type
      String lowerFileName = fileName.toLowerCase();
      bool isJpeg = lowerFileName.endsWith('.jpg') || lowerFileName.endsWith('.jpeg');
      bool isPng = lowerFileName.endsWith('.png');
      
      // Resize if image is very large
      int maxWidth = 1920;
      int maxHeight = 1080;
      
      if (imageData.length > 20 * 1024 * 1024) {
        // For very large files, reduce resolution more aggressively
        maxWidth = 1280;
        maxHeight = 720;
      } else if (imageData.length > 10 * 1024 * 1024) {
        // For large files, moderate reduction
        maxWidth = 1600;
        maxHeight = 900;
      }
      
      // Resize image if needed
      if (image.width > maxWidth || image.height > maxHeight) {
        img.Image resized;
        if (image.width > image.height) {
          // Landscape - resize based on width
          resized = img.copyResize(image, width: maxWidth);
        } else {
          // Portrait - resize based on height
          resized = img.copyResize(image, height: maxHeight);
        }
        print('📊 Image resized to: ${resized.width}x${resized.height} pixels');
        image = resized;
      }
      
      // Encode with appropriate compression
      Uint8List compressedData;
      
      if (isJpeg) {
        // For JPEG, use quality compression
        int quality = 85; // High quality by default
        if (imageData.length > 20 * 1024 * 1024) {
          quality = 60; // Lower quality for very large files
        } else if (imageData.length > 10 * 1024 * 1024) {
          quality = 75; // Moderate quality for large files
        }
        
        compressedData = Uint8List.fromList(img.encodeJpg(image, quality: quality));
        print('📋 JPEG compression applied with quality: $quality%');
      } else if (isPng) {
        // For PNG, use compression level
        int level = 6; // Default compression
        if (imageData.length > 15 * 1024 * 1024) {
          level = 9; // Maximum compression for large files
        }
        
        compressedData = Uint8List.fromList(img.encodePng(image, level: level));
        print('📋 PNG compression applied with level: $level');
      } else {
        // For other formats, convert to JPEG with moderate quality
        compressedData = Uint8List.fromList(img.encodeJpg(image, quality: 80));
        print('📋 Converted to JPEG format with 80% quality');
      }
      
      print('📈 Compression result: ${(imageData.length / 1024).toStringAsFixed(2)}KB → ${(compressedData.length / 1024).toStringAsFixed(2)}KB');
      print('📊 Compression ratio: ${((1 - compressedData.length / imageData.length) * 100).toStringAsFixed(1)}% reduction');
      
      return compressedData;
      
    } catch (e) {
      print('⚠️ Image compression failed: $e');
      print('🔄 Returning original image data');
      return imageData;
    }
  }
}
