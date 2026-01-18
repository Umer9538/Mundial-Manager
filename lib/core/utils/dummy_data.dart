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

  // Lusail Stadium coordinates
  static const double stadiumLat = 25.326622;
  static const double stadiumLng = 51.491379;

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
    id: 'venue_lusail_stadium',
    name: 'Lusail Stadium',
    address: 'Lusail, Qatar',
    coordinates: const LatLng(stadiumLat, stadiumLng),
    capacity: 88966,
    description: 'Iconic stadium for FIFA World Cup 2026',
  );

  // ========== EVENT ==========
  static final Event event = Event(
    id: 'event_wc2026_semifinal',
    name: 'FIFA World Cup 2026 - Semifinal',
    venueId: venue.id,
    startDate: DateTime(2026, 6, 15, 18, 0),
    endDate: DateTime(2026, 6, 15, 22, 0),
    capacity: venue.capacity,
    status: 'active',
    description: 'FIFA World Cup 2026 Semifinal Match',
  );

  // ========== ZONES ==========
  static final List<Zone> zones = [
    // 1. North Entrance
    Zone(
      id: 'zone_north_entrance',
      venueId: venue.id,
      name: 'North Entrance',
      boundaries: [
        LatLng(stadiumLat + 0.002, stadiumLng - 0.001),
        LatLng(stadiumLat + 0.002, stadiumLng + 0.001),
        LatLng(stadiumLat + 0.0015, stadiumLng + 0.001),
        LatLng(stadiumLat + 0.0015, stadiumLng - 0.001),
      ],
      capacity: 10000,
      type: 'entrance',
      description: 'Main northern entrance for ticket holders',
    ),

    // 2. South Entrance
    Zone(
      id: 'zone_south_entrance',
      venueId: venue.id,
      name: 'South Entrance',
      boundaries: [
        LatLng(stadiumLat - 0.002, stadiumLng - 0.001),
        LatLng(stadiumLat - 0.002, stadiumLng + 0.001),
        LatLng(stadiumLat - 0.0015, stadiumLng + 0.001),
        LatLng(stadiumLat - 0.0015, stadiumLng - 0.001),
      ],
      capacity: 10000,
      type: 'entrance',
      description: 'Southern entrance with VIP access',
    ),

    // 3. East Stand
    Zone(
      id: 'zone_east_stand',
      venueId: venue.id,
      name: 'East Stand',
      boundaries: [
        LatLng(stadiumLat - 0.001, stadiumLng + 0.0015),
        LatLng(stadiumLat + 0.001, stadiumLng + 0.0015),
        LatLng(stadiumLat + 0.001, stadiumLng + 0.002),
        LatLng(stadiumLat - 0.001, stadiumLng + 0.002),
      ],
      capacity: 20000,
      type: 'seating',
      description: 'Eastern seating section',
    ),

    // 4. West Stand
    Zone(
      id: 'zone_west_stand',
      venueId: venue.id,
      name: 'West Stand',
      boundaries: [
        LatLng(stadiumLat - 0.001, stadiumLng - 0.002),
        LatLng(stadiumLat + 0.001, stadiumLng - 0.002),
        LatLng(stadiumLat + 0.001, stadiumLng - 0.0015),
        LatLng(stadiumLat - 0.001, stadiumLng - 0.0015),
      ],
      capacity: 20000,
      type: 'seating',
      description: 'Western seating section',
    ),

    // 5. North Stand
    Zone(
      id: 'zone_north_stand',
      venueId: venue.id,
      name: 'North Stand',
      boundaries: [
        LatLng(stadiumLat + 0.001, stadiumLng - 0.0015),
        LatLng(stadiumLat + 0.002, stadiumLng - 0.0015),
        LatLng(stadiumLat + 0.002, stadiumLng + 0.0015),
        LatLng(stadiumLat + 0.001, stadiumLng + 0.0015),
      ],
      capacity: 15000,
      type: 'seating',
      description: 'Northern seating section',
    ),

    // 6. South Stand
    Zone(
      id: 'zone_south_stand',
      venueId: venue.id,
      name: 'South Stand',
      boundaries: [
        LatLng(stadiumLat - 0.002, stadiumLng - 0.0015),
        LatLng(stadiumLat - 0.001, stadiumLng - 0.0015),
        LatLng(stadiumLat - 0.001, stadiumLng + 0.0015),
        LatLng(stadiumLat - 0.002, stadiumLng + 0.0015),
      ],
      capacity: 15000,
      type: 'seating',
      description: 'Southern seating section',
    ),

    // 7. Concourse A
    Zone(
      id: 'zone_concourse_a',
      venueId: venue.id,
      name: 'Concourse A',
      boundaries: [
        LatLng(stadiumLat - 0.0005, stadiumLng - 0.001),
        LatLng(stadiumLat + 0.0005, stadiumLng - 0.001),
        LatLng(stadiumLat + 0.0005, stadiumLng + 0.001),
        LatLng(stadiumLat - 0.0005, stadiumLng + 0.001),
      ],
      capacity: 5000,
      type: 'concourse',
      description: 'Main concourse with food and facilities',
    ),

    // 8. Fan Zone
    Zone(
      id: 'zone_fan_zone',
      venueId: venue.id,
      name: 'Fan Zone',
      boundaries: [
        LatLng(stadiumLat + 0.003, stadiumLng - 0.002),
        LatLng(stadiumLat + 0.003, stadiumLng + 0.002),
        LatLng(stadiumLat + 0.004, stadiumLng + 0.002),
        LatLng(stadiumLat + 0.004, stadiumLng - 0.002),
      ],
      capacity: 3966,
      type: 'fan_zone',
      description: 'Outdoor fan celebration area',
    ),
  ];

  // ========== CROWD DENSITY ==========
  static List<CrowdDensity> get crowdDensityData {
    return [
      // North Entrance - 75% filled, HIGH
      CrowdDensity.fromZoneData(
        zoneId: 'zone_north_entrance',
        zoneName: 'North Entrance',
        currentPopulation: 7500,
        capacity: 10000,
        areaInSqMeters: 5000,
      ),

      // South Entrance - 45% filled, MODERATE
      CrowdDensity.fromZoneData(
        zoneId: 'zone_south_entrance',
        zoneName: 'South Entrance',
        currentPopulation: 4500,
        capacity: 10000,
        areaInSqMeters: 5000,
      ),

      // East Stand - 82% filled, HIGH
      CrowdDensity.fromZoneData(
        zoneId: 'zone_east_stand',
        zoneName: 'East Stand',
        currentPopulation: 16400,
        capacity: 20000,
        areaInSqMeters: 10000,
      ),

      // West Stand - 68% filled, MODERATE
      CrowdDensity.fromZoneData(
        zoneId: 'zone_west_stand',
        zoneName: 'West Stand',
        currentPopulation: 13600,
        capacity: 20000,
        areaInSqMeters: 10000,
      ),

      // North Stand - 92% filled, CRITICAL
      CrowdDensity.fromZoneData(
        zoneId: 'zone_north_stand',
        zoneName: 'North Stand',
        currentPopulation: 13800,
        capacity: 15000,
        areaInSqMeters: 7500,
      ),

      // South Stand - 55% filled, MODERATE
      CrowdDensity.fromZoneData(
        zoneId: 'zone_south_stand',
        zoneName: 'South Stand',
        currentPopulation: 8250,
        capacity: 15000,
        areaInSqMeters: 7500,
      ),

      // Concourse A - 88% filled, CRITICAL
      CrowdDensity.fromZoneData(
        zoneId: 'zone_concourse_a',
        zoneName: 'Concourse A',
        currentPopulation: 4400,
        capacity: 5000,
        areaInSqMeters: 2500,
      ),

      // Fan Zone - 35% filled, SAFE
      CrowdDensity.fromZoneData(
        zoneId: 'zone_fan_zone',
        zoneName: 'Fan Zone',
        currentPopulation: 1388,
        capacity: 3966,
        areaInSqMeters: 1983,
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
        location: zones[4].center, // North Stand
        type: 'medical',
        description: 'Fan collapsed, requires immediate medical attention',
        severity: 'critical',
        status: 'dispatched',
        createdAt: now.subtract(const Duration(minutes: 12)),
        updatedAt: now.subtract(const Duration(minutes: 8)),
        assignedTo: users[3].id, // Emergency
        assignedToName: users[3].name,
      ),

      // 2. Overcrowding - Concourse A - High
      Incident(
        id: 'incident_2',
        eventId: event.id,
        reportedBy: users[2].id, // Security
        reportedByName: users[2].name,
        location: zones[6].center, // Concourse A
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
        location: zones[2].center, // East Stand
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

      // 4. Minor Injury - South Entrance - Low
      Incident(
        id: 'incident_4',
        eventId: event.id,
        reportedBy: users[2].id,
        reportedByName: users[2].name,
        location: zones[1].center, // South Entrance
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
        location: zones[3].center, // West Stand
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
        message: 'Concourse A congested. Please use alternative routes.',
        targetRoles: ['fan', 'security'],
        targetZones: ['zone_concourse_a'],
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
