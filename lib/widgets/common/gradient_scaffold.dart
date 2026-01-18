import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_colors.dart';

/// A scaffold with a gradient background for the dark theme design.
/// Used as the base container for all screens in the app.
class GradientScaffold extends StatelessWidget {
  final Widget body;
  final PreferredSizeWidget? appBar;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final bool extendBodyBehindAppBar;
  final bool extendBody;

  const GradientScaffold({
    super.key,
    required this.body,
    this.appBar,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.extendBodyBehindAppBar = true,
    this.extendBody = false,
  });

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: AppColors.deepNavyBlue,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        extendBodyBehindAppBar: extendBodyBehindAppBar,
        extendBody: extendBody,
        backgroundColor: Colors.transparent,
        appBar: appBar,
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: AppGradients.backgroundGradient,
          ),
          child: body,
        ),
        bottomNavigationBar: bottomNavigationBar,
        floatingActionButton: floatingActionButton,
        floatingActionButtonLocation: floatingActionButtonLocation,
      ),
    );
  }
}

/// Collection of gradient definitions used throughout the app
class AppGradients {
  // Main background gradient - deep navy to slightly lighter navy
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF0F253D), // Deep Navy Blue
      Color(0xFF1A3A5C), // Slightly lighter navy
      Color(0xFF0F253D), // Back to deep navy
    ],
    stops: [0.0, 0.5, 1.0],
  );

  // Card gradient for glassmorphic effect
  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0x33FFFFFF), // 20% white
      Color(0x1AFFFFFF), // 10% white
    ],
  );

  // Primary button gradient
  static const LinearGradient primaryButtonGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF34C759), // Green
      Color(0xFF2DB350), // Slightly darker green
    ],
  );

  // Accent gradient for highlights
  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF6FAEC9), // Soft Teal Blue
      Color(0xFF27506D), // Cool Steel Blue
    ],
  );

  // Warning gradient for alerts
  static const LinearGradient warningGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFFF9500), // Orange
      Color(0xFFE08600), // Darker orange
    ],
  );

  // Danger gradient for critical alerts
  static const LinearGradient dangerGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFFF3B30), // Red
      Color(0xFFE02D22), // Darker red
    ],
  );
}
