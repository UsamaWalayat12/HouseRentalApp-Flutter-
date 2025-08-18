import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:math' as math;

class VideoCallPage extends StatefulWidget {
  final String participantName;
  final String participantId;
  final bool isLandlord;

  const VideoCallPage({
    super.key,
    required this.participantName,
    required this.participantId,
    required this.isLandlord,
  });

  @override
  State<VideoCallPage> createState() => _VideoCallPageState();
}

class _VideoCallPageState extends State<VideoCallPage>
    with TickerProviderStateMixin {
  bool _isVideoEnabled = true;
  bool _isAudioEnabled = true;
  bool _isFrontCamera = true;
  bool _isCallActive = true;
  bool _isConnecting = true;
  Duration _callDuration = Duration.zero;
  Timer? _callTimer;

  // Animation Controllers
  late AnimationController _pulseController;
  late AnimationController _glowController;
  late AnimationController _floatingController;
  late AnimationController _rotationController;

  // Animations
  late Animation<double> _pulseAnimation;
  late Animation<double> _glowAnimation;
  late Animation<double> _floatingAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimations();
    _simulateConnection();
    _startCallTimer();
  }

  void _initializeAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _glowController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    _glowAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _glowController,
      curve: Curves.easeInOut,
    ));

    _floatingController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );
    _floatingAnimation = Tween<double>(
      begin: -5,
      end: 5,
    ).animate(CurvedAnimation(
      parent: _floatingController,
      curve: Curves.easeInOutSine,
    ));

    _rotationController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    );
    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 2 * math.pi,
    ).animate(_rotationController);
  }

  void _startAnimations() {
    _pulseController.repeat(reverse: true);
    _glowController.repeat(reverse: true);
    _floatingController.repeat(reverse: true);
    _rotationController.repeat();
  }

  void _simulateConnection() {
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _isConnecting = false;
        });
      }
    });
  }

  void _startCallTimer() {
    _callTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted && _isCallActive) {
        setState(() {
          _callDuration = Duration(seconds: _callDuration.inSeconds + 1);
        });
      }
    });
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String hours = twoDigits(duration.inHours);
    String minutes = twoDigits(duration.inMinutes.remainder(60));
    String seconds = twoDigits(duration.inSeconds.remainder(60));
    return duration.inHours > 0 ? '$hours:$minutes:$seconds' : '$minutes:$seconds';
  }

  @override
  void dispose() {
    _callTimer?.cancel();
    _pulseController.dispose();
    _glowController.dispose();
    _floatingController.dispose();
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E27),
      body: Stack(
        children: [
          _buildAnimatedBackground(),
          _buildVideoContent(),
          _buildControlsOverlay(),
          if (_isConnecting) _buildConnectingOverlay(),
        ],
      ),
    );
  }

  Widget _buildAnimatedBackground() {
    return AnimatedBuilder(
      animation: _rotationAnimation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.topLeft,
              radius: 1.5,
              colors: [
                Color.lerp(
                  const Color(0xFF1A1B3A),
                  const Color(0xFF2A2B4A),
                  math.sin(_rotationAnimation.value) * 0.5 + 0.5,
                )!,
                const Color(0xFF0A0E27),
                const Color(0xFF000000),
              ],
            ),
          ),
          child: Stack(
            children: [
              // Floating particles
              ...List.generate(20, (index) {
                return AnimatedBuilder(
                  animation: _floatingAnimation,
                  builder: (context, child) {
                    final offset = Offset(
                      (index * 50.0) + (_floatingAnimation.value * index % 3),
                      (index * 80.0) + (_floatingAnimation.value * index % 2),
                    );
                    return Positioned(
                      left: offset.dx,
                      top: offset.dy,
                      child: Container(
                        width: 2 + (index % 3),
                        height: 2 + (index % 3),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: [
                            const Color(0xFF00D4FF),
                            const Color(0xFF5B73FF),
                            const Color(0xFFFF6B9D),
                            const Color(0xFF9B59B6),
                          ][index % 4].withOpacity(0.6),
                          boxShadow: [
                            BoxShadow(
                              color: [
                                const Color(0xFF00D4FF),
                                const Color(0xFF5B73FF),
                                const Color(0xFFFF6B9D),
                                const Color(0xFF9B59B6),
                              ][index % 4].withOpacity(0.4),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }

  Widget _buildVideoContent() {
    return SafeArea(
      child: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: _buildVideoArea(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.all(20),
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF00D4FF).withOpacity(0.2),
                const Color(0xFF5B73FF).withOpacity(0.2),
                const Color(0xFF9B59B6).withOpacity(0.2),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFF00D4FF).withOpacity(_glowAnimation.value),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF00D4FF).withOpacity(_glowAnimation.value * 0.5),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Row(
            children: [
              GestureDetector(
                onTap: _endCall,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFF6B9D), Color(0xFFFF4444)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFF6B9D).withOpacity(0.5),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              CircleAvatar(
                radius: 25,
                backgroundColor: const Color(0xFF00D4FF).withOpacity(0.3),
                child: Text(
                  widget.participantName.isNotEmpty 
                      ? widget.participantName[0].toUpperCase() 
                      : 'P',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.participantName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _isConnecting 
                          ? 'Connecting...' 
                          : 'Call duration: ${_formatDuration(_callDuration)}',
                      style: TextStyle(
                        color: const Color(0xFF00D4FF).withOpacity(0.8),
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _pulseAnimation.value,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF00FF80), Color(0xFF00D4FF)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF00FF80).withOpacity(0.5),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.videocam,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildVideoArea() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00D4FF).withOpacity(0.3),
            blurRadius: 30,
            spreadRadius: 5,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            // Main video area (participant's video)
            Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF1A1B3A).withOpacity(0.8),
                    const Color(0xFF2A2B4A).withOpacity(0.6),
                  ],
                ),
              ),
              child: _buildVideoPlaceholder(widget.participantName, true),
            ),
            
            // Picture-in-picture (own video)
            Positioned(
              top: 20,
              right: 20,
              child: Container(
                width: 120,
                height: 160,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: const Color(0xFF00D4FF),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF00D4FF).withOpacity(0.5),
                      blurRadius: 15,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(13),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          const Color(0xFF00D4FF).withOpacity(0.3),
                          const Color(0xFF5B73FF).withOpacity(0.3),
                        ],
                      ),
                    ),
                    child: _buildVideoPlaceholder('You', false),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoPlaceholder(String name, bool isMain) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Transform.scale(
                scale: isMain ? _pulseAnimation.value : 1.0,
                child: CircleAvatar(
                  radius: isMain ? 60 : 30,
                  backgroundColor: const Color(0xFF00D4FF).withOpacity(0.3),
                  child: Text(
                    name.isNotEmpty ? name[0].toUpperCase() : 'U',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isMain ? 36 : 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              if (isMain) ...[
                const SizedBox(height: 20),
                Text(
                  name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00FF80).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFF00FF80).withOpacity(0.5),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Color(0xFF00FF80),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Connected',
                        style: TextStyle(
                          color: Color(0xFF00FF80),
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildControlsOverlay() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              const Color(0xFF0A0E27).withOpacity(0.8),
              const Color(0xFF0A0E27),
            ],
          ),
        ),
        child: SafeArea(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildControlButton(
                icon: _isFrontCamera ? Icons.camera_front : Icons.camera_rear,
                label: 'Camera',
                color: const Color(0xFF5B73FF),
                onTap: _toggleCamera,
              ),
              _buildControlButton(
                icon: _isAudioEnabled ? Icons.mic : Icons.mic_off,
                label: 'Mute',
                color: _isAudioEnabled ? const Color(0xFF00D4FF) : const Color(0xFFFF6B9D),
                onTap: _toggleAudio,
              ),
              _buildControlButton(
                icon: _isVideoEnabled ? Icons.videocam : Icons.videocam_off,
                label: 'Video',
                color: _isVideoEnabled ? const Color(0xFF00D4FF) : const Color(0xFFFF6B9D),
                onTap: _toggleVideo,
              ),
              _buildControlButton(
                icon: Icons.call_end,
                label: 'End Call',
                color: const Color(0xFFFF4444),
                onTap: _endCall,
                isPrimary: true,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
    bool isPrimary = false,
  }) {
    return AnimatedBuilder(
      animation: isPrimary ? _pulseAnimation : _glowAnimation,
      builder: (context, child) {
        return GestureDetector(
          onTap: onTap,
          child: Transform.scale(
            scale: isPrimary ? _pulseAnimation.value : 1.0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.all(isPrimary ? 18 : 15),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        color,
                        color.withOpacity(0.8),
                      ],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: color.withOpacity(0.5),
                        blurRadius: isPrimary ? 20 : 15,
                        spreadRadius: isPrimary ? 5 : 3,
                      ),
                    ],
                  ),
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: isPrimary ? 28 : 24,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildConnectingOverlay() {
    return Container(
      color: const Color(0xFF0A0E27).withOpacity(0.9),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedBuilder(
              animation: _rotationAnimation,
              builder: (context, child) {
                return Transform.rotate(
                  angle: _rotationAnimation.value,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      gradient: const SweepGradient(
                        colors: [
                          Color(0xFF00D4FF),
                          Color(0xFF5B73FF),
                          Color(0xFF9B59B6),
                          Color(0xFF00D4FF),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(40),
                    ),
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 3,
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 30),
            Text(
              'Connecting to ${widget.participantName}...',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              'Please wait while we establish the connection',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _toggleVideo() {
    HapticFeedback.lightImpact();
    setState(() {
      _isVideoEnabled = !_isVideoEnabled;
    });
  }

  void _toggleAudio() {
    HapticFeedback.lightImpact();
    setState(() {
      _isAudioEnabled = !_isAudioEnabled;
    });
  }

  void _toggleCamera() {
    HapticFeedback.lightImpact();
    setState(() {
      _isFrontCamera = !_isFrontCamera;
    });
  }

  void _endCall() {
    HapticFeedback.heavyImpact();
    Navigator.of(context).pop();
  }
}
