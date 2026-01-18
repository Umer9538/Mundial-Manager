import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/alert.dart';
import '../core/utils/dummy_data.dart';
import '../core/constants/constants.dart';

class AlertProvider with ChangeNotifier {
  List<Alert> _alerts = [];
  bool _isLoading = false;
  String? _errorMessage;

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
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      await Future.delayed(const Duration(milliseconds: 500));
      _alerts = List.from(DummyData.alerts);
    } catch (e) {
      _errorMessage = 'Failed to load alerts';
      debugPrint('Error initializing alerts: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
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
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 800));

      final newAlert = Alert(
        id: 'alert_${const Uuid().v4()}',
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

      _alerts.insert(0, newAlert); // Add to beginning of list
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to send alert';
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

  // Refresh alerts
  Future<void> refresh() async {
    _isLoading = true;
    notifyListeners();

    try {
      await Future.delayed(const Duration(milliseconds: 500));
      _alerts = List.from(DummyData.alerts);
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
      await Future.delayed(const Duration(milliseconds: 300));
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

  // Mark alert as read (for demo - just removes from list for user)
  void markAsRead(String alertId) {
    // In a real app, this would update a read status in the database
    // For demo, we'll just notify listeners
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
}
