import 'package:flutter/material.dart';

class LandlordPageLayout extends StatelessWidget {
  final Widget child;
  final PreferredSizeWidget? appBar;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;

  const LandlordPageLayout({
    super.key,
    required this.child,
    this.appBar,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E27),
      extendBodyBehindAppBar: true,
      appBar: appBar,
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topLeft,
            radius: 1.5,
            colors: [
              Color(0xFF1E3A5F), // Dark blue-teal at the top left
              Color(0xFF2A4A6B), // Medium blue in the middle
              Color(0xFF0F1B2E), // Darker navy blue
              Color(0xFF0A0E27), // Very dark navy at the edges
            ],
            stops: [0.0, 0.3, 0.7, 1.0],
          ),
        ),
        child: child,
      ),
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
    );
  }
}
