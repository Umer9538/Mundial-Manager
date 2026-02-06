import 'package:flutter/foundation.dart';

enum Environment { development, staging, production }

class AppConfig {
  static Environment _environment = Environment.development;

  static Environment get environment => _environment;
  static bool get isDevelopment => _environment == Environment.development;
  static bool get isStaging => _environment == Environment.staging;
  static bool get isProduction => _environment == Environment.production;
  static bool get isDebugMode => kDebugMode;

  /// Whether to show demo login buttons and allow demo credentials
  static bool get showDemoFeatures => !isProduction;

  /// Whether to fall back to dummy data when Firestore is empty
  static bool get useDummyDataFallback => isDevelopment;

  /// Whether to enable simulated real-time updates
  static bool get enableSimulatedUpdates => isDevelopment;

  /// Session timeout duration
  static Duration get sessionTimeout => const Duration(days: 7);

  /// Max failed login attempts before lockout
  static int get maxLoginAttempts => 5;

  /// Lockout duration after max failed attempts
  static Duration get lockoutDuration => const Duration(minutes: 15);

  /// Data retention period
  static Duration get dataRetentionPeriod => const Duration(days: 30);

  /// Location update interval
  static Duration get locationUpdateInterval => const Duration(seconds: 30);

  /// Crowd density update interval
  static Duration get crowdUpdateInterval =>
      isProduction ? const Duration(seconds: 15) : const Duration(seconds: 10);

  static void initialize(Environment env) {
    _environment = env;
  }
}
