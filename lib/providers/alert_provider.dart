import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/alert.dart';
import '../services/database_service.dart';
import '../core/utils/dummy_data.dart';
import '../core/constants/constants.dart';

class AlertProvider with ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<Alert> _alerts = [];
  bool _isLoading = false;
  String? _errorMessage;
  StreamSubscription<QuerySnapshot>? _alertSubscription;
  String? _currentEventId;

  List<Alert> get alerts => _alerts;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Get valid alerts only
  List<Alert> get validAlerts {
    return _alerts.where((a) => a.isValid).toList();
  }

  // Get expired alerts
  List<Alert> get expiredAlerts {
    return _alerts.where((a) => a.isExpired).toList();
  }

  // Get alerts for specific user role
  List<Alert> getAlertsForRole(String role) {
    return validAlerts.where((a) => a.shouldReceiveAlert(role)).toList();
  }

  // Get alerts by type
  List<Alert> getAlertsByType(String type) {
    return validAlerts.where((a) => a.type == type).toList();
  }

  // Get alerts by severity
  List<Alert> getAlertsBySeverity(String severity) {
    return validAlerts.where((a) => a.severity == severity).toList();
  }

  // Get critical alerts
  List<Alert> get criticalAlerts {
    return validAlerts.where((a) => a.severity == 'critical').toList();
  }

  // Get alert by ID
  Alert? getAlertById(String id) {
    try {
      return _alerts.firstWhere((a) => a.id == id);
    } catch (e) {
      return null;
    }
  }

  // Get unread alerts count for role
  int getUnreadCountForRole(String role) {
    return getAlertsForRole(role).length;
  }

  // Initialize alerts
  Future<void> initialize({String? eventId}) async {
    _isLoading = true;
    notifyListeners();

    try {
      _currentEventId = eventId;

      if (eventId != null) {
        await _loadAlertsFromFirestore(eventId);
      }

      // Fallback to dummy data if Firestore is empty
      if (_alerts.isEmpty) {
        _alerts = List.from(DummyData.alerts);
      }
    } catch (e) {
      _errorMessage = 'Failed to load alerts';
      debugPrint('Error initializing alerts: $e');
      // Fallback to dummy data
      _alerts = List.from(DummyData.alerts);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load alerts from Firestore
  Future<void> _loadAlertsFromFirestore(String eventId) async {
    try {
      final snapshot = await _firestore
          .collection('alerts')
          .where('eventId', isEqualTo: eventId)
          .where('isActive', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .get();

      if (snapshot.docs.isNotEmpty) {
        _alerts = snapshot.docs.map((doc) {
          return Alert.fromJson({
            'id': doc.id,
            ...doc.data(),
          });
        }).toList();
      }
    } catch (e) {
      debugPrint('Error loading alerts from Firestore: $e');
    }
  }

  // Start real-time updates
  void startRealTimeUpdates({String? eventId, String? userRole}) {
    _currentEventId = eventId ?? _currentEventId;

    if (_currentEventId != null) {
      _alertSubscription?.cancel();

      Query query = _firestore
          .collection('alerts')
          .where('isActive', isEqualTo: true)
          .orderBy('createdAt', descending: true);

      // Optionally filter by event
      if (_currentEventId != null) {
        query = query.where('eventId', isEqualTo: _currentEventId);
      }

      _alertSubscription = query.snapshots().listen((snapshot) {
        _processAlertSnapshot(snapshot);
      });
    }
  }

  // Process alert snapshot
  void _processAlertSnapshot(QuerySnapshot snapshot) {
    _alerts = snapshot.docs.map((doc) {
      return Alert.fromJson({
        'id': doc.id,
        ...doc.data() as Map<String, dynamic>,
      });
    }).toList();
    notifyListeners();
  }

  // Stop real-time updates
  void stopRealTimeUpdates() {
    _alertSubscription?.cancel();
    _alertSubscription = null;
  }

  // Send new alert (Organizer only)
  Future<bool> sendAlert({
    required String eventId,
    required String createdBy,
    required String createdByName,
    required String type,
    required String message,
    required List<String> targetRoles,
    List<String>? targetZones,
    required String severity,
    DateTime? expiresAt,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final newAlert = Alert(
        id: '', // Will be set by Firestore
        eventId: eventId,
        createdBy: createdBy,
        createdByName: createdByName,
        type: type,
        message: message,
        targetRoles: targetRoles,
        targetZones: targetZones,
        severity: severity,
        createdAt: DateTime.now(),
        expiresAt: expiresAt ?? DateTime.now().add(const Duration(hours: 2)),
      );

      // Save to Firestore
      final docId = await _databaseService.createAlert(newAlert);

      // Add to local list with Firestore ID
      final alertWithId = Alert(
        id: docId,
        eventId: eventId,
        createdBy: createdBy,
        createdByName: createdByName,
        type: type,
        message: message,
        targetRoles: targetRoles,
        targetZones: targetZones,
        severity: severity,
        createdAt: DateTime.now(),
        expiresAt: expiresAt ?? DateTime.now().add(const Duration(hours: 2)),
      );

      _alerts.insert(0, alertWithId);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to send alert: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Send congestion alert (shortcut)
  Future<bool> sendCongestionAlert({
    required String eventId,
    required String createdBy,
    required String createdByName,
    required String zoneName,
    required String zoneId,
  }) async {
    return sendAlert(
      eventId: eventId,
      createdBy: createdBy,
      createdByName: createdByName,
      type: AppConstants.alertTypeCongestion,
      message: '$zoneName is experiencing high congestion. Please use alternative routes.',
      targetRoles: ['fan', 'security'],
      targetZones: [zoneId],
      severity: 'warning',
    );
  }

  // Send emergency alert (shortcut)
  Future<bool> sendEmergencyAlert({
    required String eventId,
    required String createdBy,
    required String createdByName,
    required String message,
    List<String>? targetZones,
  }) async {
    return sendAlert(
      eventId: eventId,
      createdBy: createdBy,
      createdByName: createdByName,
      type: AppConstants.alertTypeEmergency,
      message: message,
      targetRoles: ['security', 'emergency'],
      targetZones: targetZones,
      severity: 'critical',
    );
  }

  // Send safety alert (shortcut)
  Future<bool> sendSafetyAlert({
    required String eventId,
    required String createdBy,
    required String createdByName,
    required String message,
    List<String>? targetZones,
  }) async {
    return sendAlert(
      eventId: eventId,
      createdBy: createdBy,
      createdByName: createdByName,
      type: AppConstants.alertTypeSafety,
      message: message,
      targetRoles: ['fan', 'security', 'emergency'],
      targetZones: targetZones,
      severity: 'warning',
    );
  }

  // Send info alert (shortcut)
  Future<bool> sendInfoAlert({
    required String eventId,
    required String createdBy,
    required String createdByName,
    required String message,
  }) async {
    return sendAlert(
      eventId: eventId,
      createdBy: createdBy,
      createdByName: createdByName,
      type: AppConstants.alertTypeInfo,
      message: message,
      targetRoles: ['fan', 'security', 'emergency'],
      severity: 'info',
    );
  }

  // Dismiss alert
  Future<bool> dismissAlert(String alertId) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _databaseService.dismissAlert(alertId);
      _alerts.removeWhere((a) => a.id == alertId);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to dismiss alert';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Refresh alerts
  Future<void> refresh() async {
    _isLoading = true;
    notifyListeners();

    try {
      if (_currentEventId != null) {
        await _loadAlertsFromFirestore(_currentEventId!);
      }

      // Fallback to dummy data
      if (_alerts.isEmpty) {
        _alerts = List.from(DummyData.alerts);
      }
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Failed to refresh alerts';
      debugPrint('Error refreshing alerts: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Delete alert (for demo purposes)
  Future<bool> deleteAlert(String alertId) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _firestore.collection('alerts').doc(alertId).delete();
      _alerts.removeWhere((a) => a.id == alertId);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to delete alert';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Mark alert as read
  void markAsRead(String alertId) {
    // In a real app, this would update a read status in the database
    notifyListeners();
  }

  // Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Get alert statistics
  Map<String, int> get alertStats {
    return {
      'total': _alerts.length,
      'valid': validAlerts.length,
      'expired': expiredAlerts.length,
      'critical': criticalAlerts.length,
      'emergency': getAlertsByType(AppConstants.alertTypeEmergency).length,
      'safety': getAlertsByType(AppConstants.alertTypeSafety).length,
      'congestion': getAlertsByType(AppConstants.alertTypeCongestion).length,
      'info': getAlertsByType(AppConstants.alertTypeInfo).length,
    };
  }

  // Check if there are any critical alerts
  bool get hasCriticalAlerts {
    return criticalAlerts.isNotEmpty;
  }

  // Get most recent alert
  Alert? get mostRecentAlert {
    if (validAlerts.isEmpty) return null;
    return validAlerts.first;
  }

  // Get alerts from last hour
  List<Alert> get recentAlerts {
    final oneHourAgo = DateTime.now().subtract(const Duration(hours: 1));
    return validAlerts.where((a) => a.createdAt.isAfter(oneHourAgo)).toList();
  }

  @override
  void dispose() {
    stopRealTimeUpdates();
    super.dispose();
  }
}
