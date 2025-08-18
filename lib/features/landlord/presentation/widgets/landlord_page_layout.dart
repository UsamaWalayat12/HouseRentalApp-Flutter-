import 'package:flutter/material.dart';
import 'landlord_app_bar.dart';
import 'landlord_background.dart';

class LandlordPageLayout extends StatelessWidget {
  final String title;
  final Widget body;
  final List<Widget>? actions;
  final Widget? floatingActionButton;
  final Animation<double> backgroundAnimation;
  final Animation<double> fadeAnimation;

  const LandlordPageLayout({
    Key? key,
    required this.title,
    required this.body,
    required this.backgroundAnimation,
    required this.fadeAnimation,
    this.actions,
    this.floatingActionButton,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E27),
      extendBodyBehindAppBar: true,
      appBar: LandlordAppBar(
        title: title,
        actions: actions,
      ),
      body: LandlordBackground(
        backgroundAnimation: backgroundAnimation,
        child: SafeArea(
          child: FadeTransition(
            opacity: fadeAnimation,
            child: body,
          ),
        ),
      ),
      floatingActionButton: floatingActionButton,
    );
  }
}
