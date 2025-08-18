import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:typed_data';
import '../../core/services/mongodb_image_service.dart';

class MongoDBImageWidget extends StatefulWidget {
  final String imageId;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;
  final BorderRadius? borderRadius;
  final bool enableCaching;

  const MongoDBImageWidget({
    Key? key,
    required this.imageId,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
    this.borderRadius,
    this.enableCaching = true,
  }) : super(key: key);

  @override
  State<MongoDBImageWidget> createState() => _MongoDBImageWidgetState();
}

class _MongoDBImageWidgetState extends State<MongoDBImageWidget> {
  Uint8List? _imageData;
  bool _isLoading = false;
  bool _hasError = false;
  String? _errorMessage;

  // Simple in-memory cache
  static final Map<String, Uint8List> _imageCache = {};

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  @override
  void didUpdateWidget(MongoDBImageWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imageId != widget.imageId) {
      _loadImage();
    }
  }

  Future<void> _loadImage() async {
    // Extract the actual MongoDB ID from the URL format
    String imageId = widget.imageId;
    if (imageId.startsWith('mongodb://')) {
      imageId = imageId.substring(10); // Remove 'mongodb://' prefix
    }

    print('🎨 MongoDBImageWidget loading image: $imageId');

    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = null;
    });

    try {
      // Check cache first
      if (widget.enableCaching && _imageCache.containsKey(imageId)) {
        print('✅ Using cached image: $imageId');
        setState(() {
          _imageData = _imageCache[imageId];
          _isLoading = false;
        });
        return;
      }

      // Load from MongoDB
      print('💾 Loading from MongoDB: $imageId');
      Uint8List? data = await MongoDBImageService.getImageData(imageId);

      if (data != null) {
        print('✅ Successfully loaded image data: ${data.length} bytes');
        // Cache the image data
        if (widget.enableCaching) {
          _imageCache[imageId] = data;
        }

        if (mounted) {
          setState(() {
            _imageData = data;
            _isLoading = false;
          });
        }
      } else {
        print('❌ No image data returned for: $imageId');
        if (mounted) {
          setState(() {
            _isLoading = false;
            _hasError = true;
            _errorMessage = 'Image not found';
          });
        }
      }
    } catch (e) {
      print('❌ Error loading image $imageId: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
          _errorMessage = 'Failed to load image: $e';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget child;

    if (_isLoading) {
      child = widget.placeholder ?? _buildDefaultPlaceholder();
    } else if (_hasError || _imageData == null) {
      child = widget.errorWidget ?? _buildDefaultError();
    } else {
      child = Image.memory(
        _imageData!,
        width: widget.width,
        height: widget.height,
        fit: widget.fit,
        errorBuilder: (context, error, stackTrace) {
          return widget.errorWidget ?? _buildDefaultError();
        },
      );
    }

    if (widget.borderRadius != null) {
      child = ClipRRect(
        borderRadius: widget.borderRadius!,
        child: child,
      );
    }

    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: child,
    );
  }

  Widget _buildDefaultPlaceholder() {
    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.grey[100]!,
            Colors.grey[200]!,
          ],
        ),
        borderRadius: widget.borderRadius,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.image_outlined,
            color: Colors.grey[400],
            size: 48,
          ),
          const SizedBox(height: 8),
          Text(
            'Loading image...',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultError() {
    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.blue[100]!,
            Colors.blue[200]!,
          ],
        ),
        borderRadius: widget.borderRadius,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.image_not_supported_outlined,
            color: Colors.blue[400],
            size: 48,
          ),
          const SizedBox(height: 8),
          Text(
            'Property Image',
            style: TextStyle(
              color: Colors.blue[600],
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            'MongoDB Not Available',
            style: TextStyle(
              color: Colors.blue[400],
              fontSize: 10,
            ),
          ),
          if (_errorMessage != null) ...[
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                _errorMessage!.length > 50 ? '${_errorMessage!.substring(0, 50)}...' : _errorMessage!,
                style: TextStyle(
                  color: Colors.blue[300],
                  fontSize: 8,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Clear the image cache
  static void clearCache() {
    _imageCache.clear();
  }

  /// Remove specific image from cache
  static void clearCacheForImage(String imageId) {
    if (imageId.startsWith('mongodb://')) {
      imageId = imageId.substring(10);
    }
    _imageCache.remove(imageId);
  }

  /// Get cache size information
  static Map<String, dynamic> getCacheInfo() {
    int totalSize = 0;
    for (Uint8List data in _imageCache.values) {
      totalSize += data.length;
    }

    return {
      'cachedImages': _imageCache.length,
      'totalSizeBytes': totalSize,
      'totalSizeMB': (totalSize / (1024 * 1024)).toStringAsFixed(2),
    };
  }
}

/// MongoDB Status Widget - Shows connection status
class MongoDBStatusWidget extends StatelessWidget {
  const MongoDBStatusWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: MongoDBImageService.initialize(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.orange[100],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.orange[300]!),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.orange[600]!),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Connecting to MongoDB...',
                  style: TextStyle(
                    color: Colors.orange[800],
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        }
        
        return FutureBuilder<Uint8List?>(
          future: MongoDBImageService.getImageData('test_connection'),
          builder: (context, testSnapshot) {
            final isConnected = testSnapshot.connectionState == ConnectionState.done && testSnapshot.data != null;
            final color = isConnected ? Colors.green : Colors.red;
            
            return Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: color[300]!),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isConnected ? Icons.check_circle : Icons.error,
                    color: color[600],
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isConnected ? 'MongoDB Connected' : 'MongoDB Unavailable',
                    style: TextStyle(
                      color: color[800],
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

/// A specialized version for property image carousels
class PropertyImageCarousel extends StatelessWidget {
  final List<String> imageIds;
  final double height;
  final bool showIndicators;
  final Function(int)? onImageTapped;

  const PropertyImageCarousel({
    Key? key,
    required this.imageIds,
    this.height = 300,
    this.showIndicators = true,
    this.onImageTapped,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (imageIds.isEmpty) {
      return Container(
        height: height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFF1A1B3A).withOpacity(0.6),
              const Color(0xFF2A2B4A).withOpacity(0.4),
            ],
          ),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.image_not_supported,
              color: const Color(0xFF00D4FF),
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              'No Images Available',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      height: height,
      child: PageView.builder(
        itemCount: imageIds.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () => onImageTapped?.call(index),
            child: MongoDBImageWidget(
              imageId: imageIds[index],
              width: double.infinity,
              height: height,
              fit: BoxFit.cover,
              borderRadius: BorderRadius.circular(15),
            ),
          );
        },
      ),
    );
  }
}

/// A grid layout for displaying multiple MongoDB images
class MongoDBImageGrid extends StatelessWidget {
  final List<String> imageIds;
  final int crossAxisCount;
  final double aspectRatio;
  final double spacing;
  final Function(int, String)? onImageTapped;

  const MongoDBImageGrid({
    Key? key,
    required this.imageIds,
    this.crossAxisCount = 2,
    this.aspectRatio = 1.0,
    this.spacing = 8.0,
    this.onImageTapped,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: aspectRatio,
        crossAxisSpacing: spacing,
        mainAxisSpacing: spacing,
      ),
      itemCount: imageIds.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () => onImageTapped?.call(index, imageIds[index]),
          child: MongoDBImageWidget(
            imageId: imageIds[index],
            fit: BoxFit.cover,
            borderRadius: BorderRadius.circular(8),
          ),
        );
      },
    );
  }
}
