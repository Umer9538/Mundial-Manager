import 'package:flutter/foundation.dart';
import '../models/crowd_density.dart';
import '../providers/alert_provider.dart';

/// Automatic alert service that monitors crowd density changes
/// and sends alerts when occupancy crosses configured thresholds.
///
/// Thresholds (derived from Kaggle Hajj & Umrah dataset analysis):
///   50% occupancy -> info alert (zone reaching moderate capacity)
///   70% occupancy -> congestion warning (reroute fans)
///   85% occupancy -> safety alert (critical capacity)
///   95% occupancy -> emergency alert (immediate action needed)
class AutoAlertService {
  final AlertProvider _alertProvider;

  // Track previous occupancy tier per zone to detect crossings
  final Map<String, _OccupancyTier> _previousTier = {};

  // Cooldown: prevent repeated alerts for the same zone + tier
  final Map<String, DateTime> _lastAlertTime = {};

  static const Duration _alertCooldown = Duration(minutes: 5);

  AutoAlertService(this._alertProvider);

  /// Evaluate a zone's crowd density and auto-send alerts on threshold crossings.
  /// Only fires on *upward* crossings to avoid alert spam.
  void evaluateZone(CrowdDensity density, String eventId) {
    final occupancy = density.occupancyPercentage;
    final currentTier = _OccupancyTier.fromPercentage(occupancy);
    final previousTier = _previousTier[density.zoneId] ?? _OccupancyTier.safe;

    // Update tracked tier
    _previousTier[density.zoneId] = currentTier;

    // Only alert on upward crossings
    if (currentTier.index <= previousTier.index) return;

    // Check cooldown
    final cooldownKey = '${density.zoneId}_${currentTier.name}';
    final lastAlert = _lastAlertTime[cooldownKey];
    if (lastAlert != null && DateTime.now().difference(lastAlert) < _alertCooldown) {
      return;
    }

    // Send the appropriate alert
    _sendAutoAlert(density, eventId, currentTier);
    _lastAlertTime[cooldownKey] = DateTime.now();
  }

  void _sendAutoAlert(
    CrowdDensity density,
    String eventId,
    _OccupancyTier tier,
  ) {
    final zoneName = density.zoneName;
    final pct = density.occupancyPercentageRounded;

    switch (tier) {
      case _OccupancyTier.moderate:
        // 50% - info alert
        _alertProvider.sendAlert(
          eventId: eventId,
          createdBy: 'system',
          createdByName: 'Auto-Monitor',
          type: 'info',
          message: '$zoneName at $pct% capacity. Monitoring crowd flow.',
          targetRoles: ['organizer', 'security'],
          severity: 'info',
        );
        debugPrint('[AutoAlert] INFO: $zoneName at $pct%');
        break;

      case _OccupancyTier.high:
        // 70% - congestion warning
        _alertProvider.sendAlert(
          eventId: eventId,
          createdBy: 'system',
          createdByName: 'Auto-Monitor',
          type: 'congestion',
          message:
              '$zoneName at $pct% capacity - HIGH congestion. Consider redirecting foot traffic.',
          targetRoles: ['fan', 'security'],
          severity: 'warning',
        );
        debugPrint('[AutoAlert] WARNING: $zoneName at $pct%');
        break;

      case _OccupancyTier.critical:
        // 85% - safety alert
        _alertProvider.sendAlert(
          eventId: eventId,
          createdBy: 'system',
          createdByName: 'Auto-Monitor',
          type: 'safety',
          message:
              'CRITICAL: $zoneName at $pct% capacity. Reroute all traffic. Deploy additional staff.',
          targetRoles: ['fan', 'security', 'emergency'],
          severity: 'warning',
        );
        debugPrint('[AutoAlert] CRITICAL: $zoneName at $pct%');
        break;

      case _OccupancyTier.emergency:
        // 95% - emergency alert
        _alertProvider.sendAlert(
          eventId: eventId,
          createdBy: 'system',
          createdByName: 'Auto-Monitor',
          type: 'emergency',
          message:
              'EMERGENCY: $zoneName at $pct% capacity! Immediate action required. Risk of crush/stampede.',
          targetRoles: ['security', 'emergency'],
          severity: 'critical',
        );
        debugPrint('[AutoAlert] EMERGENCY: $zoneName at $pct%');
        break;

      case _OccupancyTier.safe:
        // No alert for safe tier
        break;
    }
  }

  /// Reset tracking for a zone (e.g., when event changes).
  void resetZone(String zoneId) {
    _previousTier.remove(zoneId);
    _lastAlertTime.removeWhere((key, _) => key.startsWith('${zoneId}_'));
  }

  /// Reset all tracking.
  void resetAll() {
    _previousTier.clear();
    _lastAlertTime.clear();
  }
}

/// Occupancy tiers derived from dataset analysis.
enum _OccupancyTier {
  safe,      // 0-49%
  moderate,  // 50-69%
  high,      // 70-84%
  critical,  // 85-94%
  emergency; // 95-100%

  static _OccupancyTier fromPercentage(double pct) {
    if (pct >= 95) return emergency;
    if (pct >= 85) return critical;
    if (pct >= 70) return high;
    if (pct >= 50) return moderate;
    return safe;
  }
}
