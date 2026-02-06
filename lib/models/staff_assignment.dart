import 'package:cloud_firestore/cloud_firestore.dart';

class StaffAssignment {
  final String id;
  final String eventId;
  final String staffId;
  final String staffName;
  final String staffRole; // security, emergency
  final String zoneId;
  final String zoneName;
  final String assignedBy; // userId of organizer
  final DateTime assignedAt;
  final DateTime updatedAt;
  final bool isActive;

  StaffAssignment({
    required this.id,
    required this.eventId,
    required this.staffId,
    required this.staffName,
    required this.staffRole,
    required this.zoneId,
    required this.zoneName,
    required this.assignedBy,
    required this.assignedAt,
    required this.updatedAt,
    this.isActive = true,
  });

  static DateTime _parseDateTime(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
    return DateTime.now();
  }

  factory StaffAssignment.fromJson(Map<String, dynamic> json) {
    return StaffAssignment(
      id: json['id'] as String,
      eventId: json['eventId'] as String,
      staffId: json['staffId'] as String,
      staffName: json['staffName'] as String,
      staffRole: json['staffRole'] as String,
      zoneId: json['zoneId'] as String,
      zoneName: json['zoneName'] as String,
      assignedBy: json['assignedBy'] as String,
      assignedAt: _parseDateTime(json['assignedAt']),
      updatedAt: _parseDateTime(json['updatedAt']),
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'eventId': eventId,
      'staffId': staffId,
      'staffName': staffName,
      'staffRole': staffRole,
      'zoneId': zoneId,
      'zoneName': zoneName,
      'assignedBy': assignedBy,
      'assignedAt': assignedAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isActive': isActive,
    };
  }

  StaffAssignment copyWith({
    String? id,
    String? eventId,
    String? staffId,
    String? staffName,
    String? staffRole,
    String? zoneId,
    String? zoneName,
    String? assignedBy,
    DateTime? assignedAt,
    DateTime? updatedAt,
    bool? isActive,
  }) {
    return StaffAssignment(
      id: id ?? this.id,
      eventId: eventId ?? this.eventId,
      staffId: staffId ?? this.staffId,
      staffName: staffName ?? this.staffName,
      staffRole: staffRole ?? this.staffRole,
      zoneId: zoneId ?? this.zoneId,
      zoneName: zoneName ?? this.zoneName,
      assignedBy: assignedBy ?? this.assignedBy,
      assignedAt: assignedAt ?? this.assignedAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
    );
  }

  // Get role display name
  String get roleDisplayName {
    switch (staffRole) {
      case 'security':
        return 'Security Team';
      case 'emergency':
        return 'Emergency Services';
      default:
        return staffRole;
    }
  }

  // Get time since assignment
  Duration get timeSinceAssignment {
    return DateTime.now().difference(assignedAt);
  }
}
