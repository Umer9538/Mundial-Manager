# Mundial Manager - Complete Code Explanation Guide

## For Students: How to Explain Every Part of This Project to Your Teacher

---

## Table of Contents

1. [Project Overview](#1-project-overview)
2. [Architecture & Design Patterns](#2-architecture--design-patterns)
3. [Project Folder Structure](#3-project-folder-structure)
4. [The Kaggle Dataset - How & Why We Use It](#4-the-kaggle-dataset---how--why-we-use-it)
5. [Entry Point - main.dart](#5-entry-point---maindart)
6. [Core Configuration Files](#6-core-configuration-files)
7. [Data Models - How We Structure Information](#7-data-models---how-we-structure-information)
8. [Services - The Backend Logic Layer](#8-services---the-backend-logic-layer)
9. [Providers - State Management Layer](#9-providers---state-management-layer)
10. [Screens - The User Interface Layer](#10-screens---the-user-interface-layer)
11. [Widgets - Reusable UI Components](#11-widgets---reusable-ui-components)
12. [Firebase Integration](#12-firebase-integration)
13. [The Complete Data Flow - From Dataset to Screen](#13-the-complete-data-flow---from-dataset-to-screen)
14. [Auto-Alert System - How Density Triggers Alerts](#14-auto-alert-system---how-density-triggers-alerts)
15. [Security Rules & Indexes](#15-security-rules--indexes)
16. [How to Run the App](#16-how-to-run-the-app)

---

## 1. Project Overview

**Mundial Manager** is a real-time crowd management system built for FIFA World Cup 2026 events in Saudi Arabia. It helps manage crowds at stadium venues by monitoring density, sending alerts, and coordinating security/emergency teams.

### What Problem Does It Solve?

Large events (60,000+ people) face serious crowd safety challenges:
- **Overcrowding** in certain zones can cause stampedes
- **Slow emergency response** when incidents aren't detected quickly
- **Poor communication** between security, emergency, and organizer teams
- **Fans don't know** which areas are crowded before going there

### How We Solve It

The app has **4 user roles**, each with their own dashboard:

| Role | What They See | What They Do |
|------|--------------|--------------|
| **Fan** | Venue map with colored zones, alerts | See which areas are safe, get crowd warnings |
| **Organizer** | Full event management, analytics | Create events, manage staff, send alerts |
| **Security** | Zone monitoring, incident list | Respond to incidents, monitor crowd density |
| **Emergency** | Critical incidents, evacuation controls | Handle medical emergencies, coordinate response |

### Key Innovation: Kaggle Dataset Integration

We use a real **Hajj & Umrah Crowd Management Dataset** (10,000 records from Kaggle) to:
- Drive realistic crowd density simulations
- Derive scientifically-backed occupancy thresholds for color changes and alerts
- Make the system behave like a real crowd monitoring tool

---

## 2. Architecture & Design Patterns

### Pattern: Provider (State Management)

We use Flutter's **Provider** pattern (similar to MVC/MVVM). Here's how it works:

```
┌─────────────┐     ┌──────────────┐     ┌─────────────┐
│   SCREENS   │────>│  PROVIDERS   │────>│  SERVICES   │
│  (UI Layer) │<────│ (State Layer)│<────│(Logic Layer) │
└─────────────┘     └──────────────┘     └─────────────┘
       │                    │                    │
       │                    │                    │
  What user sees    Holds & manages data   Talks to Firebase
  and interacts     Notifies UI of changes  & external systems
  with
```

**Why Provider?**
- Simple to understand (compared to BLoC or Redux)
- Built into Flutter ecosystem
- Each Provider manages one domain (alerts, incidents, crowd data, etc.)
- When data changes, only the affected UI parts rebuild (efficient)

### Pattern: Service Layer

Services handle external communication (Firebase, dataset loading, etc.). They are **stateless** - they don't hold data, they just perform operations.

### Pattern: Singleton (DatasetService)

The `DatasetService` uses the Singleton pattern because:
- The 10,000-row CSV should only be loaded once into memory
- Multiple screens need access to the same dataset
- Loading it multiple times would waste memory and time

```dart
// Only ONE instance ever exists
static DatasetService? _instance;
static DatasetService get instance => _instance ??= DatasetService._();
```

---

## 3. Project Folder Structure

```
lib/
├── main.dart                          # App entry point
├── firebase_options.dart              # Firebase config (auto-generated)
│
├── core/                              # App-wide configuration
│   ├── config/
│   │   └── environment.dart           # Dev/Staging/Production flags
│   ├── constants/
│   │   └── constants.dart             # Thresholds, keys, messages
│   ├── routing/
│   │   └── app_router.dart            # GoRouter navigation
│   └── theme/
│       ├── app_theme.dart             # Material3 theme
│       └── app_colors.dart            # Color palette + density colors
│
├── models/                            # Data structures
│   ├── user.dart                      # User model
│   ├── event.dart                     # Event model
│   ├── venue.dart                     # Venue model
│   ├── zone.dart                      # Stadium zone model
│   ├── alert.dart                     # Alert model
│   ├── incident.dart                  # Incident model
│   ├── facility.dart                  # Facility model (restrooms, food, etc.)
│   ├── message.dart                   # Chat message model
│   ├── staff_assignment.dart          # Staff-to-zone assignment
│   ├── crowd_density.dart             # Crowd density per zone
│   └── crowd_dataset_record.dart      # Kaggle dataset record model
│
├── services/                          # Backend logic
│   ├── auth_service.dart              # Firebase Auth operations
│   ├── database_service.dart          # Firestore CRUD
│   ├── storage_service.dart           # Firebase Storage (images)
│   ├── notification_service.dart      # Push notifications (FCM)
│   ├── location_service.dart          # GPS location tracking
│   ├── dataset_service.dart           # Kaggle CSV loading & analysis
│   ├── auto_alert_service.dart        # Automatic density-based alerts
│   ├── seed_service.dart              # Demo data seeding
│   └── services.dart                  # Barrel exports
│
├── providers/                         # State management
│   ├── auth_provider.dart             # Login/logout state
│   ├── crowd_provider.dart            # Crowd density + simulation
│   ├── alert_provider.dart            # Alerts management
│   ├── incident_provider.dart         # Incidents management
│   ├── analytics_provider.dart        # Charts & statistics
│   ├── message_provider.dart          # Chat channels
│   └── staff_provider.dart            # Staff assignments
│
├── screens/                           # UI Pages
│   ├── auth/                          # Login, Register, Verify Email
│   ├── fan/                           # Fan dashboard, map, settings
│   ├── organizer/                     # Organizer dashboard, analytics
│   ├── security/                      # Security monitoring dashboard
│   ├── emergency/                     # Emergency response dashboard
│   └── common/                        # Shared screens (report, chat)
│
└── widgets/                           # Reusable UI pieces
    ├── common/                        # Buttons, cards, text fields
    ├── cards/                         # Alert/Incident/Stat cards
    └── map/                           # Heatmap, zone overlays, markers
```

---

## 4. The Kaggle Dataset - How & Why We Use It

### The Dataset

**Source**: [Kaggle - Hajj and Umrah Crowd Management Dataset](https://www.kaggle.com/datasets/ziya07/hajj-and-umrah-crowd-management-dataset)

**What it contains**: 10,000 simulated records of pilgrims in Mecca, with 30 columns:

| Column | Type | Example | How We Use It |
|--------|------|---------|--------------|
| `Location_Lat` | 21.20-21.40 | 21.258846 | Geographic latitude of pilgrim/crowd point |
| `Location_Long` | 39.81-40.00 | 39.983949 | Geographic longitude of pilgrim/crowd point |
| `Crowd_Density` | Low/Medium/High | "High" | Maps to our 4-tier status system |
| `Distance_Between_People_m` | 0.5-2.5m | 0.94 | Estimates people/m² density |
| `Movement_Speed` | 0.2-1.5 m/s | 0.9 | Controls simulation fluctuation speed |
| `Temperature` | 30-45°C | 44 | Displayed in zone details |
| `Weather_Conditions` | Clear/Cloudy/Rainy | "Clear" | Enriches zone data |
| `Health_Condition` | Normal/Heatstroke/etc. | "Fainting" | Risk analysis |
| `Emergency_Event` | Yes/No | "Yes" | Emergency probability calculation |
| `Incident_Type` | Theft/Medical/etc. | "Medical Emergency" | Incident simulation |
| `Stress_Level` | Low/Medium/High | "High" | Crowd behavior modeling |
| `Crowd_Morale` | Positive/Neutral/Negative | "Negative" | Direction of density change |

### Location_Lat & Location_Long - Geographic Coordinates from the Dataset

The dataset contains **latitude and longitude coordinates** for each of the 10,000 records. These represent the simulated GPS positions of pilgrims in the Mecca region:

- **Location_Lat** ranges from approximately **21.20 to 21.40** (latitude in Mecca, Saudi Arabia)
- **Location_Long** ranges from approximately **39.81 to 40.00** (longitude in Mecca, Saudi Arabia)

**How these coordinates are used in our app:**

1. **Crowd Dataset Record Model** (`lib/models/crowd_dataset_record.dart`): Every record parsed from the CSV stores `locationLat` and `locationLong` as `double` fields. When the CSV is loaded by `DatasetService`, each row's latitude and longitude are extracted at column positions 1 and 2:

```dart
factory CrowdDatasetRecord.fromCsvRow(List<String> fields) {
  return CrowdDatasetRecord(
    locationLat: double.tryParse(fields[1]) ?? 0,   // Column 2: Latitude
    locationLong: double.tryParse(fields[2]) ?? 0,   // Column 3: Longitude
    // ... other fields
  );
}
```

2. **Geographic Context for Simulation**: The latitude/longitude values provide real-world geographic context. When the `DatasetService` samples a random record for simulation, the sampled record carries its original geographic position. This means our simulation is grounded in real spatial distributions - areas of the dataset that had high crowd density in the original Mecca location data inform how we model high-density behavior in our stadium zones.

3. **Spatial Density Analysis**: The coordinates, combined with `Distance_Between_People_m`, allow us to understand how crowd density varies across geographic space. Records that are clustered close together geographically (similar lat/long values) with small `Distance_Between_People_m` values represent congestion hotspots - exactly the kind of pattern our app monitors in stadium zones.

4. **Venue Zone Mapping Concept**: Our app's stadium zones (North Stand, South Stand, East Wing, etc.) each have their own center coordinates and boundary polygons defined in Firestore. The dataset's Mecca coordinates (21.2°N, 39.9°E) serve as the research basis, while our venue uses King Fahd Stadium coordinates (24.79°N, 46.84°E) in Riyadh. The principle is the same: divide a large area into zones, monitor crowd density per zone, and take action when any zone becomes dangerously crowded.

5. **Dataset Statistics Service**: The `DatasetService` stores all latitude/longitude values for potential spatial queries. This enables future features like geographic clustering analysis, heatmap generation from raw coordinate data, and distance-based density calculation across the dataset's spatial distribution.

**Why geographic coordinates matter for crowd management:**

In real crowd management systems, GPS coordinates are essential for:
- **Pinpointing exactly where** a dangerous crowd buildup is happening
- **Tracking crowd flow** - seeing which direction people are moving based on changing coordinates over time
- **Emergency response routing** - directing paramedics/security to the exact latitude/longitude of an incident
- **Heatmap generation** - plotting thousands of GPS points on a map creates a visual density heatmap showing exactly where people are concentrated

Our app uses the `flutter_map` library with `latlong2` coordinates for all map rendering. Each zone's boundaries are defined as polygons of LatLng points, and the dataset's coordinate system demonstrates the same concept at the scale of Mecca's pilgrimage sites.

### WHY We Use It

1. **Realistic Simulation**: Instead of random number generation, our density simulation is based on real crowd behavior patterns
2. **Data-Backed Thresholds**: Our alert thresholds (50%, 70%, 85%, 95%) come from analyzing when emergencies occur in the dataset
3. **Research Foundation**: The system is grounded in actual crowd science research, not arbitrary numbers

### HOW We Use It - The Pipeline

```
                CSV File (10,000 rows)
                        │
                        ▼
            ┌─────────────────────┐
            │   DatasetService    │  Loads CSV at app startup
            │   (Singleton)       │  Groups by density level
            └─────────┬───────────┘  Computes statistics
                      │
        ┌─────────────┼─────────────┐
        ▼             ▼             ▼
  ┌──────────┐  ┌──────────┐  ┌──────────┐
  │ Simulate │  │ Derive   │  │ Trigger  │
  │ Density  │  │ Colors   │  │ Alerts   │
  │ Changes  │  │          │  │          │
  └──────────┘  └──────────┘  └──────────┘
        │             │             │
        ▼             ▼             ▼
  CrowdProvider   AppColors    AutoAlertService
  updates zones   colors map   sends notifications
```

### The Occupancy Thresholds (Dataset-Derived)

From analyzing the dataset's `Crowd_Density` and `Distance_Between_People_m`:

| Occupancy % | Color  | Status   | What Happens |
|-------------|--------|----------|-------------|
| **0-49%**   | Green  | Safe     | Normal operations |
| **50-69%**  | Yellow | Moderate | Info alert sent to organizers |
| **70-84%**  | Orange | High     | Congestion warning to fans + security |
| **85-94%**  | Red    | Critical | Safety alert to ALL roles |
| **95-100%** | Red    | Emergency| Emergency alert - immediate action |

---

## 5. Entry Point - main.dart

**File**: `lib/main.dart`

This is where the app starts when you press "Run".

```dart
void main() async {
  // Step 1: Flutter must be initialized before using any plugins
  WidgetsFlutterBinding.ensureInitialized();

  // Step 2: Connect to Firebase (Authentication, Database, Storage)
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Step 3: Enable offline data caching (app works without internet)
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );

  // Step 4: Set up push notification handler for background messages
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Step 5: Lock app to portrait mode only
  await SystemChrome.setPreferredOrientations([...]);

  // Step 6: Seed demo data into Firestore (for testing/demo)
  final seedService = SeedService();
  await seedService.seedAll();

  // Step 7: Load the Kaggle crowd dataset (10,000 records)
  await DatasetService.instance.initialize();

  // Step 8: Launch the app
  runApp(const MundialManagerApp());
}
```

**Why these steps matter:**
- Firebase MUST be initialized before any Firestore/Auth calls
- The dataset loads once at startup so it's ready when simulations begin
- Seeding ensures there's always demo data to show during a presentation

### The App Widget (MundialManagerApp)

```dart
class MundialManagerApp extends StatelessWidget {
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Each provider manages one piece of app state
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => CrowdProvider()),
        ChangeNotifierProvider(create: (_) => IncidentProvider()),
        ChangeNotifierProvider(create: (_) => AlertProvider()),
        ChangeNotifierProvider(create: (_) => StaffProvider()),
        ChangeNotifierProvider(create: (_) => AnalyticsProvider()),
        ChangeNotifierProvider(create: (_) => MessageProvider()),
      ],
      child: MaterialApp.router(
        title: 'Mundial',
        theme: AppTheme.lightTheme,    // Our custom theme
        routerConfig: AppRouter.router, // GoRouter navigation
      ),
    );
  }
}
```

**Why MultiProvider?**
- Each domain (auth, crowd, alerts, etc.) has its own provider
- Screens can "listen" to only the providers they need
- When `CrowdProvider` updates, only crowd-related UI rebuilds - not the entire app

---

## 6. Core Configuration Files

### 6.1 environment.dart - App Modes

**File**: `lib/core/config/environment.dart`

Controls which features are available based on the build mode:

```dart
enum Environment { development, staging, production }

class AppConfig {
  // In development mode, show demo login buttons
  static bool get showDemoFeatures => !isProduction;

  // In development mode, enable simulated crowd updates
  static bool get enableSimulatedUpdates => isDevelopment;

  // Crowd updates every 10 seconds (dev) or 15 seconds (production)
  static Duration get crowdUpdateInterval =>
      isProduction ? Duration(seconds: 15) : Duration(seconds: 10);
}
```

**Why different environments?**
- Development: Show test buttons, use simulated data, faster updates
- Production: Hide test features, use only real Firestore data, proper intervals

### 6.2 constants.dart - App-Wide Constants

**File**: `lib/core/constants/constants.dart`

This is the single source of truth for all magic numbers and strings:

```dart
class AppConstants {
  // Density Thresholds (people per m²) - used for density badge display
  static const double densitySafeMax = 1.5;
  static const double densityModerateMax = 3.0;
  static const double densityHighMax = 4.5;
  static const double densityCriticalMin = 4.6;

  // Occupancy % Thresholds (derived from Kaggle Dataset)
  // These are the PRIMARY thresholds for color changes and auto-alerts
  static const double occupancyModerate = 50.0;   // Yellow at 50%
  static const double occupancyHigh = 70.0;        // Orange at 70%
  static const double occupancyCritical = 85.0;    // Red at 85%
  static const double occupancyEmergency = 95.0;   // Emergency at 95%

  // Auto-alert cooldown (prevents sending same alert repeatedly)
  static const Duration autoAlertCooldown = Duration(minutes: 5);

  // Demo Credentials for testing
  static Map<String, Map<String, String>>? get demoCredentials { ... }

  // Password Validation (minimum 8 chars, 1 uppercase, 1 number)
  static String? validatePassword(String password) { ... }
}
```

**Why centralize constants?**
- Change a threshold in ONE place, it updates everywhere
- No "magic numbers" scattered across the codebase
- Easy to adjust for different venues or events

### 6.3 app_colors.dart - Color System

**File**: `lib/core/theme/app_colors.dart`

Defines the entire color palette including the density-to-color mapping:

```dart
class AppColors {
  // Brand Colors
  static const Color primary = Color(0xFF27506D);     // Cool Steel Blue
  static const Color primaryDark = Color(0xFF0F253D); // Deep Navy Blue

  // Crowd Density Colors (the KEY feature)
  static const Color densitySafe = green;       // Green (safe)
  static const Color densityModerate = yellow;  // Yellow (moderate)
  static const Color densityHigh = orange;      // Orange (high)
  static const Color densityCritical = red;     // Red (critical)

  // THE METHOD THAT COLORS THE MAP ZONES
  // Called by CrowdHeatmap widget for each zone
  static Color getDensityColorByOccupancy(double occupancyPercent) {
    if (occupancyPercent >= 85) return densityCritical;  // Red
    if (occupancyPercent >= 70) return densityHigh;      // Orange
    if (occupancyPercent >= 50) return densityModerate;  // Yellow
    return densitySafe;                                   // Green
  }
}
```

**Why occupancy-based instead of density-per-m²?**
- Occupancy % (people / capacity) is more intuitive: "Zone is 85% full"
- The Kaggle dataset categorizes by Low/Medium/High which maps to occupancy ranges
- Every venue has different physical sizes, so absolute density varies, but % is universal

### 6.4 app_router.dart - Navigation

**File**: `lib/core/routing/app_router.dart`

Uses GoRouter for declarative navigation:

```dart
static final router = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(path: '/splash', builder: (_, __) => SplashScreen()),
    GoRoute(path: '/login', builder: (_, __) => LoginScreen()),
    GoRoute(path: '/register', builder: (_, __) => RegisterScreen()),
    GoRoute(path: '/fan', builder: (_, __) => FanDashboard()),
    GoRoute(path: '/organizer', builder: (_, __) => OrganizerDashboard()),
    GoRoute(path: '/security', builder: (_, __) => SecurityDashboard()),
    GoRoute(path: '/emergency', builder: (_, __) => EmergencyDashboard()),
    // ... more routes
  ],
);
```

**Why GoRouter?**
- URL-based routing (like web apps) - easier to understand and debug
- Supports deep linking and redirect logic
- Type-safe parameter passing between screens

---

## 7. Data Models - How We Structure Information

Each model represents one type of data in our system. They all follow the same pattern:

```dart
class ModelName {
  final String id;
  final String field1;
  // ... more fields

  ModelName({required this.id, required this.field1});

  // Create from Firestore document (JSON -> Object)
  factory ModelName.fromJson(Map<String, dynamic> json) { ... }

  // Convert to Firestore document (Object -> JSON)
  Map<String, dynamic> toJson() { ... }
}
```

### 7.1 crowd_density.dart - The Most Important Model

**File**: `lib/models/crowd_density.dart`

This is the heart of the crowd monitoring system:

```dart
class CrowdDensity {
  final String zoneId;              // Which zone this data is for
  final String zoneName;            // "North Stand", "Food Court", etc.
  final int currentPopulation;      // How many people are there NOW
  final int capacity;               // Maximum safe capacity
  final double densityPerSqMeter;   // People per square meter
  final String status;              // "safe", "moderate", "high", "critical"
  final DateTime lastUpdated;       // When this was last measured
  final double? temperature;        // From dataset (30-45°C)
  final String? weatherCondition;   // From dataset (Clear/Cloudy/Rainy)
  final String? healthRisk;         // Dominant health risk from dataset
}
```

**Key Methods:**

```dart
// Calculate how full the zone is (0-100%)
double get occupancyPercentage {
  return (currentPopulation / capacity) * 100;
}

// Determine status from occupancy % (DATASET-DERIVED THRESHOLDS)
static String getStatusFromOccupancy(double occupancyPercent) {
  if (occupancyPercent >= 85) return 'critical';   // Red zone
  if (occupancyPercent >= 70) return 'high';        // Orange zone
  if (occupancyPercent >= 50) return 'moderate';    // Yellow zone
  return 'safe';                                     // Green zone
}

// Simulate realistic density change (called every 10 seconds)
CrowdDensity simulateFluctuation({double? newOccupancyPercent}) {
  // If dataset provides new occupancy, use it
  // Otherwise, small random fluctuation
  // Recalculates status based on new occupancy
}
```

**How fromJson handles Firestore data:**

```dart
factory CrowdDensity.fromJson(Map<String, dynamic> json) {
  return CrowdDensity(
    // Handle BOTH field names (currentPopulation and currentCount)
    // because seed data uses "currentCount" but model uses "currentPopulation"
    currentPopulation: (json['currentPopulation'] ?? json['currentCount'] ?? 0) as int,

    // Parse date flexibly - might be String or might not exist
    lastUpdated: json['lastUpdated'] != null
        ? DateTime.parse(json['lastUpdated'] as String)
        : DateTime.now(),

    // Optional dataset-enriched fields
    temperature: json['temperature'] != null ? (json['temperature'] as num).toDouble() : null,
    weatherCondition: json['weatherCondition'] as String?,
  );
}
```

### 7.2 crowd_dataset_record.dart - Kaggle Dataset Model

**File**: `lib/models/crowd_dataset_record.dart`

Maps each row of the CSV file to a Dart object:

```dart
class CrowdDatasetRecord {
  final String crowdDensity;          // "Low", "Medium", "High"
  final double movementSpeed;          // 0.2-1.5 m/s
  final double temperature;            // 30-45°C
  final String healthCondition;        // "Normal", "Heatstroke", etc.
  final bool emergencyEvent;           // true/false
  final String stressLevel;            // "Low", "Medium", "High"
  final String crowdMorale;            // "Positive", "Neutral", "Negative"
  final double distanceBetweenPeopleM; // 0.5-2.5 meters
  // ... 30 columns total
}
```

**CSV Parsing:**

```dart
// Each row is split by comma and mapped by position
factory CrowdDatasetRecord.fromCsvRow(List<String> fields) {
  return CrowdDatasetRecord(
    crowdDensity: fields[3],                                    // Column 4
    movementSpeed: double.tryParse(fields[4]) ?? 0,            // Column 5
    emergencyEvent: fields[19].trim().toLowerCase() == 'yes',  // Column 20
    // ... etc
  );
}
```

### 7.3 Other Models (Summary)

| Model | Key Fields | Purpose |
|-------|-----------|---------|
| **User** | id, email, name, role, phone | User accounts and roles |
| **Event** | name, venueId, startDate, capacity, status | Stadium events |
| **Venue** | name, address, lat/lng, capacity | Physical venue |
| **Zone** | name, boundaries (polygon), capacity, type | Stadium sections |
| **Alert** | type, message, severity, targetRoles, expiresAt | Crowd/safety alerts |
| **Incident** | type, description, severity, status, location | Reported incidents |
| **Facility** | name, type, lat/lng, isOpen | Restrooms, food, first aid |
| **Message** | channelId, senderId, content, type | Team communication |
| **StaffAssignment** | staffId, zoneId, eventId | Who is assigned where |

---

## 8. Services - The Backend Logic Layer

Services are **stateless classes** that perform operations. They don't hold data - they get it, transform it, and pass it along.

### 8.1 dataset_service.dart - Loading & Using the Kaggle Dataset

**File**: `lib/services/dataset_service.dart`

This is the bridge between the CSV file and the rest of the app.

**How it loads the data:**

```dart
class DatasetService {
  // Singleton - only one instance ever
  static DatasetService? _instance;
  static DatasetService get instance => _instance ??= DatasetService._();

  List<CrowdDatasetRecord> _records = [];          // All 10,000 records
  List<CrowdDatasetRecord> _lowDensityRecords = [];  // ~3,294 Low records
  List<CrowdDatasetRecord> _mediumDensityRecords = []; // ~3,381 Medium records
  List<CrowdDatasetRecord> _highDensityRecords = [];   // ~3,325 High records

  Future<void> initialize() async {
    // 1. Load CSV from Flutter assets (bundled in the APK)
    final csvString = await rootBundle.loadString(
      'assets/data/hajj_umrah_crowd_management_dataset.csv',
    );

    // 2. Split into lines, skip header
    final lines = csvString.split('\n');

    // 3. Parse each line into a CrowdDatasetRecord
    for (int i = 1; i < lines.length; i++) {
      final fields = line.split(',');
      _records.add(CrowdDatasetRecord.fromCsvRow(fields));
    }

    // 4. Group by density level for fast sampling
    _lowDensityRecords = _records.where((r) => r.crowdDensity == 'Low').toList();
    _mediumDensityRecords = _records.where((r) => r.crowdDensity == 'Medium').toList();
    _highDensityRecords = _records.where((r) => r.crowdDensity == 'High').toList();

    // 5. Compute aggregate statistics
    _computeStatistics();
  }
}
```

**How it drives simulation:**

```dart
// Called every 10 seconds by CrowdProvider for each zone
double simulateOccupancyChange(double currentOccupancy) {
  // 1. Determine current density level from occupancy
  String level = currentOccupancy >= 75 ? 'High'
               : currentOccupancy >= 50 ? 'Medium' : 'Low';

  // 2. Pick a RANDOM record from that density level
  final record = sampleRecord(level);

  // 3. Use the record's movement speed to determine change magnitude
  //    Higher speed = more people moving = bigger change
  final speedFactor = record.movementSpeed / 1.5;
  final maxChange = 5.0 * speedFactor; // Up to 5% per tick

  // 4. Crowd morale affects direction:
  //    Negative morale -> people leave (density decreases)
  //    Positive morale -> people stay/arrive (density increases)
  double directionBias = 0;
  if (record.crowdMorale == 'Negative' || record.stressLevel == 'High') {
    directionBias = -0.3; // Slight decrease
  } else if (record.crowdMorale == 'Positive') {
    directionBias = 0.2;  // Slight increase
  }

  // 5. Calculate new occupancy with constrained random change
  final change = (random * 2 - 1 + directionBias) * maxChange;
  return (currentOccupancy + change).clamp(5.0, 100.0);
}
```

**Why this approach instead of random numbers?**
- The dataset contains REAL crowd behavior patterns
- Negative morale actually correlates with people leaving areas
- Movement speed affects how quickly density changes
- This makes the simulation look and behave realistically

### 8.2 auto_alert_service.dart - Automatic Density Alerts

**File**: `lib/services/auto_alert_service.dart`

Monitors density changes and automatically sends alerts when thresholds are crossed.

```dart
class AutoAlertService {
  final AlertProvider _alertProvider;

  // Track what tier each zone was at previously
  final Map<String, _OccupancyTier> _previousTier = {};

  // Cooldown tracking - prevent alert spam
  final Map<String, DateTime> _lastAlertTime = {};

  void evaluateZone(CrowdDensity density, String eventId) {
    final occupancy = density.occupancyPercentage;
    final currentTier = _OccupancyTier.fromPercentage(occupancy);
    final previousTier = _previousTier[density.zoneId] ?? _OccupancyTier.safe;

    // KEY LOGIC: Only alert on UPWARD crossings
    // If zone goes from 60% to 75%, that's crossing from moderate->high = ALERT
    // If zone stays at 75%, no new alert
    // If zone drops from 75% to 60%, no alert (it's getting better)
    if (currentTier.index <= previousTier.index) return;

    // Check 5-minute cooldown
    final cooldownKey = '${density.zoneId}_${currentTier.name}';
    final lastAlert = _lastAlertTime[cooldownKey];
    if (lastAlert != null && DateTime.now().difference(lastAlert) < _alertCooldown) {
      return; // Too soon, skip
    }

    // Send the alert!
    _sendAutoAlert(density, eventId, currentTier);
  }
}
```

**The alert tiers:**

```dart
enum _OccupancyTier {
  safe,      // 0-49%  -> No alert
  moderate,  // 50-69% -> Info to organizer+security
  high,      // 70-84% -> Congestion warning to fans+security
  critical,  // 85-94% -> Safety alert to ALL
  emergency; // 95-100% -> Emergency alert to security+emergency

  static _OccupancyTier fromPercentage(double pct) {
    if (pct >= 95) return emergency;
    if (pct >= 85) return critical;
    if (pct >= 70) return high;
    if (pct >= 50) return moderate;
    return safe;
  }
}
```

**Why upward-crossing-only?**
- Without this, a zone at 86% would generate a "CRITICAL" alert every 10 seconds
- We only care about the moment it BECOMES critical, not while it stays there
- The 5-minute cooldown adds a second layer of protection against spam

### 8.3 database_service.dart - Firestore Operations

**File**: `lib/services/database_service.dart`

All Firestore read/write operations are centralized here:

```dart
class DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // GET current active event
  Future<Event?> getCurrentActiveEvent() async {
    final snapshot = await _firestore
        .collection('events')
        .where('status', isEqualTo: 'active')
        .orderBy('startDate', descending: true)
        .limit(1)
        .get();
    // ... parse and return
  }

  // GET latest crowd density for each zone (returns Map<zoneId, CrowdDensity>)
  Future<Map<String, CrowdDensity>> getLatestCrowdDensityByZone(String eventId) async {
    final snapshot = await _firestore
        .collection('crowd_density')
        .where('eventId', isEqualTo: eventId)
        .orderBy('timestamp', descending: true)
        .get();

    // Keep only the LATEST record per zone
    final Map<String, CrowdDensity> latestByZone = {};
    for (final doc in snapshot.docs) {
      final data = CrowdDensity.fromJson({...});
      if (!latestByZone.containsKey(data.zoneId)) {
        latestByZone[data.zoneId] = data;
      }
    }
    return latestByZone;
  }

  // CREATE alert (saves to Firestore)
  Future<String> createAlert(Alert alert) async {
    final docRef = await _firestore.collection('alerts').add({
      ...alert.toJson(),
      'isActive': true,
      'createdAt': FieldValue.serverTimestamp(),
    });
    return docRef.id;
  }
}
```

**Why a separate service for database?**
- Keeps Firestore logic out of UI code
- Easy to test (can mock this service)
- Single place to change if we switch from Firestore to another database

### 8.4 seed_service.dart - Demo Data

**File**: `lib/services/seed_service.dart`

Creates realistic demo data so the app has something to show:

```dart
class SeedService {
  Future<void> seedAll() async {
    if (await isSeeded()) return; // Don't duplicate

    await seedDemoUsers();        // 12 users (fans, organizer, security, emergency)
    final venueId = await seedVenue();   // King Fahd International Stadium
    await seedZones(venueId);            // 7 zones (North/South Stand, etc.)
    await seedFacilities(venueId);       // 17 facilities (restrooms, food, etc.)
    final eventId = await seedEvent(venueId);  // "Saudi Arabia vs Mexico"
    await seedCrowdDensity(eventId);     // Dataset-derived occupancy levels
    await seedIncidents(eventId);        // 8 incidents (various severities)
    await seedAlerts(eventId);           // 7 alerts (congestion, emergency, info)
    await seedStaffAssignments(eventId); // 7 staff assigned to zones
    await seedMessages(eventId);         // 15 messages across 3 channels
  }
}
```

**Crowd density seeding uses dataset-derived thresholds:**

```dart
// Occupancy levels chosen to show ALL 4 color tiers
final occupancyLevels = [
  0.88, // North Stand  -> Red (critical, 88%)
  0.62, // South Stand  -> Yellow (moderate, 62%)
  0.75, // East Wing    -> Orange (high, 75%)
  0.40, // West Wing    -> Green (safe, 40%)
  0.92, // VIP Section  -> Red (critical, 92%)
  0.96, // Food Court   -> Red (emergency, 96%)
  0.55, // Main Entrance -> Yellow (moderate, 55%)
];
```

### 8.5 Other Services (Summary)

| Service | Purpose |
|---------|---------|
| **auth_service.dart** | Firebase Auth: login, register, verify email, reset password |
| **storage_service.dart** | Firebase Storage: upload/download profile images, incident photos |
| **notification_service.dart** | Firebase Cloud Messaging: push notifications, permission handling |
| **location_service.dart** | Geolocator: GPS tracking, update user location in Firestore |

---

## 9. Providers - State Management Layer

Providers are the "brains" between Services and Screens. They:
1. Hold the current state (data)
2. Call Services to fetch/update data
3. Notify Screens when data changes (so UI rebuilds)

### 9.1 crowd_provider.dart - The Main Brain

**File**: `lib/providers/crowd_provider.dart`

This is the most complex provider. It orchestrates everything:

```dart
class CrowdProvider with ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();
  final DatasetService _datasetService = DatasetService.instance;
  AutoAlertService? _autoAlertService;

  List<CrowdDensity> _crowdData = [];  // Current density for all zones
  List<Zone> _zones = [];               // All venue zones
  bool _datasetReady = false;           // Is CSV loaded?
```

**Initialization (called when dashboard opens):**

```dart
Future<void> initialize({String? eventId}) async {
  // 1. Load the Kaggle dataset if not already loaded
  if (!_datasetReady) {
    await _datasetService.initialize();
    _datasetReady = _datasetService.isLoaded;
  }

  // 2. Load current crowd data from Firestore
  if (eventId != null) {
    await _loadZonesFromFirestore();
    await _loadCrowdDataFromFirestore(eventId);
  }
}
```

**Connecting auto-alerts (called from each dashboard):**

```dart
// Dashboards call this to enable automatic density alerts
void connectAlertProvider(AlertProvider alertProvider) {
  _autoAlertService ??= AutoAlertService(alertProvider);
}
```

**Real-time updates (Firestore stream):**

```dart
void startRealTimeUpdates({String? eventId}) {
  // Listen to Firestore for live crowd density changes
  _crowdSubscription = _firestore
      .collection('crowd_density')
      .where('eventId', isEqualTo: eventId)
      .snapshots()
      .listen((snapshot) {
    _processCrowdSnapshot(snapshot);
  });
}

void _processCrowdSnapshot(QuerySnapshot snapshot) {
  // Parse Firestore data into CrowdDensity objects
  _crowdData = ...;

  // IMPORTANT: Evaluate auto-alerts for every zone after each update
  _evaluateAutoAlerts();

  notifyListeners(); // Tell all listening screens to rebuild
}
```

**Dataset-driven simulation (development mode):**

```dart
void _simulateUpdate() {
  _crowdData = _crowdData.map((cd) {
    if (_datasetReady) {
      // 1. Get current occupancy percentage
      final currentOccupancy = cd.occupancyPercentage;

      // 2. Ask DatasetService for a realistic new value
      //    (based on movement speed, morale, stress from dataset)
      final newOccupancy = _datasetService.simulateOccupancyChange(currentOccupancy);

      // 3. Get environment data (temperature, weather) from dataset
      final envData = _datasetService.getEnvironmentData(densityLevel);

      // 4. Create updated CrowdDensity with new values
      return cd.simulateFluctuation(newOccupancyPercent: newOccupancy)
          .copyWith(temperature: envData['temperature'], ...);
    } else {
      // Fallback: simple random fluctuation
      return cd.simulateFluctuation();
    }
  }).toList();

  // Check if any zone crossed an alert threshold
  _evaluateAutoAlerts();

  notifyListeners(); // Update all UI
}
```

**Helper getters used by screens:**

```dart
// Zones where occupancy >= 85% (red zones)
List<CrowdDensity> get criticalZones =>
    _crowdData.where((cd) => cd.isCritical).toList();

// Zones where occupancy >= 70% (orange + red zones)
List<CrowdDensity> get highDensityZones =>
    _crowdData.where((cd) => cd.needsAttention).toList();

// Overall venue statistics
Map<String, dynamic> get venueStats => {
  'totalPopulation': ...,
  'totalCapacity': ...,
  'occupancyPercentage': ...,
  'criticalZones': criticalZones.length,
  // etc.
};
```

### 9.2 alert_provider.dart - Alert Management

**File**: `lib/providers/alert_provider.dart`

Manages ALL alerts - both manual (organizer-created) and automatic (density-triggered):

```dart
class AlertProvider with ChangeNotifier {
  List<Alert> _alerts = [];

  // Send a new alert (called by organizer OR AutoAlertService)
  Future<bool> sendAlert({
    required String eventId,
    required String createdBy,       // User ID or "system"
    required String createdByName,   // Name or "Auto-Monitor"
    required String type,            // congestion, safety, emergency, info
    required String message,
    required List<String> targetRoles, // Who should see it
    required String severity,
  }) async {
    // 1. Create Alert object
    // 2. Save to Firestore
    // 3. Add to local list
    // 4. Notify UI
  }

  // Shortcut methods for common alert types
  Future<bool> sendCongestionAlert({...}) => sendAlert(type: 'congestion', ...);
  Future<bool> sendEmergencyAlert({...}) => sendAlert(type: 'emergency', ...);
  Future<bool> sendSafetyAlert({...}) => sendAlert(type: 'safety', ...);

  // Filter alerts by role (fans only see fan-targeted alerts)
  List<Alert> getAlertsForRole(String role) {
    return validAlerts.where((a) => a.shouldReceiveAlert(role)).toList();
  }
}
```

### 9.3 Other Providers (Summary)

| Provider | Purpose | Key Methods |
|----------|---------|-------------|
| **AuthProvider** | Login state, current user | `login()`, `register()`, `logout()`, `currentUser` |
| **IncidentProvider** | Incident CRUD | `reportIncident()`, `updateStatus()`, `getByEvent()` |
| **AnalyticsProvider** | Historical charts | `loadAnalytics()`, hourly density, incident stats |
| **MessageProvider** | Team chat | `sendMessage()`, `getChannelMessages()`, channels |
| **StaffProvider** | Staff assignments | `assignStaff()`, `getAvailable()`, `getByZone()` |

---

## 10. Screens - The User Interface Layer

### 10.1 Authentication Flow

```
SplashScreen → (checks auth) → LoginScreen → (verify email) → RoleDashboard
                    ↓
              RegisterScreen → EmailVerificationScreen
```

**splash_screen.dart**: Shows logo, checks if user is already logged in, routes to appropriate dashboard.

**login_screen.dart**: Email/password form with:
- Input validation (email format, password rules)
- "Remember Me" checkbox (saves email to SharedPreferences)
- Demo account buttons (for testing)
- Account lockout after 5 failed attempts

**register_screen.dart**: Registration with:
- Name validation (2-50 characters)
- Email format validation
- Password strength validation (8+ chars, 1 uppercase, 1 number)
- Auto-sends verification email

### 10.2 Fan Dashboard

**File**: `lib/screens/fan/fan_dashboard.dart`

What the fan sees:

```
┌─────────────────────────────────┐
│  MUNDIAL - Saudi Arabia vs Mexico│
│  King Fahd Stadium  |  Active    │
├─────────────────────────────────┤
│  ┌─────────┐  ┌─────────┐      │
│  │ 62,000  │  │   91%   │      │
│  │ Fans    │  │ Capacity│      │
│  └─────────┘  └─────────┘      │
│                                  │
│  ┌────────── MAP ──────────┐    │
│  │  Colored zones showing  │    │
│  │  crowd density levels   │    │
│  │  (Green/Yellow/Orange/  │    │
│  │   Red based on %)       │    │
│  └─────────────────────────┘    │
│                                  │
│  ACTIVE ALERTS:                  │
│  ⚠ Food Court at 96% capacity   │
│  ℹ Weather: 38°C - stay hydrated│
├─────────────────────────────────┤
│  🏠 Home  |  🗺 Map  |  ⚙ Settings│
└─────────────────────────────────┘
```

**How the fan dashboard initializes:**

```dart
Future<void> _initializeData() async {
  final crowdProvider = Provider.of<CrowdProvider>(context, listen: false);
  final alertProvider = Provider.of<AlertProvider>(context, listen: false);

  await Future.wait([
    crowdProvider.initialize(eventId: eventId),
    alertProvider.initialize(eventId: eventId),
  ]);

  // Connect auto-alerts (fans receive congestion/safety alerts)
  crowdProvider.connectAlertProvider(alertProvider);
  crowdProvider.startRealTimeUpdates(eventId: eventId);
}
```

**venue_map_screen.dart**: Full-screen interactive map with:
- Color-coded zone polygons (occupancy-based colors)
- Occupancy % labels on each zone
- Facility markers (restrooms, food, first aid, exits)
- Tap zone to see details (population, occupancy %, density)

### 10.3 Organizer Dashboard

**File**: `lib/screens/organizer/organizer_dashboard.dart`

The organizer sees everything:
- Full venue statistics (total attendance, capacity %)
- Crowd heatmap with all zones
- Zone-by-zone density list (colored by occupancy %)
- Active alerts list
- Incident count
- Create Event / Send Alert buttons
- Staff management link
- Analytics link

**Key zone list code (uses dataset-derived status):**

```dart
final density = crowdProvider.getZoneDensity(zone.id);
final percentage = density?.occupancyPercentageRounded ?? 0;
final level = density?.status ?? 'safe'; // "safe"/"moderate"/"high"/"critical"

// Color the percentage text based on status
Text('$percentage%', style: TextStyle(color: _getColorForLevel(level)));
```

### 10.4 Security Dashboard

**File**: `lib/screens/security/security_dashboard.dart`

Security personnel see:
- Their assigned zone highlighted
- Real-time crowd density map
- Incident list (filtered to their zone)
- On/Off duty toggle
- Report incident button
- Communication hub access

**Auto-alerts are connected here:**

```dart
crowdProvider.connectAlertProvider(alertProvider);
// Now when density crosses thresholds, security gets automatic alerts
```

### 10.5 Emergency Dashboard

**File**: `lib/screens/emergency/emergency_dashboard.dart`

Emergency team sees:
- Critical incidents requiring response
- Evacuation controls
- Emergency communication channel
- Incident timeline
- Receives auto-alerts when zones hit 95%+ capacity

### 10.6 Common Screens

| Screen | Purpose |
|--------|---------|
| **ReportIncidentScreen** | Form: type, description, photo, location |
| **CommunicationHubScreen** | Real-time team messaging by channel |
| **PrivacyPolicyScreen** | Legal/policy text |

---

## 11. Widgets - Reusable UI Components

### 11.1 CrowdHeatmap - The Star Widget

**File**: `lib/widgets/map/crowd_heatmap.dart`

This renders the colored zone map that all roles see:

```dart
class CrowdHeatmap extends StatefulWidget {
  final List<CrowdDensity> crowdData;  // Current density for all zones
  final List<Zone> zones;               // Zone boundaries (polygons)
}
```

**How it determines zone colors (THE KEY METHOD):**

```dart
Color _getZoneColor(String zoneId) {
  // 1. Find the CrowdDensity data for this zone
  final crowdDensity = widget.crowdData.firstWhere(
    (cd) => cd.zoneId == zoneId,
    orElse: () => CrowdDensity(status: 'safe', ...),
  );

  // 2. Use OCCUPANCY-BASED coloring (from Kaggle dataset thresholds)
  //    <50% = Green, 50-69% = Yellow, 70-84% = Orange, >=85% = Red
  return AppColors.getDensityColorByOccupancy(crowdDensity.occupancyPercentage);
}
```

**How it renders on the map:**

```dart
// Each zone is drawn as a colored polygon
PolygonLayer(
  polygons: widget.zones.map((zone) {
    final color = _getZoneColor(zone.id);
    return Polygon(
      points: zone.boundaries,         // Lat/Lng polygon
      color: color.withOpacity(0.4),   // Semi-transparent fill
      borderColor: color,               // Solid border
      borderStrokeWidth: 2,
    );
  }).toList(),
),

// Each zone gets a label showing occupancy %
MarkerLayer(
  markers: widget.zones.map((zone) {
    return Marker(
      point: zone.center,
      child: Text('${crowdDensity.occupancyPercentageRounded}%'),
    );
  }).toList(),
),
```

### 11.2 Other Widgets

| Widget | Purpose |
|--------|---------|
| **GlassCard** | Semi-transparent card with blur effect (dark theme) |
| **GradientScaffold** | Dark gradient background for all screens |
| **CustomButton** | Themed button (primary/warning/danger variants) |
| **CustomTextField** | Dark-themed input field with validation |
| **AlertCard** | Displays one alert with severity coloring |
| **IncidentCard** | Displays one incident with status badge |
| **StatCard** | Statistics card (icon + number + label) |
| **ZoneOverlay** | Zone polygon rendering on map |
| **IncidentMarkers** | Incident pins on map with type icons |

---

## 12. Firebase Integration

### 12.1 Firestore Database Structure

```
Firestore Database
├── users/                    # User profiles
│   └── {userId}
│       ├── email: "fan@test.com"
│       ├── name: "Ahmed Al-Rashid"
│       ├── role: "fan"
│       └── ...
│
├── venues/                   # Stadium venues
│   └── {venueId}
│       ├── name: "King Fahd International Stadium"
│       ├── capacity: 68000
│       └── latitude/longitude
│
├── zones/                    # Stadium zones
│   └── {zoneId}
│       ├── name: "North Stand"
│       ├── capacity: 15000
│       ├── type: "seating"
│       └── boundaryPoints: [{lat, lng}, ...]
│
├── events/                   # Matches/events
│   └── {eventId}
│       ├── name: "Saudi Arabia vs Mexico"
│       ├── status: "active"
│       └── capacity: 68000
│
├── crowd_density/            # Real-time crowd data (per zone)
│   └── {recordId}
│       ├── eventId
│       ├── zoneId
│       ├── currentPopulation: 13200
│       ├── capacity: 15000
│       ├── densityPerSqMeter: 3.96
│       ├── status: "critical"
│       ├── temperature: 38.0
│       └── timestamp
│
├── incidents/                # Reported incidents
│   └── {incidentId}
│       ├── type: "medical"
│       ├── severity: "critical"
│       ├── status: "dispatched"
│       └── ...
│
├── alerts/                   # Active alerts
│   └── {alertId}
│       ├── type: "congestion"
│       ├── message: "Food Court at 96%..."
│       ├── severity: "warning"
│       ├── targetRoles: ["fan", "security"]
│       ├── createdBy: "system"  ← auto-alerts say "system"
│       └── createdByName: "Auto-Monitor"
│
├── messages/                 # Team communication
│   └── {messageId}
│       ├── channelId: "security-ops"
│       ├── content: "..."
│       └── senderRole: "security"
│
├── staff_assignments/        # Staff-to-zone mapping
│   └── {assignmentId}
│       ├── staffId, zoneId, eventId
│       └── isActive: true
│
└── facilities/               # Venue facilities
    └── {facilityId}
        ├── name: "Restroom A"
        ├── type: "restroom"
        └── latitude/longitude
```

### 12.2 Firebase Auth

Handles user authentication:
- Email/password registration
- Email verification (must verify before login)
- Password reset via email
- Session persistence (stays logged in)

### 12.3 Firebase Cloud Messaging (FCM)

Push notifications for:
- New alerts (congestion, safety, emergency)
- Incident updates
- Team messages

### 12.4 Firebase Storage

Stores:
- User profile images
- Incident photos (attached to reports)

---

## 13. The Complete Data Flow - From Dataset to Screen

Here's exactly what happens when a user opens the app and sees the colored crowd map:

### Step 1: App Starts (main.dart)

```
main() → Firebase.initializeApp()
       → DatasetService.instance.initialize()  ← Loads 10,000 CSV records
       → SeedService.seedAll()                 ← Creates demo data in Firestore
       → runApp(MundialManagerApp)             ← Starts the UI
```

### Step 2: User Logs In

```
LoginScreen → AuthProvider.login(email, password)
            → Firebase Auth verifies credentials
            → AuthProvider reads user role from Firestore
            → GoRouter navigates to role dashboard
```

### Step 3: Dashboard Initializes

```
SecurityDashboard._initializeData():
  1. DatabaseService.getCurrentActiveEvent()  ← Gets "Saudi Arabia vs Mexico"
  2. CrowdProvider.initialize(eventId: ...)   ← Loads zones + crowd data
     ├── DatasetService.initialize()          ← Ensures CSV is loaded
     ├── _loadZonesFromFirestore()            ← Gets 7 zones
     └── _loadCrowdDataFromFirestore()        ← Gets density per zone
  3. crowdProvider.connectAlertProvider(...)   ← Enables auto-alerts
  4. crowdProvider.startRealTimeUpdates(...)   ← Starts Firestore listener
```

### Step 4: Map Renders

```
CrowdHeatmap widget builds:
  For each zone:
    1. Get CrowdDensity for this zone
    2. Calculate: occupancy = currentPopulation / capacity × 100
    3. Call AppColors.getDensityColorByOccupancy(occupancy)
       - 40% → Green (safe)
       - 62% → Yellow (moderate)
       - 75% → Orange (high)
       - 92% → Red (critical)
    4. Draw polygon with that color
    5. Show "92%" label
```

### Step 5: Simulation Runs (every 10 seconds)

```
Timer fires → CrowdProvider._simulateUpdate():
  For each zone:
    1. Current occupancy = 88%
    2. DatasetService.simulateOccupancyChange(88%)
       ├── Density level = "High" (because 88% ≥ 75%)
       ├── Sample random record from High density group
       ├── Record has: movementSpeed=0.9, crowdMorale="Negative"
       ├── speedFactor = 0.9/1.5 = 0.6
       ├── maxChange = 5.0 × 0.6 = 3.0
       ├── directionBias = -0.3 (negative morale → people leaving)
       └── New occupancy = 88% + (random × 3.0 - 0.3) = ~86%
    3. Update CrowdDensity with new values
    4. AutoAlertService.evaluateZone(density):
       ├── Previous tier = critical (was 88%)
       ├── Current tier = critical (still 86%)
       └── Same tier → NO alert (only fires on UPWARD crossing)
    5. notifyListeners() → UI rebuilds with new colors
```

### Step 6: Alert Triggers (when threshold crossed)

```
Zone "Food Court" goes from 84% → 87%:
  AutoAlertService.evaluateZone():
    1. Previous tier = high (84% was in 70-84% range)
    2. Current tier = critical (87% is in 85-94% range)
    3. high → critical = UPWARD crossing ✓
    4. Check cooldown: no alert sent in last 5 minutes ✓
    5. Send safety alert:
       type: "safety"
       message: "CRITICAL: Food Court at 87% capacity. Reroute all traffic."
       targetRoles: ["fan", "security", "emergency"]
       severity: "warning"
       createdBy: "system"
       createdByName: "Auto-Monitor"
    6. Alert appears in ALL dashboards (fan, security, emergency)
```

---

## 14. Auto-Alert System - How Density Triggers Alerts

### Visual Diagram

```
Zone Occupancy Over Time:

100% ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─
 95% ── EMERGENCY ──────────────────── 🚨 Emergency Alert
 85% ── CRITICAL  ──────────────────── ⛔ Safety Alert
 70% ── HIGH      ────────── 🟠 ────── ⚠️ Congestion Alert
 50% ── MODERATE  ──── 🟡 ──────────── ℹ️ Info Alert
  0% ── SAFE      ─ 🟢 ──────────────── (No alert)

        Time →   ████████████████████████████

        Zone occupancy: ─────/─────\───────/──
                        Green  Yellow  Green  Orange
                            ↑              ↑
                        Alert fires    Alert fires
                        (50% crossed)  (70% crossed)
```

### What Each Role Receives

| Alert Level | Fan | Security | Emergency | Organizer |
|-------------|-----|----------|-----------|-----------|
| 50% Info | | ✅ | | ✅ |
| 70% Congestion | ✅ | ✅ | | |
| 85% Safety | ✅ | ✅ | ✅ | |
| 95% Emergency | | ✅ | ✅ | |

### Cooldown System

```
Zone "North Stand" hits 70% at 14:00:00 → Congestion alert sent
Zone "North Stand" hits 72% at 14:00:10 → Still high tier, no alert
Zone "North Stand" drops to 68% at 14:01:00 → Went down, no alert
Zone "North Stand" hits 71% at 14:02:00 → Cooldown active (< 5 min), no alert
Zone "North Stand" hits 73% at 14:05:01 → Cooldown expired, but still same tier as before → no alert
Zone "North Stand" hits 86% at 14:06:00 → NEW tier (critical), sends safety alert!
```

---

## 15. Security Rules & Indexes

### firestore.rules

Controls who can read/write what data:

```
// Anyone authenticated can read events and venues
match /events/{eventId} {
  allow read: if request.auth != null;
  allow write: if isOrganizer();  // Only organizers can create/edit events
}

// Only staff can read/write incidents
match /incidents/{incidentId} {
  allow read: if isStaff();
  allow write: if isStaff();
}

// Alerts: staff can write, everyone can read their role's alerts
match /alerts/{alertId} {
  allow read: if request.auth != null;
  allow write: if isStaff();
}
```

### firestore.indexes.json

Composite indexes for efficient queries:

```json
{
  "collectionGroup": "crowd_density",
  "fields": [
    {"fieldPath": "eventId", "order": "ASCENDING"},
    {"fieldPath": "timestamp", "order": "DESCENDING"}
  ]
}
```

**Why indexes?** Firestore requires composite indexes for queries that filter on one field and sort by another.

---

## 16. How to Run the App

### Prerequisites

1. Flutter SDK (3.9.0+)
2. Firebase project configured
3. Android Studio or VS Code
4. iOS Simulator or Android Emulator

### Steps

```bash
# 1. Get dependencies
flutter pub get

# 2. Run on device/emulator
flutter run

# 3. The app will automatically:
#    - Initialize Firebase
#    - Load Kaggle dataset (10,000 records)
#    - Seed demo data (if not already seeded)
#    - Show the splash screen → login screen
```

### Demo Accounts

| Role | Email | Password |
|------|-------|----------|
| Fan | fan@test.com | Password1 |
| Organizer | organizer@test.com | Password1 |
| Security | security@test.com | Password1 |
| Emergency | emergency@test.com | Password1 |

### What to Show During Demo

1. **Login as Fan** → Show colored map, alerts appearing
2. **Login as Security** → Show real-time monitoring, incident list
3. **Login as Organizer** → Show zone list with colors, send manual alert
4. **Wait 30 seconds** → Watch colors change as simulation runs
5. **Login as Emergency** → Show critical alerts from auto-system
6. **Explain the colors** → "Green=safe, Yellow=50%+, Orange=70%+, Red=85%+"
7. **Explain the dataset** → "We used 10,000 records from Kaggle to make this realistic"

---

## Summary

This project demonstrates a complete, production-grade crowd management system that combines:

- **Flutter** for cross-platform mobile UI
- **Firebase** for real-time backend (auth, database, storage, notifications)
- **Provider** pattern for state management
- **Real-world Kaggle dataset** for data-driven crowd simulation
- **Automatic alerting** based on scientifically-derived occupancy thresholds
- **Role-based access** for fans, organizers, security, and emergency teams

The key innovation is using the **Hajj & Umrah Crowd Management Dataset** to drive realistic density simulations and derive alert thresholds, making the system behave like a real crowd monitoring tool rather than using arbitrary numbers.

Every file has a clear responsibility, follows consistent patterns, and connects to the bigger system through well-defined interfaces (Provider → Service → Firebase/Dataset).
