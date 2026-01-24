import 'package:latlong2/latlong.dart';
import 'package:uuid/uuid.dart';
import '../../models/user.dart';
import '../../models/event.dart';
import '../../models/venue.dart';
import '../../models/zone.dart';
import '../../models/incident.dart';
import '../../models/alert.dart';
import '../../models/crowd_density.dart';

class DummyData {
  static const _uuid = Uuid();

  // King Fahd International Stadium, Riyadh, Saudi Arabia
  static const double stadiumLat = 24.7257;
  static const double stadiumLng = 46.8222;

  // ========== USERS ==========
  static final List<User> users = [
    // Fan
    User(
      id: 'user_fan_1',
      email: 'fan@test.com',
      name: 'James Miller',
      role: 'fan',
      phoneNumber: '+1234567890',
      profileImageUrl: null,
      locationSharingEnabled: true,
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
      lastLogin: DateTime.now(),
    ),

    // Organizer
    User(
      id: 'user_organizer_1',
      email: 'organizer@test.com',
      name: 'Maria Santos',
      role: 'organizer',
      phoneNumber: '+1234567891',
      profileImageUrl: null,
      locationSharingEnabled: false,
      createdAt: DateTime.now().subtract(const Duration(days: 60)),
      lastLogin: DateTime.now(),
    ),

    // Security
    User(
      id: 'user_security_1',
      email: 'security@test.com',
      name: 'Ahmed Khan',
      role: 'security',
      phoneNumber: '+1234567892',
      profileImageUrl: null,
      assignedZone: 'zone_north_stand',
      locationSharingEnabled: false,
      createdAt: DateTime.now().subtract(const Duration(days: 45)),
      lastLogin: DateTime.now(),
    ),

    // Emergency Services
    User(
      id: 'user_emergency_1',
      email: 'emergency@test.com',
      name: 'Dr. Sarah Wilson',
      role: 'emergency',
      phoneNumber: '+1234567893',
      profileImageUrl: null,
      locationSharingEnabled: false,
      createdAt: DateTime.now().subtract(const Duration(days: 50)),
      lastLogin: DateTime.now(),
    ),
  ];

  // ========== VENUE ==========
  static final Venue venue = Venue(
    id: 'venue_king_fahd_stadium',
    name: 'King Fahd International Stadium',
    address: 'Riyadh, Saudi Arabia',
    coordinates: const LatLng(stadiumLat, stadiumLng),
    capacity: 68752,
    description: 'Premier stadium for FIFA World Cup 2035',
  );

  // ========== EVENT ==========
  static final Event event = Event(
    id: 'event_wc2035_semifinal',
    name: 'Al-Taawoun FC vs NEOM SC',
    venueId: venue.id,
    startDate: DateTime(2035, 11, 23, 20, 0),
    endDate: DateTime(2035, 11, 23, 23, 0),
    capacity: venue.capacity,
    status: 'active',
    description: 'Saudi Pro League - Matchday 12',
  );

  // ========== ZONES ==========
  // King Fahd Stadium is roughly circular, ~300m diameter
  // At lat 24.7257: 0.001° lat ≈ 111m, 0.001° lng ≈ 101m
  static final List<Zone> zones = [
    // 1. North Stand - Behind north goal
    Zone(
      id: 'zone_north_stand',
      venueId: venue.id,
      name: 'North Stand',
      boundaries: [
        LatLng(stadiumLat + 0.0010, stadiumLng - 0.0008),
        LatLng(stadiumLat + 0.0010, stadiumLng + 0.0008),
        LatLng(stadiumLat + 0.0015, stadiumLng + 0.0006),
        LatLng(stadiumLat + 0.0015, stadiumLng - 0.0006),
      ],
      capacity: 12000,
      type: 'seating',
      description: 'Northern stand behind the goal',
    ),

    // 2. South Stand - Behind south goal
    Zone(
      id: 'zone_south_stand',
      venueId: venue.id,
      name: 'South Stand',
      boundaries: [
        LatLng(stadiumLat - 0.0015, stadiumLng - 0.0006),
        LatLng(stadiumLat - 0.0015, stadiumLng + 0.0006),
        LatLng(stadiumLat - 0.0010, stadiumLng + 0.0008),
        LatLng(stadiumLat - 0.0010, stadiumLng - 0.0008),
      ],
      capacity: 12000,
      type: 'seating',
      description: 'Southern stand behind the goal',
    ),

    // 3. East Wing - Main grandstand
    Zone(
      id: 'zone_east_wing',
      venueId: venue.id,
      name: 'East Wing',
      boundaries: [
        LatLng(stadiumLat - 0.0008, stadiumLng + 0.0010),
        LatLng(stadiumLat + 0.0008, stadiumLng + 0.0010),
        LatLng(stadiumLat + 0.0006, stadiumLng + 0.0016),
        LatLng(stadiumLat - 0.0006, stadiumLng + 0.0016),
      ],
      capacity: 18000,
      type: 'seating',
      description: 'Main grandstand - east side',
    ),

    // 4. West Wing - Opposite stand
    Zone(
      id: 'zone_west_wing',
      venueId: venue.id,
      name: 'West Wing',
      boundaries: [
        LatLng(stadiumLat - 0.0006, stadiumLng - 0.0016),
        LatLng(stadiumLat + 0.0006, stadiumLng - 0.0016),
        LatLng(stadiumLat + 0.0008, stadiumLng - 0.0010),
        LatLng(stadiumLat - 0.0008, stadiumLng - 0.0010),
      ],
      capacity: 18000,
      type: 'seating',
      description: 'West side stand',
    ),

    // 5. VIP Section - Central east premium area
    Zone(
      id: 'zone_vip',
      venueId: venue.id,
      name: 'VIP Section',
      boundaries: [
        LatLng(stadiumLat - 0.0004, stadiumLng + 0.0016),
        LatLng(stadiumLat + 0.0004, stadiumLng + 0.0016),
        LatLng(stadiumLat + 0.0004, stadiumLng + 0.0020),
        LatLng(stadiumLat - 0.0004, stadiumLng + 0.0020),
      ],
      capacity: 3000,
      type: 'vip',
      description: 'Premium VIP hospitality area',
    ),

    // 6. North Gate - Entry plaza
    Zone(
      id: 'zone_north_gate',
      venueId: venue.id,
      name: 'North Gate',
      boundaries: [
        LatLng(stadiumLat + 0.0015, stadiumLng - 0.0005),
        LatLng(stadiumLat + 0.0015, stadiumLng + 0.0005),
        LatLng(stadiumLat + 0.0022, stadiumLng + 0.0005),
        LatLng(stadiumLat + 0.0022, stadiumLng - 0.0005),
      ],
      capacity: 8000,
      type: 'entrance',
      description: 'Main northern entry gate and plaza',
    ),

    // 7. South Gate - Entry plaza
    Zone(
      id: 'zone_south_gate',
      venueId: venue.id,
      name: 'South Gate',
      boundaries: [
        LatLng(stadiumLat - 0.0022, stadiumLng - 0.0005),
        LatLng(stadiumLat - 0.0022, stadiumLng + 0.0005),
        LatLng(stadiumLat - 0.0015, stadiumLng + 0.0005),
        LatLng(stadiumLat - 0.0015, stadiumLng - 0.0005),
      ],
      capacity: 8000,
      type: 'entrance',
      description: 'Southern entry gate and plaza',
    ),

    // 8. Food Court - West concourse area (outside West Wing)
    Zone(
      id: 'zone_food_court',
      venueId: venue.id,
      name: 'Food Court',
      boundaries: [
        LatLng(stadiumLat - 0.0004, stadiumLng - 0.0022),
        LatLng(stadiumLat + 0.0004, stadiumLng - 0.0022),
        LatLng(stadiumLat + 0.0004, stadiumLng - 0.0016),
        LatLng(stadiumLat - 0.0004, stadiumLng - 0.0016),
      ],
      capacity: 5000,
      type: 'concourse',
      description: 'Main concourse with food and facilities',
    ),

  ];

  // ========== CROWD DENSITY ==========
  static List<CrowdDensity> get crowdDensityData {
    return [
      // North Stand - 85% filled, HIGH
      CrowdDensity.fromZoneData(
        zoneId: 'zone_north_stand',
        zoneName: 'North Stand',
        currentPopulation: 10200,
        capacity: 12000,
        areaInSqMeters: 6000,
      ),

      // South Stand - 70% filled, MODERATE
      CrowdDensity.fromZoneData(
        zoneId: 'zone_south_stand',
        zoneName: 'South Stand',
        currentPopulation: 8400,
        capacity: 12000,
        areaInSqMeters: 6000,
      ),

      // East Wing - 92% filled, CRITICAL
      CrowdDensity.fromZoneData(
        zoneId: 'zone_east_wing',
        zoneName: 'East Wing',
        currentPopulation: 16560,
        capacity: 18000,
        areaInSqMeters: 10000,
      ),

      // West Wing - 78% filled, HIGH
      CrowdDensity.fromZoneData(
        zoneId: 'zone_west_wing',
        zoneName: 'West Wing',
        currentPopulation: 14040,
        capacity: 18000,
        areaInSqMeters: 10000,
      ),

      // VIP Section - 65% filled, MODERATE
      CrowdDensity.fromZoneData(
        zoneId: 'zone_vip',
        zoneName: 'VIP Section',
        currentPopulation: 1950,
        capacity: 3000,
        areaInSqMeters: 3500,
      ),

      // North Gate - 40% filled, SAFE
      CrowdDensity.fromZoneData(
        zoneId: 'zone_north_gate',
        zoneName: 'North Gate',
        currentPopulation: 3200,
        capacity: 8000,
        areaInSqMeters: 7500,
      ),

      // South Gate - 88% filled, CRITICAL
      CrowdDensity.fromZoneData(
        zoneId: 'zone_south_gate',
        zoneName: 'South Gate',
        currentPopulation: 7040,
        capacity: 8000,
        areaInSqMeters: 7500,
      ),

      // Food Court - 75% filled, HIGH
      CrowdDensity.fromZoneData(
        zoneId: 'zone_food_court',
        zoneName: 'Food Court',
        currentPopulation: 3750,
        capacity: 5000,
        areaInSqMeters: 2500,
      ),
    ];
  }

  // ========== INCIDENTS ==========
  static List<Incident> get incidents {
    final now = DateTime.now();

    return [
      // 1. Medical Emergency - North Stand - Critical
      Incident(
        id: 'incident_1',
        eventId: event.id,
        reportedBy: users[2].id, // Security
        reportedByName: users[2].name,
        location: zones[0].center, // North Stand
        type: 'medical',
        description: 'Fan collapsed, requires immediate medical attention',
        severity: 'critical',
        status: 'dispatched',
        createdAt: now.subtract(const Duration(minutes: 12)),
        updatedAt: now.subtract(const Duration(minutes: 8)),
        assignedTo: users[3].id, // Emergency
        assignedToName: users[3].name,
      ),

      // 2. Overcrowding - Food Court - High
      Incident(
        id: 'incident_2',
        eventId: event.id,
        reportedBy: users[2].id, // Security
        reportedByName: users[2].name,
        location: zones[7].center, // Food Court
        type: 'overcrowding',
        description: 'Dangerous crowd buildup near food vendors',
        severity: 'high',
        status: 'on-site',
        createdAt: now.subtract(const Duration(minutes: 8)),
        updatedAt: now.subtract(const Duration(minutes: 3)),
        assignedTo: users[2].id,
        assignedToName: users[2].name,
      ),

      // 3. Lost Child - East Stand - Medium
      Incident(
        id: 'incident_3',
        eventId: event.id,
        reportedBy: users[2].id,
        reportedByName: users[2].name,
        location: zones[2].center, // East Wing
        type: 'other',
        description: 'Lost child, approximately 8 years old, wearing blue jersey',
        severity: 'medium',
        status: 'resolved',
        createdAt: now.subtract(const Duration(minutes: 25)),
        updatedAt: now.subtract(const Duration(minutes: 5)),
        assignedTo: users[2].id,
        assignedToName: users[2].name,
        resolutionNotes: 'Child reunited with parents at section E12',
      ),

      // 4. Minor Injury - South Gate - Low
      Incident(
        id: 'incident_4',
        eventId: event.id,
        reportedBy: users[2].id,
        reportedByName: users[2].name,
        location: zones[6].center, // South Gate
        type: 'medical',
        description: 'Visitor twisted ankle, requesting first aid',
        severity: 'low',
        status: 'reported',
        createdAt: now.subtract(const Duration(minutes: 3)),
        updatedAt: now.subtract(const Duration(minutes: 3)),
      ),

      // 5. Suspicious Package - West Stand - High
      Incident(
        id: 'incident_5',
        eventId: event.id,
        reportedBy: users[2].id,
        reportedByName: users[2].name,
        location: zones[3].center, // West Wing
        type: 'security',
        description: 'Unattended bag reported in section W45',
        severity: 'high',
        status: 'dispatched',
        createdAt: now.subtract(const Duration(minutes: 6)),
        updatedAt: now.subtract(const Duration(minutes: 4)),
        assignedTo: users[2].id,
        assignedToName: users[2].name,
      ),
    ];
  }

  // ========== ALERTS ==========
  static List<Alert> get alerts {
    final now = DateTime.now();

    return [
      // 1. Critical density alert
      Alert(
        id: 'alert_1',
        eventId: event.id,
        createdBy: users[1].id, // Organizer
        createdByName: users[1].name,
        type: 'emergency',
        message: 'North Stand reaching critical density. Security teams respond immediately.',
        targetRoles: ['security', 'emergency'],
        targetZones: ['zone_north_stand'],
        severity: 'critical',
        createdAt: now.subtract(const Duration(minutes: 5)),
        expiresAt: now.add(const Duration(hours: 1)),
      ),

      // 2. Congestion alert
      Alert(
        id: 'alert_2',
        eventId: event.id,
        createdBy: users[1].id,
        createdByName: users[1].name,
        type: 'congestion',
        message: 'Food Court congested. Please use alternative routes.',
        targetRoles: ['fan', 'security'],
        targetZones: ['zone_food_court'],
        severity: 'warning',
        createdAt: now.subtract(const Duration(minutes: 12)),
        expiresAt: now.add(const Duration(hours: 2)),
      ),

      // 3. Match info alert
      Alert(
        id: 'alert_3',
        eventId: event.id,
        createdBy: users[1].id,
        createdByName: users[1].name,
        type: 'info',
        message: 'Match starting in 15 minutes. Expect increased movement to seating areas.',
        targetRoles: ['fan', 'security', 'emergency'],
        severity: 'info',
        createdAt: now.subtract(const Duration(minutes: 25)),
        expiresAt: now.subtract(const Duration(minutes: 10)), // Expired
      ),
    ];
  }

  // Helper method to get user by email
  static User? getUserByEmail(String email) {
    try {
      return users.firstWhere((u) => u.email == email);
    } catch (e) {
      return null;
    }
  }

  // Helper method to get zone by id
  static Zone? getZoneById(String zoneId) {
    try {
      return zones.firstWhere((z) => z.id == zoneId);
    } catch (e) {
      return null;
    }
  }

  // Helper method to get incidents by status
  static List<Incident> getIncidentsByStatus(String status) {
    return incidents.where((i) => i.status == status).toList();
  }

  // Helper method to get active incidents
  static List<Incident> getActiveIncidents() {
    return incidents.where((i) => i.status != 'resolved').toList();
  }

  // Helper method to get alerts for user role
  static List<Alert> getAlertsForRole(String role) {
    return alerts.where((a) => a.shouldReceiveAlert(role) && a.isValid).toList();
  }

  // Get critical zones
  static List<CrowdDensity> getCriticalZones() {
    return crowdDensityData.where((cd) => cd.isCritical).toList();
  }

  // Get high density zones
  static List<CrowdDensity> getHighDensityZones() {
    return crowdDensityData.where((cd) => cd.needsAttention).toList();
  }

  // Get overall venue statistics
  static Map<String, dynamic> getVenueStats() {
    final totalPopulation = crowdDensityData.fold<int>(
      0,
      (sum, cd) => sum + cd.currentPopulation,
    );

    final criticalZones = getCriticalZones().length;
    final highZones = getHighDensityZones().length;
    final activeIncidents = getActiveIncidents().length;
    final activeAlerts = alerts.where((a) => a.isValid).length;

    return {
      'totalPopulation': totalPopulation,
      'totalCapacity': venue.capacity,
      'occupancyPercentage': (totalPopulation / venue.capacity * 100).round(),
      'criticalZones': criticalZones,
      'highDensityZones': highZones,
      'activeIncidents': activeIncidents,
      'activeAlerts': activeAlerts,
    };
  }
}
