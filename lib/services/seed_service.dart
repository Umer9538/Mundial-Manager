import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

/// Service to seed Firestore with initial demo data
class SeedService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Check if data has already been seeded
  Future<bool> isSeeded() async {
    final venuesSnapshot = await _firestore.collection('venues').limit(1).get();
    return venuesSnapshot.docs.isNotEmpty;
  }

  /// Seed all demo data
  Future<void> seedAll() async {
    if (await isSeeded()) {
      if (kDebugMode) {
        print('Database already seeded. Skipping...');
      }
      return;
    }

    try {
      if (kDebugMode) {
        print('Starting database seeding...');
      }

      // Create demo users first
      await seedDemoUsers();

      // Seed venue
      final venueId = await seedVenue();

      // Seed zones
      await seedZones(venueId);

      // Seed event
      final eventId = await seedEvent(venueId);

      // Seed crowd density data
      await seedCrowdDensity(eventId);

      // Seed sample incidents
      await seedIncidents(eventId);

      // Seed sample alerts
      await seedAlerts(eventId);

      if (kDebugMode) {
        print('Database seeding completed successfully!');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error seeding database: $e');
      }
      rethrow;
    }
  }

  /// Seed demo users in Firebase Auth and Firestore
  Future<void> seedDemoUsers() async {
    final demoUsers = [
      {
        'email': 'fan@test.com',
        'password': 'password123',
        'name': 'Ahmed Al-Rashid',
        'role': 'fan',
        'phone': '+966501234567',
      },
      {
        'email': 'organizer@test.com',
        'password': 'password123',
        'name': 'Mohammed Al-Saud',
        'role': 'organizer',
        'phone': '+966502345678',
      },
      {
        'email': 'security@test.com',
        'password': 'password123',
        'name': 'Omar Hassan',
        'role': 'security',
        'phone': '+966503456789',
      },
      {
        'email': 'emergency@test.com',
        'password': 'password123',
        'name': 'Dr. Sarah Wilson',
        'role': 'emergency',
        'phone': '+966504567890',
      },
    ];

    for (final user in demoUsers) {
      try {
        // Create user in Firebase Auth
        final credential = await _auth.createUserWithEmailAndPassword(
          email: user['email']!,
          password: user['password']!,
        );

        if (credential.user != null) {
          // Create user document in Firestore
          await _firestore.collection('users').doc(credential.user!.uid).set({
            'email': user['email'],
            'name': user['name'],
            'role': user['role'],
            'phone': user['phone'],
            'createdAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
            'isActive': true,
            'assignedZones': <String>[],
            'profileImageUrl': null,
          });

          if (kDebugMode) {
            print('Created user: ${user['email']} (${user['role']})');
          }
        }
      } on FirebaseAuthException catch (e) {
        if (e.code == 'email-already-in-use') {
          if (kDebugMode) {
            print('User ${user['email']} already exists');
          }
        } else {
          rethrow;
        }
      }
    }
  }

  /// Seed venue data
  Future<String> seedVenue() async {
    final venueRef = await _firestore.collection('venues').add({
      'name': 'King Fahd International Stadium',
      'city': 'Riyadh',
      'country': 'Saudi Arabia',
      'capacity': 68000,
      'latitude': 24.7897,
      'longitude': 46.8380,
      'imageUrl': null,
      'description': 'The largest stadium in Saudi Arabia, hosting major football matches and events.',
      'facilities': ['Parking', 'VIP Lounges', 'Food Courts', 'Medical Center', 'Prayer Rooms'],
      'createdAt': FieldValue.serverTimestamp(),
    });

    if (kDebugMode) {
      print('Created venue: King Fahd International Stadium');
    }

    return venueRef.id;
  }

  /// Seed zones for the venue
  Future<void> seedZones(String venueId) async {
    final zones = [
      {
        'name': 'North Stand',
        'code': 'NS',
        'capacity': 15000,
        'type': 'seating',
        'color': '0xFF4CAF50',
        'centerLat': 24.7905,
        'centerLng': 46.8380,
        'boundaryPoints': [
          {'lat': 24.7910, 'lng': 46.8370},
          {'lat': 24.7910, 'lng': 46.8390},
          {'lat': 24.7900, 'lng': 46.8390},
          {'lat': 24.7900, 'lng': 46.8370},
        ],
      },
      {
        'name': 'South Stand',
        'code': 'SS',
        'capacity': 15000,
        'type': 'seating',
        'color': '0xFF2196F3',
        'centerLat': 24.7889,
        'centerLng': 46.8380,
        'boundaryPoints': [
          {'lat': 24.7894, 'lng': 46.8370},
          {'lat': 24.7894, 'lng': 46.8390},
          {'lat': 24.7884, 'lng': 46.8390},
          {'lat': 24.7884, 'lng': 46.8370},
        ],
      },
      {
        'name': 'East Wing',
        'code': 'EW',
        'capacity': 12000,
        'type': 'seating',
        'color': '0xFFFF9800',
        'centerLat': 24.7897,
        'centerLng': 46.8395,
        'boundaryPoints': [
          {'lat': 24.7905, 'lng': 46.8390},
          {'lat': 24.7905, 'lng': 46.8400},
          {'lat': 24.7889, 'lng': 46.8400},
          {'lat': 24.7889, 'lng': 46.8390},
        ],
      },
      {
        'name': 'West Wing',
        'code': 'WW',
        'capacity': 12000,
        'type': 'seating',
        'color': '0xFF9C27B0',
        'centerLat': 24.7897,
        'centerLng': 46.8365,
        'boundaryPoints': [
          {'lat': 24.7905, 'lng': 46.8360},
          {'lat': 24.7905, 'lng': 46.8370},
          {'lat': 24.7889, 'lng': 46.8370},
          {'lat': 24.7889, 'lng': 46.8360},
        ],
      },
      {
        'name': 'VIP Section',
        'code': 'VIP',
        'capacity': 5000,
        'type': 'vip',
        'color': '0xFFFFD700',
        'centerLat': 24.7897,
        'centerLng': 46.8380,
        'boundaryPoints': [
          {'lat': 24.7900, 'lng': 46.8375},
          {'lat': 24.7900, 'lng': 46.8385},
          {'lat': 24.7894, 'lng': 46.8385},
          {'lat': 24.7894, 'lng': 46.8375},
        ],
      },
      {
        'name': 'Food Court Area',
        'code': 'FC',
        'capacity': 3000,
        'type': 'concourse',
        'color': '0xFFE91E63',
        'centerLat': 24.7912,
        'centerLng': 46.8380,
        'boundaryPoints': [
          {'lat': 24.7915, 'lng': 46.8370},
          {'lat': 24.7915, 'lng': 46.8390},
          {'lat': 24.7910, 'lng': 46.8390},
          {'lat': 24.7910, 'lng': 46.8370},
        ],
      },
      {
        'name': 'Main Entrance',
        'code': 'ME',
        'capacity': 6000,
        'type': 'entrance',
        'color': '0xFF00BCD4',
        'centerLat': 24.7882,
        'centerLng': 46.8380,
        'boundaryPoints': [
          {'lat': 24.7886, 'lng': 46.8370},
          {'lat': 24.7886, 'lng': 46.8390},
          {'lat': 24.7878, 'lng': 46.8390},
          {'lat': 24.7878, 'lng': 46.8370},
        ],
      },
    ];

    for (final zone in zones) {
      await _firestore.collection('zones').add({
        ...zone,
        'venueId': venueId,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }

    if (kDebugMode) {
      print('Created ${zones.length} zones');
    }
  }

  /// Seed event data
  Future<String> seedEvent(String venueId) async {
    final eventRef = await _firestore.collection('events').add({
      'name': 'Al-Taawoun FC vs NEOM SC',
      'description': 'Saudi Pro League - Matchday 15',
      'venueId': venueId,
      'startDate': Timestamp.fromDate(DateTime.now()),
      'endDate': Timestamp.fromDate(DateTime.now().add(const Duration(hours: 3))),
      'expectedAttendance': 45000,
      'status': 'active',
      'type': 'football',
      'league': 'Saudi Pro League',
      'createdAt': FieldValue.serverTimestamp(),
    });

    if (kDebugMode) {
      print('Created event: Al-Taawoun FC vs NEOM SC');
    }

    return eventRef.id;
  }

  /// Seed crowd density data
  Future<void> seedCrowdDensity(String eventId) async {
    final zonesSnapshot = await _firestore.collection('zones').get();

    for (final zoneDoc in zonesSnapshot.docs) {
      final zoneData = zoneDoc.data();
      final capacity = zoneData['capacity'] as int;

      // Generate random occupancy between 40-90%
      final occupancy = 0.4 + (0.5 * (DateTime.now().millisecondsSinceEpoch % 100) / 100);
      final currentCount = (capacity * occupancy).round();

      await _firestore.collection('crowd_density').add({
        'eventId': eventId,
        'zoneId': zoneDoc.id,
        'zoneName': zoneData['name'],
        'currentCount': currentCount,
        'capacity': capacity,
        'density': occupancy,
        'latitude': zoneData['centerLat'],
        'longitude': zoneData['centerLng'],
        'timestamp': FieldValue.serverTimestamp(),
      });
    }

    if (kDebugMode) {
      print('Created crowd density data for ${zonesSnapshot.docs.length} zones');
    }
  }

  /// Seed sample incidents
  Future<void> seedIncidents(String eventId) async {
    final incidents = [
      {
        'type': 'medical',
        'description': 'Fan collapsed, requires immediate medical attention',
        'severity': 'critical',
        'status': 'dispatched',
        'latitude': 24.7900,
        'longitude': 46.8375,
        'reportedByName': 'Security Team',
      },
      {
        'type': 'overcrowding',
        'description': 'Dangerous crowd buildup near food vendors',
        'severity': 'high',
        'status': 'on_site',
        'latitude': 24.7912,
        'longitude': 46.8380,
        'reportedByName': 'Zone Monitor',
      },
      {
        'type': 'medical',
        'description': 'Visitor twisted ankle, requesting first aid',
        'severity': 'low',
        'status': 'reported',
        'latitude': 24.7895,
        'longitude': 46.8385,
        'reportedByName': 'Fan Report',
      },
      {
        'type': 'security',
        'description': 'Unattended bag reported in section W45',
        'severity': 'high',
        'status': 'dispatched',
        'latitude': 24.7897,
        'longitude': 46.8365,
        'reportedByName': 'Security Patrol',
      },
    ];

    for (final incident in incidents) {
      await _firestore.collection('incidents').add({
        ...incident,
        'eventId': eventId,
        'reportedBy': 'system',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }

    if (kDebugMode) {
      print('Created ${incidents.length} sample incidents');
    }
  }

  /// Seed sample alerts
  Future<void> seedAlerts(String eventId) async {
    final alerts = [
      {
        'type': 'congestion',
        'message': 'Food Court Area is experiencing high congestion. Please use alternative routes.',
        'severity': 'warning',
        'targetRoles': ['fan', 'security'],
        'isActive': true,
      },
      {
        'type': 'safety',
        'message': 'Please stay hydrated. Water stations available at all gates.',
        'severity': 'info',
        'targetRoles': ['fan'],
        'isActive': true,
      },
      {
        'type': 'emergency',
        'message': 'Medical emergency reported in North Stand. Emergency team dispatched.',
        'severity': 'critical',
        'targetRoles': ['security', 'emergency'],
        'isActive': true,
      },
    ];

    for (final alert in alerts) {
      await _firestore.collection('alerts').add({
        ...alert,
        'eventId': eventId,
        'createdBy': 'system',
        'createdByName': 'System',
        'createdAt': FieldValue.serverTimestamp(),
        'expiresAt': Timestamp.fromDate(DateTime.now().add(const Duration(hours: 2))),
      });
    }

    if (kDebugMode) {
      print('Created ${alerts.length} sample alerts');
    }
  }

  /// Clear all data (for testing)
  Future<void> clearAllData() async {
    final collections = ['users', 'venues', 'zones', 'events', 'crowd_density', 'incidents', 'alerts', 'notifications'];

    for (final collection in collections) {
      final snapshot = await _firestore.collection(collection).get();
      for (final doc in snapshot.docs) {
        await doc.reference.delete();
      }
      if (kDebugMode) {
        print('Cleared collection: $collection');
      }
    }
  }
}
