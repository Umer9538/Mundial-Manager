class Alert {
  final String id;
  final String eventId;
  final String createdBy; // userId
  final String createdByName;
  final String type; // congestion, safety, emergency, info
  final String message;
  final List<String> targetRoles; // fan, security, emergency
  final List<String>? targetZones; // Optional location-based targeting
  final String severity; // info, warning, critical
  final DateTime createdAt;
  final DateTime? expiresAt;

  Alert({
    required this.id,
    required this.eventId,
    required this.createdBy,
    required this.createdByName,
    required this.type,
    required this.message,
    required this.targetRoles,
    this.targetZones,
    required this.severity,
    required this.createdAt,
    this.expiresAt,
  });

  factory Alert.fromJson(Map<String, dynamic> json) {
    return Alert(
      id: json['id'] as String,
      eventId: json['eventId'] as String? ?? '',
      createdBy: json['createdBy'] as String? ?? 'system',
      createdByName: json['createdByName'] as String? ?? 'System',
      type: json['type'] as String,
      message: json['message'] as String,
      targetRoles: (json['targetRoles'] as List).cast<String>(),
      targetZones: (json['targetZones'] as List?)?.cast<String>(),
      severity: json['severity'] as String,
      createdAt: _parseDateTime(json['createdAt']),
      expiresAt: json['expiresAt'] != null ? _parseDateTime(json['expiresAt']) : null,
    );
  }

  /// Safely parse DateTime from Firestore Timestamp or ISO String.
  static DateTime _parseDateTime(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
    // Firestore Timestamp has a toDate() method
    try {
      return (value as dynamic).toDate();
    } catch (_) {
      return DateTime.now();
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'eventId': eventId,
      'createdBy': createdBy,
      'createdByName': createdByName,
      'type': type,
      'message': message,
      'targetRoles': targetRoles,
      'targetZones': targetZones,
      'severity': severity,
      'createdAt': createdAt.toIso8601String(),
      'expiresAt': expiresAt?.toIso8601String(),
    };
  }

  // Get type display name
  String get typeDisplayName {
    switch (type) {
      case 'congestion':
        return 'Congestion Alert';
      case 'safety':
        return 'Safety Alert';
      case 'emergency':
        return 'Emergency Alert';
      case 'info':
        return 'Information';
      default:
        return type;
    }
  }

  // Check if alert is still valid
  bool get isValid {
    if (expiresAt == null) return true;
    return DateTime.now().isBefore(expiresAt!);
  }

  // Check if alert has expired
  bool get isExpired {
    return !isValid;
  }

  // Get time since creation
  Duration get timeSinceCreation {
    return DateTime.now().difference(createdAt);
  }

  // Get time since creation in readable format
  String get timeAgo {
    final duration = timeSinceCreation;
    if (duration.inMinutes < 1) {
      return 'Just now';
    } else if (duration.inMinutes < 60) {
      return '${duration.inMinutes} min ago';
    } else if (duration.inHours < 24) {
      return '${duration.inHours} hr ago';
    } else {
      return '${duration.inDays} days ago';
    }
  }

  // Check if user role should receive this alert
  bool shouldReceiveAlert(String userRole) {
    return targetRoles.contains(userRole);
  }
}
