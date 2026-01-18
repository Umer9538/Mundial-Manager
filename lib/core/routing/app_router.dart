import 'package:go_router/go_router.dart';
import '../../screens/auth/splash_screen.dart';
import '../../screens/auth/login_screen.dart';
import '../../screens/auth/register_screen.dart';
import '../../screens/fan/fan_dashboard.dart';
import '../../screens/organizer/organizer_dashboard.dart';
import '../../screens/security/security_dashboard.dart';
import '../../screens/emergency/emergency_dashboard.dart';

class AppRouter {
  static final router = GoRouter(
    initialLocation: '/splash',
    routes: [
      // Auth Routes
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),

      // Role-specific Dashboards
      GoRoute(
        path: '/fan',
        builder: (context, state) => const FanDashboard(),
      ),
      GoRoute(
        path: '/organizer',
        builder: (context, state) => const OrganizerDashboard(),
      ),
      GoRoute(
        path: '/security',
        builder: (context, state) => const SecurityDashboard(),
      ),
      GoRoute(
        path: '/emergency',
        builder: (context, state) => const EmergencyDashboard(),
      ),
    ],
  );

  // Helper method to get dashboard route based on role
  static String getDashboardRoute(String role) {
    switch (role) {
      case 'fan':
        return '/fan';
      case 'organizer':
        return '/organizer';
      case 'security':
        return '/security';
      case 'emergency':
        return '/emergency';
      default:
        return '/login';
    }
  }
}
