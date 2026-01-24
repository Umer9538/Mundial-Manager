 class AppConstants {
  // App Info
  static const String appName = 'Mundial Manager';
  static const String appVersion = '1.0.0';
  static const String appTagline = 'Crowd Management for FIFA World Cup 2026';

  // API & Backend (Placeholder for future)
  static const String apiBaseUrl = 'https://api.mundialmanager.com';
  static const Duration apiTimeout = Duration(seconds: 30);

  // Shared Preferences Keys
  static const String keyUserId = 'user_id';
  static const String keyUserEmail = 'user_email';
  static const String keyUserName = 'user_name';
  static const String keyUserRole = 'user_role';
  static const String keyIsLoggedIn = 'is_logged_in';
  static const String keyLocationSharingEnabled = 'location_sharing_enabled';

  // User Roles
  static const String roleFan = 'fan';
  static const String roleOrganizer = 'organizer';
  static const String roleSecurity = 'security';
  static const String roleEmergency = 'emergency';

  // Density Thresholds (people per m²)
  static const double densitySafeMax = 1.5;
  static const double densityModerateMax = 3.0;
  static const double densityHighMax = 4.5;
  static const double densityCriticalMin = 4.6;

  // Alert Thresholds
  static const double alertThresholdRed = 3.0; // Red alert
  static const double alertThresholdCritical = 4.5; // Critical warning

  // Map Settings
  static const double defaultLat = 24.7257; // King Fahd International Stadium, Riyadh
  static const double defaultLng = 46.8222;
  static const double defaultZoom = 16.0;
  static const double minZoom = 14.0;
  static const double maxZoom = 19.0;

  // Real-time Update Intervals
  static const Duration crowdUpdateInterval = Duration(seconds: 10);
  static const Duration alertCheckInterval = Duration(seconds: 5);
  static const Duration incidentCheckInterval = Duration(seconds: 8);

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  // Incident Types
  static const String incidentTypeMedical = 'medical';
  static const String incidentTypeSecurity = 'security';
  static const String incidentTypeOvercrowding = 'overcrowding';
  static const String incidentTypeOther = 'other';

  // Incident Severity
  static const String severityLow = 'low';
  static const String severityMedium = 'medium';
  static const String severityHigh = 'high';
  static const String severityCritical = 'critical';

  // Incident Status
  static const String statusReported = 'reported';
  static const String statusDispatched = 'dispatched';
  static const String statusOnSite = 'on-site';
  static const String statusResolved = 'resolved';

  // Alert Types
  static const String alertTypeCongestion = 'congestion';
  static const String alertTypeSafety = 'safety';
  static const String alertTypeEmergency = 'emergency';
  static const String alertTypeInfo = 'info';

  // Event Data
  static const String eventName = 'FIFA World Cup 2026 - Semifinal';
  static const String venueName = 'Lusail Stadium';
  static const String venueLocation = 'Qatar';
  static const int venueCapacity = 88966;

  // Validation
  static const int minPasswordLength = 8;
  static const int maxPasswordLength = 128;
  static const int minNameLength = 2;
  static const int maxNameLength = 50;

  // UI
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double borderRadius = 8.0;
  static const double cardElevation = 2.0;

  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);

  // Error Messages
  static const String errorGeneric = 'Something went wrong. Please try again.';
  static const String errorNetwork = 'Network error. Please check your connection.';
  static const String errorInvalidEmail = 'Please enter a valid email address.';
  static const String errorInvalidPassword = 'Password must be at least 8 characters long.';
  static const String errorLoginFailed = 'Invalid email or password.';
  static const String errorEmptyField = 'This field cannot be empty.';

  // Success Messages
  static const String successLogin = 'Login successful!';
  static const String successRegister = 'Registration successful!';
  static const String successAlertSent = 'Alert sent successfully!';
  static const String successIncidentReported = 'Incident reported successfully!';
  static const String successStatusUpdated = 'Status updated successfully!';

  // Demo Credentials
  static const Map<String, Map<String, String>> demoCredentials = {
    'fan': {
      'email': 'fan@test.com',
      'password': 'password123',
      'name': 'James Miller',
    },
    'organizer': {
      'email': 'organizer@test.com',
      'password': 'password123',
      'name': 'Maria Santos',
    },
    'security': {
      'email': 'security@test.com',
      'password': 'password123',
      'name': 'Ahmed Khan',
    },
    'emergency': {
      'email': 'emergency@test.com',
      'password': 'password123',
      'name': 'Dr. Sarah Wilson',
    },
  };

  // Helper method to check if email is a demo account
  static bool isDemoAccount(String email) {
    return demoCredentials.values.any((creds) => creds['email'] == email);
  }

  // Get role from demo email
  static String? getRoleFromEmail(String email) {
    for (var entry in demoCredentials.entries) {
      if (entry.value['email'] == email) {
        return entry.key;
      }
    }
    return null;
  }

  // Get name from demo email
  static String? getNameFromEmail(String email) {
    for (var entry in demoCredentials.entries) {
      if (entry.value['email'] == email) {
        return entry.value['name'];
      }
    }
    return null;
  }
}
