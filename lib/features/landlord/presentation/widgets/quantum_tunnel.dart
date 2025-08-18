import 'package:flutter/material.dart';
import 'dart:math' as math;

class QuantumTunnel extends StatefulWidget {
  final int index;

  const QuantumTunnel({
    super.key,
    required this.index,
  });

  @override
  State<QuantumTunnel> createState() => _QuantumTunnelState();
}

class _QuantumTunnelState extends State<QuantumTunnel> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 15),
      vsync: this,
    )..repeat();

    _animation = Tween<double>(
      begin: 0.0,
      end: 2 * math.pi,
    ).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Positioned(
          left: (widget.index * 160.0) + (math.sin(_animation.value * 0.5 + widget.index) * 60),
          top: (widget.index * 200.0) + (math.cos(_animation.value * 0.7 + widget.index) * 80),
          child: Transform.rotate(
            angle: _animation.value + (widget.index * 0.8),
            child: Container(
              width: 80,
              height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(40),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    [
                      const Color(0xFF00FFFF),
                      const Color(0xFF8000FF),
                      const Color(0xFFFF0080),
                    ][widget.index % 3].withOpacity(0.3),
                    [
                      const Color(0xFF00FFFF),
                      const Color(0xFF8000FF),
                      const Color(0xFFFF0080),
                    ][widget.index % 3].withOpacity(0.6),
                    Colors.transparent,
                  ],
                ),
                border: Border.all(
                  color: [
                    const Color(0xFF00FFFF),
                    const Color(0xFF8000FF),
                    const Color(0xFFFF0080),
                  ][widget.index % 3].withOpacity(0.5),
                  width: 1,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
} 