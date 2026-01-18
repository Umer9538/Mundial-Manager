import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/constants.dart';
import '../../core/routing/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/gradient_scaffold.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // Set status bar style
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _controller.forward();

    // Initialize auth and navigate
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // Initialize auth provider
    await authProvider.initialize();

    // Wait for animation to complete
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      // Navigate to appropriate screen based on auth state
      if (authProvider.isAuthenticated) {
        // Navigate to role-specific dashboard
        context.go(AppRouter.getDashboardRoute(authProvider.userRole!));
      } else {
        // Navigate to login
        context.go('/login');
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo Container
                _buildLogo(),
                const SizedBox(height: 32),

                // App Name
                Text(
                  'Mundial',
                  style: GoogleFonts.montserrat(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'MANAGER',
                  style: GoogleFonts.montserrat(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppColors.softTealBlue,
                    letterSpacing: 4,
                  ),
                ),
                const SizedBox(height: 16),

                // Tagline
                Text(
                  AppConstants.appTagline,
                  style: GoogleFonts.roboto(
                    fontSize: 14,
                    color: Colors.white60,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 60),

                // Loading Indicator
                SizedBox(
                  width: 36,
                  height: 36,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.softTealBlue,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: AppColors.softTealBlue.withOpacity(0.15),
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.softTealBlue.withOpacity(0.4),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.softTealBlue.withOpacity(0.2),
            blurRadius: 30,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Location pin shape
          Icon(
            Icons.location_on,
            size: 70,
            color: AppColors.softTealBlue,
          ),
          // Football icon overlay
          Positioned(
            top: 22,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.mediumSteelBlue,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.sports_soccer,
                size: 28,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
