import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:latlong2/latlong.dart';
import '../models/incident.dart';
import '../services/database_service.dart';
import '../core/utils/dummy_data.dart';
import '../core/constants/constants.dart';

class IncidentProvider with ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<Incident> _incidents = [];
  bool _isLoading = false;
  String? _errorMessage;
  StreamSubscription<QuerySnapshot>? _incidentSubscription;
  String? _currentEventId;

  List<Incident> get incidents => _incidents;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Get active incidents only
  List<Incident> get activeIncidents {
    return _incidents.where((i) => i.isActive).toList();
  }

  // Get resolved incidents
  List<Incident> get resolvedIncidents {
    return _incidents.where((i) => i.status == AppConstants.statusResolved).toList();
  }

  // Get incidents by status
  List<Incident> getIncidentsByStatus(String status) {
    return _incidents.where((i) => i.status == status).toList();
  }

  // Get incidents by severity
  List<Incident> getIncidentsBySeverity(String severity) {
    return _incidents.where((i) => i.severity == severity).toList();
  }

  // Get critical incidents
  List<Incident> get criticalIncidents {
    return _incidents.where((i) =>
      i.severity == AppConstants.severityCritical && i.isActive
    ).toList();
  }

  // Get incident by ID
  Incident? getIncidentById(String id) {
    try {
      return _incidents.firstWhere((i) => i.id == id);
    } catch (e) {
      return null;
    }
  }

  // Get incidents for specific user (reported by or assigned to)
  List<Incident> getIncidentsForUser(String userId) {
    return _incidents.where((i) =>
      i.reportedBy == userId || i.assignedTo == userId
    ).toList();
  }

  // Initialize incidents
  Future<void> initialize({String? eventId}) async {
    _isLoading = true;
    notifyListeners();

    try {
      _currentEventId = eventId;

      if (eventId != null) {
        // Load from Firestore
        await _loadIncidentsFromFirestore(eventId);
      }

      // Fallback to dummy data if Firestore is empty
      if (_incidents.isEmpty) {
        _incidents = List.from(DummyData.incidents);
      }
    } catch (e) {
      _errorMessage = 'Failed to load incidents';
      debugPrint('Error initializing incidents: $e');
      // Fallback to dummy data
      _incidents = List.from(DummyData.incidents);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load incidents from Firestore
  Future<void> _loadIncidentsFromFirestore(String eventId) async {
    try {
      final snapshot = await _firestore
          .collection('incidents')
          .where('eventId', isEqualTo: eventId)
          .orderBy('createdAt', descending: true)
          .get();

      if (snapshot.docs.isNotEmpty) {
        _incidents = snapshot.docs.map((doc) {
          return Incident.fromJson({
            'id': doc.id,
            ...doc.data(),
          });
        }).toList();
      }
    } catch (e) {
      debugPrint('Error loading incidents from Firestore: $e');
    }
  }

  // Start real-time updates
  void startRealTimeUpdates({String? eventId}) {
    _currentEventId = eventId ?? _currentEventId;

    if (_currentEventId != null) {
      _incidentSubscription?.cancel();
      _incidentSubscription = _firestore
          .collection('incidents')
          .where('eventId', isEqualTo: _currentEventId)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .listen((snapshot) {
        _processIncidentSnapshot(snapshot);
      });
    }
  }

  // Process incident snapshot
  void _processIncidentSnapshot(QuerySnapshot snapshot) {
    _incidents = snapshot.docs.map((doc) {
      return Incident.fromJson({
        'id': doc.id,
        ...doc.data() as Map<String, dynamic>,
      });
    }).toList();
    notifyListeners();
  }

  // Stop real-time updates
  void stopRealTimeUpdates() {
    _incidentSubscription?.cancel();
    _incidentSubscription = null;
  }

  // Report new incident
  Future<bool> reportIncident({
    required String eventId,
    required String reportedBy,
    required String reportedByName,
    required LatLng location,
    required String type,
    required String description,
    required String severity,
    List<String>? imageUrls,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final newIncident = Incident(
        id: '', // Will be set by Firestore
        eventId: eventId,
        reportedBy: reportedBy,
        reportedByName: reportedByName,
        location: location,
        type: type,
        description: description,
        severity: severity,
        status: AppConstants.statusReported,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        imageUrls: imageUrls,
      );

      // Save to Firestore
      final docId = await _databaseService.createIncident(newIncident);

      // Add to local list with Firestore ID
      final incidentWithId = Incident(
        id: docId,
        eventId: eventId,
        reportedBy: reportedBy,
        reportedByName: reportedByName,
        location: location,
        type: type,
        description: description,
        severity: severity,
        status: AppConstants.statusReported,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        imageUrls: imageUrls,
      );

      _incidents.insert(0, incidentWithId);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to report incident: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Update incident status
  Future<bool> updateIncidentStatus({
    required String incidentId,
    required String newStatus,
    String? assignedTo,
    String? assignedToName,
    String? resolutionNotes,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Update in Firestore
      await _databaseService.updateIncidentStatus(
        incidentId: incidentId,
        status: newStatus,
        assignedTo: assignedTo,
        resolutionNotes: resolutionNotes,
      );

      // Update local list
      final index = _incidents.indexWhere((i) => i.id == incidentId);
      if (index != -1) {
        final updatedIncident = _incidents[index].copyWith(
          status: newStatus,
          updatedAt: DateTime.now(),
          assignedTo: assignedTo ?? _incidents[index].assignedTo,
          assignedToName: assignedToName ?? _incidents[index].assignedToName,
          resolutionNotes: resolutionNotes ?? _incidents[index].resolutionNotes,
        );
        _incidents[index] = updatedIncident;
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to update incident: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Assign incident to user
  Future<bool> assignIncident({
    required String incidentId,
    required String assignedTo,
    required String assignedToName,
  }) async {
    return updateIncidentStatus(
      incidentId: incidentId,
      newStatus: AppConstants.statusDispatched,
      assignedTo: assignedTo,
      assignedToName: assignedToName,
    );
  }

  // Mark incident as on-site
  Future<bool> markOnSite(String incidentId) async {
    return updateIncidentStatus(
      incidentId: incidentId,
      newStatus: AppConstants.statusOnSite,
    );
  }

  // Resolve incident
  Future<bool> resolveIncident({
    required String incidentId,
    String? resolutionNotes,
  }) async {
    return updateIncidentStatus(
      incidentId: incidentId,
      newStatus: AppConstants.statusResolved,
      resolutionNotes: resolutionNotes,
    );
  }

  // Refresh incidents
  Future<void> refresh() async {
    _isLoading = true;
    notifyListeners();

    try {
      if (_currentEventId != null) {
        await _loadIncidentsFromFirestore(_currentEventId!);
      }

      // Fallback to dummy data
      if (_incidents.isEmpty) {
        _incidents = List.from(DummyData.incidents);
      }
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Failed to refresh incidents';
      debugPrint('Error refreshing incidents: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Delete incident
  Future<bool> deleteIncident(String incidentId) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _firestore.collection('incidents').doc(incidentId).delete();
      _incidents.removeWhere((i) => i.id == incidentId);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to delete incident';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Get incident statistics
  Map<String, int> get incidentStats {
    return {
      'total': _incidents.length,
      'active': activeIncidents.length,
      'resolved': resolvedIncidents.length,
      'critical': criticalIncidents.length,
      'reported': getIncidentsByStatus(AppConstants.statusReported).length,
      'dispatched': getIncidentsByStatus(AppConstants.statusDispatched).length,
      'onSite': getIncidentsByStatus(AppConstants.statusOnSite).length,
    };
  }

  @override
  void dispose() {
    stopRealTimeUpdates();
    super.dispose();
  }
}
