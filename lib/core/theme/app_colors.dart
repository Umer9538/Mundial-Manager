import 'package:flutter/material.dart';

class AppColors {
  // ============================================
  // BRAND / LOGO COLORS
  // ============================================
  static const Color pureWhite = Color(0xFFFFFFFF);
  static const Color mediumSteelBlue = Color(0xFF2F5A7D); // Primary brand color
  static const Color blueGrey = Color(0xFF6C8BA6);

  // ============================================
  // PRIMARY UI COLORS
  // ============================================
  static const Color softTealBlue = Color(0xFF6FAEC9); // Backgrounds, subtle highlights
  static const Color coolSteelBlue = Color(0xFF27506D); // Headers, key buttons
  static const Color deepNavyBlue = Color(0xFF0F253D); // Navigation bars, strong contrast

  // Primary color aliases for convenience
  static const Color primary = coolSteelBlue;
  static const Color primaryDark = deepNavyBlue;
  static const Color primaryLight = softTealBlue;

  // ============================================
  // SECONDARY COLORS (Indicators, Alerts, Status)
  // ============================================
  static const Color blue = Color(0xFF007AFF); // Interactive elements, links, buttons
  static const Color green = Color(0xFF34C759); // Success, confirmation, positive status
  static const Color yellow = Color(0xFFFDD90A); // Warnings, alerts, caution
  static const Color orange = Color(0xFFFF9500); // Medium-level alerts, notifications
  static const Color red = Color(0xFFFF3B30); // Errors, critical alerts, destructive actions

  // Secondary color aliases
  static const Color secondary = orange;
  static const Color secondaryDark = Color(0xFFE08600);
  static const Color secondaryLight = Color(0xFFFFAA33);

  // ============================================
  // CROWD DENSITY COLORS (Based on Secondary Palette)
  // ============================================
  static const Color densitySafe = green; // Green (0-1.5 people/m²)
  static const Color densityModerate = yellow; // Yellow (1.6-3.0)
  static const Color densityHigh = orange; // Orange (3.1-4.5)
  static const Color densityCritical = red; // Red (≥4.6)

  // ============================================
  // STATUS COLORS
  // ============================================
  static const Color success = green;
  static const Color warning = yellow;
  static const Color error = red;
  static const Color info = blue;

  // ============================================
  // BACKGROUND COLORS
  // ============================================
  static const Color background = pureWhite;
  static const Color backgroundLight = Color(0xFFF5F7FA);
  static const Color backgroundDark = deepNavyBlue;

  // ============================================
  // TEXT COLORS
  // ============================================
  static const Color textPrimary = deepNavyBlue;
  static const Color textSecondary = blueGrey;
  static const Color textDisabled = Color(0xFFBDBDBD);
  static const Color textOnPrimary = pureWhite;
  static const Color textOnDark = pureWhite;

  // ============================================
  // BORDER COLORS
  // ============================================
  static const Color border = Color(0xFFE0E0E0);
  static const Color borderDark = blueGrey;

  // ============================================
  // CARD & SURFACE
  // ============================================
  static const Color surface = pureWhite;
  static const Color surfaceVariant = Color(0xFFF5F7FA);

  // ============================================
  // SHADOW
  // ============================================
  static const Color shadow = Color(0x1A000000); // 10% black

  // ============================================
  // INCIDENT SEVERITY COLORS
  // ============================================
  static const Color severityLow = green;
  static const Color severityMedium = yellow;
  static const Color severityHigh = orange;
  static const Color severityCritical = red;

  // ============================================
  // ALERT TYPE COLORS
  // ============================================
  static const Color alertCongestion = orange;
  static const Color alertSafety = yellow;
  static const Color alertEmergency = red;
  static const Color alertInfo = blue;

  // Get density color based on people per square meter
  static Color getDensityColor(double peoplePerSqMeter) {
    if (peoplePerSqMeter >= 4.6) {
      return densityCritical;
    } else if (peoplePerSqMeter >= 3.1) {
      return densityHigh;
    } else if (peoplePerSqMeter >= 1.6) {
      return densityModerate;
    } else {
      return densitySafe;
    }
  }

  // Get density status text
  static String getDensityStatus(double peoplePerSqMeter) {
    if (peoplePerSqMeter >= 4.6) {
      return 'CRITICAL';
    } else if (peoplePerSqMeter >= 3.1) {
      return 'HIGH';
    } else if (peoplePerSqMeter >= 1.6) {
      return 'MODERATE';
    } else {
      return 'SAFE';
    }
  }

  // Get severity color
  static Color getSeverityColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'low':
        return severityLow;
      case 'medium':
        return severityMedium;
      case 'high':
        return severityHigh;
      case 'critical':
        return severityCritical;
      default:
        return severityMedium;
    }
  }

  // Get alert color
  static Color getAlertColor(String type) {
    switch (type.toLowerCase()) {
      case 'congestion':
        return alertCongestion;
      case 'safety':
        return alertSafety;
      case 'emergency':
        return alertEmergency;
      case 'info':
        return alertInfo;
      default:
        return alertInfo;
    }
  }
}
