# Firebase Storage Collections Guide

## Overview

I've created a comprehensive Firebase Storage collection system for your app. This organizes all your images into separate collections with proper metadata tracking.

## 🗂️ Available Collections

### 1. Property Images (`property_images`)
- **Purpose**: Store property photos
- **Structure**: `property_images/{propertyId}/{image_files}`
- **Metadata**: Stored in Firestore collection `property_images_metadata`

### 2. User Avatars (`user_avatars`)
- **Purpose**: Store user profile pictures
- **Structure**: `user_avatars/{userId}/{avatar_files}`
- **Metadata**: Stored in Firestore collection `user_avatars_metadata`

### 3. Property Documents (`property_documents`)
- **Purpose**: Store property-related documents (contracts, certificates, etc.)
- **Structure**: `property_documents/{propertyId}/{document_files}`
- **Metadata**: Stored in Firestore collection `property_documents_metadata`

### 4. Gallery Images (`gallery_images`)
- **Purpose**: Store general gallery or showcase images
- **Structure**: `gallery_images/{galleryId}/{image_files}`
- **Metadata**: Stored in Firestore collection `gallery_images_metadata`

## 🚀 How to Use

### Setup (One-time)

1. **Run the setup script:**
   ```powershell
   .\setup_firebase_collections.ps1
   ```

2. **Follow the prompts to:**
   - Enable Firebase Storage
   - Deploy security rules
   - Create collections
   - Configure your app

### In Your Code

#### Upload Property Images
```dart
import 'package:image_picker/image_picker.dart';

// Pick images
final ImagePicker picker = ImagePicker();
List<XFile> imageFiles = await picker.pickMultiImage();

// Upload to property images collection
List<String> imageUrls = await ImageService.uploadPropertyImagesToCollection(
  imageFiles, 
  'property_123'
);

print('Uploaded ${imageUrls.length} property images');
```

#### Get Property Images
```dart
List<String> imageUrls = await ImageService.getPropertyImagesFromCollection('property_123');

// Use the URLs in your UI
for (String url in imageUrls) {
  Image.network(url);
}
```

#### Upload User Avatar
```dart
List<XFile> avatarFiles = await picker.pickMultiImage();
List<String> avatarUrls = await ImageService.uploadUserAvatar(avatarFiles, 'user_456');
```

#### Upload Property Documents
```dart
List<XFile> documentFiles = await picker.pickMultiImage();
List<String> documentUrls = await ImageService.uploadPropertyDocuments(
  documentFiles, 
  'property_123'
);
```

#### Get Collection Statistics
```dart
Map<String, dynamic> stats = await ImageService.getCollectionStats('property_images');
print('Total images: ${stats['totalImages']}');
print('Total size: ${stats['totalSizeMB']} MB');
```

#### Search Across All Collections
```dart
List<Map<String, dynamic>> results = await ImageService.searchAllImages('property_123');
for (var result in results) {
  print('Found ${result['imageCount']} images in ${result['collection']}');
}
```

#### Delete Collection Images
```dart
bool success = await ImageService.deleteImagesFromCollection('property_images', 'property_123');
```

## 📊 Benefits

### 1. **Organization**
- Images are organized by purpose and ID
- Easy to find specific images
- Clear folder structure in Firebase Storage

### 2. **Metadata Tracking**
- Each collection has metadata in Firestore
- Track upload times, file sizes, image counts
- Search and filter capabilities

### 3. **Performance**
- Fast retrieval using Firestore metadata
- Fallback to Storage if Firestore unavailable
- Efficient batch operations

### 4. **Scalability**
- Handles thousands of images per collection
- Automatic filename generation with timestamps
- Proper MIME type detection

## 🔧 Folder Structure

```
Firebase Storage:
├── property_images/
│   ├── property_123/
│   │   ├── property_123_0_1640995200000.jpg
│   │   ├── property_123_1_1640995201000.png
│   │   └── ...
│   └── property_456/
│       └── ...
├── user_avatars/
│   ├── user_789/
│   │   └── user_789_0_1640995300000.jpg
│   └── ...
├── property_documents/
└── gallery_images/

Firestore:
├── property_images_metadata/
│   ├── property_123: {imageUrls: [...], imageCount: 5, lastUpdated: ...}
│   └── property_456: {...}
├── user_avatars_metadata/
├── property_documents_metadata/
└── gallery_images_metadata/
```

## 🛠️ Advanced Features

### Custom Metadata
```dart
List<String> urls = await FirebaseCollectionService.uploadImagesToCollection(
  collectionName: 'property_images',
  imageFiles: imageFiles,
  documentId: 'property_123',
  metadata: {
    'category': 'bedroom',
    'photographer': 'John Doe',
    'location': 'New York',
    'tags': ['luxury', 'furnished'],
  },
);
```

### List All Collections
```dart
List<String> collections = await ImageService.listAllCollections();
print('Available collections: $collections');
```

### Collection Statistics
```dart
Map<String, dynamic> stats = await ImageService.getCollectionStats('property_images');
print('Properties with images: ${stats['totalDocuments']}');
print('Average images per property: ${stats['averageImagesPerDocument']}');
```

## 🔐 Security

The system uses Firebase Storage security rules that:
- Allow read access to all users
- Allow write access (configurable for authentication)
- Organize files by collection and document ID
- Include proper metadata for tracking

## 📱 Integration with Your App

The collection system is already integrated into your existing `ImageService`. Your property cards and other components will automatically use the new system once Firebase Storage is enabled.

## 🚨 Important Notes

1. **Enable Firebase Storage First**: The collections won't work until Firebase Storage is enabled in your project
2. **Firestore Required**: The system uses Firestore for metadata, ensure it's enabled
3. **CORS Configuration**: Apply CORS settings for web app compatibility
4. **Security Rules**: Update rules in production for proper authentication

## 📞 Support

If you encounter issues:
1. Check the browser console for error messages
2. Verify Firebase Storage is enabled
3. Ensure Firestore is enabled
4. Check security rules are deployed
5. Verify CORS configuration is applied

Your images will be properly organized, searchable, and efficiently managed with this collection system!
