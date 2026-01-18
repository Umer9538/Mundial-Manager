import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';
import 'package:uuid/uuid.dart';
import '../models/incident.dart';
import '../core/utils/dummy_data.dart';
import '../core/constants/constants.dart';

class IncidentProvider with ChangeNotifier {
  List<Incident> _incidents = [];
  bool _isLoading = false;
  String? _errorMessage;

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
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      await Future.delayed(const Duration(milliseconds: 500));
      _incidents = List.from(DummyData.incidents);
    } catch (e) {
      _errorMessage = 'Failed to load incidents';
      debugPrint('Error initializing incidents: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
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
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 800));

      final newIncident = Incident(
        id: 'incident_${const Uuid().v4()}',
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

      _incidents.insert(0, newIncident); // Add to beginning of list
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to report incident';
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
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 500));

      final index = _incidents.indexWhere((i) => i.id == incidentId);
      if (index == -1) {
        _errorMessage = 'Incident not found';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final updatedIncident = _incidents[index].copyWith(
        status: newStatus,
        updatedAt: DateTime.now(),
        assignedTo: assignedTo ?? _incidents[index].assignedTo,
        assignedToName: assignedToName ?? _incidents[index].assignedToName,
        resolutionNotes: resolutionNotes ?? _incidents[index].resolutionNotes,
      );

      _incidents[index] = updatedIncident;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to update incident';
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
      await Future.delayed(const Duration(milliseconds: 500));
      _incidents = List.from(DummyData.incidents);
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Failed to refresh incidents';
      debugPrint('Error refreshing incidents: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Delete incident (for demo purposes)
  Future<bool> deleteIncident(String incidentId) async {
    _isLoading = true;
    notifyListeners();

    try {
      await Future.delayed(const Duration(milliseconds: 300));
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
}
