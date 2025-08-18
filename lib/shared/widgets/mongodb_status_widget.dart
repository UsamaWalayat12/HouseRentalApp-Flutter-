import 'package:flutter/material.dart';
import '../../core/services/mongodb_image_service.dart';
import '../../core/services/image_service.dart';

class MongoDBConnectionStatusWidget extends StatefulWidget {
  const MongoDBConnectionStatusWidget({super.key});

  @override
  State<MongoDBConnectionStatusWidget> createState() => _MongoDBConnectionStatusWidgetState();
}

// Add image storage status widget
class ImageStorageStatusWidget extends StatefulWidget {
  const ImageStorageStatusWidget({super.key});

  @override
  State<ImageStorageStatusWidget> createState() => _ImageStorageStatusWidgetState();
}

class _MongoDBConnectionStatusWidgetState extends State<MongoDBConnectionStatusWidget> {
  bool _isConnected = false;
  bool _isLoading = true;
  String? _errorMessage;
  Map<String, dynamic>? _storageStats;

  @override
  void initState() {
    super.initState();
    _checkMongoDBStatus();
  }

  Future<void> _checkMongoDBStatus() async {
    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Initialize the service
      await MongoDBImageService.initialize();
      
      // Try to get storage stats to test connection
      final stats = await MongoDBImageService.getStorageStats();
      
      if (mounted) {
        setState(() {
          _isConnected = true;
          _storageStats = stats;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isConnected = false;
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _isConnected
                ? const Color(0xFF00FF80).withOpacity(0.2)
                : const Color(0xFFFF6B9D).withOpacity(0.2),
            _isConnected
                ? const Color(0xFF00CC66).withOpacity(0.1)
                : const Color(0xFFE91E63).withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _isConnected
              ? const Color(0xFF00FF80).withOpacity(0.3)
              : const Color(0xFFFF6B9D).withOpacity(0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: _isConnected
                ? const Color(0xFF00FF80).withOpacity(0.1)
                : const Color(0xFFFF6B9D).withOpacity(0.1),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _isLoading
                    ? Icons.hourglass_empty
                    : _isConnected
                        ? Icons.check_circle
                        : Icons.error,
                color: _isLoading
                    ? const Color(0xFF00D4FF)
                    : _isConnected
                        ? const Color(0xFF00FF80)
                        : const Color(0xFFFF6B9D),
                size: 28,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'MongoDB Connection Status',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        color: _isConnected
                            ? const Color(0xFF00FF80).withOpacity(0.5)
                            : const Color(0xFFFF6B9D).withOpacity(0.5),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                ),
              ),
              IconButton(
                onPressed: _checkMongoDBStatus,
                icon: Icon(
                  Icons.refresh,
                  color: const Color(0xFF00D4FF),
                ),
                tooltip: 'Refresh Status',
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_isLoading)
            Center(
              child: Column(
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      const Color(0xFF00D4FF),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Checking MongoDB connection...',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            )
          else ...[
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _isConnected
                        ? const Color(0xFF00FF80).withOpacity(0.2)
                        : const Color(0xFFFF6B9D).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _isConnected
                          ? const Color(0xFF00FF80).withOpacity(0.5)
                          : const Color(0xFFFF6B9D).withOpacity(0.5),
                    ),
                  ),
                  child: Text(
                    _isConnected ? 'CONNECTED' : 'DISCONNECTED',
                    style: TextStyle(
                      color: _isConnected
                          ? const Color(0xFF00FF80)
                          : const Color(0xFFFF6B9D),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  'Database: rent_a_home',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_isConnected && _storageStats != null) ...[
              Text(
                'Storage Statistics:',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: const Color(0xFF00D4FF).withOpacity(0.2),
                  ),
                ),
                child: Column(
                  children: [
                    _buildStatRow('Total Images', _storageStats!['totalImages']?.toString() ?? '0'),
                    const SizedBox(height: 4),
                    _buildStatRow('Total Size', '${_storageStats!['totalSizeMB'] ?? '0.00'} MB'),
                    const SizedBox(height: 4),
                    _buildStatRow('Average Size', '${_storageStats!['averageSizeKB'] ?? '0.00'} KB'),
                  ],
                ),
              ),
            ],
            if (!_isConnected && _errorMessage != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF6B9D).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: const Color(0xFFFF6B9D).withOpacity(0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.warning_amber_rounded,
                          color: const Color(0xFFFF6B9D),
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Error Details:',
                          style: TextStyle(
                            color: const Color(0xFFFF6B9D),
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _errorMessage!,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 12,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 12,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: const Color(0xFF00D4FF),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    // MongoDBImageService uses static methods, no need to dispose instance
    super.dispose();
  }
}

// Image Storage Status Widget Implementation
class _ImageStorageStatusWidgetState extends State<ImageStorageStatusWidget> {
  bool _isConnected = false;
  bool _isLoading = true;
  String _providerStatus = '❌ Checking...';
  Map<String, dynamic>? _storageStats;
  String? _errorMessage;
  bool _showTroubleshooting = false;

  @override
  void initState() {
    super.initState();
    _checkImageStorageStatus();
  }

  Future<void> _checkImageStorageStatus() async {
    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
    });

    try {
      // Initialize the image service
      await ImageService.initialize();
      
      // Check if the current provider is available
      bool isAvailable = await ImageService.isAvailable();
      String providerStatus = ImageService.getProviderStatus();
      
      // Try to get storage stats
      final stats = await ImageService.getStorageStats();
      
      if (mounted) {
        setState(() {
          _isConnected = isAvailable;
          _providerStatus = providerStatus;
          _storageStats = stats;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isConnected = false;
          _providerStatus = '❌ Error: ${e.toString()}';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _isConnected
                ? const Color(0xFF00FF80).withOpacity(0.2)
                : const Color(0xFF5B73FF).withOpacity(0.2),
            _isConnected
                ? const Color(0xFF00CC66).withOpacity(0.1)
                : const Color(0xFF4158D0).withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _isConnected
              ? const Color(0xFF00FF80).withOpacity(0.3)
              : const Color(0xFF5B73FF).withOpacity(0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: _isConnected
                ? const Color(0xFF00FF80).withOpacity(0.1)
                : const Color(0xFF5B73FF).withOpacity(0.1),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _isLoading
                    ? Icons.hourglass_empty
                    : _isConnected
                        ? Icons.cloud_done
                        : Icons.cloud_off,
                color: _isLoading
                    ? const Color(0xFF00D4FF)
                    : _isConnected
                        ? const Color(0xFF00FF80)
                        : const Color(0xFF5B73FF),
                size: 28,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Image Storage Status',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        color: _isConnected
                            ? const Color(0xFF00FF80).withOpacity(0.5)
                            : const Color(0xFF5B73FF).withOpacity(0.5),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                ),
              ),
              IconButton(
                onPressed: _checkImageStorageStatus,
                icon: Icon(
                  Icons.refresh,
                  color: const Color(0xFF00D4FF),
                ),
                tooltip: 'Refresh Status',
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_isLoading)
            Center(
              child: Column(
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      const Color(0xFF00D4FF),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Checking image storage...',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            )
          else ...[
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _isConnected
                        ? const Color(0xFF00FF80).withOpacity(0.2)
                        : const Color(0xFF5B73FF).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _isConnected
                          ? const Color(0xFF00FF80).withOpacity(0.5)
                          : const Color(0xFF5B73FF).withOpacity(0.5),
                    ),
                  ),
                  child: Text(
                    _isConnected ? 'AVAILABLE' : 'FALLBACK MODE',
                    style: TextStyle(
                      color: _isConnected
                          ? const Color(0xFF00FF80)
                          : const Color(0xFF5B73FF),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Spacer(),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: const Color(0xFF00D4FF).withOpacity(0.2),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Provider',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        _providerStatus,
                        style: TextStyle(
                          color: const Color(0xFF00D4FF),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  if (_storageStats != null && _isConnected) ...[
                    const SizedBox(height: 4),
                    _buildStatRow('Total Images', _storageStats!['totalImages']?.toString() ?? '0'),
                    const SizedBox(height: 4),
                    _buildStatRow('Total Size', '${_storageStats!['totalSizeMB'] ?? '0.00'} MB'),
                  ],
                ],
              ),
            ),
            if (!_isConnected) ...[
              const SizedBox(height: 12),
              InkWell(
                onTap: () {
                  setState(() {
                    _showTroubleshooting = !_showTroubleshooting;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF6B9D).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: const Color(0xFFFF6B9D).withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.help_outline,
                        color: const Color(0xFFFF6B9D),
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Troubleshooting Guide',
                          style: TextStyle(
                            color: const Color(0xFFFF6B9D),
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Icon(
                        _showTroubleshooting 
                          ? Icons.expand_less
                          : Icons.expand_more,
                        color: const Color(0xFFFF6B9D),
                      ),
                    ],
                  ),
                ),
              ),
              if (_showTroubleshooting) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: const Color(0xFF00D4FF).withOpacity(0.2),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '🚨 Firebase Storage CORS Issues',
                        style: TextStyle(
                          color: const Color(0xFFFF6B9D),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '1. Enable Firebase Storage in Console:\n   https://console.firebase.google.com/project/unilegal-14d0c/storage\n\n'
                        '2. Deploy storage rules:\n   firebase deploy --only storage\n\n'
                        '3. Apply CORS configuration:\n   gsutil cors set cors.json gs://unilegal-14d0c.firebasestorage.app\n\n'
                        '📖 See FIREBASE_CORS_FIX.md for detailed instructions',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 11,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 12,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: const Color(0xFF00D4FF),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
