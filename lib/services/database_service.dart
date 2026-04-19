import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';
import '../models/event.dart';
import '../models/venue.dart';
import '../models/zone.dart';
import '../models/crowd_density.dart';
import '../models/incident.dart';
import '../models/alert.dart';

class DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ==================== EVENTS ====================

  // Get all events
  Stream<List<Event>> getEvents() {
    return _firestore
        .collection('events')
        .orderBy('startDate', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              return Event.fromJson({
                'id': doc.id,
                ...doc.data(),
              });
            }).toList());
  }

  // Get active events
  Stream<List<Event>> getActiveEvents() {
    return _firestore
        .collection('events')
        .where('status', isEqualTo: 'active')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              return Event.fromJson({
                'id': doc.id,
                ...doc.data(),
              });
            }).toList());
  }

  // Get current active event (most recent active event)
  Future<Event?> getCurrentActiveEvent() async {
    // Try with composite index (status + startDate)
    try {
      final snapshot = await _firestore
          .collection('events')
          .where('status', isEqualTo: 'active')
          .orderBy('startDate', descending: true)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        return _eventFromDoc(snapshot.docs.first);
      }
    } catch (e) {
      debugPrint('Active event query with index failed: $e');
    }

    // Fallback: query without orderBy (works without composite index)
    try {
      final snapshot = await _firestore
          .collection('events')
          .where('status', isEqualTo: 'active')
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        return _eventFromDoc(snapshot.docs.first);
      }
    } catch (e) {
      debugPrint('Active event fallback query failed: $e');
    }

    // Last resort: get any event
    try {
      final snapshot = await _firestore
          .collection('events')
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        return _eventFromDoc(snapshot.docs.first);
      }
    } catch (e) {
      debugPrint('Any event query failed: $e');
    }

    return null;
  }

  // Get venue address by ID
  Future<String?> getVenueAddress(String venueId) async {
    try {
      final doc = await _firestore.collection('venues').doc(venueId).get();
      if (doc.exists) {
        return doc.data()?['address'] as String?;
      }
    } catch (e) {
      // Ignore
    }
    return null;
  }

  // Get event by ID
  Future<Event?> getEventById(String eventId) async {
    final doc = await _firestore.collection('events').doc(eventId).get();
    if (doc.exists) {
      return _eventFromDoc(doc);
    }
    return null;
  }

  // Build Event from Firestore doc, handling both Timestamp and String dates
  Event _eventFromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Event.fromJson({
      'id': doc.id,
      ...data,
      'startDate': _toIso8601(data['startDate']),
      'endDate': _toIso8601(data['endDate']),
    });
  }

  String _toIso8601(dynamic value) {
    if (value is Timestamp) return value.toDate().toIso8601String();
    if (value is String) return value;
    return DateTime.now().toIso8601String();
  }

  // Create event
  Future<String> createEvent(Event event) async {
    final docRef = await _firestore.collection('events').add(event.toJson());
    return docRef.id;
  }

  // Update event
  Future<void> updateEvent(Event event) async {
    await _firestore.collection('events').doc(event.id).update(event.toJson());
  }

  // ==================== VENUES ====================

  // Get all venues
  Stream<List<Venue>> getVenues() {
    return _firestore.collection('venues').snapshots().map((snapshot) =>
        snapshot.docs.map((doc) {
          return Venue.fromJson({
            'id': doc.id,
            ...doc.data(),
          });
        }).toList());
  }

  // Get venue by ID
  Future<Venue?> getVenueById(String venueId) async {
    final doc = await _firestore.collection('venues').doc(venueId).get();
    if (doc.exists) {
      return Venue.fromJson({
        'id': doc.id,
        ...doc.data()!,
      });
    }
    return null;
  }

  // Create venue
  Future<String> createVenue(Venue venue) async {
    final docRef = await _firestore.collection('venues').add(venue.toJson());
    return docRef.id;
  }

  // ==================== ZONES ====================

  // Get zones for venue
  Stream<List<Zone>> getZonesForVenue(String venueId) {
    return _firestore
        .collection('zones')
        .where('venueId', isEqualTo: venueId)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              return Zone.fromJson({
                'id': doc.id,
                ...doc.data(),
              });
            }).toList());
  }

  // Get all zones
  Stream<List<Zone>> getAllZones() {
    return _firestore.collection('zones').snapshots().map((snapshot) =>
        snapshot.docs.map((doc) {
          return Zone.fromJson({
            'id': doc.id,
            ...doc.data(),
          });
        }).toList());
  }

  // Create zone
  Future<String> createZone(Zone zone) async {
    final docRef = await _firestore.collection('zones').add(zone.toJson());
    return docRef.id;
  }

  // Update zone
  Future<void> updateZone(Zone zone) async {
    await _firestore.collection('zones').doc(zone.id).update(zone.toJson());
  }

  // ==================== CROWD DENSITY ====================

  // Get real-time crowd density for event
  Stream<List<CrowdDensity>> getCrowdDensityStream(String eventId) {
    return _firestore
        .collection('crowd_density')
        .where('eventId', isEqualTo: eventId)
        .orderBy('timestamp', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              return CrowdDensity.fromJson({
                'id': doc.id,
                ...doc.data(),
              });
            }).toList());
  }

  // Get latest crowd density for each zone
  Future<Map<String, CrowdDensity>> getLatestCrowdDensityByZone(String eventId) async {
    final snapshot = await _firestore
        .collection('crowd_density')
        .where('eventId', isEqualTo: eventId)
        .orderBy('timestamp', descending: true)
        .get();

    final Map<String, CrowdDensity> latestByZone = {};
    for (final doc in snapshot.docs) {
      final data = CrowdDensity.fromJson({
        'id': doc.id,
        ...doc.data(),
      });
      if (!latestByZone.containsKey(data.zoneId)) {
        latestByZone[data.zoneId] = data;
      }
    }
    return latestByZone;
  }

  // Update crowd density
  Future<void> updateCrowdDensity({
    required String eventId,
    required String zoneId,
    required int currentCount,
    required double density,
    required LatLng location,
  }) async {
    await _firestore.collection('crowd_density').add({
      'eventId': eventId,
      'zoneId': zoneId,
      'currentCount': currentCount,
      'density': density,
      'latitude': location.latitude,
      'longitude': location.longitude,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  // ==================== INCIDENTS ====================

  // Get incidents for event
  Stream<List<Incident>> getIncidentsStream(String eventId) {
    return _firestore
        .collection('incidents')
        .where('eventId', isEqualTo: eventId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              return Incident.fromJson({
                'id': doc.id,
                ...doc.data(),
              });
            }).toList());
  }

  // Get all active incidents
  Stream<List<Incident>> getActiveIncidentsStream() {
    return _firestore
        .collection('incidents')
        .where('status', whereIn: ['reported', 'acknowledged', 'dispatched', 'on_site'])
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              return Incident.fromJson({
                'id': doc.id,
                ...doc.data(),
              });
            }).toList());
  }

  // Create incident
  Future<String> createIncident(Incident incident) async {
    final docRef = await _firestore.collection('incidents').add({
      ...incident.toJson(),
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    return docRef.id;
  }

  // Update incident status
  Future<void> updateIncidentStatus({
    required String incidentId,
    required String status,
    String? assignedTo,
    String? resolutionNotes,
  }) async {
    final updates = <String, dynamic>{
      'status': status,
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (assignedTo != null) updates['assignedTo'] = assignedTo;
    if (resolutionNotes != null) updates['resolutionNotes'] = resolutionNotes;
    if (status == 'resolved') updates['resolvedAt'] = FieldValue.serverTimestamp();

    await _firestore.collection('incidents').doc(incidentId).update(updates);
  }

  // ==================== ALERTS ====================

  // Get alerts stream
  Stream<List<Alert>> getAlertsStream() {
    return _firestore
        .collection('alerts')
        .where('isActive', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              return Alert.fromJson({
                'id': doc.id,
                ...doc.data(),
              });
            }).toList());
  }

  // Get alerts for specific roles
  Stream<List<Alert>> getAlertsForRoles(List<String> roles) {
    return _firestore
        .collection('alerts')
        .where('isActive', isEqualTo: true)
        .where('targetRoles', arrayContainsAny: roles)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              return Alert.fromJson({
                'id': doc.id,
                ...doc.data(),
              });
            }).toList());
  }

  // Create alert
  Future<String> createAlert(Alert alert) async {
    final docRef = await _firestore.collection('alerts').add({
      ...alert.toJson(),
      'isActive': true,
      'createdAt': FieldValue.serverTimestamp(),
    });
    return docRef.id;
  }

  // Dismiss alert
  Future<void> dismissAlert(String alertId) async {
    await _firestore.collection('alerts').doc(alertId).update({
      'isActive': false,
      'dismissedAt': FieldValue.serverTimestamp(),
    });
  }

  // Resolve alert
  Future<void> resolveAlert(String alertId) async {
    await _firestore.collection('alerts').doc(alertId).update({
      'severity': 'resolved',
      'resolvedAt': FieldValue.serverTimestamp(),
    });
  }

  // ==================== BATCH OPERATIONS ====================

  // Seed initial data (for development)
  Future<void> seedInitialData({
    required Venue venue,
    required List<Zone> zones,
    required Event event,
  }) async {
    final batch = _firestore.batch();

    // Add venue
    final venueRef = _firestore.collection('venues').doc();
    batch.set(venueRef, venue.toJson());

    // Add zones
    for (final zone in zones) {
      final zoneRef = _firestore.collection('zones').doc();
      batch.set(zoneRef, {
        ...zone.toJson(),
        'venueId': venueRef.id,
      });
    }

    // Add event
    final eventRef = _firestore.collection('events').doc();
    batch.set(eventRef, {
      ...event.toJson(),
      'venueId': venueRef.id,
    });

    await batch.commit();
  }
}
