import 'dart:io';
import 'dart:typed_data';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';

class CloudinaryService {
  static const String _cloudName = 'duu2vyk9a';
  static const String _apiKey = '656995321123295';
  static const String _apiSecret = 'wUL_N57p9sIJSunCFfgwhpQnQgo';
  static const String _uploadPreset = 'rent_a_home_images'; // You'll need to create this preset in Cloudinary
  
  late final CloudinaryPublic _cloudinary;
  
  CloudinaryService() {
    _cloudinary = CloudinaryPublic(
      _cloudName, 
      _uploadPreset,
      cache: false,
    );
  }

  /// Upload a single image file to Cloudinary
  Future<CloudinaryResponse?> uploadImage(XFile imageFile, {String? folder}) async {
    try {
      CloudinaryResponse? response;
      
      if (kIsWeb) {
        // For web platform
        final bytes = await imageFile.readAsBytes();
        response = await _cloudinary.uploadFile(
          CloudinaryFile.fromBytesData(
            bytes,
            identifier: imageFile.name,
            folder: folder ?? 'property_images',
          ),
        );
      } else {
        // For mobile platforms
        response = await _cloudinary.uploadFile(
          CloudinaryFile.fromFile(
            imageFile.path,
            folder: folder ?? 'property_images',
          ),
        );
      }
      
      print('=== CLOUDINARY UPLOAD SUCCESS ===');
      print('Public ID: ${response.publicId}');
      print('Secure URL: ${response.secureUrl}');
      print('================================');
      
      return response;
    } catch (e) {
      print('=== CLOUDINARY UPLOAD ERROR ===');
      print('Error: $e');
      print('==============================');
      return null;
    }
  }

  /// Upload multiple images to Cloudinary
  Future<List<String>> uploadMultipleImages(List<XFile> imageFiles, {String? folder}) async {
    List<String> uploadedUrls = [];
    
    for (XFile imageFile in imageFiles) {
      final response = await uploadImage(imageFile, folder: folder);
      if (response != null) {
        uploadedUrls.add(response.secureUrl);
      }
    }
    
    return uploadedUrls;
  }

  /// Upload image from bytes (useful for web)
  Future<CloudinaryResponse?> uploadImageFromBytes(
    Uint8List bytes, 
    String fileName, 
    {String? folder}
  ) async {
    try {
      final response = await _cloudinary.uploadFile(
        CloudinaryFile.fromBytesData(
          bytes,
          identifier: fileName,
          folder: folder ?? 'property_images',
        ),
      );
      
      print('=== CLOUDINARY BYTES UPLOAD SUCCESS ===');
      print('Public ID: ${response.publicId}');
      print('Secure URL: ${response.secureUrl}');
      print('=====================================');
      
      return response;
    } catch (e) {
      print('=== CLOUDINARY BYTES UPLOAD ERROR ===');
      print('Error: $e');
      print('====================================');
      return null;
    }
  }

  /// Note: Image deletion requires signed uploads or Admin API
  /// For this implementation, we're using unsigned uploads
  /// Image deletion would need to be handled server-side

  /// Generate optimized image URL with transformations
  String getOptimizedImageUrl(
    String publicId, {
    int? width,
    int? height,
    String quality = 'auto',
    String format = 'auto',
    String crop = 'fill',
  }) {
    String transformation = 'c_$crop,q_$quality,f_$format';
    
    if (width != null) {
      transformation += ',w_$width';
    }
    
    if (height != null) {
      transformation += ',h_$height';
    }
    
    return 'https://res.cloudinary.com/$_cloudName/image/upload/$transformation/$publicId';
  }

  /// Generate thumbnail URL
  String getThumbnailUrl(String publicId, {int size = 150}) {
    return getOptimizedImageUrl(
      publicId,
      width: size,
      height: size,
      crop: 'thumb',
    );
  }

  /// Extract public ID from Cloudinary URL
  String? getPublicIdFromUrl(String cloudinaryUrl) {
    try {
      final uri = Uri.parse(cloudinaryUrl);
      final pathSegments = uri.pathSegments;
      
      // Find the index of 'upload' in path segments
      final uploadIndex = pathSegments.indexOf('upload');
      if (uploadIndex != -1 && uploadIndex < pathSegments.length - 1) {
        // Skip transformation parameters and get the public ID
        final publicIdParts = pathSegments.sublist(uploadIndex + 1);
        
        // Remove version if present (starts with 'v' followed by numbers)
        if (publicIdParts.isNotEmpty && 
            publicIdParts.first.startsWith('v') && 
            publicIdParts.first.length > 1) {
          publicIdParts.removeAt(0);
        }
        
        // Join remaining parts and remove file extension
        final publicId = publicIdParts.join('/');
        return publicId.replaceAll(RegExp(r'\.[^.]+$'), '');
      }
    } catch (e) {
      print('Error extracting public ID from URL: $e');
    }
    return null;
  }

  /// Validate if URL is a Cloudinary URL
  bool isCloudinaryUrl(String url) {
    return url.contains('res.cloudinary.com') || url.contains('cloudinary.com');
  }

  /// Get all transformation options for an image
  Map<String, String> getImageTransformations({
    int? width,
    int? height,
    String quality = 'auto',
    String format = 'auto',
    String crop = 'fill',
    double? aspectRatio,
    bool grayscale = false,
    int? blur,
    int? brightness,
    int? contrast,
  }) {
    Map<String, String> transformations = {
      'c': crop,
      'q': quality,
      'f': format,
    };

    if (width != null) transformations['w'] = width.toString();
    if (height != null) transformations['h'] = height.toString();
    if (aspectRatio != null) transformations['ar'] = aspectRatio.toString();
    if (grayscale) transformations['e'] = 'grayscale';
    if (blur != null) transformations['e'] = 'blur:$blur';
    if (brightness != null) transformations['e'] = 'brightness:$brightness';
    if (contrast != null) transformations['e'] = 'contrast:$contrast';

    return transformations;
  }
}
