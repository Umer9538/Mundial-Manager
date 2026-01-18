import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/constants.dart';
import 'core/routing/app_router.dart';
import 'providers/auth_provider.dart';
import 'providers/crowd_provider.dart';
import 'providers/incident_provider.dart';
import 'providers/alert_provider.dart';

void main() {
  runApp(const MundialManagerApp());
}

class MundialManagerApp extends StatelessWidget {
  const MundialManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => CrowdProvider()),
        ChangeNotifierProvider(create: (_) => IncidentProvider()),
        ChangeNotifierProvider(create: (_) => AlertProvider()),
      ],
      child: MaterialApp.router(
        title: AppConstants.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        routerConfig: AppRouter.router,
      ),
    );
  }
}

// Temporary home page - will be replaced with splash screen
class TemporaryHomePage extends StatelessWidget {
  const TemporaryHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mundial Manager 2035'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.stadium,
              size: 80,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 24),
            Text(
              AppConstants.appName,
              style: Theme.of(context).textTheme.displayMedium,
            ),
            const SizedBox(height: 8),
            Text(
              AppConstants.appTagline,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 48),
            ElevatedButton(
              onPressed: () {},
              child: const Text('Get Started'),
            ),
          ],
        ),
      ),
    );
  }
}
