import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

/// Service to seed Firestore with comprehensive demo data
/// so all app features are clearly visible during demonstration.
class SeedService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Store created user IDs for cross-referencing
  final Map<String, String> _userIds = {};
  final List<String> _zoneIds = [];
  final List<String> _zoneNames = [];

  /// Check if data has already been seeded
  Future<bool> isSeeded() async {
    final venuesSnapshot =
        await _firestore.collection('venues').limit(1).get();
    return venuesSnapshot.docs.isNotEmpty;
  }

  /// Clear all seeded data (except user accounts) and re-seed fresh.
  /// Signs in as organizer to have write permissions, then restores previous auth state.
  Future<void> clearAndReseed() async {
    // Remember who's currently logged in so we can restore after seeding
    final currentUser = _auth.currentUser;
    final currentUid = currentUser?.uid;

    // Create a fresh temporary organizer account for seeding.
    // This avoids issues with existing accounts that have unknown passwords.
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final seedEmail = 'seed-organizer-$timestamp@mundial.app';
    const seedPassword = 'SeedPass1!';

    debugPrint('Creating temporary seed organizer: $seedEmail');
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: seedEmail,
        password: seedPassword,
      );
      // Write user doc with organizer role — Firestore allows creating your own profile
      await _firestore.collection('users').doc(cred.user!.uid).set({
        'email': seedEmail,
        'name': 'Seed Organizer',
        'role': 'organizer',
        'phone': '+966500000000',
        'createdAt': FieldValue.serverTimestamp(),
        'isActive': true,
        'emailVerified': true,
      });
      debugPrint('Seed organizer created and signed in');
    } catch (e) {
      debugPrint('Failed to create seed organizer: $e');
      debugPrint('Seeding skipped - cannot authenticate');
      return;
    }

    debugPrint('Clearing data for fresh re-seed (preserving user accounts)...');
    final collections = [
      'venues', 'zones', 'facilities', 'events',
      'crowd_density', 'incidents', 'alerts',
      'staff_assignments', 'messages', 'notifications',
    ];
    for (final col in collections) {
      final snapshot = await _firestore.collection(col).get();
      if (snapshot.docs.isEmpty) continue;
      final batch = _firestore.batch();
      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
      debugPrint('  Cleared $col (${snapshot.docs.length} docs)');
    }

    // Seed fresh data (seed organizer is now signed in with write permissions)
    await _doSeedDataOnly(seedEmail, seedPassword);

    // Promote the original user to organizer so they can see everything
    if (currentUid != null) {
      debugPrint('Promoting original user to organizer role...');
      await _firestore.collection('users').doc(currentUid).update({
        'role': 'organizer',
      });
    }

    // Sign out the seed organizer — splash screen will handle re-login
    await _auth.signOut();
    debugPrint('Seed complete. Signed out seed organizer.');
  }

  /// Seed all data including demo users.
  /// Creates users first, then re-authenticates as the seed organizer to seed the rest.
  Future<void> _doSeedDataOnly(String seedEmail, String seedPassword) async {
    try {
      debugPrint('Seeding fresh data (skipping user creation)...');

      final venueId = await seedVenue();
      await seedZones(venueId);
      await seedFacilities(venueId);
      final eventId = await seedEvent(venueId);
      await seedCrowdDensity(eventId);
      await seedIncidents(eventId);
      await seedAlerts(eventId);
      await seedStaffAssignments(eventId);
      await seedMessages(eventId);
      debugPrint('Database seeding completed successfully!');
    } catch (e) {
      debugPrint('Error seeding data: $e');
      rethrow;
    }
  }

  /// Seed all demo data
  Future<void> seedAll() async {
    if (await isSeeded()) {
      debugPrint('Database already seeded. Skipping...');
      return;
    }
    await _doSeed();
  }

  Future<void> _doSeed() async {

    try {
      debugPrint('Starting database seeding...');

      // 1. Create demo users
      await seedDemoUsers();

      // 2. Seed venue
      final venueId = await seedVenue();

      // 3. Seed zones
      await seedZones(venueId);

      // 4. Seed facilities (for fan venue map)
      await seedFacilities(venueId);

      // 5. Seed event
      final eventId = await seedEvent(venueId);

      // 6. Seed crowd density data
      await seedCrowdDensity(eventId);

      // 7. Seed incidents (various statuses)
      await seedIncidents(eventId);

      // 8. Seed alerts (various types & severities)
      await seedAlerts(eventId);

      // 9. Seed staff assignments
      await seedStaffAssignments(eventId);

      // 10. Seed messages (communication hub)
      await seedMessages(eventId);

      debugPrint('Database seeding completed successfully!');
    } catch (e) {
      debugPrint('Error seeding database: $e');
      rethrow;
    }
  }

  // ==================== USERS ====================

  Future<void> seedDemoUsers() async {
    final demoUsers = [
      // --- Fans ---
      {
        'email': 'fan@test.com',
        'password': 'Password1',
        'name': 'Ahmed Al-Rashid',
        'role': 'fan',
        'phone': '+966501234567',
      },
      {
        'email': 'fan2@test.com',
        'password': 'Password1',
        'name': 'Fatima Al-Zahra',
        'role': 'fan',
        'phone': '+966501234568',
      },
      // --- Organizer ---
      {
        'email': 'organizer@test.com',
        'password': 'Password1',
        'name': 'Mohammed Al-Saud',
        'role': 'organizer',
        'phone': '+966502345678',
      },
      // --- Security Team (multiple for staff management) ---
      {
        'email': 'security@test.com',
        'password': 'Password1',
        'name': 'Omar Hassan',
        'role': 'security',
        'phone': '+966503456789',
      },
      {
        'email': 'security2@test.com',
        'password': 'Password1',
        'name': 'Khalid Al-Fahad',
        'role': 'security',
        'phone': '+966503456790',
      },
      {
        'email': 'security3@test.com',
        'password': 'Password1',
        'name': 'Yusuf Ibrahim',
        'role': 'security',
        'phone': '+966503456791',
      },
      {
        'email': 'security4@test.com',
        'password': 'Password1',
        'name': 'Ali Al-Mutairi',
        'role': 'security',
        'phone': '+966503456792',
      },
      {
        'email': 'security5@test.com',
        'password': 'Password1',
        'name': 'Saad Al-Qahtani',
        'role': 'security',
        'phone': '+966503456793',
      },
      // --- Emergency Team (multiple for staff management) ---
      {
        'email': 'emergency@test.com',
        'password': 'Password1',
        'name': 'Dr. Sarah Wilson',
        'role': 'emergency',
        'phone': '+966504567890',
      },
      {
        'email': 'emergency2@test.com',
        'password': 'Password1',
        'name': 'Dr. Nora Al-Harbi',
        'role': 'emergency',
        'phone': '+966504567891',
      },
      {
        'email': 'emergency3@test.com',
        'password': 'Password1',
        'name': 'Paramedic Tariq Saleh',
        'role': 'emergency',
        'phone': '+966504567892',
      },
    ];

    for (final user in demoUsers) {
      try {
        final credential = await _auth.createUserWithEmailAndPassword(
          email: user['email']!,
          password: user['password']!,
        );

        if (credential.user != null) {
          final uid = credential.user!.uid;
          _userIds[user['email']!] = uid;

          await _firestore.collection('users').doc(uid).set({
            'email': user['email'],
            'name': user['name'],
            'role': user['role'],
            'phone': user['phone'],
            'createdAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
            'lastLogin': FieldValue.serverTimestamp(),
            'isActive': true,
            'emailVerified': true,
            'assignedZones': <String>[],
            'profileImageUrl': null,
            'locationSharingEnabled':
                user['role'] == 'security' || user['role'] == 'emergency',
          });

          debugPrint('Created user: ${user['email']} (${user['role']})');
        }
      } on FirebaseAuthException catch (e) {
        if (e.code == 'email-already-in-use') {
          debugPrint('User ${user['email']} already exists');
          // Try to sign in to get the UID
          try {
            final cred = await _auth.signInWithEmailAndPassword(
              email: user['email']!,
              password: user['password']!,
            );
            if (cred.user != null) {
              _userIds[user['email']!] = cred.user!.uid;
            }
          } catch (_) {}
        } else {
          rethrow;
        }
      }
    }

    // Sign out after seeding users
    await _auth.signOut();
    debugPrint('Created ${_userIds.length} demo users');
  }

  // ==================== VENUE ====================

  // Actual King Fahd International Stadium center (from OpenStreetMap)
  static const double _stadiumLat = 24.7133;
  static const double _stadiumLng = 46.8253;

  Future<String> seedVenue() async {
    final venueRef = await _firestore.collection('venues').add({
      'name': 'King Fahd International Stadium',
      'city': 'Riyadh',
      'country': 'Saudi Arabia',
      'capacity': 68000,
      'latitude': _stadiumLat,
      'longitude': _stadiumLng,
      'address': 'King Fahd Road, Al Malaz, Riyadh 12836, Saudi Arabia',
      'imageUrl': null,
      'description':
          'The largest stadium in Saudi Arabia, hosting FIFA World Cup 2026 matches.',
      'facilities': [
        'Parking',
        'VIP Lounges',
        'Food Courts',
        'Medical Center',
        'Prayer Rooms',
        'Restrooms',
        'Info Desks',
      ],
      'createdAt': FieldValue.serverTimestamp(),
    });

    debugPrint('Created venue: King Fahd International Stadium');
    return venueRef.id;
  }

  // ==================== ZONES ====================

  Future<void> seedZones(String venueId) async {
    // Zone boundaries designed as segments around the circular King Fahd Stadium.
    // Stadium center: 24.7133, 46.8253. Outer radius ~0.0018°, inner ~0.0010°.
    const cLat = _stadiumLat;
    const cLng = _stadiumLng;

    final zones = [
      {
        'name': 'North Stand',
        'code': 'NS',
        'capacity': 15000,
        'type': 'seating',
        'color': '0xFF4CAF50',
        'centerLat': cLat + 0.0014,
        'centerLng': cLng,
        'boundaries': [
          {'lat': cLat + 0.0010, 'lng': cLng - 0.0010},
          {'lat': cLat + 0.0015, 'lng': cLng - 0.0015},
          {'lat': cLat + 0.0020, 'lng': cLng - 0.0008},
          {'lat': cLat + 0.0020, 'lng': cLng + 0.0008},
          {'lat': cLat + 0.0015, 'lng': cLng + 0.0015},
          {'lat': cLat + 0.0010, 'lng': cLng + 0.0010},
        ],
      },
      {
        'name': 'South Stand',
        'code': 'SS',
        'capacity': 15000,
        'type': 'seating',
        'color': '0xFF2196F3',
        'centerLat': cLat - 0.0014,
        'centerLng': cLng,
        'boundaries': [
          {'lat': cLat - 0.0010, 'lng': cLng + 0.0010},
          {'lat': cLat - 0.0015, 'lng': cLng + 0.0015},
          {'lat': cLat - 0.0020, 'lng': cLng + 0.0008},
          {'lat': cLat - 0.0020, 'lng': cLng - 0.0008},
          {'lat': cLat - 0.0015, 'lng': cLng - 0.0015},
          {'lat': cLat - 0.0010, 'lng': cLng - 0.0010},
        ],
      },
      {
        'name': 'East Wing',
        'code': 'EW',
        'capacity': 12000,
        'type': 'seating',
        'color': '0xFFFF9800',
        'centerLat': cLat,
        'centerLng': cLng + 0.0016,
        'boundaries': [
          {'lat': cLat + 0.0010, 'lng': cLng + 0.0010},
          {'lat': cLat + 0.0015, 'lng': cLng + 0.0015},
          {'lat': cLat + 0.0008, 'lng': cLng + 0.0020},
          {'lat': cLat - 0.0008, 'lng': cLng + 0.0020},
          {'lat': cLat - 0.0015, 'lng': cLng + 0.0015},
          {'lat': cLat - 0.0010, 'lng': cLng + 0.0010},
        ],
      },
      {
        'name': 'West Wing',
        'code': 'WW',
        'capacity': 12000,
        'type': 'seating',
        'color': '0xFF9C27B0',
        'centerLat': cLat,
        'centerLng': cLng - 0.0016,
        'boundaries': [
          {'lat': cLat - 0.0010, 'lng': cLng - 0.0010},
          {'lat': cLat - 0.0015, 'lng': cLng - 0.0015},
          {'lat': cLat - 0.0008, 'lng': cLng - 0.0020},
          {'lat': cLat + 0.0008, 'lng': cLng - 0.0020},
          {'lat': cLat + 0.0015, 'lng': cLng - 0.0015},
          {'lat': cLat + 0.0010, 'lng': cLng - 0.0010},
        ],
      },
      {
        'name': 'VIP Section',
        'code': 'VIP',
        'capacity': 5000,
        'type': 'vip',
        'color': '0xFFFFD700',
        'centerLat': cLat,
        'centerLng': cLng,
        'boundaries': [
          {'lat': cLat + 0.0008, 'lng': cLng - 0.0008},
          {'lat': cLat + 0.0008, 'lng': cLng + 0.0008},
          {'lat': cLat - 0.0008, 'lng': cLng + 0.0008},
          {'lat': cLat - 0.0008, 'lng': cLng - 0.0008},
        ],
      },
      {
        'name': 'Food Court Area',
        'code': 'FC',
        'capacity': 3000,
        'type': 'concourse',
        'color': '0xFFE91E63',
        'centerLat': cLat + 0.0025,
        'centerLng': cLng,
        'boundaries': [
          {'lat': cLat + 0.0022, 'lng': cLng - 0.0012},
          {'lat': cLat + 0.0022, 'lng': cLng + 0.0012},
          {'lat': cLat + 0.0028, 'lng': cLng + 0.0012},
          {'lat': cLat + 0.0028, 'lng': cLng - 0.0012},
        ],
      },
      {
        'name': 'Main Entrance',
        'code': 'ME',
        'capacity': 6000,
        'type': 'entrance',
        'color': '0xFF00BCD4',
        'centerLat': cLat - 0.0025,
        'centerLng': cLng,
        'boundaries': [
          {'lat': cLat - 0.0022, 'lng': cLng - 0.0015},
          {'lat': cLat - 0.0022, 'lng': cLng + 0.0015},
          {'lat': cLat - 0.0028, 'lng': cLng + 0.0015},
          {'lat': cLat - 0.0028, 'lng': cLng - 0.0015},
        ],
      },
    ];

    for (final zone in zones) {
      final ref = await _firestore.collection('zones').add({
        ...zone,
        'venueId': venueId,
        'createdAt': FieldValue.serverTimestamp(),
      });
      _zoneIds.add(ref.id);
      _zoneNames.add(zone['name'] as String);
    }

    debugPrint('Created ${zones.length} zones');
  }

  // ==================== FACILITIES ====================

  Future<void> seedFacilities(String venueId) async {
    const cLat = _stadiumLat;
    const cLng = _stadiumLng;

    final facilities = [
      // Restrooms
      {
        'name': 'Restroom A - North',
        'type': 'restroom',
        'latitude': cLat + 0.0022,
        'longitude': cLng - 0.0010,
        'description': 'Main restrooms near North Stand Gate 1',
        'isOpen': true,
        'floor': 0,
      },
      {
        'name': 'Restroom B - South',
        'type': 'restroom',
        'latitude': cLat - 0.0022,
        'longitude': cLng + 0.0010,
        'description': 'Restrooms near South Stand Gate 3',
        'isOpen': true,
        'floor': 0,
      },
      {
        'name': 'Restroom C - East',
        'type': 'restroom',
        'latitude': cLat + 0.0002,
        'longitude': cLng + 0.0022,
        'description': 'Restrooms near East Wing entrance',
        'isOpen': true,
        'floor': 0,
      },
      // Food vendors
      {
        'name': 'Al Baik Restaurant',
        'type': 'food',
        'latitude': cLat + 0.0026,
        'longitude': cLng - 0.0008,
        'description': 'Popular Saudi fast food - chicken & shrimp meals',
        'isOpen': true,
        'floor': 0,
      },
      {
        'name': 'Shawarma House',
        'type': 'food',
        'latitude': cLat + 0.0025,
        'longitude': cLng + 0.0005,
        'description': 'Shawarma wraps, fries & fresh juices',
        'isOpen': true,
        'floor': 0,
      },
      {
        'name': 'Coffee & Snacks Corner',
        'type': 'food',
        'latitude': cLat + 0.0024,
        'longitude': cLng + 0.0010,
        'description': 'Arabic coffee, tea, pastries & light snacks',
        'isOpen': true,
        'floor': 0,
      },
      {
        'name': 'VIP Dining Lounge',
        'type': 'food',
        'latitude': cLat + 0.0003,
        'longitude': cLng + 0.0003,
        'description': 'Exclusive dining for VIP ticket holders',
        'isOpen': true,
        'floor': 1,
      },
      // First Aid
      {
        'name': 'Medical Center - Main',
        'type': 'first_aid',
        'latitude': cLat - 0.0003,
        'longitude': cLng - 0.0020,
        'description': 'Primary medical center with doctors on duty',
        'isOpen': true,
        'floor': 0,
      },
      {
        'name': 'First Aid Post - North',
        'type': 'first_aid',
        'latitude': cLat + 0.0018,
        'longitude': cLng + 0.0012,
        'description': 'First aid station near North Stand',
        'isOpen': true,
        'floor': 0,
      },
      {
        'name': 'First Aid Post - South',
        'type': 'first_aid',
        'latitude': cLat - 0.0018,
        'longitude': cLng - 0.0012,
        'description': 'First aid station near South Stand',
        'isOpen': true,
        'floor': 0,
      },
      // Exits
      {
        'name': 'Emergency Exit A',
        'type': 'exit',
        'latitude': cLat + 0.0016,
        'longitude': cLng - 0.0018,
        'description': 'Northwest emergency exit - leads to parking lot A',
        'isOpen': true,
        'floor': 0,
      },
      {
        'name': 'Emergency Exit B',
        'type': 'exit',
        'latitude': cLat + 0.0016,
        'longitude': cLng + 0.0018,
        'description': 'Northeast emergency exit - leads to parking lot B',
        'isOpen': true,
        'floor': 0,
      },
      {
        'name': 'Main Gate Exit',
        'type': 'exit',
        'latitude': cLat - 0.0025,
        'longitude': cLng,
        'description': 'Main entrance/exit gate',
        'isOpen': true,
        'floor': 0,
      },
      // Info desks
      {
        'name': 'Information Desk - Main',
        'type': 'info_desk',
        'latitude': cLat - 0.0022,
        'longitude': cLng,
        'description': 'Main information desk - tickets, directions, lost & found',
        'isOpen': true,
        'floor': 0,
      },
      {
        'name': 'Information Desk - VIP',
        'type': 'info_desk',
        'latitude': cLat,
        'longitude': cLng - 0.0005,
        'description': 'VIP assistance and concierge services',
        'isOpen': true,
        'floor': 1,
      },
      // Prayer rooms
      {
        'name': 'Prayer Room - North',
        'type': 'prayer_room',
        'latitude': cLat + 0.0020,
        'longitude': cLng - 0.0015,
        'description': 'Prayer room with ablution facilities',
        'isOpen': true,
        'floor': 0,
      },
      {
        'name': 'Prayer Room - South',
        'type': 'prayer_room',
        'latitude': cLat - 0.0020,
        'longitude': cLng + 0.0015,
        'description': 'Prayer room with ablution facilities',
        'isOpen': true,
        'floor': 0,
      },
    ];

    for (final facility in facilities) {
      await _firestore.collection('facilities').add({
        ...facility,
        'venueId': venueId,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }

    debugPrint('Created ${facilities.length} facilities');
  }

  // ==================== EVENT ====================

  Future<String> seedEvent(String venueId) async {
    final eventRef = await _firestore.collection('events').add({
      'name': 'Saudi Arabia vs Mexico',
      'description':
          'FIFA World Cup 2026 - Group Stage Matchday 2. A highly anticipated group match at King Fahd International Stadium.',
      'venueId': venueId,
      'startDate': Timestamp.fromDate(DateTime.now()),
      'endDate': Timestamp.fromDate(
          DateTime.now().add(const Duration(hours: 3))),
      'capacity': 68000,
      'expectedAttendance': 62000,
      'status': 'active',
      'type': 'football',
      'league': 'FIFA World Cup 2026',
      'createdAt': FieldValue.serverTimestamp(),
    });

    debugPrint('Created event: Saudi Arabia vs Mexico');
    return eventRef.id;
  }

  // ==================== CROWD DENSITY ====================

  Future<void> seedCrowdDensity(String eventId) async {
    // Occupancy percentages chosen to showcase all 4 color tiers:
    //   <50% = Green (safe), 50-69% = Yellow (moderate),
    //   70-84% = Orange (high), >=85% = Red (critical)
    // Thresholds derived from Kaggle Hajj & Umrah Crowd Management Dataset.
    final occupancyLevels = [
      0.88, // North Stand  -> Red (critical, 88%)
      0.62, // South Stand  -> Yellow (moderate, 62%)
      0.75, // East Wing    -> Orange (high, 75%)
      0.40, // West Wing    -> Green (safe, 40%)
      0.92, // VIP Section  -> Red (critical, 92%)
      0.96, // Food Court   -> Red (emergency, 96%)
      0.55, // Main Entrance -> Yellow (moderate, 55%)
    ];

    for (int i = 0; i < _zoneIds.length; i++) {
      final zonesSnapshot =
          await _firestore.collection('zones').doc(_zoneIds[i]).get();
      final zoneData = zonesSnapshot.data()!;
      final capacity = zoneData['capacity'] as int;
      final occupancy = occupancyLevels[i];
      final currentCount = (capacity * occupancy).round();

      // Dataset-derived status from occupancy percentage
      String status;
      if (occupancy >= 0.85) {
        status = 'critical';
      } else if (occupancy >= 0.70) {
        status = 'high';
      } else if (occupancy >= 0.50) {
        status = 'moderate';
      } else {
        status = 'safe';
      }

      await _firestore.collection('crowd_density').add({
        'eventId': eventId,
        'zoneId': _zoneIds[i],
        'zoneName': zoneData['name'],
        'currentPopulation': currentCount,
        'currentCount': currentCount,
        'capacity': capacity,
        'density': occupancy,
        'densityPerSqMeter': occupancy * 4.5,
        'status': status,
        'temperature': 38.0, // Dataset avg temperature
        'weatherCondition': 'Clear',
        'latitude': zoneData['centerLat'],
        'longitude': zoneData['centerLng'],
        'timestamp': FieldValue.serverTimestamp(),
      });
    }

    debugPrint('Created crowd density data for ${_zoneIds.length} zones (dataset thresholds)');
  }

  // ==================== INCIDENTS ====================

  Future<void> seedIncidents(String eventId) async {
    final now = DateTime.now();
    final securityId = _userIds['security@test.com'] ?? 'system';
    final emergencyId = _userIds['emergency@test.com'] ?? 'system';
    const cLat = _stadiumLat;
    const cLng = _stadiumLng;

    final incidents = [
      // CRITICAL - dispatched (shows on emergency dashboard)
      {
        'type': 'medical',
        'description':
            'Male fan (approx. 55 years old) collapsed in North Stand section A12. Unresponsive, bystanders performing CPR. Ambulance requested.',
        'severity': 'critical',
        'status': 'dispatched',
        'latitude': cLat + 0.0014,
        'longitude': cLng - 0.0005,
        'reportedBy': securityId,
        'reportedByName': 'Omar Hassan',
        'assignedTo': emergencyId,
        'assignedToName': 'Dr. Sarah Wilson',
        'createdAt': Timestamp.fromDate(now.subtract(const Duration(minutes: 8))),
        'updatedAt': Timestamp.fromDate(now.subtract(const Duration(minutes: 3))),
      },
      // HIGH - on_site (emergency team already there)
      {
        'type': 'overcrowding',
        'description':
            'Dangerous crowd buildup at Food Court Area. Estimated 3500+ people in zone rated for 3000. Barriers being pushed. Crowd control needed urgently.',
        'severity': 'high',
        'status': 'on_site',
        'latitude': cLat + 0.0025,
        'longitude': cLng + 0.0003,
        'reportedBy': securityId,
        'reportedByName': 'Khalid Al-Fahad',
        'assignedTo': _userIds['security3@test.com'] ?? securityId,
        'assignedToName': 'Yusuf Ibrahim',
        'createdAt': Timestamp.fromDate(now.subtract(const Duration(minutes: 22))),
        'updatedAt': Timestamp.fromDate(now.subtract(const Duration(minutes: 10))),
      },
      // HIGH - dispatched (security responding)
      {
        'type': 'security',
        'description':
            'Unattended black backpack reported under seat W45-Row12. Area partially evacuated. Bomb squad notified.',
        'severity': 'high',
        'status': 'dispatched',
        'latitude': cLat,
        'longitude': cLng - 0.0016,
        'reportedBy': _userIds['security4@test.com'] ?? securityId,
        'reportedByName': 'Ali Al-Mutairi',
        'createdAt': Timestamp.fromDate(now.subtract(const Duration(minutes: 15))),
        'updatedAt': Timestamp.fromDate(now.subtract(const Duration(minutes: 12))),
      },
      // MEDIUM - reported (new, not yet dispatched)
      {
        'type': 'medical',
        'description':
            'Female visitor complaining of severe dehydration and dizziness in East Wing section E22. Conscious but unable to walk.',
        'severity': 'medium',
        'status': 'reported',
        'latitude': cLat + 0.0002,
        'longitude': cLng + 0.0016,
        'reportedBy': 'fan_report',
        'reportedByName': 'Fan Report (Anonymous)',
        'createdAt': Timestamp.fromDate(now.subtract(const Duration(minutes: 4))),
        'updatedAt': Timestamp.fromDate(now.subtract(const Duration(minutes: 4))),
      },
      // LOW - reported
      {
        'type': 'medical',
        'description':
            'Child (8 years old) scraped knee near South Stand stairs. Parents requesting first aid kit.',
        'severity': 'low',
        'status': 'reported',
        'latitude': cLat - 0.0012,
        'longitude': cLng + 0.0005,
        'reportedBy': 'fan_report',
        'reportedByName': 'Fan Report',
        'createdAt': Timestamp.fromDate(now.subtract(const Duration(minutes: 2))),
        'updatedAt': Timestamp.fromDate(now.subtract(const Duration(minutes: 2))),
      },
      // RESOLVED - to show completed incidents
      {
        'type': 'security',
        'description':
            'Physical altercation between two groups of fans in South Stand. Security intervened, individuals separated and escorted out.',
        'severity': 'high',
        'status': 'resolved',
        'latitude': cLat - 0.0014,
        'longitude': cLng - 0.0005,
        'reportedBy': _userIds['security5@test.com'] ?? securityId,
        'reportedByName': 'Saad Al-Qahtani',
        'assignedTo': securityId,
        'assignedToName': 'Omar Hassan',
        'resolutionNotes':
            'Two individuals escorted out by security. Police report filed. No serious injuries.',
        'createdAt': Timestamp.fromDate(now.subtract(const Duration(hours: 1, minutes: 30))),
        'updatedAt': Timestamp.fromDate(now.subtract(const Duration(hours: 1))),
      },
      // RESOLVED - medical
      {
        'type': 'medical',
        'description':
            'Elderly man experienced chest pains in VIP Section. Paramedics attended.',
        'severity': 'critical',
        'status': 'resolved',
        'latitude': cLat + 0.0002,
        'longitude': cLng + 0.0002,
        'reportedBy': securityId,
        'reportedByName': 'Omar Hassan',
        'assignedTo': emergencyId,
        'assignedToName': 'Dr. Sarah Wilson',
        'resolutionNotes':
            'Patient stabilized on-site. Transferred to King Faisal Hospital by ambulance. Condition: stable.',
        'createdAt': Timestamp.fromDate(now.subtract(const Duration(hours: 2))),
        'updatedAt': Timestamp.fromDate(now.subtract(const Duration(hours: 1, minutes: 45))),
      },
      // Overcrowding - resolved
      {
        'type': 'overcrowding',
        'description':
            'Main Entrance gate congestion during initial entry. Queue length exceeded 500m.',
        'severity': 'medium',
        'status': 'resolved',
        'latitude': cLat - 0.0025,
        'longitude': cLng,
        'reportedBy': securityId,
        'reportedByName': 'Omar Hassan',
        'resolutionNotes':
            'Opened additional gates 4 & 5. Deployed 8 extra staff. Congestion cleared in 25 minutes.',
        'createdAt': Timestamp.fromDate(now.subtract(const Duration(hours: 2, minutes: 45))),
        'updatedAt': Timestamp.fromDate(now.subtract(const Duration(hours: 2, minutes: 20))),
      },
    ];

    for (final incident in incidents) {
      await _firestore.collection('incidents').add({
        ...incident,
        'eventId': eventId,
      });
    }

    debugPrint('Created ${incidents.length} incidents');
  }

  // ==================== ALERTS ====================

  Future<void> seedAlerts(String eventId) async {
    final organizerId = _userIds['organizer@test.com'] ?? 'system';
    final securityId = _userIds['security@test.com'] ?? 'system';
    final now = DateTime.now();

    final alerts = [
      // Critical - emergency
      {
        'type': 'emergency',
        'message':
            'MEDICAL EMERGENCY: CPR in progress at North Stand A12. Emergency team dispatched. Clear path for paramedics.',
        'severity': 'critical',
        'targetRoles': ['security', 'emergency'],
        'isActive': true,
        'createdBy': securityId,
        'createdByName': 'Omar Hassan',
        'createdAt': Timestamp.fromDate(now.subtract(const Duration(minutes: 8))),
        'expiresAt': Timestamp.fromDate(now.add(const Duration(hours: 1))),
      },
      // Warning - congestion for fans
      {
        'type': 'congestion',
        'message':
            'HIGH CONGESTION at Food Court Area. Please use South Gate food vendors as alternative. Wait time: ~25 min at Food Court.',
        'severity': 'warning',
        'targetRoles': ['fan', 'security'],
        'isActive': true,
        'createdBy': organizerId,
        'createdByName': 'Mohammed Al-Saud',
        'createdAt': Timestamp.fromDate(now.subtract(const Duration(minutes: 20))),
        'expiresAt': Timestamp.fromDate(now.add(const Duration(hours: 1))),
      },
      // Warning - security
      {
        'type': 'safety',
        'message':
            'SECURITY ALERT: Unattended bag under investigation in West Wing W45. Perimeter established. Avoid rows 10-15.',
        'severity': 'warning',
        'targetRoles': ['security', 'emergency', 'fan'],
        'isActive': true,
        'createdBy': securityId,
        'createdByName': 'Omar Hassan',
        'createdAt': Timestamp.fromDate(now.subtract(const Duration(minutes: 15))),
        'expiresAt': Timestamp.fromDate(now.add(const Duration(hours: 1))),
      },
      // Info - general for fans
      {
        'type': 'info',
        'message':
            'Welcome to the FIFA World Cup 2026! Stay hydrated - free water stations at all gates. Download the app for live crowd updates.',
        'severity': 'info',
        'targetRoles': ['fan'],
        'isActive': true,
        'createdBy': organizerId,
        'createdByName': 'Mohammed Al-Saud',
        'createdAt': Timestamp.fromDate(now.subtract(const Duration(hours: 3))),
        'expiresAt': Timestamp.fromDate(now.add(const Duration(hours: 4))),
      },
      // Info - weather
      {
        'type': 'info',
        'message':
            'Weather advisory: Temperature 38°C. Cooling zones available near Gates 2 and 5. Mist fans active in concourse areas.',
        'severity': 'info',
        'targetRoles': ['fan', 'security', 'emergency'],
        'isActive': true,
        'createdBy': organizerId,
        'createdByName': 'Mohammed Al-Saud',
        'createdAt': Timestamp.fromDate(now.subtract(const Duration(hours: 2))),
        'expiresAt': Timestamp.fromDate(now.add(const Duration(hours: 3))),
      },
      // Info - halftime
      {
        'type': 'info',
        'message':
            'Halftime approaching. Expect increased movement to food courts and restrooms. Security staff: maintain positions until shift change.',
        'severity': 'info',
        'targetRoles': ['security', 'emergency'],
        'isActive': true,
        'createdBy': organizerId,
        'createdByName': 'Mohammed Al-Saud',
        'createdAt': Timestamp.fromDate(now.subtract(const Duration(minutes: 5))),
        'expiresAt': Timestamp.fromDate(now.add(const Duration(minutes: 30))),
      },
      // Resolved alert (inactive)
      {
        'type': 'congestion',
        'message':
            'Main Entrance congestion has been resolved. All gates now operating normally.',
        'severity': 'info',
        'targetRoles': ['fan', 'security'],
        'isActive': false,
        'createdBy': organizerId,
        'createdByName': 'Mohammed Al-Saud',
        'createdAt': Timestamp.fromDate(now.subtract(const Duration(hours: 2, minutes: 20))),
        'expiresAt': Timestamp.fromDate(now.subtract(const Duration(hours: 1))),
      },
    ];

    for (final alert in alerts) {
      await _firestore.collection('alerts').add({
        ...alert,
        'eventId': eventId,
      });
    }

    debugPrint('Created ${alerts.length} alerts');
  }

  // ==================== STAFF ASSIGNMENTS ====================

  Future<void> seedStaffAssignments(String eventId) async {
    if (_zoneIds.length < 7) {
      debugPrint('Not enough zones to assign staff. Skipping assignments.');
      return;
    }

    final organizerId = _userIds['organizer@test.com'] ?? 'system';
    final now = DateTime.now();

    final assignments = [
      // Security staff assigned to zones
      {
        'staffId': _userIds['security@test.com'] ?? '',
        'staffName': 'Omar Hassan',
        'staffRole': 'security',
        'zoneId': _zoneIds[0], // North Stand
        'zoneName': _zoneNames[0],
      },
      {
        'staffId': _userIds['security2@test.com'] ?? '',
        'staffName': 'Khalid Al-Fahad',
        'staffRole': 'security',
        'zoneId': _zoneIds[5], // Food Court
        'zoneName': _zoneNames[5],
      },
      {
        'staffId': _userIds['security3@test.com'] ?? '',
        'staffName': 'Yusuf Ibrahim',
        'staffRole': 'security',
        'zoneId': _zoneIds[5], // Food Court (overcrowding help)
        'zoneName': _zoneNames[5],
      },
      {
        'staffId': _userIds['security4@test.com'] ?? '',
        'staffName': 'Ali Al-Mutairi',
        'staffRole': 'security',
        'zoneId': _zoneIds[3], // West Wing
        'zoneName': _zoneNames[3],
      },
      // security5 - Saad - NOT assigned (to show as "available" in staff list)

      // Emergency staff assigned
      {
        'staffId': _userIds['emergency@test.com'] ?? '',
        'staffName': 'Dr. Sarah Wilson',
        'staffRole': 'emergency',
        'zoneId': _zoneIds[0], // North Stand (responding to critical incident)
        'zoneName': _zoneNames[0],
      },
      {
        'staffId': _userIds['emergency2@test.com'] ?? '',
        'staffName': 'Dr. Nora Al-Harbi',
        'staffRole': 'emergency',
        'zoneId': _zoneIds[4], // VIP Section
        'zoneName': _zoneNames[4],
      },
      // emergency3 - Tariq - NOT assigned (available as backup)
    ];

    for (final assignment in assignments) {
      if ((assignment['staffId'] as String).isEmpty) continue;

      await _firestore.collection('staff_assignments').add({
        ...assignment,
        'eventId': eventId,
        'assignedBy': organizerId,
        'assignedAt': Timestamp.fromDate(
            now.subtract(const Duration(hours: 2, minutes: 30))),
        'updatedAt': Timestamp.fromDate(
            now.subtract(const Duration(hours: 2, minutes: 30))),
        'isActive': true,
      });
    }

    debugPrint('Created ${assignments.length} staff assignments');
  }

  // ==================== MESSAGES ====================

  Future<void> seedMessages(String eventId) async {
    final organizerId = _userIds['organizer@test.com'] ?? 'system';
    final securityId = _userIds['security@test.com'] ?? 'system';
    final emergencyId = _userIds['emergency@test.com'] ?? 'system';
    final now = DateTime.now();

    // Channel: security-ops (security team coordination)
    final securityMessages = [
      {
        'channelId': 'security-ops',
        'senderId': organizerId,
        'senderName': 'Mohammed Al-Saud',
        'senderRole': 'organizer',
        'content':
            'All security units: Match is about to start. Full capacity expected. Stay alert and maintain positions.',
        'type': 'text',
        'createdAt': Timestamp.fromDate(now.subtract(const Duration(hours: 2, minutes: 50))),
      },
      {
        'channelId': 'security-ops',
        'senderId': securityId,
        'senderName': 'Omar Hassan',
        'senderRole': 'security',
        'content':
            'North Stand secured. All entry points checked. CCTV operational. 15,200 fans entered through gates 1-3.',
        'type': 'text',
        'createdAt': Timestamp.fromDate(now.subtract(const Duration(hours: 2, minutes: 40))),
      },
      {
        'channelId': 'security-ops',
        'senderId': _userIds['security2@test.com'] ?? securityId,
        'senderName': 'Khalid Al-Fahad',
        'senderRole': 'security',
        'content':
            'Food Court getting crowded. Requesting 2 additional officers for crowd control. Current count exceeding safe limits.',
        'type': 'text',
        'createdAt': Timestamp.fromDate(now.subtract(const Duration(minutes: 25))),
      },
      {
        'channelId': 'security-ops',
        'senderId': organizerId,
        'senderName': 'Mohammed Al-Saud',
        'senderRole': 'organizer',
        'content':
            'Copy that Khalid. Dispatching Yusuf Ibrahim to Food Court. Also pushing congestion alert to fan app now.',
        'type': 'text',
        'createdAt': Timestamp.fromDate(now.subtract(const Duration(minutes: 23))),
      },
      {
        'channelId': 'security-ops',
        'senderId': _userIds['security4@test.com'] ?? securityId,
        'senderName': 'Ali Al-Mutairi',
        'senderRole': 'security',
        'content':
            'URGENT: Unattended bag found at West Wing W45-Row12. Establishing 50m perimeter. Need bomb squad clearance.',
        'type': 'alert',
        'createdAt': Timestamp.fromDate(now.subtract(const Duration(minutes: 15))),
      },
      {
        'channelId': 'security-ops',
        'senderId': organizerId,
        'senderName': 'Mohammed Al-Saud',
        'senderRole': 'organizer',
        'content':
            'Acknowledged. Bomb disposal team ETA 12 minutes. Do NOT touch the bag. Evacuate rows 10-15 quietly. Pushing safety alert now.',
        'type': 'alert',
        'createdAt': Timestamp.fromDate(now.subtract(const Duration(minutes: 14))),
      },
    ];

    // Channel: emergency-ops (emergency team coordination)
    final emergencyMessages = [
      {
        'channelId': 'emergency-ops',
        'senderId': emergencyId,
        'senderName': 'Dr. Sarah Wilson',
        'senderRole': 'emergency',
        'content':
            'Medical team Alpha stationed at North Stand aid post. All equipment checked. Ready for duty.',
        'type': 'text',
        'createdAt': Timestamp.fromDate(now.subtract(const Duration(hours: 2, minutes: 45))),
      },
      {
        'channelId': 'emergency-ops',
        'senderId': _userIds['emergency2@test.com'] ?? emergencyId,
        'senderName': 'Dr. Nora Al-Harbi',
        'senderRole': 'emergency',
        'content':
            'Medical team Bravo at VIP medical room. Noted: 3 pre-registered attendees with known cardiac conditions in VIP section.',
        'type': 'text',
        'createdAt': Timestamp.fromDate(now.subtract(const Duration(hours: 2, minutes: 40))),
      },
      {
        'channelId': 'emergency-ops',
        'senderId': securityId,
        'senderName': 'Omar Hassan',
        'senderRole': 'security',
        'content':
            'EMERGENCY: Man collapsed North Stand A12. CPR in progress by bystander. Need paramedic team IMMEDIATELY.',
        'type': 'incident_update',
        'createdAt': Timestamp.fromDate(now.subtract(const Duration(minutes: 8))),
      },
      {
        'channelId': 'emergency-ops',
        'senderId': emergencyId,
        'senderName': 'Dr. Sarah Wilson',
        'senderRole': 'emergency',
        'content':
            'Responding now. ETA 2 minutes. Bringing defibrillator and crash cart. Keep airway clear. Continue CPR.',
        'type': 'incident_update',
        'createdAt': Timestamp.fromDate(now.subtract(const Duration(minutes: 7))),
      },
      {
        'channelId': 'emergency-ops',
        'senderId': emergencyId,
        'senderName': 'Dr. Sarah Wilson',
        'senderRole': 'emergency',
        'content':
            'On scene. Patient: Male ~55yo, regained pulse after AED. Stable but needs hospital transfer. Requesting ambulance to North Stand Gate 1.',
        'type': 'incident_update',
        'createdAt': Timestamp.fromDate(now.subtract(const Duration(minutes: 4))),
      },
      {
        'channelId': 'emergency-ops',
        'senderId': organizerId,
        'senderName': 'Mohammed Al-Saud',
        'senderRole': 'organizer',
        'content':
            'Ambulance dispatched to Gate 1. Security clearing path now. Well done Dr. Wilson.',
        'type': 'text',
        'createdAt': Timestamp.fromDate(now.subtract(const Duration(minutes: 3))),
      },
    ];

    // Channel: all-staff (general announcements)
    final generalMessages = [
      {
        'channelId': 'all-staff',
        'senderId': organizerId,
        'senderName': 'Mohammed Al-Saud',
        'senderRole': 'organizer',
        'content':
            'Welcome everyone to the Saudi Arabia vs Mexico World Cup match! This is our biggest event. Let\'s make it safe and memorable. All channels are live.',
        'type': 'text',
        'createdAt': Timestamp.fromDate(now.subtract(const Duration(hours: 3))),
      },
      {
        'channelId': 'all-staff',
        'senderId': organizerId,
        'senderName': 'Mohammed Al-Saud',
        'senderRole': 'organizer',
        'content':
            'Reminder: Current temperature is 38°C. Ensure all cooling stations are operational. Watch for heat-related issues in the crowd.',
        'type': 'text',
        'createdAt': Timestamp.fromDate(now.subtract(const Duration(hours: 2))),
      },
      {
        'channelId': 'all-staff',
        'senderId': organizerId,
        'senderName': 'Mohammed Al-Saud',
        'senderRole': 'organizer',
        'content':
            'Halftime in 10 minutes. Expect heavy foot traffic to food courts and restrooms. All staff maintain positions until crowd flow stabilizes.',
        'type': 'text',
        'createdAt': Timestamp.fromDate(now.subtract(const Duration(minutes: 5))),
      },
    ];

    final allMessages = [
      ...securityMessages,
      ...emergencyMessages,
      ...generalMessages,
    ];

    for (final msg in allMessages) {
      await _firestore.collection('messages').add({
        ...msg,
        'eventId': eventId,
        'isRead': false,
        'readBy': <String>[],
      });
    }

    debugPrint('Created ${allMessages.length} messages across 3 channels');
  }

  // ==================== CLEAR DATA ====================

  Future<void> clearAllData() async {
    final collections = [
      'users',
      'venues',
      'zones',
      'events',
      'crowd_density',
      'incidents',
      'alerts',
      'notifications',
      'staff_assignments',
      'messages',
      'facilities',
    ];

    for (final collection in collections) {
      final snapshot = await _firestore.collection(collection).get();
      for (final doc in snapshot.docs) {
        await doc.reference.delete();
      }
      debugPrint('Cleared collection: $collection');
    }
  }
}
